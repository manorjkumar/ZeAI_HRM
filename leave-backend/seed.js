require('dotenv').config();
const mongoose = require('mongoose');
const Employee = require('./models/employee');

mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/Demo_Db').then(async () => {
  console.log('Connected for seeding');
  const list = [
    { employeeId: 'ZeAI002', employeeName: 'Atheeba Feroz M', position: 'CEO', role: 'admin', canApproveLeave: true },
    { employeeId: 'ZeAI001', employeeName: 'Kirthika K', position: 'Founder', role: 'admin', canApproveLeave: true },
    { employeeId: 'ZeAI005', employeeName: 'Hari Baskaran P', position: 'CTO', role: 'admin', canApproveLeave: true },
    { employeeId: 'ZeAI109', employeeName: 'Kamesh E', position: 'Senior HR', role: 'admin', canApproveLeave: true },
    { employeeId: 'ZeAI102', employeeName: 'Nivetha S', position: 'Business development executive', role: 'employee', canApproveLeave: false },
    { employeeId: 'ZeAI104', employeeName: 'Sachin L', position: 'Human Resource', role: 'admin', canApproveLeave: true },
    { employeeId: 'ZeAI107', employeeName: 'Uday kiran M', position: 'Tech Trainee', role: 'employee', canApproveLeave: false },
    { employeeId: 'ZeAI108', employeeName: 'Hariprasad B', position: 'Tech Trainee', role: 'employee', canApproveLeave: false },
    { employeeId: 'ZeAI110', employeeName: 'Karthick K', position: 'Tech Trainee', role: 'employee', canApproveLeave: false },
    { employeeId: 'ZeAI111', employeeName: 'Vishal G', position: 'UXD', role: 'employee', canApproveLeave: false },
    { employeeId: 'ZeAI112', employeeName: 'Hemeswari D', position: 'Tech Trainee', role: 'employee', canApproveLeave: false },
  ];

  await Employee.deleteMany({});
  await Employee.insertMany(list);
  console.log('Seed complete');
  process.exit(0);
}).catch(err => { console.error(err); process.exit(1); });
