import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'emp_payroll.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';
void main() => runApp(EmployeeProfilePage());

class EmployeeProfilePage extends StatelessWidget {
  final Color darkBlue = Color(0xFF0E0E2C);
  final Color sidebarGray = Color(0xFFE9E9E9);

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
                        null,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/logo_z.png', height: 40, width: 40),
                      const Spacer(),
                      Image.asset(
                        'assets/logo_zeai.png',
                        height: 100,
                        width: 100,
                      ),
                      const Spacer(),
                      Container(
                        width: 250,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search here..",
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Employee profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.person, size: 48, color: Colors.white),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Anitha",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "UI Developer",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            infoRow(Icons.email, "anitha.choudhary@zeai.com"),
                            infoRow(Icons.phone, "9825755501", bold: true),
                            infoRow(Icons.calendar_today, "02-Dec-1999"),
                            infoRow(
                              Icons.linked_camera,
                              "Connect with Linkedin",
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            plainInfo("Father name: xxxxx"),
                            plainInfo("Father occupation: xxxxx"),
                            plainInfo("Mother name: xxxxx"),
                            plainInfo("Siblings details: xxxxx"),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white54, height: 32),
                  plainInfo("Aadhar no: xxxxxxxxxxxxxxx"),
                  plainInfo(
                    "Address: H.no-xx,xxx(V),xxx(M),xxx(D),xxx(state),xxx(pincode)",
                  ),
                  SizedBox(height: 8),
                  Text("Marks sheet:", style: TextStyle(color: Colors.white)),
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


  Widget infoRow(IconData icon, String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget plainInfo(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(text, style: TextStyle(color: Colors.white)),
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
