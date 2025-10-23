const mongoose = require('mongoose');

const PaymentSchema = new mongoose.Schema({
  customerId: {
    type: String,
    required: true
  },
  amount: {
    type: Number,
    required: true
  },
  currency: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'succeeded', 'failed'],
    default: 'pending'
  },
  description: String,
  metadata: Object,
}, { timestamps: true });

module.exports = mongoose.model('Payment', PaymentSchema);

