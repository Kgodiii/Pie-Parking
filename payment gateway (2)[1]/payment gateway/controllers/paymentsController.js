// controllers/paymentsController.js
const Stripe = require('stripe');
const Payment = require('../models/payment');
const { getIdempotencyKey } = require('../utils/idempotency');
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

/**
 * Create Payment Intent + local DB record
 * POST /api/payments/create-intent
 */
async function createIntent(req, res) {
  try {
    const { amount, currency = 'ZAR', customerId, description, metadata = {} } = req.body;

    // server-side validation
    if (!amount || !Number.isInteger(amount) || amount <= 0) {
      return res.status(400).json({ error: 'Invalid amount. Must be integer (cents).' });
    }

    // create local payment record
    const payment = new Payment({
      customerId,
      amount,
      currency,
      status: 'pending',
      metadata
    });
    await payment.save();

    // create Stripe PaymentIntent in test mode
    const idempotencyKey = getIdempotencyKey(req);
    const intent = await stripe.paymentIntents.create({
      amount,
      currency,
      description,
      metadata: { localPaymentId: payment._id.toString(), ...metadata }
    }, {
      idempotencyKey
    });

    // store provider id and client secret
    payment.providerPaymentId = intent.id;
    payment.clientSecret = intent.client_secret; // optional: treat carefully
    await payment.save();

    return res.json({
      paymentIntentId: intent.id,
      clientSecret: intent.client_secret,
      amount,
      currency,
      localPaymentId: payment._id
    });
  } catch (err) {
    console.error('createIntent err', err);
    return res.status(500).json({ error: 'Internal server error' });
  }
}

/**
 * GET /api/payments/:paymentIntentId/status
 */
async function getStatus(req, res) {
  try {
    const { paymentIntentId } = req.params;
    if (!paymentIntentId) return res.status(400).json({ error: 'Missing paymentIntentId param' });

    const payment = await Payment.findOne({ providerPaymentId: paymentIntentId });
    if (!payment) return res.status(404).json({ error: 'Payment not found' });

    return res.json({
      status: payment.status,
      amount: payment.amount,
      currency: payment.currency,
      updatedAt: payment.updatedAt
    });
  } catch (err) {
    console.error('getStatus err', err);
    return res.status(500).json({ error: 'Internal error' });
  }
}

/**
 * POST /api/payments/refund
 * Body: { paymentIntentId, amount, reason }
 */
async function refund(req, res) {
  try {
    const { paymentIntentId, amount, reason } = req.body;
    if (!paymentIntentId) return res.status(400).json({ error: 'Missing paymentIntentId' });

    const payment = await Payment.findOne({ providerPaymentId: paymentIntentId });
    if (!payment) return res.status(404).json({ error: 'Payment not found' });

    // Create refund on Stripe
    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      amount: amount || payment.amount,
      reason: reason || 'requested_by_customer'
    }, {
      idempotencyKey: `refund-${payment._id.toString()}-${Date.now()}`
    });

    // update local payment state
    payment.status = 'refunded';
    await payment.save();

    return res.json({ success: true, refund });
  } catch (err) {
    console.error('refund err', err);
    return res.status(500).json({ error: 'Refund failed' });
  }
}

/**
 * Webhook handler - must use raw body and STRIPE_WEBHOOK_SECRET to verify signature
 * POST /api/payments/webhook
 */
async function webhookHandler(req, res) {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;
  try {
    // req.rawBody is set in server.js raw-body middleware
    event = stripe.webhooks.constructEvent(req.rawBody, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed.', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Idempotency: check event.id against stored webhookEvents in Payment
  const eventId = event.id;
  try {
    const type = event.type;
    const data = event.data.object;

    // For many events, the PaymentIntent is in event.data.object (or nested)
    const piId = data.id || (data.payment_intent ? data.payment_intent : null);

    // If event has a PaymentIntent id, find matching Payment record
    let payment;
    if (piId) {
      payment = await Payment.findOne({ providerPaymentId: piId });
    }

    // Avoid reprocessing same webhook
    if (payment && payment.webhookEvents && payment.webhookEvents.includes(eventId)) {
      return res.status(200).send('Event already processed');
    }

    // Process relevant event types
    switch (type) {
      case 'payment_intent.succeeded':
        if (payment) {
          payment.status = 'succeeded';
          payment.webhookEvents.push(eventId);
          await payment.save();
        }
        // TODO: trigger fulfillment, emails, etc.
        break;

      case 'payment_intent.payment_failed':
        if (payment) {
          payment.status = 'failed';
          payment.webhookEvents.push(eventId);
          await payment.save();
        }
        break;

      case 'charge.refunded':
        if (payment) {
          payment.status = 'refunded';
          payment.webhookEvents.push(eventId);
          await payment.save();
        }
        break;

      // handle disputes, chargebacks, payment_intent.requires_action etc as needed
      default:
        // optionally store other events
        if (payment) {
          payment.webhookEvents.push(eventId);
          await payment.save();
        }
        break;
    }

    // respond quickly
    return res.status(200).json({ received: true });
  } catch (err) {
    console.error('Error processing webhook', err);
    return res.status(500).send('Server error while processing webhook');
  }
}

module.exports = {
  createIntent,
  getStatus,
  refund,
  webhookHandler
};
