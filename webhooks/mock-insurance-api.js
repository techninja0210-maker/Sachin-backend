/**
 * ============================================================================
 * NFT Admin Dashboard - Mock Insurance API Server
 * ============================================================================
 * Purpose: Mock Insurance API for NFT insurance verification and quotes
 * Stack: Node.js + Express
 * Version: 1.0.0 (Production Ready)
 * ============================================================================
 */

const express = require('express');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.INSURANCE_API_PORT || 3001;

// ============================================================================
// Middleware
// ============================================================================

app.use(cors());
app.use(express.json());

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// ============================================================================
// Mock Insurance Data
// ============================================================================

const mockPolicies = [
  {
    id: 'POLICY-NFT-2025-001',
    nft_id: '10000000-0000-0000-0000-000000000001',
    user_id: '00000000-0000-0000-0000-000000000001',
    status: 'approved',
    coverage_amount: 150.00,
    premium_paid: 7.50,
    expiry_date: '2026-01-15',
    coverage_type: 'theft_and_loss'
  },
  {
    id: 'POLICY-NFT-2025-002',
    nft_id: '10000000-0000-0000-0000-000000000002',
    user_id: '00000000-0000-0000-0000-000000000002',
    status: 'approved',
    coverage_amount: 75.50,
    premium_paid: 3.78,
    expiry_date: '2026-02-20',
    coverage_type: 'theft_and_loss'
  }
];

// ============================================================================
// Helper Functions
// ============================================================================

function generatePolicyId() {
  const year = new Date().getFullYear();
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
  return `POLICY-NFT-${year}-${random}`;
}

function calculatePremium(amount) {
  // Premium is 5% of coverage amount
  return Math.round((amount * 0.05) * 100) / 100;
}

function isNftEligible(nftId, amount) {
  // Mock eligibility rules
  if (amount > 10000) return false; // Too high value
  if (amount < 10) return false;    // Too low value
  return true;
}

// ============================================================================
// API Endpoints
// ============================================================================

/**
 * Verify NFT Insurance
 * POST /insurance/verify
 */
app.post('/insurance/verify', async (req, res) => {
  try {
    const { nft_id, user_id, coverage_amount } = req.body;

    // Validate required fields
    if (!nft_id || !user_id || !coverage_amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: nft_id, user_id, coverage_amount',
        code: 'MISSING_FIELDS'
      });
    }

    // Check if NFT is eligible
    if (!isNftEligible(nft_id, coverage_amount)) {
      return res.status(400).json({
        success: false,
        error: 'NFT not eligible for insurance coverage',
        code: 'NFT_NOT_ELIGIBLE',
        details: {
          nft_id,
          coverage_amount,
          reason: coverage_amount > 10000 ? 'NFT value too high' : 'NFT value too low'
        }
      });
    }

    // Check if NFT already has active insurance
    const existingPolicy = mockPolicies.find(p => p.nft_id === nft_id && p.status === 'approved');
    if (existingPolicy) {
      return res.status(400).json({
        success: false,
        error: 'NFT already has active insurance policy',
        code: 'ALREADY_INSURED',
        details: {
          existing_policy_id: existingPolicy.id,
          expiry_date: existingPolicy.expiry_date
        }
      });
    }

    // Generate new policy
    const premium = calculatePremium(coverage_amount);
    const policyId = generatePolicyId();
    const expiryDate = new Date();
    expiryDate.setFullYear(expiryDate.getFullYear() + 1);

    const newPolicy = {
      id: policyId,
      nft_id,
      user_id,
      status: 'approved',
      coverage_amount,
      premium_paid: premium,
      expiry_date: expiryDate.toISOString().split('T')[0],
      coverage_type: 'theft_and_loss',
      created_at: new Date().toISOString()
    };

    // Add to mock policies (in real implementation, this would be saved to database)
    mockPolicies.push(newPolicy);

    return res.status(200).json({
      success: true,
      message: 'Insurance policy approved',
      policy: newPolicy
    });

  } catch (error) {
    console.error('Error in /insurance/verify:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  }
});

/**
 * Get Insurance Quote
 * POST /insurance/quote
 */
app.post('/insurance/quote', async (req, res) => {
  try {
    const { nft_id, coverage_amount } = req.body;

    // Validate required fields
    if (!nft_id || !coverage_amount) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: nft_id, coverage_amount',
        code: 'MISSING_FIELDS'
      });
    }

    // Check if NFT is eligible
    if (!isNftEligible(nft_id, coverage_amount)) {
      return res.status(400).json({
        success: false,
        error: 'NFT not eligible for insurance coverage',
        code: 'NFT_NOT_ELIGIBLE',
        details: {
          nft_id,
          coverage_amount,
          reason: coverage_amount > 10000 ? 'NFT value too high' : 'NFT value too low'
        }
      });
    }

    // Calculate quote
    const premium = calculatePremium(coverage_amount);
    const quoteId = `QUOTE-${Date.now()}`;

    return res.status(200).json({
      success: true,
      quote: {
        id: quoteId,
        nft_id,
        coverage_amount,
        premium_quote: premium,
        coverage_type: 'theft_and_loss',
        valid_until: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // 24 hours
        terms: [
          'Coverage for theft and loss',
          'Valid for 12 months from purchase',
          'Premium must be paid upfront',
          'Claims must be reported within 30 days'
        ]
      }
    });

  } catch (error) {
    console.error('Error in /insurance/quote:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  }
});

