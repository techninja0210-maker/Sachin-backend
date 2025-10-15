/**
 * ============================================================================
 * NFT Admin Dashboard - Stripe Webhook Handler
 * ============================================================================
 * Purpose: Handle Stripe webhook events for BNPL, Subscriptions, Insurance
 * Stack: Node.js + Express + Stripe SDK + Supabase
 * Version: 1.0.0
 * ============================================================================
 */

const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const Stripe = require('stripe');
require('dotenv').config();

// ============================================================================
// Configuration
// ============================================================================

const app = express();
const PORT = process.env.PORT || 4242;

// Initialize Stripe
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2023-10-16',
});

// Initialize Supabase
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_KEY // Use service key for admin operations
);

const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

// ============================================================================
// Middleware
// ============================================================================

// For webhook signature verification, we need raw body
app.use('/webhook', express.raw({ type: 'application/json' }));
app.use(express.json());

// ============================================================================
// Helper Functions
// ============================================================================

/**
 * Insert BNPL transaction into Supabase
 */
async function insertBNPLTransaction(data) {
  const { error } = await supabase
    .from('bnpl_transactions')
    .insert([data]);

  if (error) {
    console.error('❌ Error inserting BNPL transaction:', error);
    throw error;
  }
  
  console.log('✅ BNPL transaction inserted:', data.order_id);
}

/**
 * Update or insert subscription
 */
async function upsertSubscription(data) {
  const { error } = await supabase
    .from('weekly_subscriptions')
    .upsert([data], {
      onConflict: 'subscription_id'
    });

  if (error) {
    console.error('❌ Error upserting subscription:', error);
    throw error;
  }
  
  console.log('✅ Subscription upserted:', data.subscription_id);
}

/**
 * Insert NFT insurance log
 */
async function insertInsuranceLog(data) {
  const { error } = await supabase
    .from('nft_insurance_logs')
    .insert([data]);

  if (error) {
    console.error('❌ Error inserting insurance log:', error);
    throw error;
  }
  
  console.log('✅ Insurance log inserted for NFT:', data.nft_id);
}

/**
 * Lock user access on subscription failure
 */
async function lockUserAccess(userId, reason) {
  // This is a placeholder - implement based on your user access control logic
  console.log(`🔒 Locking access for user ${userId}. Reason: ${reason}`);
  
  // Example: Update user metadata or permissions table
  const { error } = await supabase
    .from('users')
    .update({ 
      subscription_locked: true,
      lock_reason: reason,
      locked_at: new Date().toISOString()
    })
    .eq('id', userId);

  if (error) {
    console.error('❌ Error locking user access:', error);
  }
}

/**
 * Calculate next billing date (7 days from now for weekly subscription)
 */
function getNextBillingDate() {
  const nextDate = new Date();
  nextDate.setDate(nextDate.getDate() + 7);
  return nextDate.toISOString().split('T')[0]; // YYYY-MM-DD format
}

// ============================================================================
// Webhook Event Handlers
// ============================================================================

/**
 * Handle checkout.session.completed event
 * Triggered when a checkout session is successfully completed
 */
async function handleCheckoutCompleted(session) {
  console.log('📦 Processing checkout.session.completed:', session.id);

  const paymentMethod = session.payment_method_types?.[0] || 'card';
  const isBNPL = paymentMethod === 'afterpay_clearpay' || paymentMethod === 'klarna';

  // Insert BNPL transaction
  if (isBNPL || session.mode === 'payment') {
    await insertBNPLTransaction({
      user_id: session.client_reference_id || session.customer,
      order_id: session.id,
      payment_id: session.payment_intent,
      payment_method: paymentMethod,
      amount_paid: session.amount_total / 100, // Convert cents to dollars
      bnpl_status: 'success',
      metadata: {
        stripe_session: session.id,
        currency: session.currency,
        customer_email: session.customer_details?.email,
        raw_session: session
      }
    });
  }

  // Handle subscription checkout
  if (session.mode === 'subscription' && session.subscription) {
    await upsertSubscription({
      user_id: session.client_reference_id || session.customer,
      subscription_id: session.subscription,
      stripe_customer_id: session.customer,
      start_date: new Date().toISOString().split('T')[0],
      status: 'active',
      next_billing_date: getNextBillingDate(),
      amount: 5.00, // Weekly subscription amount
      currency: session.currency || 'AUD',
      metadata: {
        stripe_session: session.id,
        customer_email: session.customer_details?.email
      }
    });
  }

  console.log('✅ Checkout completed successfully');
}

