// lib/screens/employee_directory.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'sidebar.dart';
import 'message.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class EmployeeDirectoryPage extends StatefulWidget {
  const EmployeeDirectoryPage({super.key});

  @override
  EmployeeDirectoryPageState createState() => EmployeeDirectoryPageState();
}

class EmployeeDirectoryPageState extends State<EmployeeDirectoryPage> {
  List<dynamic> employees = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  IO.Socket? socket;
  String? employeeId;

  @override
  void initState() {
    super.initState();
    fetchEmployees();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSocket();
    });
  }

  void initSocket() {
    final id = Provider.of<UserProvider>(context, listen: false).employeeId;
    employeeId = id;

    socket = IO.io("https://your-socket-server-url.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": true,
    });

    socket?.onConnect((_) {
      debugPrint("✅ Socket connected");
      socket?.emit("register", employeeId);
    });

    socket?.on("incoming-call", (data) {
      final from = data["from"];
      final type = data["type"];
      final offer = data["offer"];
      _showIncomingCallDialog(from, type, offer);
    });

    socket?.on("user-offline", (targetId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$targetId is offline")),
      );
    });
  }

  Future<void> fetchEmployees() async {
    try {
      final response =
          await http.get(Uri.parse("https://zeai-hrm-1.onrender.com/api/employees"));

      if (response.statusCode == 200) {
        setState(() {
          employees = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching employees: $e");
      setState(() => _isLoading = false);
    }
  }

  void _showIncomingCallDialog(String from, String type, String offer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Incoming ${type.toUpperCase()} Call"),
        content: Text("Call from $from"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptCall(from, type, offer);
            },
            child: const Text("Accept"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              socket?.emit("reject-call", {"to": from});
            },
            child: const Text("Decline"),
          ),
        ],
      ),
    );
  }

  void _startCall(String targetId, String type) {
    if (employeeId == null || socket == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Socket not ready")));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          socket: socket!,
          from: employeeId!,
          to: targetId,
          isCaller: true,
          callType: type,
        ),
      ),
    );
  }

  void _acceptCall(String from, String type, String offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          socket: socket!,
          from: from,
          to: employeeId!,
          isCaller: false,
          callType: type,
          remoteOffer: offer,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Sidebar(
      title: 'Employee Directory',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _searchBox('Search by ID, Name, Position, or Domain...'),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _EmployeeGrid(
                      employees: employees,
                      onAudioCall: (id) => _startCall(id, "audio"),
                      onVideoCall: (id) => _startCall(id, "video"),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBox(String hint) {
    return TextField(
      controller: _searchController,
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
      onChanged: (_) => setState(() {}),
    );
  }
}

// ---------------- EMPLOYEE GRID ----------------
class _EmployeeGrid extends StatelessWidget {
  final List employees;
  final void Function(String) onAudioCall;
  final void Function(String) onVideoCall;

  const _EmployeeGrid({
    required this.employees,
    required this.onAudioCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return const Center(child: Text("No employees found", style: TextStyle(color: Colors.white)));
    }
    return GridView.builder(
      itemCount: employees.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final emp = employees[index];
        final imagePath = emp['employeeImage'];
        final imageUrl = (imagePath != null && imagePath.isNotEmpty)
            ? "https://zeai-hrm-1.onrender.com$imagePath"
            : "";
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : const AssetImage("assets/profile.png") as ImageProvider,
                ),
                const SizedBox(height: 8),
                Text(emp['employeeName'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(emp['position'] ?? "",
                    style: const TextStyle(color: Colors.black54)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green, size: 25),
                      onPressed: () => onAudioCall(emp['employeeId']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.videocam, color: Colors.blueAccent, size: 25),
                      onPressed: () => onVideoCall(emp['employeeId']),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------- CALL SCREEN ----------------
class CallScreen extends StatefulWidget {
  final IO.Socket socket;
  final String from;
  final String to;
  final bool isCaller;
  final String callType;
  final String? remoteOffer;

  const CallScreen({
    super.key,
    required this.socket,
    required this.from,
    required this.to,
    required this.isCaller,
    required this.callType,
    this.remoteOffer,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _pc;
  MediaStream? _localStream;
  bool muted = false;

  @override
  void initState() {
    super.initState();
    initRenderers();
    _startWebRTC();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _startWebRTC() async {
    final config = {
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"},
      ]
    };

    _pc = await createPeerConnection(config);
    _localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": widget.callType == "video",
    });

    _localRenderer.srcObject = _localStream;
    _localStream?.getTracks().forEach((t) => _pc?.addTrack(t, _localStream!));

    _pc?.onTrack = (event) {
      setState(() {
        _remoteRenderer.srcObject = event.streams[0];
      });
    };

    _pc?.onIceCandidate = (candidate) {
      widget.socket.emit("ice-candidate", {
        "to": widget.isCaller ? widget.to : widget.from,
        "candidate": candidate.toMap(),
      });
    };

    if (widget.isCaller) {
      RTCSessionDescription offer = await _pc!.createOffer();
      await _pc!.setLocalDescription(offer);
      widget.socket.emit("call-user", {
        "targetId": widget.to,
        "from": widget.from,
        "type": widget.callType,
        "offer": offer.sdp,
      });
    } else if (widget.remoteOffer != null) {
      await _pc!.setRemoteDescription(
          RTCSessionDescription(widget.remoteOffer!, "offer"));
      RTCSessionDescription answer = await _pc!.createAnswer();
      await _pc!.setLocalDescription(answer);
      widget.socket.emit("answer-call", {
        "to": widget.from,
        "answer": answer.sdp,
      });
    }

    widget.socket.on("call-answered", (data) async {
      await _pc!.setRemoteDescription(
          RTCSessionDescription(data["answer"], "answer"));
    });

    widget.socket.on("ice-candidate", (data) async {
      var candidate = RTCIceCandidate(
        data["candidate"]["candidate"],
        data["candidate"]["sdpMid"],
        data["candidate"]["sdpMLineIndex"],
      );
      await _pc!.addCandidate(candidate);
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _pc?.close();
    _localStream?.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      muted = !muted;
      _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
    });
  }

  void _endCall() {
    widget.socket.emit("end-call", {"to": widget.to, "from": widget.from});
    Navigator.pop(context);
    _pc?.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: RTCVideoView(_remoteRenderer)),
          Align(
            alignment: Alignment.topRight,
            child: SizedBox(
              height: 150,
              width: 120,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                        muted ? Icons.mic_off : Icons.mic,
                        color: Colors.white),
                    onPressed: _toggleMute,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
