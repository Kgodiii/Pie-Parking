const jwt = require("jsonwebtoken");
const express = require("express");
const crypto = require("crypto");
const User = require("../models/user");


const router = express.Router();

// Helper: SHA256 encryption
function encryptPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}

/* SIGN-UP ROUTE */
router.post("/signup", async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Validation
    if (!username || !email || !password)
      return res.status(400).json({ error: "All fields are required." });

    if (password.length < 6)
      return res.status(400).json({ error: "Password must be at least 6 characters." });

    // Check existing user
    const existingUser = await User.findOne({ email });
    if (existingUser)
      return res.status(400).json({ error: "Email already registered." });

    // Encrypt password
    const hashedPassword = encryptPassword(password);

    // Save user
    const newUser = new User({ username, email, password: hashedPassword });
    await newUser.save();

    res.status(201).json({
      message: "User registered successfully!",
      user: { username, email },
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
});
// LOGIN ROUTE
router.get("/login", async (req, res) => {
  try {
    const { email, password } = req.query;

    if (!email || !password)
      return res.status(400).json({ error: "Email and password required." });

    const hashedPassword = encryptPassword(password);
    const user = await User.findOne({ email, password: hashedPassword });

    if (!user)
      return res.status(401).json({ error: "Invalid email or password." });

    // 🔑 Generate JWT token
    const token = jwt.sign(
      { userId: user._id, email: user.email },
      "mySuperSecretKey", // you can replace with process.env.JWT_SECRET later
      { expiresIn: "1h" }
    );

    // ✅ Send token back to user
    res.status(200).json({
      message: "Login successful!",
      token, // make sure this line exists
      user: { username: user.username, email: user.email },
    });
  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Server error" });
  }
});
module.exports = router;
// GET all users (for admin/testing)
router.get("/users", async (req, res) => {
  try {
    const users = await User.find({}, "-password"); // exclude password field
    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ error: "Failed to fetch users" });
  }
});



