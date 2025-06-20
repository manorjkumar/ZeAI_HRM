import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'leave_history_cancelled.dart';
import 'login.dart';
import 'emp_payroll.dart';
import 'employee_profile.dart';
import 'employee_directory.dart';
import 'reports.dart';
import 'performance.dart';
import 'notification.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginApp(),
        '/employee_dashboard' : (context) => const EmployeeDashboard(),
        '/leave-management': (context) => const LeaveManagement(),
        '/leave-history-cancelled': (context) => const LeaveHistoryCancelled(),
        '/emp_payroll' : (context) => const EmpPayroll(),
        '/employee_profile' :(context) => EmployeeProfilePage(),
        './employee_directory' :(context) => EmployeeDirectoryApp(),
        './reports' :(context) => ReportsAnalyticsPage(),
        './performance' :(context) => Performance(),
        './notification' :(context) => NotificationsPage(),
      },
    );
  }
}
