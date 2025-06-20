import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'leave_management.dart';
import 'notification.dart';
import 'emp_payroll.dart';

void main() => runApp(Performance());



class Performance extends StatelessWidget {
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
                          EmployeeProfilePage(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar
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
                    SizedBox(height: 32),
                    // Title & Flags
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
                            "Performance Review",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                flagDot(Colors.green),
                                Text(
                                  "  Green Flag",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                flagDot(Colors.yellow),
                                Text(
                                  "  Yellow Flag",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                flagDot(Colors.red),
                                Text(
                                  "  Red Flag",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 32),
                    reviewField("Communication"),
                    reviewField("Attitude"),
                    reviewField("Technical knowledge"),
                    reviewField("Business"),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text("Agree"),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Text("Disagree"),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Reviewed by",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Hari Baskaran",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  Widget reviewField(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: "Text field for $label",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget flagDot(Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
