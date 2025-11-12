// lib/call_listener.dart
import 'package:flutter/material.dart';
import 'call_manager.dart';
import 'call_popup.dart';
import 'audio_call_page.dart';

class CallListener extends StatefulWidget {
  final Widget child;
  final String currentUserId;

  const CallListener({
    super.key,
    required this.child,
    required this.currentUserId,
  });

  @override
  State<CallListener> createState() => _CallListenerState();
}

class _CallListenerState extends State<CallListener> {
  late CallManager _callManager;

  @override
  void initState() {
    super.initState();

    _callManager = CallManager(
      serverUrl: 'https://zeai-hrm-1.onrender.com',
      currentUserId: widget.currentUserId,
    );

    // 📞 Handle incoming call
    _callManager.onIncomingCall = (fromId, signal) {
      final isVideo =
          signal['isVideo'] == true || signal['isVideo']?.toString() == 'true';
      _showIncoming(fromId, isVideo, signal);
    };

    // 📴 Handle call end
    _callManager.onCallEnded = () {
      if (mounted && Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    };

    // ⚡ Initialize socket & listeners
    _callManager.init();

    // 🧩 Ensure "call-ended" event from server also cleans up UI
    _callManager.socket.on('call-ended', (data) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('📞 Caller ended the call')),
        );
      }
    });
  }

  /// 🔔 Display the incoming call popup
  void _showIncoming(String fromId, bool isVideo, Map signal) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => IncomingCallPopup(
        callerId: fromId,
        isVideo: isVideo,
        onReject: () {
          _callManager.rejectCall(fromId);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onAccept: () {
          Navigator.pop(context); // close popup
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AudioCallPage(
                currentUserId: widget.currentUserId,
                targetUserId: fromId,
                isCaller: false,
                isVideo: isVideo,
                offerSignal: signal,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _callManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
