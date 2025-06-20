
import 'package:flutter/material.dart';
import 'employee_dashboard.dart';
import 'leave_Management.dart';

class ApplyLeave extends StatefulWidget {
  const ApplyLeave({super.key});

  @override
  State<ApplyLeave> createState() => _ApplyLeaveState();
}

class _ApplyLeaveState extends State<ApplyLeave> {
  String? selectedLeaveType;
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  final TextEditingController reasonController = TextEditingController();

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? fromDate : toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _submitLeave() async {
    if (selectedLeaveType == null || reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Apply'),
        content: const Text('Are you sure you want to apply for leave?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Apply')),
        ],
      ),
    );

    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave applied successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      // Reset form
      setState(() {
        selectedLeaveType = null;
        fromDate = DateTime.now();
        toDate = DateTime.now();
        reasonController.clear();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LeaveManagement()),
      );
    }
  }

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
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  title: const Text('Anitha', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Employee Tech'),
                  trailing: const Icon(Icons.more_vert),
                ),
                const Divider(),
                _sidebarItem(context, Icons.dashboard, 'Dashboard', const EmployeeDashboard()),
                _sidebarItem(context, Icons.calendar_month, 'Leave Management', const LeaveManagement()),
                _sidebarItem(context, Icons.payments, 'Payroll Management', null),
                _sidebarItem(context, Icons.how_to_reg, 'Attendance System', null),
                _sidebarItem(context, Icons.analytics, 'Reports & Analytics', null),
                _sidebarItem(context, Icons.people, 'Employee Directory', null),
                _sidebarItem(context, Icons.notifications, 'Notifications', null),
                _sidebarItem(context, Icons.person, 'Employee Profile', null),
              ],
            ),
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
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
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  'APPLY LEAVE',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Form Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Leave Type', style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 5),
                                DropdownButtonFormField<String>(
                                  dropdownColor: Colors.white,
                                  value: selectedLeaveType,
                                  items: ['Sad', 'Sick', 'Casual']
                                      .map((type) => DropdownMenuItem(
                                            value: type,
                                            child: Text(type),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLeaveType = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('Approver', style: TextStyle(color: Colors.white)),
                                SizedBox(height: 5),
                                TextField(
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                                    hintText: 'Hari Bhaskar',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('From', style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 5),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: '${fromDate.day}/${fromDate.month}/${fromDate.year}'),
                                  onTap: () => _selectDate(context, true),
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('To', style: TextStyle(color: Colors.white)),
                                const SizedBox(height: 5),
                                TextField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: '${toDate.day}/${toDate.month}/${toDate.year}'),
                                  onTap: () => _selectDate(context, false),
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(Icons.calendar_today),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reason for Leave', style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: reasonController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 240, 239, 243)),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _submitLeave,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 240, 239, 243)),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(BuildContext context, IconData icon, String label, Widget? targetScreen) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(color: Colors.black87)),
      onTap: () {
        if (targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => targetScreen),
          );
        }
      },
    );
  }
}
