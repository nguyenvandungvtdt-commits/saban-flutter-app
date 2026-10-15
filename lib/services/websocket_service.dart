// // import 'dart:async';
// // import 'package:flutter/foundation.dart';
// // import 'package:web_socket_channel/web_socket_channel.dart';

// // class WebSocketService {
// //   // Singleton pattern
// //   static final WebSocketService _instance = WebSocketService._internal();
// //   factory WebSocketService() => _instance;
// //   WebSocketService._internal();

// //   WebSocketChannel? _channel;
// //   bool isConnected = false;
// //   String _currentIp = '';
// //   Timer? _reconnectTimer;

// //   // Stream để UI đăng ký lắng nghe trạng thái kết nối
// //   final _connectionController = StreamController<bool>.broadcast();
// //   Stream<bool> get connectionStream => _connectionController.stream;

// //   /// Khởi tạo kết nối tới ESP32 WebSocket Server
// //   void connect(String ipAddress) {
// //     _currentIp = ipAddress;
// //     final wsUrl = Uri.parse('ws://$ipAddress:81');

// //     try {
// //       _channel = WebSocketChannel.connect(wsUrl);
// //       isConnected = true;
// //       _connectionController.add(true);
// //       if (kDebugMode) print('WebSocket: Đã kết nối tới $wsUrl');

// //       // Lắng nghe dữ liệu phản hồi từ ESP32 nếu có
// //       _channel!.stream.listen(
// //         (message) {
// //           if (kDebugMode) print('WebSocket nhan: $message');
// //         },
// //         onDone: () {
// //           _handleDisconnect();
// //         },
// //         onError: (error) {
// //           if (kDebugMode) print('WebSocket loi: $error');
// //           _handleDisconnect();
// //         },
// //       );
// //     } catch (e) {
// //       if (kDebugMode) print('Loi ket noi WebSocket: $e');
// //       _handleDisconnect();
// //     }
// //   }

// //   /// Xử lý ngắt kết nối & tự động kết nối lại sau 3 giây
// //   void _handleDisconnect() {
// //     isConnected = false;
// //     _connectionController.add(false);
// //     _channel = null;

// //     _reconnectTimer?.cancel();
// //     _reconnectTimer = Timer(const Duration(seconds: 3), () {
// //       if (!isConnected && _currentIp.isNotEmpty) {
// //         if (kDebugMode) print('WebSocket: Dang thu ket noi lai...');
// //         connect(_currentIp);
// //       }
// //     });
// //   }

// //   /// Gửi lệnh điều khiển 1 phòng: "roomIndex:state" (VD: "5:1")
// //   void sendSingleRoom(int roomIndex, bool state) {
// //     if (!isConnected || _channel == null) {
// //       if (kDebugMode) print('WebSocket: Chưa kết nối, không thể gửi lệnh');
// //       return;
// //     }
// //     final command = '$roomIndex:${state ? 1 : 0}';
// //     _channel!.sink.add(command);
// //     if (kDebugMode) print('WebSocket gui: $command');
// //   }

// //   /// Gửi lệnh điều khiển nhóm (Tòa / Tầng / Loại phòng): "ALL:state:id1,id2,id3"
// //   void sendGroupRooms(List<int> roomIndexes, bool state) {
// //     if (!isConnected || _channel == null || roomIndexes.isEmpty) return;

// //     final idsString = roomIndexes.join(',');
// //     final command = 'ALL:${state ? 1 : 0}:$idsString';
// //     _channel!.sink.add(command);
// //     if (kDebugMode) print('WebSocket gui nhom: $command');
// //   }

// //   /// Ngắt kết nối thủ công
// //   void disconnect() {
// //     _reconnectTimer?.cancel();
// //     _channel?.sink.close();
// //     isConnected = false;
// //     _connectionController.add(false);
// //   }
// // }

// import 'dart:async';
// import 'package:flutter/foundation.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class WebSocketService {
//   // Singleton pattern
//   static final WebSocketService _instance = WebSocketService._internal();
//   factory WebSocketService() => _instance;
//   WebSocketService._internal();

//   WebSocketChannel? _channel;
//   bool isConnected = false;
//   String _currentIp = '';
//   Timer? _reconnectTimer;
//   Timer? _pingTimer;

//   // Stream để UI đăng ký lắng nghe trạng thái kết nối
//   final _connectionController = StreamController<bool>.broadcast();
//   Stream<bool> get connectionStream => _connectionController.stream;

//   /// Khởi tạo kết nối tới ESP32 WebSocket Server
//   void connect(String ipAddress) {
//     if (ipAddress.isEmpty) return;
//     _currentIp = ipAddress;
//     final wsUrl = Uri.parse('ws://$ipAddress:81');

