const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const connectDB = require("./config/db");
const authRoutes = require("./routes/authRoutes");

const app = express();
connectDB();

app.use(cors());
app.use(bodyParser.json());

// Routes
app.use("/api/auth", authRoutes);

const PORT = 3000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: "Something went wrong!" });
});

