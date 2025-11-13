// lib/screens/call_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:math';

class CallScreen extends StatefulWidget {
  final IO.Socket socket;
  final String localId;
  final List<String> targets; // employeeIds to call (if caller)
  final bool isVideo;
  final bool isCaller;
  final String? roomId;

  const CallScreen({
    super.key,
    required this.socket,
    required this.localId,
    required this.targets,
    this.isVideo = true,
    this.isCaller = true,
    this.roomId,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final Map<String, RTCVideoRenderer> _remoteRenderers = {};
  final Map<String, RTCPeerConnection> _pcs = {};
  MediaStream? _localStream;
  String roomId = '';
  bool muted = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _localRenderer.initialize();
    roomId = widget.roomId ?? _makeRoomId();
    _setupSocketHandlers();
    await _openUserMedia();
    if (widget.isCaller) {
      // notify targets
      widget.socket.emit('start-call', {
        'from': widget.localId,
        'targets': widget.targets,
        'type': widget.isVideo ? 'video' : 'audio',
        'roomId': roomId,
      });

      // create offers to each target
      for (var t in widget.targets) {
        if (t == widget.localId) continue;
        await _createPeerConnection(t, createOffer: true);
      }
    }
  }

  String _makeRoomId() {
    final rnd = Random();
    return 'room_${DateTime.now().millisecondsSinceEpoch}_${rnd.nextInt(9999)}';
  }

  Future<void> _openUserMedia() async {
    final mediaConstraints = {
      'audio': true,
      'video': widget.isVideo,
    };
    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localRenderer.srcObject = _localStream;
    setState(() {});
  }

  void _setupSocketHandlers() {
    widget.socket.on('signal', (data) async {
      final from = data['from'];
      final payload = data['payload'];
      final type = payload['type'];

      if (!_pcs.containsKey(from)) {
        await _createPeerConnection(from, createOffer: false);
      }

      final pc = _pcs[from];
      if (type == 'offer') {
        await pc!.setRemoteDescription(RTCSessionDescription(payload['sdp'], 'offer'));
        final ans = await pc.createAnswer();
        await pc.setLocalDescription(ans);
        widget.socket.emit('signal', {
          'to': from,
          'from': widget.localId,
          'payload': {'type': 'answer', 'sdp': ans.sdp}
        });
      } else if (type == 'answer') {
        await pc!.setRemoteDescription(RTCSessionDescription(payload['sdp'], 'answer'));
      } else if (type == 'candidate') {
        final c = payload['candidate'];
        await pc!.addCandidate(RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']));
      }
    });

    widget.socket.on('call-ended', (data) {
      final from = data['from'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Call ended by $from')));
      _closePeer(from);
    });

    widget.socket.on('user-offline', (data) {
      final offlineList = (data['offline'] as List?) ?? [];
      if (offlineList.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${offlineList.join(", ")} offline')));
      }
    });

    widget.socket.on('incoming-call', (data) async {
      // If this screen is already open as non-caller, ignore here
      // Incoming calls are handled globally in main app to show popup (see next section)
    });
  }

  Future<RTCPeerConnection> _createPeerConnection(String remoteId, {bool createOffer = false}) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    };

    final pc = await createPeerConnection(config);

    // add local tracks
    _localStream?.getTracks().forEach((t) => pc.addTrack(t, _localStream!));

    // prepare remote renderer
    final renderer = RTCVideoRenderer();
    await renderer.initialize();
    _remoteRenderers[remoteId] = renderer;

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        renderer.srcObject = event.streams[0];
        setState(() {});
      }
    };

    pc.onIceCandidate = (candidate) {
      widget.socket.emit('signal', {
        'to': remoteId,
        'from': widget.localId,
        'payload': {
          'type': 'candidate',
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex
          }
        }
      });
    };

    _pcs[remoteId] = pc;

    if (createOffer) {
      final offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
      widget.socket.emit('signal', {
        'to': remoteId,
        'from': widget.localId,
        'payload': {'type': 'offer', 'sdp': offer.sdp}
      });
    }

    return pc;
  }

  void _toggleMute() {
    setState(() {
      muted = !muted;
      _localStream?.getAudioTracks().forEach((t) => t.enabled = !muted);
    });
  }

  void _endCall() {
    widget.socket.emit('end-call', {'from': widget.localId, 'roomId': roomId});
    _closeAll();
    Navigator.pop(context);
  }

  void _closePeer(String id) {
    _pcs[id]?.close();
    _pcs.remove(id);
    _remoteRenderers[id]?.dispose();
    _remoteRenderers.remove(id);
    setState(() {});
  }

  void _closeAll() {
    _pcs.forEach((_, pc) => pc.close());
    _pcs.clear();
    _remoteRenderers.forEach((_, r) => r.dispose());
    _remoteRenderers.clear();
    _localRenderer.dispose();
    _localStream?.dispose();
  }

  Future<void> addParticipantDialog() async {
    final controller = TextEditingController();
    final newId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add participant (employeeId)'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'employeeId')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Add')),
        ],
      ),
    );
    if (newId != null && newId.isNotEmpty) {
      widget.socket.emit('start-call', {
        'from': widget.localId,
        'targets': [newId],
        'type': widget.isVideo ? 'video' : 'audio',
        'roomId': roomId,
      });
      await _createPeerConnection(newId, createOffer: true);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _closeAll();
    widget.socket.off('signal');
    widget.socket.off('call-ended');
    widget.socket.off('user-offline');
  }

  @override
  Widget build(BuildContext context) {
    final remoteWidgets = _remoteRenderers.entries.map((e) {
      return Container(
        margin: const EdgeInsets.all(6),
        color: Colors.black,
        child: RTCVideoView(e.value, objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
      );
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Call — $roomId'),
        backgroundColor: const Color(0xFF2D2F41),
        actions: [
          IconButton(onPressed: addParticipantDialog, icon: const Icon(Icons.person_add)),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 180, child: RTCVideoView(_localRenderer, mirror: true)),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: remoteWidgets.isEmpty
                  ? [Center(child: Text('Waiting for participants...', style: TextStyle(color: Colors.white70)))]
                  : remoteWidgets,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(icon: Icon(muted ? Icons.mic_off : Icons.mic, color: Colors.white), onPressed: _toggleMute),
                IconButton(icon: const Icon(Icons.call_end, color: Colors.red), onPressed: _endCall),
                IconButton(icon: const Icon(Icons.volume_up, color: Colors.white), onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Speaker toggle may be platform specific')));
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
