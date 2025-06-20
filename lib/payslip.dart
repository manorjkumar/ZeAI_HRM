import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'notification.dart';
import 'emp_payroll.dart';

void main() => runApp(ZeAIApp());

class ZeAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PayslipScreen(),
    );
  }
}

class PayslipScreen extends StatelessWidget {
  void _downloadPayslip() {
    print("Payslip downloaded to Google Drive (simulated)");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111427),
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar with full height
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
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
                  Expanded(
                    child: ListView(
                      children: [
                        _sidebarTile(Icons.dashboard, 'Dashboard', context, const EmployeeDashboard()),
                        _sidebarTile(Icons.calendar_month, 'Leave Management', context, const LeaveManagement()),
                        _sidebarTile(Icons.payments, 'Payroll Management', context, EmpPayroll()),
                        _sidebarTile(Icons.how_to_reg, 'Attendance System', context, null),
                        _sidebarTile(Icons.analytics, 'Reports & Analytics', context, ReportsAnalyticsPage()),
                        _sidebarTile(Icons.people, 'Employee Directory', context, EmployeeDirectoryApp()),
                        _sidebarTile(Icons.notifications, 'Notifications', context, NotificationsPage()),
                        _sidebarTile(Icons.person, 'Employee Profile', context, EmployeeProfilePage()),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content with header and body
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Container(
                                width: 505,
                                height: 49,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('Pay slip for April 2025',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  _infoRow('Name', 'Anitha', 'Employee ID', '234457'),
                                  const Divider(),
                                  _infoRow('Designation', 'Python Developer', 'Bank Name', 'ABC Bank'),
                                  const Divider(),
                                  _infoRow('Department', 'Tech', 'A/C NO', '100033347868'),
                                  const Divider(),
                                  _infoRow('Location', 'Chennai', 'LOP', '0.0'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 219,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _header('Earnings'),
                                        _payRow('Basic Salary', '₹25200'),
                                        _payRow('House Rent Allowance', '₹9408'),
                                        _payRow('Conveyance Allowance', '₹1679'),
                                        _payRow('Medical Allowance', '₹2580'),
                                        _payRow('Special Allowance', '₹19800'),
                                        _payRow('Gross Salary', '₹57885'),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.black),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _header('Deductions'),
                                        _payRow('EPF', '₹1800'),
                                        _payRow('Health Insurance', '₹500'),
                                        _payRow('Professional Tax', '₹200'),
                                        _payRow('Total Deductions', '₹2500'),
                                        _payRow('Net Pay', '₹53608', isBold: true),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _button(Icons.picture_as_pdf, 'Payslips', Colors.blueGrey, _downloadPayslip),
                                _outlinedButton(Icons.download, 'Download', _downloadPayslip),
                                _filledButton('Send'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              SizedBox(width: 30),
              Image(image: AssetImage('assets/logo_z.png'), height: 30),
              SizedBox(width: 450),
              Image(image: AssetImage('assets/logo_zeai.png'), height: 250),
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

  Widget _infoRow(String label1, String value1, String label2, String value2) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text('$label1: $value1', style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('$label2: $value2', style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _header(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade300,
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
    );
  }

  Widget _payRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
          Expanded(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  Widget _button(IconData icon, String text, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 41,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _outlinedButton(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 66,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            Text(text, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _filledButton(String text) {
    return Container(
      width: 80,
      height: 35,
      decoration: BoxDecoration(color: const Color(0xFF9F71F8), borderRadius: BorderRadius.circular(8)),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}