//     // Hủy kết nối cũ & timer cũ trước khi tạo kết nối mới
//     _cleanupConnection();

//     try {
//       if (kDebugMode) print('WebSocket: Đang thử kết nối tới $wsUrl...');
//       _channel = WebSocketChannel.connect(wsUrl);

//       // Lắng nghe dữ liệu phản hồi từ ESP32
//       _channel!.stream.listen(
//         (message) {
//           // 🟢 CHỈ XÁC NHẬN KẾT NỐI THÀNH CÔNG KHI DỮ LIỆU ĐẦU TIÊN TRẢ VỀ/HOẶC STREAM HOẠT ĐỘNG
//           if (!isConnected) {
//             isConnected = true;
//             _connectionController.add(true);
//             _startPingTimer(); // Bắt đầu gửi Ping giữ kết nối
//             if (kDebugMode) print('WebSocket: ✅ Kết nối THÀNH CÔNG tới $wsUrl');
//           }

//           if (kDebugMode) print('WebSocket nhận: $message');
//         },
//         onDone: () {
//           if (kDebugMode) print('WebSocket: Mất kết nối (onDone)');
//           _handleDisconnect();
//         },
//         onError: (error) {
//           if (kDebugMode) print('WebSocket lỗi: $error');
//           _handleDisconnect();
//         },
//       );

