import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'reports.dart';
import 'notification.dart';


void main() => runApp(EmployeeDirectoryApp());

class EmployeeDirectoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Directory',
      debugShowCheckedModeBanner: false,
      home: EmployeeDirectoryPage(),
    );
  }
}

class EmployeeDirectoryPage extends StatefulWidget {
  @override
  _EmployeeDirectoryPageState createState() => _EmployeeDirectoryPageState();
}

class _EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  final Color darkBlue = Color(0xFF0E0E2C);
  final Color sidebarGray = Color(0xFFE9E9E9);

  final List<Map<String, String>> employees = [
    {'name': 'Anitha', 'role': 'UI Developer'},
    {'name': 'Uday', 'role': 'UI Developer'},
    {'name': 'Sanjay', 'role': 'UI Developer'},
    {'name': 'Harika', 'role': 'UI Developer'},
    {'name': 'Bhanu', 'role': 'UI Developer'},
    {'name': 'Sunil', 'role': 'UI Developer'},
    {'name': 'Anil', 'role': 'UI Developer'},
    {'name': 'Balu', 'role': 'UI Developer'},
  ];

  String selectedPage = 'Directory';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 160,
            color: sidebarGray,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    children: [
                      CircleAvatar(radius: 24, backgroundColor: Colors.grey),
                      SizedBox(height: 6),
                      Text(
                        "Anitha",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Employee\nTech",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10),
                      ),
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
                          null,
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
              child: Column(
                children: [
                  // Header Row
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
                      searchBox("Search here...", width: 180),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Sub-header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      searchBox("Search employee...", width: 180),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          "Employee list",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Dynamic content
                  Expanded(child: buildPageContent()),
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


  Widget searchBox(String hint, {double width = 180}) {
    return Container(
      width: width,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white, size: 18),
          SizedBox(width: 6),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPageContent() {
    if (selectedPage == 'Directory') {
      return GridView.builder(
        itemCount: employees.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final emp = employees[index];
          return employeeCard(emp['name']!, emp['role']!);
        },
      );
    } else {
      return Center(
        child: Text(
          '$selectedPage Page',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }
  }

  Widget employeeCard(String name, String role) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(Icons.person, size: 30),
            SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(role, style: TextStyle(color: Colors.black87, fontSize: 10)),
            Spacer(),
            Wrap(
              spacing: 4,
              children: [
                Icon(Icons.email, size: 12),
                Icon(Icons.message, size: 12),
                Icon(Icons.phone, size: 12),
                Icon(Icons.video_call, size: 12),
                Icon(Icons.info, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
