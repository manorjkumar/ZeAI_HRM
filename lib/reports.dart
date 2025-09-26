import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'sidebar.dart';
import 'user_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// ---------------- Model ----------------
class PerformanceReview {
  final String id;
  final String reviewedBy;
  final String reviewMonth;
  final String flag;
  String status; // ✅ mutable

  PerformanceReview({
    required this.id,
    required this.reviewedBy,
    required this.reviewMonth,
    required this.flag,
    required this.status,
  });

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      reviewedBy: json['reviewedBy']?.toString() ?? 'Unknown',
      reviewMonth:
          json['reviewMonth'] != null
              ? _monthName(
                int.tryParse(json['reviewMonth'].toString()) ??
                    DateTime.now().month,
              )
              : _monthName(DateTime.now().month),
      flag: json['flag']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
    );
  }

  static String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }
}

// ---------------- Reports Page ----------------
class ReportsAnalyticsPage extends StatefulWidget {
  const ReportsAnalyticsPage({super.key});

  @override
  State<ReportsAnalyticsPage> createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  final String apiBase = 'http://localhost:5000';
  final String listPath = '/reports';
  final String detailsPath = '/reports';

  List<PerformanceReview> _reviews = [];
  bool _loadingList = true;
  bool _dataFetched = false;

  int workProgress = 0;
  int leaveUsed = 0;
  String leavePercent = '0';
  String presentPercent = '100';

  @override
  void initState() {
    super.initState();
    if (!_dataFetched) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final empId = userProvider.employeeId ?? '';

      if (empId.isNotEmpty) {
        fetchPerformanceReviews(empId);
        fetchWorkProgress(empId);
        fetchLeaveStats(empId);
        _dataFetched = true;
      }
    }
  }

  // ✅ Fetch performance list
  Future<void> fetchPerformanceReviews(String empId) async {
    setState(() => _loadingList = true);
    try {
      final uri = Uri.parse('$apiBase$listPath/employee/$empId');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body.trim());
        setState(() {
          _reviews =
              data.map((item) => PerformanceReview.fromJson(item)).toList();
          _loadingList = false;
        });
      } else {
        setState(() {
          _reviews = [];
          _loadingList = false;
        });
      }
    } catch (e) {
      _loadingList = false;
      _showSnack('Error loading list: $e');
    } finally {
      if (mounted) setState(() {});
    }
  }

  // ✅ Fetch review details by ID
  Future<Map<String, dynamic>?> fetchReviewDetails(String id) async {
    try {
      final uri = Uri.parse('$apiBase$detailsPath/$id');
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body.trim());
      }
    } catch (e) {
      _showSnack('Error fetching details: $e');
    }
    return null;
  }

  // ✅ updated sendDecision method (with reviewId)
