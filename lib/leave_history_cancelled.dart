import 'package:flutter/material.dart';
import 'leave_management.dart';
import 'employee_dashboard.dart';

class LeaveHistoryCancelled extends StatelessWidget {
  const LeaveHistoryCancelled({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1020),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 30),
                const Text(
                  'Leave History (Cancelled)',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Leave Type')),
                        DataColumn(label: Text('From')),
                        DataColumn(label: Text('To')),
                        DataColumn(label: Text('Status')),
                      ],
                      rows: const [
                        DataRow(cells: [
                          DataCell(Text('Sad leave')),
                          DataCell(Text('25/5/2025')),
                          DataCell(Text('27/5/2025')),
                          DataCell(Text('Cancelled')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Casual leave')),
                          DataCell(Text('12/2/2025')),
                          DataCell(Text('13/2/2025')),
                          DataCell(Text('Rejected')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Sick Leave')),
                          DataCell(Text('07/12/2024')),
                          DataCell(Text('8/12/2024')),
                          DataCell(Text('Approved')),
                        ]),
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

  // Sidebar
  Widget _buildSidebar(BuildContext context) {
    return Container(
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
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            title: const Text('Anitha', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Employee Tech'),
            trailing: const Icon(Icons.more_vert),
          ),
          const Divider(),
          _sidebarItem(context, Icons.dashboard, 'Dashboard', const EmployeeDashboard()),
          _sidebarItem(context, Icons.calendar_today, 'Leave Management', const LeaveManagement()),
          _sidebarItem(context, Icons.payments, 'Payroll Management', null),
          _sidebarItem(context, Icons.how_to_reg, 'Attendance system', null),
          _sidebarItem(context, Icons.analytics, 'Reports & Analytics', null),
          _sidebarItem(context, Icons.people, 'Employee Directory', null),
          _sidebarItem(context, Icons.notifications, 'Notifications', null),
          _sidebarItem(context, Icons.person, 'Employee Profile', null),
        ],
      ),
    );
  }

  // Sidebar Item Builder
  Widget _sidebarItem(BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title page not implemented')),
          );
        }
      },
    );
  }

  // Header
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
              Icon(Icons.chevron_right, color: Colors.white),
              SizedBox(width: 30),
              Image(image: AssetImage('assets/logo_z.png'), height: 30),
              SizedBox(width: 446),
              Image(image: AssetImage('assets/logo_zeai.png'), height: 300),
            ],
          ),
          const SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here...',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
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
