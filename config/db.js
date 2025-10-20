const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    await mongoose.connect("mongodb+srv://Tumiso:TFARdn4fxQuq8ZsY@signupin.l7fntfw.mongodb.net/?retryWrites=true&w=majority&appName=SignUpIn");
    console.log("✅ MongoDB connected");
  } catch (error) {
    console.error("❌ MongoDB connection failed:", error);
    process.exit(1);
  }
};

module.exports = connectDB;
