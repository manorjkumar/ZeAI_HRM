import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sidebar.dart';
import 'employee_dashboard.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key}); // ✅ self-sufficient (no action)

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isLoginDisabled = false;
  bool isLogoutDisabled = true;
  bool isBreakActive = false;
  bool attendanceSubmitted = false;
  bool isLoginReasonSubmitted = false;
  bool isLogoutReasonSubmitted = false;


  String loginTime = "";
  String logoutTime = "";
  String breakStart = "";
  String breakEnd = "";
  String loginReason = "";
  String logoutReason = "";

  List<Map<String, String>> attendanceData = [];

  final loginReasonController = TextEditingController();
  final logoutReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLatestStatus();
    fetchAttendanceHistory();
  }

  String getCurrentTime() {
    return DateFormat('hh:mm:ss a').format(DateTime.now());
  }

  String getCurrentDate() {
    return DateFormat('dd-MM-yyyy').format(DateTime.now());
  }

  Future<void> fetchLatestStatus() async {
    final employeeId =
        Provider.of<UserProvider>(context, listen: false).employeeId ?? '';
    var url = Uri.parse(
        'https://zeai-hrm-1.onrender.com/attendance/attendance/status/$employeeId');

    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final todayDate = getCurrentDate();
        final recordDate = data['date'] ?? "";

        if (recordDate != todayDate) {
          setState(() {
            loginTime = "";
            logoutTime = "";
            isBreakActive = false;
            isLoginDisabled = false;
            isLogoutDisabled = true;
            attendanceSubmitted = false;
          });
          return;
        }

       setState(() {
        loginTime = data['loginTime'] ?? "";
        logoutTime = data['logoutTime'] ?? "";
        loginReason = data['loginReason'] ?? "";
        logoutReason = data['logoutReason'] ?? "";
        loginReasonController.text = loginReason;
        logoutReasonController.text = logoutReason;
        // ✅ Lock fields if reasons already exist
         isLoginReasonSubmitted = loginReason.isNotEmpty && loginReason != "-";
         isLogoutReasonSubmitted = logoutReason.isNotEmpty && logoutReason != "-";
        isBreakActive = data['status'] == "Break";
        isLoginDisabled =
        data['status'] == "Login" || data['status'] == "Break";
        isLogoutDisabled =
          data['status'] == "Logout" || data['status'] == "None";
        attendanceSubmitted = data['status'] != "None";
        });

      }
    } catch (e) {
      print('❌ Error fetching status: $e');
    }
  }

  // ✅ POST: Save new login
  Future<void> postAttendanceData() async {
    final employeeId =
        Provider.of<UserProvider>(context, listen: false).employeeId ?? '';
    var url =
        Uri.parse('https://zeai-hrm-1.onrender.com/attendance/attendance/mark/$employeeId');

    var body = {
      'date': getCurrentDate(),
      'loginTime': loginTime,
      'breakTime': (breakStart.isNotEmpty && breakEnd.isNotEmpty)
          ? "$breakStart to $breakEnd"
          : "-",
      'loginReason': loginReason,
      'logoutReason': logoutReason,
      'status': "Login",
    };

    try {
      var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        attendanceSubmitted = true;
        fetchAttendanceHistory();
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
  }

  // ✅ PUT: Update for logout or break
  Future<void> updateAttendanceData({bool isLogout = false}) async {
    final employeeId =
        Provider.of<UserProvider>(context, listen: false).employeeId ?? '';
    var url = Uri.parse(
        'https://zeai-hrm-1.onrender.com/attendance/attendance/update/$employeeId');

    var body = {
      'date': getCurrentDate(),
      'loginTime': loginTime,
      'breakTime': (breakStart.isNotEmpty && breakEnd.isNotEmpty)
          ? "$breakStart to $breakEnd"
          : "-",
      'loginReason': loginReason,
      'logoutReason': logoutReason,
      'status': isLogout ? "Logout" : "Login",
    };

    if (isLogout) {
      body['logoutTime'] = logoutTime;
    }

    try {
      var response = await http.put(
        url,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchAttendanceHistory();
      }
    } catch (e) {
      print('❌ Exception during update: $e');
    }
  }

  Future<void> fetchAttendanceHistory() async {
    try {
      final employeeId =
          Provider.of<UserProvider>(context, listen: false).employeeId ?? '';
      var url = Uri.parse(
          'https://zeai-hrm-1.onrender.com/attendance/attendance/history/$employeeId');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          attendanceData = data.take(5).map<Map<String, String>>((item) {
            return {
              'date': item['date'] ?? '',
              'status': item['status'] ?? '-',
              'break': item['breakTime'] ?? '-',
              'login': item['loginTime'] ?? '',
              'logout': item['logoutTime'] ?? '',
            };
          }).toList();
        });
      }
    } catch (e) {
      print('❌ Error fetching history: $e');
    }
  }

  // --- Dialogs ---