/**
 * Reject Insurance Application
 * POST /insurance/reject
 */
app.post('/insurance/reject', async (req, res) => {
  try {
    const { nft_id, user_id, rejection_reason } = req.body;

    // Validate required fields
    if (!nft_id || !user_id) {
      return res.status(400).json({
        success: false,
        error: 'Missing required fields: nft_id, user_id',
        code: 'MISSING_FIELDS'
      });
    }

    return res.status(200).json({
      success: true,
      message: 'Insurance application rejected',
      rejection: {
        nft_id,
        user_id,
        rejection_reason: rejection_reason || 'Application does not meet eligibility criteria',
        rejected_at: new Date().toISOString()
      }
    });

  } catch (error) {
    console.error('Error in /insurance/reject:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  }
});

/**
 * Get Policy Status
 * GET /insurance/policy/:policy_id
 */
app.get('/insurance/policy/:policy_id', async (req, res) => {
  try {
    const { policy_id } = req.params;

    const policy = mockPolicies.find(p => p.id === policy_id);
    if (!policy) {
      return res.status(404).json({
        success: false,
        error: 'Policy not found',
        code: 'POLICY_NOT_FOUND'
      });
    }

    return res.status(200).json({
      success: true,
      policy
    });

  } catch (error) {
    console.error('Error in /insurance/policy:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  }
});

/**
 * List All Policies
 * GET /insurance/policies
 */
app.get('/insurance/policies', async (req, res) => {
  try {
    const { user_id, status } = req.query;

    let filteredPolicies = [...mockPolicies];

    // Filter by user_id if provided
    if (user_id) {
      filteredPolicies = filteredPolicies.filter(p => p.user_id === user_id);
    }

    // Filter by status if provided
    if (status) {
      filteredPolicies = filteredPolicies.filter(p => p.status === status);
    }

    return res.status(200).json({
      success: true,
      policies: filteredPolicies,
      total: filteredPolicies.length
    });

  } catch (error) {
    console.error('Error in /insurance/policies:', error);
    return res.status(500).json({
      success: false,
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    });
  }
});

/**
 * Health Check
 * GET /health
 */
app.get('/health', (req, res) => {
  return res.status(200).json({
    status: 'healthy',
    service: 'mock-insurance-api',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

/**
 * API Documentation
 * GET /
 */
app.get('/', (req, res) => {
  return res.status(200).json({
    service: 'Mock Insurance API',
    version: '1.0.0',
    description: 'Mock API for NFT insurance verification and quotes',
    endpoints: [
      'POST /insurance/verify - Verify and approve NFT insurance',
      'POST /insurance/quote - Get insurance quote',
      'POST /insurance/reject - Reject insurance application',
      'GET /insurance/policy/:policy_id - Get policy details',
      'GET /insurance/policies - List all policies',
      'GET /health - Health check',
      'GET / - This documentation'
    ],
    example_verify: {
      method: 'POST',
      url: '/insurance/verify',
      body: {
        nft_id: '10000000-0000-0000-0000-000000000001',
        user_id: '00000000-0000-0000-0000-000000000001',
        coverage_amount: 150.00
      }
    }
  });
});

// ============================================================================
// Error Handling
// ============================================================================

// 404 Handler
app.use('*', (req, res) => {
  return res.status(404).json({
    success: false,
    error: 'Endpoint not found',
    message: `The requested endpoint ${req.method} ${req.originalUrl} does not exist`,
    available_endpoints: [
      'POST /insurance/verify',
      'POST /insurance/quote',
      'POST /insurance/reject',
      'GET /insurance/policy/:policy_id',
      'GET /insurance/policies',
      'GET /health',
      'GET /'
    ]
  });
});

// Global Error Handler
app.use((error, req, res, next) => {
  console.error('❌ Unhandled error:', error);
  
  return res.status(500).json({
    success: false,
    error: 'Internal server error',
    code: 'INTERNAL_ERROR'
  });
});

// ============================================================================
// Start Server
// ============================================================================

const server = app.listen(PORT, () => {
  console.log('\n🛡️ Mock Insurance API Server Started');
  console.log(`📍 Port: ${PORT}`);
  console.log(`🔗 API URL: http://localhost:${PORT}`);
  console.log(`💚 Health check: http://localhost:${PORT}/health`);
  console.log(`📚 Documentation: http://localhost:${PORT}/`);
  console.log('\n✅ Ready to handle insurance API requests\n');
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

// Graceful shutdown
const gracefulShutdown = (signal) => {
  console.log(`\n⚠️ ${signal} signal received: closing HTTP server`);
  
  server.close(() => {
    console.log('✅ HTTP server closed');
    process.exit(0);
  });

  setTimeout(() => {
    console.log('❌ Forcing shutdown');
    process.exit(1);
  }, 10000);
};

process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));
