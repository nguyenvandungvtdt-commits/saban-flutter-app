// import 'package:flutter/material.dart';
// // import 'package:web_socket_channel/web_socket_channel.dart';
// import '../services/config_service.dart';
// import 'connect_screen.dart';
// import 'master_control_screen.dart';
// import 'package:web_socket_channel/io.dart'; // Bổ sung import này
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkSavedConfig();
//   }

//   Future<void> _checkSavedConfig() async {
//     String? savedIp = await ConfigService.getSavedIp();
//     String? savedJson = await ConfigService.getSavedJsonConfig();

//     if (!mounted) return;

//     if (savedIp != null && savedJson != null) {
//       try {
//         // final wsUrl = Uri.parse('ws://$savedIp:81');
//         // final channel = WebSocketChannel.connect(wsUrl);
//         final wsUrl = Uri.parse('ws://$savedIp:81');
// final channel = IOWebSocketChannel.connect(wsUrl); // ✅ Dùng IOWebSocketChannel

//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => MasterControlScreen(
//               channel: channel,
//               ip: savedIp,
//               cachedJson: savedJson,
//             ),
//           ),
//         );
//         return;
//       } catch (e) {
//         debugPrint("Lỗi kết nối WS với IP lưu tạm: $e");
//       }
//     }

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const ConnectScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(color: Colors.teal),
//             SizedBox(height: 16),
//             Text('Đang tải cấu hình sa bàn...'),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../services/config_service.dart';
import 'connect_screen.dart';
import 'master_control_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSavedConfig();
  }

  Future<void> _checkSavedConfig() async {
    String? savedIp = await ConfigService.getSavedIp();
    String? savedJson = await ConfigService.getSavedJsonConfig();

    if (!mounted) return;

    if (savedIp != null && savedJson != null) {
      try {
        final wsUrl = Uri.parse('ws://$savedIp:81');
        final channel = IOWebSocketChannel.connect(wsUrl);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MasterControlScreen(
              channel: channel,
              ip: savedIp,
              cachedJson: savedJson,
              ledStates: const {}, // 🟢 Đã bổ sung ledStates khởi tạo ban đầu
            ),
          ),
        );
        return;
      } catch (e) {
        debugPrint("Lỗi kết nối WS với IP lưu tạm: $e");
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConnectScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.teal),
            SizedBox(height: 16),
            Text('Đang tải cấu hình sa bàn...'),
          ],
        ),
      ),
    );
  }
}