Future<bool> showLoginReasonDialog() async {
  // Store original value in case user cancels
  final originalReason = loginReasonController.text;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // ❌ cannot tap outside
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Reason for Early/Late Login"),
        content: TextField(
          controller: loginReasonController,
          decoration: const InputDecoration(hintText: "Enter reason"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (loginReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠ Please enter a reason before submitting."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              loginReason = loginReasonController.text.trim();
              isLoginReasonSubmitted = true;
              Navigator.of(context).pop(true); // ✅ Submit
            },
            child: const Text("Submit"),
          ),
          TextButton(
            onPressed: () {
              // ❌ Cancel → revert text field to original
              loginReasonController.text = originalReason;
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );

  return result ?? false; // true if submitted, false if cancelled
}


 Future<bool> showLogoutReasonDialog() async {
  final originalReason = logoutReasonController.text;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Reason for Early/Late Logout"),
        content: TextField(
          controller: logoutReasonController,
          decoration: const InputDecoration(hintText: "Enter reason"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (logoutReasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("⚠ Please enter a reason before submitting."),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              logoutReason = logoutReasonController.text.trim();
              isLogoutReasonSubmitted = true;
              Navigator.of(context).pop(true);
            },
            child: const Text("Submit"),
          ),
          TextButton(
            onPressed: () {
              // ❌ Cancel → revert text field to original
              logoutReasonController.text = originalReason;
              Navigator.of(context).pop(false);
            },
            child: const Text("Cancel"),
          ),
        ],
      );
    },
  );

  return result ?? false;
}


  void showAlreadyLoggedOutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Already Logged Out"),
        content: const Text("You have already logged off this day."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }




  // --- Handlers ---
  void handleLogin() async {
  if (logoutTime.isNotEmpty) {
    showAlreadyLoggedOutDialog();
    return;
  }

  DateTime now = DateTime.now();
  DateTime start = DateTime(now.year, now.month, now.day, 8, 55);
  DateTime end = DateTime(now.year, now.month, now.day, 9, 05);

  // Check if outside allowed login time → require reason
  if (now.isBefore(start) || now.isAfter(end)) {
    bool submitted = await showLoginReasonDialog();
    if (!submitted) return; // ❌ stop if user didn’t click Submit
  }

  String timeNow = getCurrentTime();
  setState(() {
    loginTime = timeNow;
    isLoginDisabled = true;
    isLogoutDisabled = false;
    loginReason = loginReasonController.text.trim();
  });

  await postAttendanceData();

  setState(() {
    loginReasonController.text = loginReason;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("✅ Logged in successfully!"),
      backgroundColor: Colors.green,
    ),
  );
}



  void handleBreak() {
    if (logoutTime.isNotEmpty) {
      showAlreadyLoggedOutDialog();
      return;
    }

    String timeNow = getCurrentTime();
    setState(() {
      if (!isBreakActive) {
        breakStart = timeNow;
        isBreakActive = true;
      } else {
        breakEnd = timeNow;
        isBreakActive = false;
        loginReason = loginReasonController.text.trim();
        logoutReason = logoutReasonController.text.trim();
        if (attendanceSubmitted) updateAttendanceData();
      }
    });
  }

 void handleLogout() async {
  if (logoutTime.isNotEmpty) {
    showAlreadyLoggedOutDialog();
    return;
  }

  DateTime now = DateTime.now();
  DateTime logoutStart = DateTime(now.year, now.month, now.day, 17, 00);
  DateTime logoutEnd = DateTime(now.year, now.month, now.day, 17, 10);

  // Check if outside normal logout time → ask for reason
  if (now.isBefore(logoutStart) || now.isAfter(logoutEnd)) {
    bool reasonSubmitted = await showLogoutReasonDialog();
    if (!reasonSubmitted) return; // ❌ Stop if not submitted

  }

  String timeNow = getCurrentTime();
  setState(() {
    logoutTime = timeNow;
    isLogoutDisabled = true;
    isLoginDisabled = true;
    isBreakActive = false;
    loginReason = loginReasonController.text.trim();
    logoutReason = logoutReasonController.text.trim();
  });

  if (attendanceSubmitted) {
    await updateAttendanceData(isLogout: true);
  } else {
    await postAttendanceData();
    await updateAttendanceData(isLogout: true);
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("✅ Logged out successfully!"),
      backgroundColor: Colors.green,
    ),
  );
}


  @override
  void dispose() {
    loginReasonController.dispose();
    logoutReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Attendance Logs',
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: !isLoginDisabled ? handleLogin : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("LOGIN"),
                ),
                ElevatedButton(
                  onPressed: isLoginDisabled ? handleBreak : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  child: Text(isBreakActive ? "Break Off" : "Breakin"),
                ),
                ElevatedButton(
                  onPressed: !isLogoutDisabled ? handleLogout : null,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text("LOGOUT"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 300,
                  height: 90, 
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                child: IgnorePointer(
                 child: TextField(
                  controller: loginReasonController,
                    readOnly: true,
                   maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                      labelText: "Reason for Early/Late Login 👋",
                       border: OutlineInputBorder(),
                            ),
                     ),
                     ),
                     ),
                Container(
                  width: 300,
                  height: 90,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IgnorePointer(
                    child: TextField(
                      controller: logoutReasonController,
                        readOnly: true,
                        maxLines: null,
                         expands: true,
                         textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                         labelText: "Reason for Early/Late Logout 👋",
                         border: OutlineInputBorder(),
                       ),
                   ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Last Five Days Attendance",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 30,
                headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.grey.shade700),
                dataRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.grey.shade100),
                columns: const [
                  DataColumn(
                      label: Text('Date', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Status', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Break', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Login', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label:
                          Text('Logout', style: TextStyle(color: Colors.white))),
                ],
                rows: attendanceData.map((data) {
                  final status = data['status'] ?? '-';
                  return DataRow(
                    cells: [
                      DataCell(Text(data['date'] ?? '')),
                      DataCell(Text(
                        status,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: status == "Login" ? Colors.green : Colors.red,
                        ),
                      )),
                      DataCell(Text(data['break'] ?? '')),
                      DataCell(Text(data['login'] ?? '')),
                      DataCell(Text(data['logout'] ?? '')),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Back to Dashboard",
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}