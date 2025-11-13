// index.js (HRM backend + Socket.IO signaling + group call support)
require('dotenv').config();

const express = require('express');
const http = require("http");
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const { Server } = require('socket.io');

// ---------------- EXPRESS + HTTP SERVER ---------------- //
const app = express();
const server = http.createServer(app);
const PORT = process.env.PORT || 5000;
const MONGO_URI = process.env.MONGO_URI;

// ---------------- SOCKET.IO for signaling ---------------- //
// Allow both frontend and local dev
const io = new Server(server, {
  cors: {
    origin: [
      process.env.FRONTEND_URL || "https://hrmzeaisoftverbeta.netlify.app",
      "http://localhost:3000",
      "http://10.0.2.2:3000" // android emulator
    ],
    methods: ["GET", "POST"],
  },
});

// Store active users & call rooms
let onlineUsers = new Map(); // employeeId -> socketId
let rooms = {}; // roomId -> Set(employeeIds)

io.on("connection", (socket) => {
  console.log("🔗 Socket connected:", socket.id);

  // Register user
  socket.on("register", (employeeId) => {
    if (!employeeId) return;
    onlineUsers.set(employeeId, socket.id);
    console.log(`✅ Registered ${employeeId} -> ${socket.id}`);
  });

  // ------------------- ONE-TO-ONE CALL ------------------- //
  socket.on("call-user", (data) => {
    const { to, from, type } = data;
    const targetSocket = onlineUsers.get(to);

    if (targetSocket) {
      io.to(targetSocket).emit("incoming-call", { from, type });
    } else {
      io.to(socket.id).emit("user-offline", { to });
    }
  });

  socket.on("accept-call", (data) => {
    const { from, roomId } = data;
    const targetSocket = onlineUsers.get(from);
    if (targetSocket) io.to(targetSocket).emit("call-accepted", { roomId });
  });

  // ------------------- GROUP CALL SUPPORT ------------------- //
  socket.on("start-group-call", (data) => {
    try {
      const { from, targets, type, roomId } = data;
      const members = Array.isArray(targets) ? targets : [targets];

      // Notify caller if someone is offline
      const offline = members.filter(t => !onlineUsers.has(t));
      if (offline.length && onlineUsers.has(from)) {
        io.to(onlineUsers.get(from)).emit("user-offline", { offline });
      }

      // Notify online users
      members.forEach(targetId => {
        const sock = onlineUsers.get(targetId);
        if (sock) {
          io.to(sock).emit("incoming-call", { from, type, roomId });
        }
      });

      // Maintain group room
      if (roomId) {
        rooms[roomId] = rooms[roomId] || new Set();
        rooms[roomId].add(from);
        members.forEach(m => rooms[roomId].add(m));
      }
    } catch (err) {
      console.error("❌ start-group-call error:", err);
    }
  });

  // ------------------- SIGNALING (WebRTC exchange) ------------------- //
  socket.on("signal", (data) => {
    const { to, from, payload } = data;
    const sockId = onlineUsers.get(to);
    if (sockId) io.to(sockId).emit("signal", { from, payload });
  });

  // ------------------- END CALL ------------------- //
  socket.on("end-call", (data) => {
    const { from, to, roomId } = data;
    if (to && onlineUsers.has(to)) {
      io.to(onlineUsers.get(to)).emit("call-ended", { from });
    } else if (roomId && rooms[roomId]) {
      rooms[roomId].forEach(emp => {
        if (onlineUsers.has(emp))
          io.to(onlineUsers.get(emp)).emit("call-ended", { from, roomId });
      });
      delete rooms[roomId];
    }
  });

  // ------------------- DISCONNECT ------------------- //
  socket.on("disconnect", () => {
    for (let [empId, sockId] of onlineUsers.entries()) {
      if (sockId === socket.id) {
        onlineUsers.delete(empId);
        console.log(`❌ ${empId} disconnected`);
        break;
      }
    }
  });
});

// ---------------- YOUR EXISTING MODELS & ROUTES (UNCHANGED) ---------------- //
const Employee = require('./models/employee');
const LeaveBalance = require('./models/leaveBalance');
const Payslip = require('./schema/payslip');

const employeeRoutes = require('./routes/employee');
const leaveRoutes = require('./routes/leave');
const profileRoutes = require('./routes/profile_route');
const todoRoutes = require('./routes/todo');
const attendanceRoutes = require('./routes/attendance');
const performanceRoutes = require('./routes/performance');
const reviewRiver = require('./routes/adminperformance');
const reviewscreen = require('./routes/reviewRoutes');
const reviewDecisionRoutes = require('./routes/performanceDecision');
const notificationRoutes = require('./routes/notifications');
const requestsRoutes = require('./routes/changeRequests');
const uploadRoutes = require('./routes/upload');
const payslipRoutes = require('./routes/payslip');
const companyEventRoutes = require('./routes/companyEvent');

