import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

typedef IncomingCallHandler = void Function(String fromId, Map signal);
typedef CallEndedHandler = void Function();

class CallManager {
  final String serverUrl;
  final String currentUserId;
  late IO.Socket socket;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? get localStream => _localStream;
  MediaStream? _remoteStream;

  Function(MediaStream stream)? onLocalStream;
  Function(MediaStream stream)? onRemoteStream;

  IncomingCallHandler? onIncomingCall;
  CallEndedHandler? onCallEnded;

  CallManager({required this.serverUrl, required this.currentUserId});

  void init() {
    socket = IO.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': false,
    });

    socket.connect();
    socket.onConnect((_) {
      socket.emit('register', currentUserId);
      print('✅ Connected to signaling server as $currentUserId');
    });

    socket.on('offer', (data) => onIncomingCall?.call(data['from'], data));
    socket.on('answer', (data) async {
      final desc = RTCSessionDescription(data['sdp'], data['type']);
      await _peerConnection?.setRemoteDescription(desc);
    });

    socket.on('candidate', (data) async {
      final candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      await _peerConnection?.addCandidate(candidate);
    });

    socket.on('call-ended', (_) => onCallEnded?.call());
  }

  Future<void> startCall(String targetId, bool isVideo) async {
    await _createPeerConnection(isVideo);
    _localStream = await _getUserMedia(isVideo);
    onLocalStream?.call(_localStream!);

    _localStream!.getTracks().forEach((t) => _peerConnection!.addTrack(t, _localStream!));

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    socket.emit('offer', {
      'from': currentUserId,
      'to': targetId,
      'sdp': offer.sdp,
      'type': offer.type,
      'isVideo': isVideo,
    });
  }

  Future<void> answerCall(Map offer) async {
    final isVideo = offer['isVideo'] == true || offer['isVideo']?.toString() == 'true';
    await _createPeerConnection(isVideo);

    _localStream = await _getUserMedia(isVideo);
    onLocalStream?.call(_localStream!);
    _localStream!.getTracks().forEach((t) => _peerConnection!.addTrack(t, _localStream!));

    final desc = RTCSessionDescription(offer['sdp'], offer['type']);
    await _peerConnection!.setRemoteDescription(desc);

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    socket.emit('answer', {
      'from': currentUserId,
      'to': offer['from'],
      'sdp': answer.sdp,
      'type': answer.type,
    });
  }

  void rejectCall(String fromId) => socket.emit('call-rejected', {'from': currentUserId, 'to': fromId});
  void endCall(String targetId) {
    socket.emit('call-ended', {'from': currentUserId, 'to': targetId});
    _cleanup();
  }

  Future<void> _createPeerConnection(bool isVideo) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };
    _peerConnection = await createPeerConnection(config);

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate.candidate != null) {
        socket.emit('candidate', {
          'to': currentUserId == null ? '' : currentUserId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex,
        });
      }
    };

    _peerConnection!.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };
  }

  Future<MediaStream> _getUserMedia(bool isVideo) async {
    return await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': isVideo
          ? {
              'facingMode': 'user',
              'width': {'ideal': 640},
              'height': {'ideal': 480},
            }
          : false,
    });
  }

  void _cleanup() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    _peerConnection = null;
  }

  void dispose() {
    _cleanup();
    socket.dispose();
  }
}
