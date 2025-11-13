// lib/services/socket_service.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;

  void init(String baseUrl, String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      print('✅ Socket connected: ${_socket!.id}');
      _socket!.emit('register', userId);
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket disconnected');
    });

    _socket!.onError((err) {
      print('⚠️ Socket error: $err');
    });
  }

  IO.Socket? get socket => _socket;

  void sendSignal(Map<String, dynamic> data) {
    _socket?.emit('signal', data);
  }

  void startCall(Map<String, dynamic> data) {
    _socket?.emit('start-call', data);
  }

  void acceptCall(Map<String, dynamic> data) {
    _socket?.emit('accept-call', data);
  }

  void endCall(Map<String, dynamic> data) {
    _socket?.emit('end-call', data);
  }
}