/**
 * Handle invoice.payment_succeeded event
 * Triggered when subscription payment succeeds
 */
async function handleInvoicePaymentSucceeded(invoice) {
  console.log('💰 Processing invoice.payment_succeeded:', invoice.id);

  if (invoice.subscription) {
    await upsertSubscription({
      user_id: invoice.customer,
      subscription_id: invoice.subscription,
      stripe_customer_id: invoice.customer,
      start_date: new Date(invoice.created * 1000).toISOString().split('T')[0],
      status: 'active',
      next_billing_date: getNextBillingDate(),
      amount: invoice.total / 100,
      currency: invoice.currency || 'AUD',
      metadata: {
        last_invoice: invoice.id,
        last_payment_date: new Date().toISOString()
      }
    });
  }

  console.log('✅ Invoice payment succeeded');
}

/**
 * Handle invoice.payment_failed event
 * Triggered when subscription payment fails
 */
async function handleInvoicePaymentFailed(invoice) {
  console.log('❌ Processing invoice.payment_failed:', invoice.id);

  if (invoice.subscription) {
    // Update subscription status
    await upsertSubscription({
      user_id: invoice.customer,
      subscription_id: invoice.subscription,
      stripe_customer_id: invoice.customer,
      status: 'past_due',
      metadata: {
        last_failed_invoice: invoice.id,
        failure_reason: invoice.last_payment_error?.message || 'Payment failed',
        failed_at: new Date().toISOString()
      }
    });

    // Lock user access
    await lockUserAccess(invoice.customer, 'subscription_payment_failed');
  }

  console.log('⚠️ Invoice payment failed - user access locked');
}

/**
 * Handle customer.subscription.created event
 */
async function handleSubscriptionCreated(subscription) {
  console.log('🆕 Processing customer.subscription.created:', subscription.id);

  await upsertSubscription({
    user_id: subscription.customer,
    subscription_id: subscription.id,
    stripe_customer_id: subscription.customer,
    start_date: new Date(subscription.created * 1000).toISOString().split('T')[0],
    status: subscription.status,
    next_billing_date: new Date(subscription.current_period_end * 1000).toISOString().split('T')[0],
    amount: subscription.items.data[0]?.price?.unit_amount / 100 || 5.00,
    currency: subscription.currency || 'AUD',
    metadata: {
      plan_id: subscription.items.data[0]?.price?.id,
      trial_end: subscription.trial_end ? new Date(subscription.trial_end * 1000).toISOString() : null
    }
  });

  console.log('✅ Subscription created');
}

/**
 * Handle customer.subscription.updated event
 */
async function handleSubscriptionUpdated(subscription) {
  console.log('🔄 Processing customer.subscription.updated:', subscription.id);

  const statusMap = {
    'active': 'active',
    'past_due': 'past_due',
    'canceled': 'canceled',
    'unpaid': 'canceled',
    'paused': 'paused'
  };

  await upsertSubscription({
    subscription_id: subscription.id,
    stripe_customer_id: subscription.customer,
    status: statusMap[subscription.status] || subscription.status,
    next_billing_date: subscription.current_period_end 
      ? new Date(subscription.current_period_end * 1000).toISOString().split('T')[0]
      : null,
    metadata: {
      cancel_at_period_end: subscription.cancel_at_period_end,
      canceled_at: subscription.canceled_at ? new Date(subscription.canceled_at * 1000).toISOString() : null
    }
  });

  console.log('✅ Subscription updated');
}

/**
 * Handle customer.subscription.deleted event
 */
async function handleSubscriptionDeleted(subscription) {
  console.log('🗑️ Processing customer.subscription.deleted:', subscription.id);

  await upsertSubscription({
    subscription_id: subscription.id,
    stripe_customer_id: subscription.customer,
    status: 'canceled',
    next_billing_date: null,
    metadata: {
      canceled_at: new Date().toISOString(),
      cancellation_reason: subscription.cancellation_details?.reason || 'user_canceled'
    }
  });

  // Lock user access
  await lockUserAccess(subscription.customer, 'subscription_canceled');

  console.log('✅ Subscription deleted - user access locked');
}

