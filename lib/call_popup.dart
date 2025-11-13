import 'package:flutter/material.dart';

class IncomingCallPopup extends StatelessWidget {
  final String callerId;
  final bool isVideo;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCallPopup({
    super.key,
    required this.callerId,
    required this.isVideo,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        "Incoming ${isVideo ? 'Video' : 'Audio'} Call",
        style: const TextStyle(color: Colors.white),
      ),
      content: Text(
        "From: $callerId",
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call_end, color: Colors.red, size: 35),
          onPressed: onReject,
        ),
        IconButton(
          icon: const Icon(Icons.call, color: Colors.green, size: 35),
          onPressed: onAccept,
        ),
      ],
    );
  }
}