app.use((req, res, next) => {
  console.log(`📥 ${req.method} ${req.originalUrl}`);
  next();
});

app.use(cors({
  origin: [process.env.FRONTEND_URL || "https://hrmzeaisoftverbeta.netlify.app"],
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true,
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ROUTES
app.use('/api', employeeRoutes);
app.use('/apply', leaveRoutes);
app.use('/profile', profileRoutes);
app.use('/todo_planner', todoRoutes);
app.use('/attendance', attendanceRoutes);
app.use('/perform', performanceRoutes);
app.use('/reviews', reviewRiver);
app.use('/reports', reviewscreen);
app.use('/review-decision', reviewDecisionRoutes);
app.use('/notifications', notificationRoutes);
app.use('/requests', requestsRoutes);
app.use('/upload', uploadRoutes);
app.use('/payslip', payslipRoutes);
app.use('/company-events', companyEventRoutes);

// PAYSLIP & EMPLOYEE INFO ENDPOINTS (unchanged)
app.get('/get-payslip-details', async (req, res) => {
  try {
    const { employee_id, year, month } = req.query;
    const payslip = await Payslip.findOne({ employee_id });
    if (!payslip) return res.status(404).json({ message: 'Payslip not found' });

    const yearData = payslip.data_years.find(y => y.year === year);
    if (!yearData) return res.status(404).json({ message: 'Year not found' });

    const monthKey = month.toLowerCase().slice(0, 3);
    const monthData = yearData.months[monthKey];
    if (!monthData) return res.status(404).json({ message: 'Month data not found' });

    res.json({
      employee_name: payslip.employee_name,
      employee_id: payslip.employee_id,
      date_of_joining: payslip.date_of_joining,
      no_of_workdays: payslip.no_of_workdays,
      designation: payslip.designation,
      bank_name: payslip.bank_name,
      account_no: payslip.account_no,
      location: payslip.location,
      pan: payslip.pan,
      uan: payslip.uan,
      esic_no: payslip.esic_no,
      lop: payslip.lop,
      earnings: monthData.earnings,
      deductions: monthData.deductions,
    });
  } catch (error) {
    console.error('❌ Fetch Payslip Error:', error);
    res.status(500).json({ message: '❌ Failed to fetch payslip data', error: error.message });
  }
});

app.post('/get-multiple-payslips', async (req, res) => {
  try {
    const { employee_id, year, months } = req.body;
    if (!employee_id || !year || !Array.isArray(months)) {
      return res.status(400).json({ message: 'Missing or invalid fields' });
    }

    const payslip = await Payslip.findOne({ employee_id });
    if (!payslip) return res.status(404).json({ message: 'Employee not found' });

    const yearData = payslip.data_years.find(y => y.year === year);
    if (!yearData) return res.status(404).json({ message: 'Year not found' });

    const results = {};
    months.forEach(month => {
      const monthKey = month.toLowerCase().slice(0, 3);
      const monthData = yearData.months[monthKey];
      if (monthData) results[monthKey] = monthData;
    });

    res.status(200).json({
      employeeInfo: {
        employee_name: payslip.employee_name,
        employee_id: payslip.employee_id,
        date_of_joining: payslip.date_of_joining,
        no_of_workdays: payslip.no_of_workdays,
        designation: payslip.designation,
        bank_name: payslip.bank_name,
        account_no: payslip.account_no,
        location: payslip.location,
        pan: payslip.pan,
        uan: payslip.uan,
        esic_no: payslip.esic_no,
        lop: payslip.lop,
      },
      months: results,
    });
  } catch (error) {
    console.error('❌ Get Multiple Payslips Error:', error);
    res.status(500).json({ message: '❌ Failed to fetch payslip data', error: error.message });
  }
});

app.get('/get-employee-name/:employeeId', async (req, res) => {
  try {
    const employee = await Employee.findOne({ employeeId: req.params.employeeId.trim() });
    if (!employee) return res.status(404).json({ message: 'Employee not found' });

    res.status(200).json({
      employeeName: employee.employeeName,
      position: employee.position,
    });
  } catch (error) {
    console.error('❌ Get Employee Name Error:', error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

app.get('/', (req, res) => {
  res.send('✅ HRM Backend & Socket.IO Signaling Server Running Successfully!');
});

// ---------------- CONNECT MONGODB & START SERVER ---------------- //
mongoose.connect(MONGO_URI)
  .then(() => {
    console.log('✅ MongoDB connected');
    server.listen(PORT, () => console.log(`🚀 Server & Socket.IO running on port ${PORT}`));
  })
  .catch(err => console.error('❌ MongoDB connection error:', err));
