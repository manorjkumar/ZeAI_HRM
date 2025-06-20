import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'apply_leave.dart';
import 'leave_Management.dart';
import 'employee_dashboard.dart';

class ToDoPlanner extends StatefulWidget {
  const ToDoPlanner({super.key});

  @override
  State<ToDoPlanner> createState() => _ToDoPlannerState();
}

class _ToDoPlannerState extends State<ToDoPlanner> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<String, List<Map<String, String>>> _tasks = {};

  final List<String> statusOptions = ['Yet to start', 'In progress', 'Completed'];
  final List<String> workStatusOptions = [
    'WFH',
    'WFO',
    'Casual leave',
    'Sick leave',
    'Sad leave',
    'Holiday'
  ];

  List<Map<String, String>> workItems = [
    {'item': '', 'eta': '', 'status': ''},
  ];

  void _showAddTaskDialog(DateTime date) {
    workItems = [
      {'item': '', 'eta': '', 'status': ''},
    ];
    String selectedWorkStatus = workStatusOptions[0];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1F2235),
        title: const Text('Add Work Items', style: TextStyle(color: Colors.white)),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.black,
                  value: selectedWorkStatus,
                  items: workStatusOptions
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedWorkStatus = val!),
                  decoration: const InputDecoration(labelText: 'Work Status', labelStyle: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                ...workItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  return Column(
                    children: [
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'Work Item', labelStyle: TextStyle(color: Colors.white)),
                        onChanged: (val) => workItems[index]['item'] = val,
                      ),
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: 'ETA', labelStyle: TextStyle(color: Colors.white)),
                        onChanged: (val) => workItems[index]['eta'] = val,
                      ),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.black,
                        value: workItems[index]['status']?.isNotEmpty == true ? workItems[index]['status'] : null,
                        items: statusOptions
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => workItems[index]['status'] = val!),
                        decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                }).toList(),
                if (workItems.length < 6)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        workItems.add({'item': '', 'eta': '', 'status': ''});
                      });
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_selectedDay != null && !_selectedDay!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                final formattedDate = _selectedDay!.toIso8601String().split('T').first;
                _tasks[formattedDate] = [
                  {'workStatus': selectedWorkStatus},
                  ...workItems
                ];
                setState(() {});
              }
              Navigator.pop(context);
            },
            child: const Text('Done', style: TextStyle(color: Colors.deepPurple)),
          )
        ],
      ),
    );
  }

  List<Widget> _getTasksForDay(DateTime day) {
    final formattedDate = day.toIso8601String().split('T').first;
    final taskList = _tasks[formattedDate];
    if (taskList == null || taskList.isEmpty) return [];

    return [
      const Icon(Icons.check_circle, color: Color.fromARGB(255, 212, 73, 216)),
      const Text(" Work Set", style: TextStyle(color: Colors.deepPurple, fontSize: 10)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1020),
      body: Row(
        children: [
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
                  leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatar.png')),
                  title: const Text('Anitha', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Employee Tech'),
                ),
                const Divider(),
                _sidebarTile(context, Icons.dashboard, 'Dashboard', const EmployeeDashboard()),
                _sidebarTile(context, Icons.calendar_month, 'Leave Management', const LeaveManagement()),
                _sidebarTile(context, Icons.note_alt, 'Apply Leave', const ApplyLeave()),
                _sidebarTile(context, Icons.payments, 'Payroll Management', null),
                _sidebarTile(context, Icons.how_to_reg, 'Attendance System', null),
                _sidebarTile(context, Icons.analytics, 'Reports & Analytics', null),
                _sidebarTile(context, Icons.people, 'Employee Directory', null),
                _sidebarTile(context, Icons.notifications, 'Notifications', null),
                _sidebarTile(context, Icons.person, 'Employee Profile', null),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: const Color(0xFF0F1020),
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
                            fillColor: Colors.black26,
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
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _showAddTaskDialog(selectedDay);
                      }
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white),
                      selectedDecoration: BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
                      todayDecoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                      selectedTextStyle: TextStyle(color: Colors.white),
                      todayTextStyle: TextStyle(color: Colors.white),
                    ),
                    daysOfWeekStyle: const DaysOfWeekStyle(weekdayStyle: TextStyle(color: Colors.white), weekendStyle: TextStyle(color: Colors.white)),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: _getTasksForDay(day),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _sidebarTile(BuildContext context, IconData icon, String title, Widget? page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
    );
  }
}
