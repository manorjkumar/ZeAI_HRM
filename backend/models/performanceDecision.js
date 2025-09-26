
const mongoose = require("mongoose");

const ReviewDecisionSchema = new mongoose.Schema({
  employeeId: { type: String, required: true },
  employeeName: { type: String, required: true },
  position: { type: String, required: true },
  decision: { type: String, enum: ["agree", "disagree"], required: true },
  comment: { type: String, required: true },
  sendTo: [{ type: String, enum: ["Admin", "Super Admin"], required: true}],
  createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model("performanceDecision", ReviewDecisionSchema);
