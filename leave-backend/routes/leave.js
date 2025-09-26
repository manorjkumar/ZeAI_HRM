const express = require('express');
const router = express.Router();
const Leave = require('../models/leave');
const Employee = require('../models/employee');
const { authMiddleware, requireAdmin } = require('../middleware/auth');

// Employee applies for leave (authenticated)
router.post('/apply-leave', authMiddleware, async (req, res) => {
  try {
    const { leaveType, approver, fromDate, toDate, reason } = req.body;
    const employeeId = req.user.employeeId;

    if (!leaveType || !fromDate || !toDate || !reason) {
      return res.status(400).json({ message: 'Missing fields' });
    }

    const emp = await Employee.findOne({ employeeId });
    if (!emp) return res.status(404).json({ message: 'Employee not found' });

    const l = new Leave({
      employeeId,
      employeeName: emp.employeeName,
      leaveType,
      fromDate,
      toDate,
      reason,
      approver,
      status: 'Pending'
    });

    await l.save();

    if (req.app.get('io')) {
      req.app.get('io').emit('leave:new', { leave: l.toObject() });
    }

    res.status(201).json({ message: 'Leave applied', leave: l });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Employee: fetch own leaves
router.get('/fetch/:employeeId', authMiddleware, async (req, res) => {
  try {
    const employeeId = req.params.employeeId.trim();
    if (employeeId !== req.user.employeeId) {
      return res.status(403).json({ message: 'Forbidden' });
    }
    const leaves = await Leave.find({ employeeId }).sort({ createdAt: -1 });
    res.json(leaves);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: get all pending
router.get('/pending', authMiddleware, requireAdmin, async (req, res) => {
  try {
    const pending = await Leave.find({ status: 'Pending' }).sort({ createdAt: 1 });
    res.json(pending);
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Admin: approve/reject
router.put('/approve-reject/:leaveId', authMiddleware, requireAdmin, async (req, res) => {
  try {
    const { leaveId } = req.params;
    const { status } = req.body;
    if (!['Approved', 'Rejected'].includes(status)) {
      return res.status(400).json({ message: 'Invalid status' });
    }
    const updated = await Leave.findByIdAndUpdate(leaveId, { status }, { new: true });
    if (!updated) return res.status(404).json({ message: 'Not found' });

    if (req.app.get('io')) {
      req.app.get('io').emit('leave:updated', { leave: updated.toObject() });
    }

    res.json({ message: 'Leave updated', leave: updated });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Employee: update own leave (before approved)
router.put('/update/:employeeId/:id', authMiddleware, async (req, res) => {
  try {
    const { employeeId, id } = req.params;
    if (employeeId !== req.user.employeeId) return res.status(403).json({ message: 'Forbidden' });

    const body = req.body;
    const leave = await Leave.findOne({ _id: id, employeeId });
    if (!leave) return res.status(404).json({ message: 'Leave not found' });
    if (leave.status !== 'Pending' && leave.status !== 'Cancelled') {
      return res.status(400).json({ message: 'Cannot update processed leave' });
    }

    leave.leaveType = body.leaveType ?? leave.leaveType;
    leave.fromDate = body.fromDate ?? leave.fromDate;
    leave.toDate = body.toDate ?? leave.toDate;
    leave.reason = body.reason ?? leave.reason;
    leave.status = 'Pending';
    await leave.save();

    if (req.app.get('io')) req.app.get('io').emit('leave:updated', { leave: leave.toObject() });

    res.json({ message: 'Leave updated', leave });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

// Employee: cancel
router.delete('/delete/:employeeId/:id', authMiddleware, async (req, res) => {
  try {
    const { employeeId, id } = req.params;
    if (employeeId !== req.user.employeeId) return res.status(403).json({ message: 'Forbidden' });

    const leave = await Leave.findOne({ _id: id, employeeId });
    if (!leave) return res.status(404).json({ message: 'Leave not found' });

    leave.status = 'Cancelled';
    await leave.save();

    if (req.app.get('io')) req.app.get('io').emit('leave:updated', { leave: leave.toObject() });

    res.json({ message: 'Cancelled', leave });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
