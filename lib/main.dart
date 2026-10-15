// import 'package:flutter/material.dart';
// import 'screens/splash_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // GIỚI HẠN MEMORY CACHE ẢNH (Giúp app nhẹ máy, hết đơ lag)
//   PaintingBinding.instance.imageCache.maximumSize = 20; // Giới hạn tối đa lưu 20 ảnh trong RAM
//   PaintingBinding.instance.imageCache.maximumSizeBytes = 30 * 1024 * 1024; // Giới hạn tối đa 30MB RAM

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Điều Khiển Sa Bàn',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF5F7FA),
//       ),
//       home: const SplashScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cho phép xoay ngang màn hình (Ưu tiên chế độ Landscape cho Sa Bàn)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp, // Vẫn cho phép dọc nếu chạy trên iPhone nhỏ
  ]);

  // 2. GIỚI HẠN MEMORY CACHE ẢNH (Giúp app nhẹ máy, hết đơ lag)
  PaintingBinding.instance.imageCache.maximumSize = 20; // Giới hạn tối đa lưu 20 ảnh trong RAM
  PaintingBinding.instance.imageCache.maximumSizeBytes = 30 * 1024 * 1024; // Giới hạn tối đa 30MB RAM

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Điều Khiển Sa Bàn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
          primary: const Color(0xFF0284C7),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      // Tự động ẩn bàn phím khi chạm ra ngoài ô nhập IP
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: child,
        );
      },
      home: const SplashScreen(),
    );
  }
}