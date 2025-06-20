import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'leave_management.dart';
import 'apply_leave.dart';
import 'todo_planner.dart';
import 'company_events.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

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
                  title: const Text('Anitha', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Employee Tech'),
                  trailing: const Icon(Icons.more_vert),
                ),
                const Divider(),
                _sidebarTile(Icons.dashboard, 'Dashboard', context, const EmployeeDashboard()),
                _sidebarTile(Icons.calendar_month, 'Leave Management', context, const LeaveManagement()),
                _sidebarTile(Icons.payments, 'Payroll Management', context, const  EmpPayroll()),
                _sidebarTile(Icons.how_to_reg, 'Attendance System', context, null),
                _sidebarTile(Icons.analytics, 'Reports & Analytics', context, ReportsAnalyticsPage()),
                _sidebarTile(Icons.people, 'Employee Directory', context, EmployeeDirectoryApp()),
                _sidebarTile(Icons.notifications, 'Notifications', context,  NotificationsPage()),
                _sidebarTile(Icons.person, 'Employee Profile', context,  EmployeeProfilePage()),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Welcome, Anitha!',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 250),
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 10,
                    children: [
                      _quickActionButton(
                        'Apply Leave',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ApplyLeave()),
                          );
                        },
                      ),
                      _quickActionButton('Download Payslip'),
                      _quickActionButton('Mark Attendance'),
                      _quickActionButton('Notifications Preview'),
                      _quickActionButton('Company Events', onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const CompanyEventsScreen()),
  );
}),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildClockCard(context),
                const SizedBox(height: 20),
                _buildLeaveCards(),
                const SizedBox(height: 20),
                _buildBirthdayBanner(),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Sidebar tile
  static Widget _sidebarTile(IconData icon, String title, BuildContext context, Widget? page) {
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

  // Header bar
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

  // Quick action buttons
  static Widget _quickActionButton(String title, {VoidCallback? onPressed}) {
    return ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 214, 226, 231),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(title),
    );
  }

  // Clock and To-Do Card
  Widget _buildClockCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 180,
            height: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2235),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb, size: 30, color: Colors.white),
                const SizedBox(height: 8),
                Text(TimeOfDay.now().format(context), style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Today: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ToDoPlanner()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('To do List', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Leave cards with circular percent
  Widget _buildLeaveCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          leaveCard('Casual leave', 10, 12),
          leaveCard('Sick leave', 9, 12),
          leaveCard('Sad leave', 5, 12),
        ],
      ),
    );
  }

  // Leave Card Widget
  Widget leaveCard(String type, int used, int total) {
    final remaining = total - used;
    final percent = used / total;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2235),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 30.0,
            lineWidth: 6.0,
            percent: percent,
            center: Text("$used/$total", style: const TextStyle(color: Colors.white)),
            progressColor: const Color.fromARGB(255, 127, 23, 145),
            backgroundColor: Colors.white24,
          ),
          const SizedBox(height: 8),
          Text(
            type,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
          Text("Remaining: $remaining", style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  // Birthday Banner
  Widget _buildBirthdayBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.pink[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: const [
            Text(
              'Happy Birthday 🎂',
              style: TextStyle(color: Colors.deepOrange, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text('May all your wishes come true'),
            SizedBox(height: 10),
            Image(image: AssetImage('assets/cake.png'), height: 80),
          ],
        ),
      ),
    );
  }
}
