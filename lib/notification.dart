import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';

void main() => runApp(NotificationsPage());



class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final Color darkBlue = Color(0xFF0E0E2C);
  final Color sidebarGray = Color(0xFFE9E9E9);

  String selectedMonth = "January";
  final List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December",
  ];

  final List<Map<String, String>> leaves = [
    {"message": "Your leave request has been approved", "time": "1mo ago"},
    {"message": "Your leave request is in pending", "time": "1mo ago"},
  ];

  final List<Map<String, String>> payslips = [
    {"message": "You have received a new payslip", "time": "2mo ago"},
    {"message": "You will receive a payslip on Monday", "time": "2mo ago"},
  ];

  final List<Map<String, String>> events = [
    {"message": "Company event on next June", "time": "2mo ago"},
    {"message": "Managing Director’s birthday on August", "time": "3mo ago"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Row(
        children: [
          // Sidebar
           Container(
            width: 200,
            color: sidebarGray,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 30, backgroundColor: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        "Anitha",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text("Employee\nTech", textAlign: TextAlign.center),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      sidebarItem(
                        context,
                        Icons.dashboard,
                        "Dashboard",
                        const EmployeeDashboard(),
                      ),
                      sidebarItem(
                        context,
                        Icons.calendar_today,
                        "Leave Management",
                        LeaveManagement(), // Not yet implemented
                      ),
                      sidebarItem(
                        context,
                        Icons.money,
                        "Payroll Management",
                        EmpPayroll(),
                      ),
                      sidebarItem(
                        context,
                        Icons.fingerprint,
                        "Attendance system",
                         null,
                      ),
                      sidebarItem(
                        context,
                        Icons.bar_chart,
                        "Reports & Analytics",
                          ReportsAnalyticsPage(),
                      ),
                      sidebarItem(
                        context,
                        Icons.group,
                        "Employee Directory",
                          EmployeeDirectoryApp(),
                      ),
                      sidebarItem(
                        context,
                        Icons.notifications,
                        "Notifications",
                         NotificationsPage(),
                      ),
                      sidebarItem(
                        context,
                        Icons.person_2_outlined,
                        "Employee profile",
                        EmployeeProfilePage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Notifications",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedMonth,
                            icon: Icon(Icons.arrow_drop_down),
                            items:
                                months
                                    .map(
                                      (month) => DropdownMenuItem(
                                        child: Text(month),
                                        value: month,
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedMonth = value!;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  notificationCategory("Leaves", leaves),
                  notificationCategory("Payslips", payslips),
                  notificationCategory("Upcoming Events", events),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget sidebarItem(
  BuildContext context,
  IconData icon,
  String title,
  Widget? page, // Nullable
) {
  return ListTile(
    leading: Icon(icon, color: Colors.black),
    title: Text(title, style: TextStyle(fontSize: 14)),
    onTap: () {
      if (page != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title page is under construction')),
        );
      }
    },
  );
}

  Widget notificationCategory(
    String title,
    List<Map<String, String>> notifications,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 16, bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ...notifications
            .map((item) => notificationCard(item["message"]!, item["time"]!))
            .toList(),
      ],
    );
  }

  Widget notificationCard(String message, String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(2, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(message, style: TextStyle(fontSize: 14))),
          Row(
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Mark as read", style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExamplePage extends StatelessWidget {
  final String title;
  const ExamplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Color(0xFF0E0E2C)),
      body: Center(child: Text('$title Page', style: TextStyle(fontSize: 24))),
    );
  }
}
