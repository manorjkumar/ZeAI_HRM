import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'employee_dashboard.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login Page',
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF171A30),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double loginBoxWidth = screenWidth > 1000 ? 500 : screenWidth * 0.8;
          double imageWidth = screenWidth > 1000 ? 400 : screenWidth * 0.4;
          double spacing = screenWidth > 1000 ? 80 : 30;

          return Column(
            children: [
              // Top navbar
              Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF171A30),
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 2),
                    bottom: BorderSide(color: Colors.black, width: 2),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const FaIcon(
                      FontAwesomeIcons.chevronLeft,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(width: 16),
                    const FaIcon(
                      FontAwesomeIcons.chevronRight,
                      color: Colors.white,
                      size: 30,
                    ),

                    const SizedBox(width: 18),
                    const Image(
                      image: AssetImage('assets/png-z.png'),
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 70),
                    const Spacer(),
                    const Image(
                      image: AssetImage('assets/png2.png'),
                      width: 140,
                      height: 140,
                    ),
                    const Spacer(),
                    Container(
                      width: 300,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search here..',
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                          filled: true,
                          fillColor: const Color(0xFF2C2C3E),
                          suffixIcon: const Icon(
                            FontAwesomeIcons.magnifyingGlass,
                            color: Colors.white,
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 20,
                            top: 16,
                            bottom: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ),

              // Main Body
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Image.asset(
                          'assets/png1.png',
                          width: imageWidth,
                          height: 350,
                        ),

                        SizedBox(width: spacing),

                        // Login Box
                        Container(
                          width: loginBoxWidth,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromARGB(255, 158, 27, 219),
                                blurRadius: 12,
                                offset: Offset(6, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Employee Login',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF171A30),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Employee ID
                              buildTextFieldRow('Employee ID :', 'Enter_id'),

                              const SizedBox(height: 16),

                              // Employee Name
                              buildTextFieldRow(
                                'Employee Name :',
                                'Enter_Name',
                              ),

                              const SizedBox(height: 16),

                              // Position
                              buildTextFieldRow('Position :', 'Enter_position'),

                              const SizedBox(height: 30),

                              // Login Button
                              SizedBox(
                                width: 100,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EmployeeDashboard(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF171A30),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Login',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper method to build each TextField row
  Widget buildTextFieldRow(String label, String hint) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(53, 64, 85, 0.77),
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 183, 181, 181),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
