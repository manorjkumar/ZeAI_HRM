const express = require("express");
const router = express.Router();
const ReviewDecision = require("../models/performanceDecision");
const Reports = require("../models/reviewmodel");

// ✅ Save new decision AND update review status
router.post("/", async (req, res) => {
  try {
    const { employeeId, employeeName, position, decision, comment, sendTo, reviewId } = req.body;

    if (!employeeId || !employeeName || !position || !decision || !comment || !sendTo || !reviewId) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Ensure sendTo is array
    const targets = Array.isArray(sendTo) ? sendTo : [sendTo];

    // Save decision
    const newDecision = new ReviewDecision({
      employeeId,
      employeeName,
      position,
      decision,
      comment,
      sendTo: targets,
    });
    await newDecision.save();

    // ✅ Update review status
    const statusText = decision === "agree" ? "Agreed" : "Disagreed";
    await Reports.findByIdAndUpdate(reviewId, { status: statusText });

    res.status(201).json({ message: "Decision saved successfully", newDecision });
  } catch (error) {
    console.error("Error saving decision:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Get all decisions
router.get("/", async (req, res) => {
  try {
    const decisions = await ReviewDecision.find().sort({ createdAt: -1 });
    res.json(decisions);
  } catch (error) {
    console.error("Error fetching decisions:", error);
    res.status(500).json({ message: "Server error" });
  }
});

// ✅ Get decisions for specific employee
router.get("/:employeeId", async (req, res) => {
  try {
    const { employeeId } = req.params;
    const { sendTo } = req.query;

    let filter = { employeeId };
    if (sendTo) filter.sendTo = sendTo;

    const decisions = await ReviewDecision.find(filter).sort({ createdAt: -1 });
    res.json(decisions);
  } catch (error) {
    console.error("Error fetching employee decisions:", error);
    res.status(500).json({ message: "Server error" });
  }
});

module.exports = router;