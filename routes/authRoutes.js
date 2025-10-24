const express = require("express");
const crypto = require("crypto");
const jwt = require("jsonwebtoken");
const User = require("../models/user");

const router = express.Router();

// Helper: Encrypt password using SHA256
function encryptPassword(password) {
  return crypto.createHash("sha256").update(password).digest("hex");
}

// Generate JWT token
function generateToken(user) {
  return jwt.sign(
    { id: user._id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: "2h" } // Token expires in 2 hours
  );
}

// ------------------ SIGNUP ------------------
router.post("/signup", async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Input validation
    if (!username || !email || !password) {
      return res.status(400).json({ message: "All fields are required." });
    }

    // Check if email already exists
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      return res.status(400).json({ message: "Email already registered." });
    }

    // Encrypt password
    const hashedPassword = encryptPassword(password);

    // Save user
    const newUser = new User({ username, email, password: hashedPassword });
    await newUser.save();

    // Generate token
    const token = generateToken(newUser);

    return res.status(201).json({
      message: "User registered successfully",
      token: `Bearer ${token}`, // ✅ Send token with Bearer prefix
      user: {
        id: newUser._id,
        username: newUser.username,
        email: newUser.email,
      },
    });
  } catch (error) {
    console.error("Signup error:", error);
    res.status(500).json({ message: "Server error during signup." });
  }
});

// ------------------ LOGIN ------------------
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Input validation
    if (!email || !password) {
      return res.status(400).json({ message: "All fields are required." });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: "Invalid credentials." });
    }

    // Encrypt incoming password and compare
    const encryptedPassword = encryptPassword(password);
    if (user.password !== encryptedPassword) {
      return res.status(400).json({ message: "Invalid credentials." });
    }

    // Generate token
    const token = generateToken(user);

    return res.status(200).json({
      message: "Login successful",
      token: `Bearer ${token}`,
      user: {
        id: user._id,
        username: user.username,
        email: user.email,
      },
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Server error during login." });
  }
});

// ------------------ TOKEN VERIFICATION ------------------
function verifyToken(req, res, next) {
  try {
    const authHeader = req.headers["authorization"];
    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(403).json({ message: "Access denied. No token provided." });
    }

    const token = authHeader.split(" ")[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // Add decoded user data to request
    next();
  } catch (error) {
    console.error("Token verification failed:", error);
    res.status(401).json({ message: "Invalid or expired token." });
  }
}

// Example of a protected route
router.get("/profile", verifyToken, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select("-password");
    if (!user) return res.status(404).json({ message: "User not found." });
    res.status(200).json({ user });
  } catch (error) {
    res.status(500).json({ message: "Error fetching profile." });
  }
});

module.exports = router;





