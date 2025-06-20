import 'package:flutter/material.dart';
import 'apply_leave.dart';
import 'leave_history_cancelled.dart';
import 'employee_dashboard.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';

class LeaveManagement extends StatelessWidget {
  const LeaveManagement({super.key});

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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leave History',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLeaveTable(),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => _buildEditCancelDialog(context),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancel/Edit Pending Leave request',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
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
          sidebarItem(context, Icons.dashboard, 'Dashboard', const EmployeeDashboard()),
sidebarItem(context, Icons.calendar_today, 'Leave Management',  LeaveManagement()),
sidebarItem(context, Icons.payments, 'Payroll Management',  EmpPayroll()),
sidebarItem(context, Icons.how_to_reg, 'Attendance system', null),
sidebarItem(context, Icons.analytics, 'Reports & Analytics', ReportsAnalyticsPage()),
sidebarItem(context, Icons.people, 'Employee Directory', EmployeeDirectoryApp()),
sidebarItem(context, Icons.notifications, 'Notifications', NotificationsPage()),
sidebarItem(context, Icons.person, 'Employee profile', EmployeeProfilePage()),

        ],
      ),
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
          SizedBox(
            width: 250,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search here..',
                hintStyle: TextStyle(color: Colors.white70),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.black26,
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

  // Leave History Table
  Widget _buildLeaveTable() {
    return Container(
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
            DataCell(Text('Pending')),
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
    );
  }

  // Edit/Cancel Dialog
  Widget _buildEditCancelDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white70,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("Edit or Cancel Leave"),
      content: const Text("Do you want to edit or cancel this leave request?"),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApplyLeave()),
            );
          },
          icon: const Icon(Icons.edit, color: Colors.purple),
          label: const Text('Edit', style: TextStyle(color: Colors.purple)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.purple),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LeaveHistoryCancelled()),
            );
          },
          icon: const Icon(Icons.cancel, color: Colors.purple),
          label: const Text('Cancel', style: TextStyle(color: Colors.purple)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            side: const BorderSide(color: Colors.purple),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Close", style: TextStyle(color: Colors.purple)),
        )
      ],
    );
  }

  // Sidebar item widget
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

}