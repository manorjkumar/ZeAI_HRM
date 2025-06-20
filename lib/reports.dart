import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'performance.dart';
import 'leave_management.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'notification.dart';

void main() => runApp(ReportsAnalyticsPage());

class ReportsAnalyticsPage extends StatelessWidget {
  final Color darkBlue = Color(0xFF0E0E2C);
  final Color lightGrey = Colors.white70;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: const Color(0xFFE9E9E9), // sidebarItem gray
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
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
                          null,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 10),
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
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.white54),
                            SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search here..',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Reports & Analytics',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      reportCard(
                        'Overall Attendance',
                        '87%',
                        'Leave - 13%\nPresent - 87%',
                      ),
                      reportCard(
                        'Overall Leave',
                        '13%',
                        'Leave - 13%\nPresent - 87%',
                      ),
                      reportCard(
                        'Overall Work progress',
                        '82%',
                        'Working - 82%\nPending - 18%',
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Performance Review',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  SizedBox(height: 8),
                  DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Colors.blueGrey.shade700,
                    ),
                    columns: [
                      DataColumn(
                        label: Text(
                          'Reviewed by',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Month of review',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Flag',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'More',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Status',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                    rows: [
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'Hari baskaran',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                          DataCell(
                            Text(
                              'March - 2025',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                          DataCell(
                            Text(
                              'Red Flag',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                          DataCell(
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                         Performance(),
                                  ),
                                );
                              },
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration
                                      .underline, // Optional: looks like a link
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text('Agree', style: TextStyle(color: lightGrey)),
                          ),
                        ],
                      ),
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              'Hari baskaran',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                          DataCell(
                            Text(
                              'April - 2025',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                          DataCell(
                            Text(
                              'Green Flag',
                              style: TextStyle(color: lightGrey),
                            ),
                          ),
                            DataCell(
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Performance(),
                                  ),
                                );
                              },
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration
                                      .underline, // Optional: looks like a link
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text('Agree', style: TextStyle(color: lightGrey)),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Widget reportCard(String title, String percent, String details) {
    return Container(
      width: 110,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            percent,
            style: TextStyle(
              color: Colors.purpleAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          SizedBox(height: 4),
          Text(
            details,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 10),
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


class PerformanceReviewPage extends StatelessWidget {
  const PerformanceReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Review')),
      body: const Center(child: Text('Details')),
    );
  }
}
