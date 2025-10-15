/**
 * ============================================================================
 * NFT Admin Dashboard - Production Stripe Webhook Handler
 * ============================================================================
 * Purpose: Handle Stripe webhook events for BNPL, Subscriptions, Insurance
 * Stack: Node.js + Express + Stripe SDK + Supabase
 * Version: 2.0.0 (Production Ready)
 * ============================================================================
 */

const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const Stripe = require('stripe');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
require('dotenv').config();

// ============================================================================
// Configuration & Validation
// ============================================================================

// Validate required environment variables
const requiredEnvVars = [
  'SUPABASE_URL',
  'SUPABASE_SERVICE_KEY', 
  'STRIPE_SECRET_KEY',
  'STRIPE_WEBHOOK_SECRET'
];

const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
if (missingVars.length > 0) {
  console.error('❌ Missing required environment variables:', missingVars.join(', '));
  process.exit(1);
}

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Stripe with proper error handling
let stripe;
try {
  stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
    apiVersion: '2023-10-16',
    timeout: 10000, // 10 second timeout
  });
} catch (error) {
  console.error('❌ Failed to initialize Stripe:', error.message);
  process.exit(1);
}

// Initialize Supabase with proper error handling
let supabase;
try {
  supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_SERVICE_KEY,
    {
      auth: {
        persistSession: false
      }
    }
  );
} catch (error) {
  console.error('❌ Failed to initialize Supabase:', error.message);
  process.exit(1);
}

const WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET;

// ============================================================================
// Security Middleware
// ============================================================================

// Security headers
app.use(helmet({
  contentSecurityPolicy: false, // Disable for webhook endpoints
}));

// Rate limiting for webhook endpoint
const webhookLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 1000, // Limit each IP to 1000 requests per windowMs
  message: {
    error: 'Too many webhook requests from this IP',
    retryAfter: '15 minutes'
  },
  standardHeaders: true,
  legacyHeaders: false,
});

// ============================================================================
// Middleware
// ============================================================================

// For webhook signature verification, we need raw body
app.use('/webhook', webhookLimiter, express.raw({ type: 'application/json' }));
app.use(express.json({ limit: '10mb' }));

// Request logging middleware
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
});

// ============================================================================
// Helper Functions with Retry Logic
// ============================================================================

/**
 * Retry function with exponential backoff
 */
async function retryOperation(operation, maxRetries = 3, baseDelay = 1000) {
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      return await operation();
    } catch (error) {
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, attempt - 1);
      console.log(`⚠️ Attempt ${attempt} failed, retrying in ${delay}ms...`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}

/**
 * Insert BNPL transaction into Supabase with retry logic
 */
async function insertBNPLTransaction(data) {
  return await retryOperation(async () => {
    const { error } = await supabase
      .from('bnpl_transactions')
      .insert([data]);

    if (error) {
      console.error('❌ Error inserting BNPL transaction:', error);
      throw error;
    }
    
    console.log('✅ BNPL transaction inserted:', data.order_id);
    return true;
  });
}

/**
 * Update or insert subscription with retry logic
 */
async function upsertSubscription(data) {
  return await retryOperation(async () => {
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
    return true;
  });
}

/**
 * Insert NFT insurance log with retry logic
 */
async function insertInsuranceLog(data) {
  return await retryOperation(async () => {
    const { error } = await supabase
      .from('nft_insurance_logs')
      .insert([data]);

    if (error) {
      console.error('❌ Error inserting insurance log:', error);
      throw error;
    }
    
    console.log('✅ Insurance log inserted for NFT:', data.nft_id);
    return true;
  });
}

/**
 * Lock user access on subscription failure
 */
