const express = require("express");
const Attendance = require("../models/attendance");
const router = express.Router();

// 🔹 Utility: Always return DD-MM-YYYY
function formatDateToDDMMYYYY(dateInput) {
  if (!dateInput) {
    const today = new Date();
    const day = String(today.getDate()).padStart(2, "0");
    const month = String(today.getMonth() + 1).padStart(2, "0");
    const year = today.getFullYear();
    return `${day}-${month}-${year}`;
  }

  if (typeof dateInput === "string" && /^\d{2}-\d{2}-\d{4}$/.test(dateInput)) {
    return dateInput;
  }

  const d = new Date(dateInput);
  const day = String(d.getDate()).padStart(2, "0");
  const month = String(d.getMonth() + 1).padStart(2, "0");
  const year = d.getFullYear();
  return `${day}-${month}-${year}`;
}

// ✅ POST: Save attendance (Login)
router.post("/attendance/mark/:employeeId", async (req, res) => {
  const { employeeId } = req.params;
  let { date, loginTime, logoutTime, breakTime, loginReason, logoutReason, status } = req.body;

  try {
    date = formatDateToDDMMYYYY(date);

    let existing = await Attendance.findOne({ employeeId, date });

    if (existing) {
      if (existing.status === "Login") {
        return res.status(400).json({ message: "❌ Already Logged In" });
      }

      existing.status = "Login";
      existing.loginTime = loginTime;
      existing.logoutTime = ""; // reset until actual logout
      existing.loginReason = loginReason || existing.loginReason;

      await existing.save();
      return res.status(200).json({ 
        message: "✅ Attendance updated to Login", 
        attendance: existing 
      });
    }

    // ✅ New record
    const newAttendance = new Attendance({
      employeeId,
      date,
      loginTime,
      logoutTime: "", // keep empty, not "Not logged out yet"
      breakTime: breakTime || "-",
      loginReason,
      logoutReason,
      status: status || "Login",
    });

    await newAttendance.save();
    res.status(201).json({ message: "✅ Attendance saved successfully", attendance: newAttendance });

  } catch (error) {
    console.error("❌ Error saving attendance:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

// ✅ PUT: Update attendance (Logout / Break) with total 60-min limit
router.put("/attendance/update/:employeeId", async (req, res) => {
  const { employeeId } = req.params;
  let { date, logoutTime, breakTime, loginReason, logoutReason, status } = req.body;

  try {
    date = formatDateToDDMMYYYY(date || undefined);

    const todayRecord = await Attendance.findOne({ employeeId, date });
    if (!todayRecord) {
      return res.status(404).json({ message: "❌ Attendance not found" });
    }

    let breakArray = [];

    // ✅ Existing breaks
    if (todayRecord.breakTime && todayRecord.breakTime !== "-") {
      breakArray = todayRecord.breakTime
        .split(",")
        .map((b) => b.trim().split(" (")[0]); // remove durations
    }

    // ✅ Add new break if provided
    if (breakTime && breakTime.includes("to")) {
      breakArray.push(breakTime.trim());
    }

    // ✅ Safe time parsing
    const parseTime = (timeStr) => {
      if (!timeStr) return 0;
      timeStr = timeStr.trim();

      // Extract time and modifier (AM/PM)
      const parts = timeStr.split(" ");
      const timePart = parts[0];
      const modifier = parts[1] ? parts[1].toUpperCase() : null;

      // Handle hh:mm:ss or hh:mm formats
      const [h, m, s] = timePart.split(":").map(Number);
      let hours = h || 0;
      let minutes = m || 0;

      if (modifier === "PM" && hours !== 12) hours += 12;
      if (modifier === "AM" && hours === 12) hours = 0;

      return hours * 60 + minutes; // convert to minutes
    };

    // ✅ Calculate total break duration
    let totalMinutes = 0;
    const formattedBreaks = breakArray.map((b) => {
      const [start, end] = b.split("to").map((t) => t.trim());
      const startMinutes = parseTime(start);
      const endMinutes = parseTime(end);

      const diff = Math.max(endMinutes - startMinutes, 0);
      totalMinutes += diff;

      return `${start} to ${end} (${diff} mins)`;
    });

    // ✅ Check total break limit
    if (totalMinutes > 60) {
      return res.status(400).json({
        message: "⚠ Total break time exceeded 60 minutes.",
        totalMinutes,
        limitReached: true,
      });
    }

    const finalBreakTime =
      formattedBreaks.join(", ") + ` (Total: ${totalMinutes} mins)`;

    // ✅ Prepare update fields
    let updateFields = {
      breakTime: finalBreakTime,
      ...(loginReason && { loginReason }),
      ...(logoutReason && { logoutReason }),
    };

    // ✅ Update logout or break status
    if (logoutTime) {
      updateFields.logoutTime = logoutTime;
      updateFields.status = "Logout";
    } else if (status) {
      // ✅ Preserve Break status properly
      updateFields.status = status === "Break" ? "Break" : status;
    }

    const updatedAttendance = await Attendance.findOneAndUpdate(
      { employeeId, date },
      { $set: updateFields },
      { new: true }
    );

    res.status(200).json({
      message: "✅ Attendance updated successfully",
      updatedAttendance,
      totalMinutes,
      limitReached: false,
    });
  } catch (error) {
    console.error("❌ Error updating attendance:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

// ✅ GET: Last 5 records
router.get("/attendance/history/:employeeId", async (req, res) => {
  try {
    const { employeeId } = req.params;
    const history = await Attendance.find({ employeeId })
      .sort({ createdAt: -1 })
      .limit(5);

    res.status(200).json(history);
  } catch (error) {
    console.error("❌ Error fetching history:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

// ✅ FIXED: Get today's status
router.get("/attendance/status/:employeeId", async (req, res) => {
  try {
    const { employeeId } = req.params;
    const todayDate = formatDateToDDMMYYYY();

    const todayRecord = await Attendance.findOne({ employeeId, date: todayDate });

    if (!todayRecord) {
      return res.json({ status: "None", date: todayDate });
    }

    res.json({
      status: todayRecord.status,
      loginTime: todayRecord.loginTime,
      logoutTime: todayRecord.logoutTime,
      loginReason: todayRecord.loginReason,
      logoutReason: todayRecord.logoutReason,
      breakTime: todayRecord.breakTime,
      date: todayRecord.date,
    });

  } catch (error) {
    console.error("❌ Error fetching status:", error);
    res.status(500).json({ message: "Server Error" });
  }
});

module.exports = router;