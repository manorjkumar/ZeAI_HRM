import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';

class CompanyEventsScreen extends StatelessWidget {
  const CompanyEventsScreen({super.key});

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
                _sidebarTile(Icons.payments, 'Payroll Management', context, Placeholder()),
                _sidebarTile(Icons.how_to_reg, 'Attendance System', context, Placeholder()),
                _sidebarTile(Icons.analytics, 'Reports & Analytics', context, Placeholder()),
                _sidebarTile(Icons.people, 'Employee Directory', context, Placeholder()),
                _sidebarTile(Icons.notifications, 'Notifications', context, Placeholder()),
                _sidebarTile(Icons.person, 'Employee Profile', context, Placeholder()),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Events',
                      style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ListView(
                      children: const [
                        EventTile(day: '20', weekday: 'Mon', title: 'Development planning', company: 'W3 Technologies', time: '12:02 PM'),
                        EventTile(day: '21', weekday: 'Wed', title: 'Development planning', company: 'W3 Technologies', time: '12:20 PM'),
                        EventTile(day: '24', weekday: 'Fri', title: 'Development planning', company: 'W3 Technologies', time: '12:30 PM'),
                        EventTile(day: '25', weekday: 'Tue', title: 'Development planning', company: 'W3 Technologies', time: '12:40 PM'),
                      ],
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

  static Widget _sidebarTile(IconData icon, String title, BuildContext context, Widget page) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
    );
  }

  Widget _buildHeader() {
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

class EventTile extends StatelessWidget {
  final String day;
  final String weekday;
  final String title;
  final String company;
  final String time;

  const EventTile({
    super.key,
    required this.day,
    required this.weekday,
    required this.title,
    required this.company,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2D2F41),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(weekday, style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(company, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
