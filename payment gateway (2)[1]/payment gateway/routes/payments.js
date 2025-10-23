// routes/payments.js
const express = require('express');
const router = express.Router();
const paymentsController = require('../controllers/paymentsController');

// create payment intent
router.post('/create-intent', paymentsController.createIntent);

// get status
router.get('/:paymentIntentId/status', paymentsController.getStatus);

// refund
router.post('/refund', paymentsController.refund);

// webhook uses raw body middleware in server.js, so mount here and handle raw body there
router.post('/webhook', paymentsController.webhookHandler);

module.exports = router;