/**
 * Handle payment_intent.succeeded event
 */
async function handlePaymentIntentSucceeded(paymentIntent) {
  console.log('💳 Processing payment_intent.succeeded:', paymentIntent.id);

  // Only create BNPL transaction if not already created by checkout.session.completed
  const { data: existing } = await supabase
    .from('bnpl_transactions')
    .select('id')
    .eq('payment_id', paymentIntent.id)
    .single();

  if (!existing) {
    await insertBNPLTransaction({
      user_id: paymentIntent.customer || paymentIntent.metadata?.user_id,
      order_id: paymentIntent.metadata?.order_id || paymentIntent.id,
      payment_id: paymentIntent.id,
      payment_method: paymentIntent.payment_method_types?.[0] || 'card',
      amount_paid: paymentIntent.amount / 100,
      bnpl_status: 'success',
      metadata: {
        currency: paymentIntent.currency,
        receipt_email: paymentIntent.receipt_email
      }
    });
  }

  console.log('✅ Payment intent succeeded');
}

/**
 * Handle payment_intent.payment_failed event
 */
async function handlePaymentIntentFailed(paymentIntent) {
  console.log('❌ Processing payment_intent.payment_failed:', paymentIntent.id);

  await insertBNPLTransaction({
    user_id: paymentIntent.customer || paymentIntent.metadata?.user_id,
    order_id: paymentIntent.metadata?.order_id || paymentIntent.id,
    payment_id: paymentIntent.id,
    payment_method: paymentIntent.payment_method_types?.[0] || 'card',
    amount_paid: paymentIntent.amount / 100,
    bnpl_status: 'failed',
    metadata: {
      error_code: paymentIntent.last_payment_error?.code,
      error_message: paymentIntent.last_payment_error?.message,
      decline_code: paymentIntent.last_payment_error?.decline_code
    }
  });

  console.log('⚠️ Payment intent failed');
}

// ============================================================================
// Webhook Endpoint
// ============================================================================

app.post('/webhook', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    // Verify webhook signature
    event = stripe.webhooks.constructEvent(req.body, sig, WEBHOOK_SECRET);
  } catch (err) {
    console.error('⚠️ Webhook signature verification failed:', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  console.log(`\n🔔 Received event: ${event.type}`);

  try {
    // Route event to appropriate handler
    switch (event.type) {
      // Checkout events
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;

      // Invoice events (subscriptions)
      case 'invoice.payment_succeeded':
        await handleInvoicePaymentSucceeded(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object);
        break;

      // Subscription events
      case 'customer.subscription.created':
        await handleSubscriptionCreated(event.data.object);
        break;
      
      case 'customer.subscription.updated':
        await handleSubscriptionUpdated(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;

      // Payment intent events
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object);
        break;
      
      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object);
        break;

      default:
        console.log(`ℹ️ Unhandled event type: ${event.type}`);
    }

    // Return success response
    res.json({ received: true, event: event.type });
  } catch (error) {
    console.error('❌ Error processing webhook:', error);
    res.status(500).json({ error: 'Webhook processing failed', message: error.message });
  }
});

// ============================================================================
// Health Check Endpoint
// ============================================================================

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'nft-admin-webhook',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// Test Endpoint (Development Only)
// ============================================================================

if (process.env.NODE_ENV === 'development') {
  app.post('/test/bnpl', async (req, res) => {
    try {
      await insertBNPLTransaction(req.body);
      res.json({ success: true, message: 'Test BNPL transaction created' });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });

  app.post('/test/subscription', async (req, res) => {
    try {
      await upsertSubscription(req.body);
      res.json({ success: true, message: 'Test subscription created' });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });
}

// ============================================================================
// Start Server
// ============================================================================

app.listen(PORT, () => {
  console.log('\n🚀 NFT Admin Webhook Server Started');
  console.log(`📍 Port: ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Webhook URL: http://localhost:${PORT}/webhook`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log('\n✅ Ready to receive Stripe webhook events\n');
});

// ============================================================================
// Graceful Shutdown
// ============================================================================

process.on('SIGTERM', () => {
  console.log('⚠️ SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\n⚠️ SIGINT signal received: closing HTTP server');
  process.exit(0);
});

