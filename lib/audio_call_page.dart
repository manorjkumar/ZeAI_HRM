import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'call_manager.dart';

class AudioCallPage extends StatefulWidget {
  final String currentUserId;
  final String targetUserId;
  final bool isCaller;
  final bool isVideo;
  final Map? offerSignal;

  const AudioCallPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.isCaller,
    required this.isVideo,
    this.offerSignal,
  });

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late CallManager _callManager;

  bool _isMuted = false;
  bool _speakerOn = false;

  @override
  void initState() {
    super.initState();
    _initRenderers();
    _callManager = CallManager(
      serverUrl: 'https://zeai-hrm-1.onrender.com',
      currentUserId: widget.currentUserId,
    );

    _callManager.onLocalStream = (stream) => _localRenderer.srcObject = stream;
    _callManager.onRemoteStream = (stream) => _remoteRenderer.srcObject = stream;

    _callManager.init();

    if (widget.isCaller) {
      _callManager.startCall(widget.targetUserId, widget.isVideo);
    } else if (widget.offerSignal != null) {
      _callManager.answerCall(widget.offerSignal!);
    }
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  @override
  void dispose() {
    _callManager.endCall(widget.targetUserId);
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void _toggleMute() {
    final stream = _callManager.localStream;
    if (stream != null) {
      for (var track in stream.getAudioTracks()) {
        track.enabled = !track.enabled;
      }
      setState(() => _isMuted = !_isMuted);
    }
  }

  void _toggleSpeaker() async {
    await Helper.setSpeakerphoneOn(!_speakerOn);
    setState(() => _speakerOn = !_speakerOn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: RTCVideoView(_remoteRenderer, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
          ),
          Positioned(
            right: 10,
            top: 40,
            width: 120,
            height: 160,
            child: RTCVideoView(_localRenderer, mirror: true),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _circleButton(Icons.mic_off, _isMuted ? Colors.red : Colors.white, _toggleMute),
                  _circleButton(Icons.volume_up, _speakerOn ? Colors.blue : Colors.white, _toggleSpeaker),
                  _circleButton(Icons.call_end, Colors.red, () {
                    Navigator.pop(context);
                    _callManager.endCall(widget.targetUserId);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onPressed) {
    return CircleAvatar(
      radius: 30,
      backgroundColor: Colors.white12,
      child: IconButton(icon: Icon(icon, color: color, size: 28), onPressed: onPressed),
    );
  }
}
