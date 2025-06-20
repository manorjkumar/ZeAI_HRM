import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_management.dart';
import 'leave_history_cancelled.dart';

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
        '/': (context) => const EmployeeDashboard(),
        '/leave-management': (context) => const LeaveManagement(),
        '/leave-history-cancelled': (context) => const LeaveHistoryCancelled(),
      },
    );
  }
}