//       // Tự động xác nhận kết nối sau 500ms nếu stream lắng nghe không báo lỗi
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (_channel != null && !isConnected) {
//           isConnected = true;
//           _connectionController.add(true);
//           _startPingTimer();
//           if (kDebugMode) print('WebSocket: ✅ Đã thiết lập kết nối!');
//         }
//       });

//     } catch (e) {
//       if (kDebugMode) print('Lỗi kết nối WebSocket: $e');
//       _handleDisconnect();
//     }
//   }

//   /// Timer duy trì kết nối (Heartbeat Ping) cứ mỗi 5 giây
//   void _startPingTimer() {
//     _pingTimer?.cancel();
//     _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (isConnected && _channel != null) {
//         try {
//           _channel!.sink.add('PING');
//         } catch (e) {
//           _handleDisconnect();
//         }
//       }
//     });
//   }

//   /// Dọn dẹp tài nguyên
//   void _cleanupConnection() {
//     _pingTimer?.cancel();
//     _reconnectTimer?.cancel();
//     try {
//       _channel?.sink.close();
//     } catch (_) {}
//     _channel = null;
//   }

//   /// Xử lý ngắt kết nối & tự động kết nối lại sau 3 giây
//   void _handleDisconnect() {
//     bool wasConnected = isConnected;
//     isConnected = false;
//     _cleanupConnection();

//     if (wasConnected) {
//       _connectionController.add(false);
//     }

//     // Tự động kết nối lại nếu có IP
//     _reconnectTimer = Timer(const Duration(seconds: 3), () {
//       if (!isConnected && _currentIp.isNotEmpty) {
//         if (kDebugMode) print('WebSocket: Đang tự động kết nối lại...');
//         connect(_currentIp);
//       }
//     });
//   }

//   /// Gửi lệnh điều khiển 1 phòng: "roomIndex:state" (VD: "5:1")
//   void sendSingleRoom(int roomIndex, bool state) {
//     if (!isConnected || _channel == null) {
//       if (kDebugMode) print('WebSocket: Chưa kết nối, không thể gửi lệnh');
//       return;
//     }
//     final command = '$roomIndex:${state ? 1 : 0}';
//     try {
//       _channel!.sink.add(command);
//       if (kDebugMode) print('WebSocket gửi: $command');
//     } catch (e) {
//       _handleDisconnect();
//     }
//   }

//   /// Gửi lệnh điều khiển nhóm (Tòa / Tầng / Loại phòng): "ALL:state:id1,id2,id3"
//   void sendGroupRooms(List<int> roomIndexes, bool state) {
//     if (!isConnected || _channel == null || roomIndexes.isEmpty) return;

//     final idsString = roomIndexes.join(',');
//     final command = 'ALL:${state ? 1 : 0}:$idsString';
//     try {
//       _channel!.sink.add(command);
//       if (kDebugMode) print('WebSocket gửi nhóm: $command');
//     } catch (e) {
//       _handleDisconnect();
//     }
//   }

//   /// Ngắt kết nối thủ công
//   void disconnect() {
//     _currentIp = '';
//     isConnected = false;
//     _cleanupConnection();
//     _connectionController.add(false);
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  bool isConnected = false;
  String _currentAddress = '';
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  // Stream để UI đăng ký lắng nghe trạng thái kết nối
  final _connectionController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Domain mặc định Server Demo cho Apple Review
  static const String defaultDemoDomain = 'wss://saban-demo.onrender.com';

  /// Khởi tạo kết nối tới WebSocket Server (Tự động nhận dạng IP LAN hoặc Domain SSL)
  void connect(String inputAddress) {
    if (inputAddress.isEmpty) return;
    _currentAddress = inputAddress;

    // 1. Tự động xử lý URL linh hoạt (Hỗ trợ cả ESP32 thật & Server Render)
    Uri wsUrl;
    if (inputAddress.contains('onrender.com') || inputAddress.startsWith('ws://') || inputAddress.startsWith('wss://')) {
      String formatted = inputAddress;
      if (!formatted.startsWith('ws://') && !formatted.startsWith('wss://')) {
        formatted = 'wss://$formatted';
      }
      wsUrl = Uri.parse(formatted);
    } else {
      // Trường hợp nhập IP thật trong LAN (VD: 192.168.0.27)
      wsUrl = Uri.parse('ws://$inputAddress:81');
    }

    // Hủy kết nối cũ trước khi tạo kết nối mới
    _cleanupConnection();

    try {
      if (kDebugMode) print('WebSocket: Đang kết nối tới $wsUrl...');
      _channel = WebSocketChannel.connect(wsUrl);

      // Lắng nghe dữ liệu phản hồi
      _channel!.stream.listen(
        (message) {
          if (!isConnected) {
            isConnected = true;
            _connectionController.add(true);
            _startPingTimer();
            if (kDebugMode) print('WebSocket: ✅ Kết nối THÀNH CÔNG tới $wsUrl');
          }
          if (kDebugMode) print('WebSocket nhận: $message');
        },
        onDone: () => _handleDisconnect(),
        onError: (error) {
          if (kDebugMode) print('WebSocket lỗi: $error');
          _handleDisconnect();
        },
      );

      // Xác nhận kết nối sau 500ms
      Future.delayed(const Duration(milliseconds: 500), () {
        if (_channel != null && !isConnected) {
          isConnected = true;
          _connectionController.add(true);
          _startPingTimer();
          if (kDebugMode) print('WebSocket: ✅ Đã thiết lập kết nối!');
        }
      });

    } catch (e) {
      if (kDebugMode) print('Lỗi kết nối WebSocket: $e');
      _handleDisconnect();
    }
  }

  /// Timer Ping duy trì kết nối
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (_) {
          _handleDisconnect();
        }
      }
    });
  }

  /// Dọn dẹp tài nguyên
  void _cleanupConnection() {
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  /// Xử lý ngắt kết nối
  void _handleDisconnect() {
    bool wasConnected = isConnected;
    isConnected = false;
    _cleanupConnection();

    if (wasConnected) {
      _connectionController.add(false);
    }

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (!isConnected && _currentAddress.isNotEmpty) {
        if (kDebugMode) print('WebSocket: Đang tự động kết nối lại...');
        connect(_currentAddress);
      }
    });
  }

  /// Gửi lệnh điều khiển 1 phòng (Gửi song song cả định dạng ESP32 & JSON Render)
  void sendSingleRoom(int roomIndex, bool state) {
    if (!isConnected || _channel == null) {
      if (kDebugMode) print('WebSocket: Chưa kết nối, không thể gửi lệnh');
      return;
    }

    // Gửi dạng JSON để Server Render đổi màu Icon trên Web Dashboard
    final payload = jsonEncode({
      'hardwareIndex': roomIndex,
      'state': state,
      'status': state ? 'ON' : 'OFF'
    });

    try {
      _channel!.sink.add(payload);
      // Gửi thêm chuỗi thô phòng trường hợp ESP32 thật đọc
      _channel!.sink.add('$roomIndex:${state ? 1 : 0}');
      if (kDebugMode) print('WebSocket gửi: $payload');
    } catch (e) {
      _handleDisconnect();
    }
  }

  /// Gửi lệnh điều khiển nhóm phòng
  void sendGroupRooms(List<int> roomIndexes, bool state) {
    if (!isConnected || _channel == null || roomIndexes.isEmpty) return;

    final payload = jsonEncode({
      'leds': roomIndexes,
      'state': state,
      'status': state ? 'ON' : 'OFF'
    });

    try {
      _channel!.sink.add(payload);
      final idsString = roomIndexes.join(',');
      _channel!.sink.add('ALL:${state ? 1 : 0}:$idsString');
      if (kDebugMode) print('WebSocket gửi nhóm: $payload');
    } catch (e) {
      _handleDisconnect();
    }
  }

  /// Ngắt kết nối thủ công
  void disconnect() {
    _currentAddress = '';
    isConnected = false;
    _cleanupConnection();
    _connectionController.add(false);
  }
}