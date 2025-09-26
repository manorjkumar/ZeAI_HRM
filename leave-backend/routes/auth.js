const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');
const Employee = require('../models/employee');

router.post('/login', async (req, res) => {
  try {
    const { employeeId, employeeName } = req.body;
    if (!employeeId || !employeeName) return res.status(400).json({ message: 'employeeId & employeeName required' });

    const user = await Employee.findOne({
      employeeId: employeeId.trim(),
      employeeName: employeeName.trim()
    });

    if (!user) return res.status(401).json({ message: 'Invalid credentials' });

    const token = jwt.sign({
      employeeId: user.employeeId,
      employeeName: user.employeeName,
      role: user.role,
      canApproveLeave: user.canApproveLeave
    }, process.env.JWT_SECRET || 'super-secret-change-me', { expiresIn: '7d' });

    res.json({
      token,
      user: {
        employeeId: user.employeeId,
        employeeName: user.employeeName,
        role: user.role,
        canApproveLeave: user.canApproveLeave
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

router.get('/me/:employeeId', async (req, res) => {
  try {
    const emp = await Employee.findOne({ employeeId: req.params.employeeId.trim() });
    if (!emp) return res.status(404).json({ message: 'Not found' });
    res.json({
      employeeId: emp.employeeId,
      employeeName: emp.employeeName,
      position: emp.position,
      role: emp.role,
      canApproveLeave: emp.canApproveLeave
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
