import 'package:flutter/material.dart';
import 'leave_management.dart';
import 'employee_dashboard.dart';
import 'payslip.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';

class EmpPayroll extends StatefulWidget {
  const EmpPayroll({super.key});

  @override
  State<EmpPayroll> createState() => _EmpPayrollState();
}

class _EmpPayrollState extends State<EmpPayroll> {
  String? selectedYear;
  List<bool> checkedList = List<bool>.filled(12, false);

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1020),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 220,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: ListView(
              children: [
                const SizedBox(height: 40),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/png-profile.png'),
                  ),
                  title: const Text(
                    'Anitha',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Employee Tech'),
                  trailing: const Icon(Icons.more_vert),
                ),
                const Divider(),
                _sidebarTile(
                  Icons.dashboard,
                  'Dashboard',
                  context,
                  const EmployeeDashboard(),
                ),
                _sidebarTile(
                  Icons.calendar_month,
                  'Leave Management',
                  context,
                  const LeaveManagement(),
                ),
                _sidebarTile(
                  Icons.payments,
                  'Payroll Management',
                  context,
                   EmpPayroll(),
                ),
                _sidebarTile(
                  Icons.how_to_reg,
                  'Attendance System',
                  context,
                  null,
                ),
                _sidebarTile(
                  Icons.analytics,
                  'Reports & Analytics',
                  context,
                  ReportsAnalyticsPage(),
                ),
                _sidebarTile(Icons.people, 'Employee Directory', context, EmployeeDirectoryApp()),
                _sidebarTile(
                  Icons.notifications,
                  'Notifications',
                  context,
                  NotificationsPage(),
                ),
                _sidebarTile(Icons.person, 'Employee Profile', context,  EmployeeProfilePage()),
              ],
            ),
          ),

          // Right Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(context), // <<== Your custom header
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Top buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C314A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ZeAIApp(),
                                      ),
                                    );
                                  },
                                  child: const Text('Payslip'),
                                ),

                                SizedBox(
                                  width: 180,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: DropdownButton<String>(
                                      value: selectedYear,
                                      hint: const Text(
                                        'Select Year >',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                      dropdownColor: Colors.white,
                                      icon: const Icon(Icons.arrow_drop_up),
                                      isExpanded: true,
                                      underline: Container(),
                                      items: [
                                        for (
                                          int year = 2000;
                                          year <= DateTime.now().year;
                                          year++
                                        )
                                          DropdownMenuItem(
                                            value: year.toString(),
                                            child: Text(
                                              year.toString(),
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          selectedYear = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C314A),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text('Download all'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Months',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'View/Download',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Check Box',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const Divider(thickness: 2, color: Colors.white),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 12,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            months[index],
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.remove_red_eye,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.download,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Checkbox(
                                            value: checkedList[index],
                                            onChanged: (bool? value) {
                                              setState(() {
                                                checkedList[index] = value!;
                                              });
                                            },
                                            checkColor: Colors.black,
                                            fillColor:
                                                MaterialStateProperty.all(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sidebar tile
  Widget _sidebarTile(
    IconData icon,
    String title,
    BuildContext context,
    Widget? page,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
    );
  }

  // ⬇️ Custom Header Widget as requested
  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 80,
      color: const Color(0xFF0F1020),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: const [
              Icon(Icons.chevron_left, color: Colors.white),
              SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.white),
              SizedBox(width: 16),
              Image(image: AssetImage('assets/logo_z.png'), height: 30),
              SizedBox(width: 446),
              Image(image: AssetImage('assets/logo_zeai.png'), height: 80),
            ],
          ),
          SizedBox(
            width: 250,
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search here..',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF2D2F41),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