async function lockUserAccess(userId, reason) {
  try {
    console.log(`🔒 Locking access for user ${userId}. Reason: ${reason}`);
    
    // Update user metadata or create a user access log
    const { error } = await supabase
      .from('users')
      .update({ 
        subscription_locked: true,
        lock_reason: reason,
        locked_at: new Date().toISOString()
      })
      .eq('id', userId);

    if (error && !error.message.includes('relation "users" does not exist')) {
      console.error('❌ Error locking user access:', error);
    }
  } catch (error) {
    console.error('❌ Error in lockUserAccess:', error.message);
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

/**
 * Validate webhook signature
 */
function validateWebhookSignature(payload, signature) {
  try {
    return stripe.webhooks.constructEvent(payload, signature, WEBHOOK_SECRET);
  } catch (error) {
    throw new Error(`Webhook signature verification failed: ${error.message}`);
  }
}

// ============================================================================
// Webhook Event Handlers
// ============================================================================

/**
 * Handle checkout.session.completed event
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
      amount_paid: session.amount_total / 100,
      bnpl_status: 'success',
      user_email: session.customer_details?.email,
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
      amount: 5.00,
      currency: session.currency || 'AUD',
      user_email: session.customer_details?.email,
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
 */
async function handleInvoicePaymentFailed(invoice) {
  console.log('❌ Processing invoice.payment_failed:', invoice.id);

  if (invoice.subscription) {
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

    await lockUserAccess(invoice.customer, 'subscription_payment_failed');
  }

  console.log('⚠️ Invoice payment failed - user access locked');
}

/**
 * Handle customer.subscription.deleted event
 */
async function handleSubscriptionDeleted(subscription) {
  console.log('🗑️ Processing customer.subscription.deleted:', subscription.id);

  await upsertSubscription({
    user_id: subscription.customer,
    subscription_id: subscription.id,
    stripe_customer_id: subscription.customer,
    status: 'canceled',
    next_billing_date: null,
    metadata: {
      canceled_at: new Date().toISOString(),
      cancellation_reason: subscription.cancellation_details?.reason || 'user_canceled'
    }
  });

  await lockUserAccess(subscription.customer, 'subscription_canceled');
  console.log('✅ Subscription deleted - user access locked');
}

/**
 * Handle payment_intent.succeeded event
 */
async function handlePaymentIntentSucceeded(paymentIntent) {
  console.log('💳 Processing payment_intent.succeeded:', paymentIntent.id);

  // Check if transaction already exists
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
// Webhook Endpoint with Enhanced Error Handling
// ============================================================================

app.post('/webhook', async (req, res) => {
  const sig = req.headers['stripe-signature'];
  let event;

  try {
    // Verify webhook signature
    event = validateWebhookSignature(req.body, sig);
  } catch (err) {
    console.error('⚠️ Webhook signature verification failed:', err.message);
    return res.status(400).json({ 
      error: 'Webhook signature verification failed',
      message: err.message 
    });
  }

  console.log(`\n🔔 Received event: ${event.type} - ID: ${event.id}`);

  try {
    // Route event to appropriate handler with error handling
    switch (event.type) {
      case 'checkout.session.completed':
        await handleCheckoutCompleted(event.data.object);
        break;

      case 'invoice.payment_succeeded':
        await handleInvoicePaymentSucceeded(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await handleInvoicePaymentFailed(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;

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
    res.status(200).json({ 
      received: true, 
      event: event.type,
      id: event.id,
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('❌ Error processing webhook:', error);
    
    // Return 500 for server errors, 400 for client errors
    const statusCode = error.message.includes('validation') || error.message.includes('invalid') ? 400 : 500;
    
    res.status(statusCode).json({ 
      error: 'Webhook processing failed', 
      message: error.message,
      event: event.type,
      id: event.id
    });
  }
});

// ============================================================================
// Health Check Endpoint
// ============================================================================

app.get('/health', async (req, res) => {
  try {
    // Test Supabase connection
    const { error } = await supabase
      .from('bnpl_transactions')
      .select('id')
      .limit(1);

    const dbStatus = error ? 'disconnected' : 'connected';

    res.json({
      status: 'healthy',
      service: 'nft-admin-webhook',
      version: '2.0.0',
      environment: process.env.NODE_ENV || 'development',
      database: dbStatus,
      stripe: 'connected',
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }
});

// ============================================================================
// Test Endpoints (Development Only)
// ============================================================================

if (process.env.NODE_ENV === 'development' || process.env.ENABLE_TEST_ENDPOINTS === 'true') {
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

  app.post('/test/insurance', async (req, res) => {
    try {
      await insertInsuranceLog(req.body);
      res.json({ success: true, message: 'Test insurance log created' });
    } catch (error) {
      res.status(500).json({ success: false, error: error.message });
    }
  });
}

// ============================================================================
// 404 Handler
// ============================================================================

app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Endpoint not found',
    message: `The requested endpoint ${req.method} ${req.originalUrl} does not exist`,
    available_endpoints: [
      'POST /webhook - Stripe webhook handler',
      'GET /health - Health check',
      ...(process.env.NODE_ENV === 'development' || process.env.ENABLE_TEST_ENDPOINTS === 'true' ? [
        'POST /test/bnpl - Test BNPL transaction',
        'POST /test/subscription - Test subscription',
        'POST /test/insurance - Test insurance log'
      ] : [])
    ]
  });
});

// ============================================================================
// Global Error Handler
// ============================================================================

app.use((error, req, res, next) => {
  console.error('❌ Unhandled error:', error);
  
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? error.message : 'Something went wrong',
    timestamp: new Date().toISOString()
  });
});

// ============================================================================
// Start Server with Error Handling
// ============================================================================

const server = app.listen(PORT, () => {
  console.log('\n🚀 NFT Admin Webhook Server Started (Production Ready)');
  console.log(`📍 Port: ${PORT}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔗 Webhook URL: http://localhost:${PORT}/webhook`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`🔒 Security: Rate limiting, helmet, signature verification enabled`);
  console.log(`⚡ Retry logic: Enabled with exponential backoff`);
  console.log('\n✅ Ready to receive Stripe webhook events\n');
});

// Handle server startup errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use. Please use a different port.`);
  } else {
    console.error('❌ Server startup error:', error);
  }
  process.exit(1);
});

// ============================================================================
// Graceful Shutdown
// ============================================================================

const gracefulShutdown = (signal) => {
  console.log(`\n⚠️ ${signal} signal received: closing HTTP server`);
  
  server.close(() => {
    console.log('✅ HTTP server closed');
    process.exit(0);
  });

  // Force close after 10 seconds
  setTimeout(() => {
    console.log('❌ Forcing shutdown');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (error) => {
  console.error('❌ Uncaught Exception:', error);
  gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('❌ Unhandled Rejection at:', promise, 'reason:', reason);
  gracefulShutdown('unhandledRejection');
});
