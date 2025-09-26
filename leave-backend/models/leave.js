const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const leaveSchema = new Schema({
  employeeId: { type: String, required: true, index: true },
  employeeName: String,
  leaveType: String,
  fromDate: Date,
  toDate: Date,
  reason: String,
  approver: String,
  status: { type: String, enum: ['Pending', 'Approved', 'Rejected', 'Cancelled'], default: 'Pending' }
}, { collection: 'leaves', timestamps: true });

module.exports = mongoose.model('Leave', leaveSchema);
