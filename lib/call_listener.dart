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
    _callManager.onIncomingCall = _showIncoming;
    _callManager.init();
  }

  void _showIncoming(String fromId, Map signal) {
    final isVideo = signal['isVideo'] == true;
    showDialog(
      context: context,
      builder: (_) => IncomingCallPopup(
        callerId: fromId,
        isVideo: isVideo,
        onAccept: () {
          Navigator.pop(context);
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
        onReject: () {
          Navigator.pop(context);
          _callManager.rejectCall(fromId);
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
