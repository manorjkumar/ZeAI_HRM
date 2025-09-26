require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');

const authRoutes = require('./routes/auth');
const leaveRoutes = require('./routes/leave');

const app = express();
app.use(cors());
app.use(express.json());

const server = http.createServer(app);
const PORT = process.env.PORT || 5000;

// socket.io
const { Server } = require('socket.io');
const io = new Server(server, {
  cors: { origin: '*' }
});
app.set('io', io);

io.on('connection', (socket) => {
  console.log('Socket connected', socket.id);
  socket.on('disconnect', () => console.log('Socket disconnected', socket.id));
});

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/Demo_Db', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('MongoDB connected');
}).catch(err => console.error('Mongo error', err));

// routes
app.use('/auth', authRoutes);
app.use('/apply', leaveRoutes);

// helper endpoint to get employee by id (public for testing)
app.get('/get-employee-name/:employeeId', async (req, res) => {
  const Employee = require('./models/employee');
  try {
    const e = await Employee.findOne({ employeeId: req.params.employeeId.trim() });
    if (!e) return res.status(404).json({ message: 'Not found' });
    res.json({
      employeeName: e.employeeName,
      position: e.position,
      role: e.role,
      canApproveLeave: e.canApproveLeave
    });
  } catch (err) { res.status(500).json({ message: 'Server error' }); }
});

server.listen(PORT, () => console.log(`Server running on ${PORT}`));
