import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sidebar.dart';
//import 'email_page.dart';
import 'message.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  const EmployeeDirectoryPage({super.key});

  @override
  EmployeeDirectoryPageState createState() => EmployeeDirectoryPageState();
}

class EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  List<dynamic> employees = [];
  bool _isLoading = true;
  
  

  @override
  void initState() {
    super.initState();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    try {
      final response =
          await http.get(Uri.parse("http://localhost:5000/api/employees"));

      if (response.statusCode == 200) {
        setState(() {
          employees = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        print("❌ Failed to load employees: ${response.statusCode}");
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching employees: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Employee Directory',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Search + Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _searchBox('Search employee...', 200),
                ElevatedButton(
                  onPressed: fetchEmployees, // 🔄 refresh from DB
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    "EmployeeList",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ Loader or Grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      itemCount: employees.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final emp = employees[index];
                        final imageUrl = (emp['employeeImage'] != null &&
                                emp['employeeImage'].isNotEmpty)
                            ? "http://localhost:5000${emp['employeeImage']}"
                            : "";
                        return _employeeCard(
                          emp['employeeId'] ?? "", // ✅ pass employeeId also
                          emp['employeeName'] ?? "Unknown",
                          emp['position'] ?? "Unknown",
                         // "http://localhost:5000/uploads/${emp['photo']}", // 🔴 profile image URL
                         imageUrl,  // 🔹 safe URL or empty
                         
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Employee Card
  Widget _employeeCard(String employeeId,String name, String role, String imageUrl) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl.isNotEmpty
                  ? NetworkImage(imageUrl)
                  : const AssetImage("assets/profile.png"),
              //backgroundImage: NetworkImage(imageUrl),
              onBackgroundImageError: (_, __) {
                debugPrint('Image load error for $imageUrl');
              },
            ),
            const SizedBox(height: 8),
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Colors.black),
                textAlign: TextAlign.center),
            Text(role,
                style:
                    const TextStyle(fontSize: 15.5, color: Colors.black54),
                textAlign: TextAlign.center),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:  [
                Icon(Icons.email, size: 25, color: Colors.deepPurple.withOpacity(0.3)),
/*
                IconButton(
                  icon:const Icon(Icons.email, size: 25, color: Colors.deepPurple.withOpacity(0.3)),
                  onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmailPage(
                            employeeId: employeeId, // ✅ now correct
                          ),
                        ),
                      );
                    },

                    ),*/
                      IconButton(
                              icon: const Icon(Icons.message, size: 25, color: Colors.deepPurple),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MsgPage(
                                      employeeId: employeeId, // ✅ new message page
                                    ),
                                  ),
                                );
                              },
                            ),
                                        
            
                
                //Icon(Icons.message, size: 25, color: Colors.deepPurple),
                Icon(Icons.phone, size: 25, color: Colors.deepPurple.withOpacity(0.3)),
                Icon(Icons.video_call, size: 25, color: Colors.deepPurple.withOpacity(0.3)),
                Icon(Icons.info_outline, size: 25, color: Colors.deepPurple.withOpacity(0.3)),
              ],
            ),
          ],
        ),
      ),
    );
  }



 

  // ✅ Search Box
  Widget _searchBox(String hint, double width) {
    return SizedBox(
      width: width,
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
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
    );
  }
}