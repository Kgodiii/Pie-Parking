// server.js
require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const helmet = require('helmet');
const morgan = require('morgan');
const bodyParser = require('body-parser');
const cors = require('cors');

const paymentsRoutes = require('./routes/payments');

const app = express();
const PORT = process.env.PORT || 3000;

// Connect MongoDB
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => console.log('MongoDB connected'))
  .catch(err => {
    console.error('MongoDB connection error', err);
    process.exit(1);
  });

// General middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));

// For JSON endpoints except webhook: parse as usual
app.use((req, res, next) => {
  // leave rawBody undefined unless webhook
  next();
});

app.use(express.json());

// Mount normal routes (create intent, status, refund)
app.use('/api/payments', paymentsRoutes);

// IMPORTANT: override webhook route to use raw body for signature verification
// We need to register a raw body parser specifically for the webhook path BEFORE the route handler executes.
const { json, raw } = bodyParser;

// Re-mount the webhook route with raw body parsing
app.post('/api/payments/webhook', raw({ type: '*/*' }), (req, res, next) => {
  // attach rawBody to req for controller to use
  req.rawBody = req.body;
  // forward to controller (it will be handled by same controller already wired)
  const paymentsController = require('./controllers/paymentsController');
  return paymentsController.webhookHandler(req, res);
});

// Health check
app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
});