Future<void> _sendDecision({
  required PerformanceReview review,
  required Map<String, dynamic> reviewData,
  required String decision,
  required String? comment,
}) async {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  final reviewedBy = review.reviewedBy.trim().toLowerCase();

  // Decide recipients based on who reviewed
  List<String> targets = [];
  if (reviewedBy == "admin") {
    targets = ["Admin", "Super Admin"];
  } else if (reviewedBy == "super admin") {
    targets = ["Super Admin"];
  } else {
    targets = [review.reviewedBy]; // fallback
  }

  final uri = Uri.parse('$apiBase/review-decision');
  final body = json.encode({
    "employeeId": userProvider.employeeId,
    "employeeName": reviewData['empName'],
    "position": reviewData['position'] ?? "employee",
    "decision": decision,
    "comment": comment,
    "sendTo": targets,
    "reviewId": review.id, // ✅ send reviewId to backend
  });

  try {
    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 201) {
      debugPrint("Decision sent successfully");

      // Update local status too
      final updatedStatus = decision == "agree" ? "Agreed" : "Disagreed";
      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index].status = updatedStatus;
        }
      });
    } else {
      debugPrint("Failed to send decision: ${response.body}");
    }
  } catch (e) {
    debugPrint("Error sending decision: $e");
  }
}


  // ✅ Show review details with Agree & Disagree
  Future<void> _showReviewDetails(PerformanceReview review) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final reviewData = await fetchReviewDetails(review.id);
    if (mounted) Navigator.pop(context);

    if (reviewData != null && mounted) {
      final reviewedAt = reviewData['reviewedAt'] ?? reviewData['createdAt'];
      final flagColor = _getFlagTextColor(review.flag);
      final reviewIndex = _reviews.indexWhere((r) => r.id == review.id);
      if (reviewIndex == -1) return;

      await showDialog(
        context: context,
        builder:
            (_) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: flagColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Performance Review Details",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _detailRow(
                          "Employee ID",
                          reviewData['empId'],
                          textColor: Colors.black,
                        ),
                        _detailRow(
                          "Employee Name",
                          reviewData['empName'],
                          textColor: Colors.black,
                        ),
                        _detailRow(
                          "Communication",
                          reviewData['communication'],
                          textColor: Colors.black,
                        ),
                        _detailRow(
                          "Attitude",
                          reviewData['attitude'],
                          textColor: Colors.black,
                        ),
                        _detailRow(
                          "Technical Knowledge",
                          reviewData['technicalKnowledge'],
                          textColor: Colors.black,
                        ),
                        _detailRow(
                          "Business",
                          reviewData['businessKnowledge'] ??
                              reviewData['business'],
                          textColor: Colors.black,
                        ),
                        _detailRow("Flag", review.flag, textColor: flagColor),
                        _detailRow(
                          "Reviewed At",
                          _formatDate(reviewedAt),
                          textColor: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final comment = await _askComment(
                                  "Reason for Agree",
                                );
                                if (comment == null) return;

                                await _sendDecision(
                                  review: review,
                                  reviewData: reviewData,
                                  decision: "agree",
                                  comment: comment,
                                );

                                setState(() {
                                  _reviews[reviewIndex].status = "Agreed";
                                });

                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Agree",
                                style: TextStyle(color: Colors.green),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                final comment = await _askComment(
                                  "Reason for Disagree",
                                );
                                if (comment == null) return;

                                await _sendDecision(
                                  review: review,
                                  reviewData: reviewData,
                                  decision: "disagree",
                                  comment: comment,
                                );

                                setState(() {
                                  _reviews[reviewIndex].status = "Disagreed";
                                });

                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Disagree",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      );
    }
  }

  // ✅ Comment popup
  Future<String?> _askComment(String title) async {
    TextEditingController controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter comment"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Submit"),
              ),
            ],
          ),
    );
  }

  // ---------------- Fetch stats ----------------
  Future<void> fetchWorkProgress(String empId) async {
    var url = Uri.parse('$apiBase/todo_planner/todo/progress/$empId');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          workProgress = data['progress'] ?? 0;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchLeaveStats(String empId) async {
    var url = Uri.parse('$apiBase/apply/leave-balance/$empId');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final balances = data['balances'] ?? {};

        int totalUsed =
            (balances['casual']?['used'] ?? 0) +
            (balances['sick']?['used'] ?? 0) +
            (balances['sad']?['used'] ?? 0);

        setState(() {
          leaveUsed = totalUsed;
          int totalLeaves =
              (balances['casual']?['total'] ?? 0) +
              (balances['sick']?['total'] ?? 0) +
              (balances['sad']?['total'] ?? 0);

          double percent =
              totalLeaves > 0 ? (leaveUsed / totalLeaves) * 100 : 0;
          leavePercent = percent.toStringAsFixed(0);
          presentPercent = (100 - percent).toStringAsFixed(0);
        });
      }
    } catch (_) {}
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Reports & Analytics',
      body: SingleChildScrollView(
        child: Column(
          children: [
            _sectionTitle('Reports & Analytics'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                reportCard(
                  'Overall Attendance',
                  '$presentPercent%',
                  'Leave - $leavePercent%\nPresent - $presentPercent%',
                ),
                reportCard(
                  'Overall Leave',
                  '$leavePercent%',
                  'Used - $leaveUsed days\nOut of 36',
                ),
                reportCard(
                  'Overall Work Progress',
                  '$workProgress%',
                  'Working - $workProgress%\nPending - ${100 - workProgress}%',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('Latest Performance Review'),
            const SizedBox(height: 8),
            _loadingList
                ? const Center(child: CircularProgressIndicator())
                : _buildDataTable(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  Widget reportCard(String title, String percentText, String details) {
    double percent = double.tryParse(percentText.replaceAll('%', '')) ?? 0;
    Color color =
        percent >= 80
            ? Colors.green
            : percent >= 50
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        CircularPercentIndicator(
          radius: 55.0,
          lineWidth: 10.0,
          percent: (percent / 100).clamp(0.0, 1.0),
          center: Text(
            percentText,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          progressColor: color,
          backgroundColor: Colors.grey.shade300,
          animation: true,
          animationDuration: 800,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 4),
        Text(
          details,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Text(
          "No reviews available",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final latestReview = _reviews.first;

    return SizedBox(
      height: 120,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: WidgetStateColor.resolveWith(
            (_) => Colors.blueGrey.shade700,
          ),
          columns: const [
            DataColumn(
              label: Text('Reviewed by', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text(
                'Month of review',
                style: TextStyle(color: Colors.white),
              ),
            ),
            DataColumn(
              label: Text('Flag', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('More', style: TextStyle(color: Colors.white)),
            ),
            DataColumn(
              label: Text('Status', style: TextStyle(color: Colors.white)),
            ),
          ],
          rows: [
            DataRow(
              cells: [
                DataCell(
                  Text(
                    latestReview.reviewedBy,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(
                  Text(
                    latestReview.reviewMonth,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                DataCell(buildFlagCell(latestReview.flag)), // ✅ merged UI
                DataCell(
                  GestureDetector(
                    onTap: () async {
                      await _showReviewDetails(latestReview);
                    },
                    child: const Text(
                      'View',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    latestReview.status,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Flag cell with icon + color
  Widget buildFlagCell(String? flagValue) {
    String flag = (flagValue ?? '').toLowerCase();
    Color color;
    IconData icon = Icons.flag;

    if (flag.contains('red')) {
      color = Colors.red;
    } else if (flag.contains('yellow')) {
      color = Colors.amber;
    } else if (flag.contains('green')) {
      color = Colors.green;
    } else {
      color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          flagValue ?? 'Unknown',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ✅ Keep fallback flag text color (for popup bar color)
  Color _getFlagTextColor(String flag) {
    final normalized = flag.toLowerCase().replaceAll(" flag", "").trim();
    switch (normalized) {
      case "red":
        return Colors.red;
      case "yellow":
        return Colors.yellow;
      case "green":
        return Colors.green;
      default:
        return Colors.white70;
    }
  }

  Widget _detailRow(
    String label,
    dynamic value, {
    Color textColor = Colors.white70,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: TextStyle(color: textColor),
      ),
    );
  }

  String _formatDate(dynamic iso) {
    if (iso == null) return 'N/A';
    try {
      final dt = DateTime.tryParse(iso.toString());
      if (dt == null) return iso.toString();
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
          "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return iso.toString();
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
