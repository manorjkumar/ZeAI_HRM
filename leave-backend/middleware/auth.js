const jwt = require('jsonwebtoken');
const Employee = require('../models/employee');

module.exports = {
  authMiddleware: async (req, res, next) => {
    try {
      const header = req.headers.authorization || '';
      const token = header.startsWith('Bearer ') ? header.slice(7) : null;
      if (!token) return res.status(401).json({ message: 'Missing token' });
      const payload = jwt.verify(token, process.env.JWT_SECRET || 'super-secret-change-me');
      req.user = payload;
      next();
    } catch (err) {
      return res.status(401).json({ message: 'Invalid token', error: err.message });
    }
  },

  requireAdmin: async (req, res, next) => {
    try {
      if (!req.user) return res.status(401).json({ message: 'Missing auth' });
      const employee = await Employee.findOne({ employeeId: req.user.employeeId });
      if (!employee || !employee.canApproveLeave) {
        return res.status(403).json({ message: 'Admin permission required' });
      }
      next();
    } catch (err) {
      res.status(500).json({ message: 'Server error', error: err.message });
    }
  }
};
