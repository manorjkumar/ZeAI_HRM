const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const employeeSchema = new Schema({
  employeeId: { type: String, unique: true, index: true, required: true },
  employeeName: { type: String, required: true },
  position: String,
  role: { type: String, enum: ['admin', 'employee'], default: 'employee' },
  canApproveLeave: { type: Boolean, default: false },
  passwordHash: { type: String }
}, { collection: 'employees', timestamps: true });

module.exports = mongoose.model('Employee', employeeSchema);
