// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';
// import '../widgets/info_dialog.dart';
// import 'master_control_screen.dart';
// class ConnectScreen extends StatefulWidget {
//   final String? autoConnectIp;
//   const ConnectScreen({super.key, this.autoConnectIp});
//   @override
//   State<ConnectScreen> createState() => _ConnectScreenState();
// }
// class _ConnectScreenState extends State<ConnectScreen> {
//   final TextEditingController _ipController =
//       TextEditingController(text: '192.168.0.27');
//   bool _isLoading = false;
//   String _bgImagePath = 'assets/images/background.png';
//   bool _isValidIPv4(String ip) {
//     final ipRegExp = RegExp(
//       r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
//     );
//     return ipRegExp.hasMatch(ip);
//   }
//   String _parseDriveUrl(String url) {
//     if (url.trim().isEmpty) return url;
//     String trimmed = url.trim();
//     String? fileId;
//     if (trimmed.contains('drive.google.com')) {
//       if (trimmed.contains('/d/')) {
//         fileId = trimmed.split('/d/')[1].split('/')[0].split('?')[0];
//       } else if (trimmed.contains('id=')) {
//         fileId = trimmed.split('id=')[1].split('&')[0];
//       }
//     }
//     if (fileId != null && fileId.isNotEmpty) {
//       return 'https://drive.google.com/uc?export=view&id=$fileId';
//     }
//     return trimmed;
//   }
//   Future<Map<String, dynamic>> _loadRemoteConfigFast() async {
//     final String gistRawUrl =
//         'https://gist.githubusercontent.com/nguyenvandungvtdt-commits/b3440aa5a5ab9e6e69bb570b389c88cb/raw/config.json?t=${DateTime.now().millisecondsSinceEpoch}';
//     try {
//       final response = await http
//           .get(Uri.parse(gistRawUrl))
//           .timeout(const Duration(milliseconds: 1800));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> remoteData =
//             jsonDecode(utf8.decode(response.bodyBytes));
//         String? bgUrl = remoteData['assets']?['background'];
//         if (bgUrl != null && bgUrl.isNotEmpty && mounted) {
//           _bgImagePath = _parseDriveUrl(bgUrl);
//         }
//         return remoteData;
//       }
//     } catch (e) {
//       debugPrint('Dùng Config nội bộ để tăng tốc: $e');
//     }
//     final String localJson = await rootBundle.loadString('assets/config.json');
//     return jsonDecode(localJson);
//   }
// Future<void> _triggerFirmwareUpdate() async {
//   final ip = _ipController.text.trim();
//   if (!_isValidIPv4(ip)) {
//     _showErrorSnackBar('Vui lòng nhập đúng IP của ESP32 trước khi nạp Firmware!');
//     return;
//   }
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(
//       content: Row(
//         children: [
//           SizedBox(
//             width: 18,
//             height: 18,
//             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//           ),
//           SizedBox(width: 12),
//           Text('Đang kiểm tra bản cập nhật Firmware từ Cloud...'),
//         ],
//       ),
//       duration: Duration(seconds: 2),
//     ),
//   );
//   try {
//     String binUrl = '';
//     String version = 'Mới nhất';
//     try {
//       final configData = await _loadRemoteConfigFast();
//       final firmwareInfo = configData['firmware_info'];
//       if (firmwareInfo != null && firmwareInfo['bin_url'] != null) {
//         binUrl = firmwareInfo['bin_url'].toString().trim();
//         version = firmwareInfo['version'] ?? 'Mới nhất';
//       }
//     } catch (_) {
//       debugPrint("Không lấy được từ Remote Config, thử gọi GitHub API trực tiếp...");
//     }
//     if (binUrl.isEmpty) {
//       final releaseInfo = await fetchLatestRelease();
//       if (releaseInfo != null) {
//         binUrl = releaseInfo['download_url']!;
//         version = releaseInfo['version']!;
//       }
//     }
//     if (binUrl.isEmpty) {
//       _showErrorSnackBar('Không tìm thấy link Firmware trong cấu hình Cloud hoặc GitHub!');
//       return;
//     }
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.system_update_rounded, color: Color(0xFF0284C7)),
//               SizedBox(width: 10),
//               Text('Nâng Cấp Firmware ESP32',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('• Phiên bản mới: v$version',
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//               const SizedBox(height: 6),
//               Text('• Link tải: ${binUrl.substring(0, binUrl.length > 35 ? 35 : binUrl.length)}...'),
//               const SizedBox(height: 12),
//               const Text(
//                 'ESP32 sẽ tự tải file .bin từ Cloud về tự ghi đè Flash và khởi động lại trong khoảng 15-20 giây. Bạn có muốn tiếp tục?',
//                 style: TextStyle(fontSize: 13, color: Colors.black87),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(dialogContext),
//               child: const Text('Hủy'),
//             ),
//             ElevatedButton.icon(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0284C7),
//                 foregroundColor: Colors.white,
//               ),
//               icon: const Icon(Icons.cloud_upload_rounded, size: 18),
//               label: const Text('Tiến Hành Nạp'),
//               onPressed: () async {
//                 Navigator.pop(dialogContext);
//                 _sendOTACmdToESP32(ip, binUrl, version);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   } catch (e) {
//     _showErrorSnackBar('Lỗi tải cấu hình Firmware: $e');
//   }
// }
//   Future<Map<String, String>?> fetchLatestRelease() async {
//     final url = Uri.parse(
//       'https://api.github.com/repos/nguyenvandungvtdt-commits/saban_firmware/releases/latest',
//     );
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         String tagName = data['tag_name'] ?? '';
//         List assets = data['assets'] ?? [];
//         var binAsset = assets.firstWhere(
//           (asset) => asset['name'].toString().endsWith('.bin'),
//           orElse: () => null,
//         );
//         if (binAsset != null) {
//           return {
//             'version': tagName,
//             'download_url': binAsset['browser_download_url'],
//           };
//         }
//       }
//     } catch (e) {
//       debugPrint("Lỗi lấy thông tin GitHub Release: $e");
//     }
//     return null;
//   }
// Future<void> _sendOTACmdToESP32(String ip, String binUrl, [String version = '']) async {
//   setState(() => _isLoading = true);
//   double progressValue = 0.0;
//   StateSetter? dialogSetState;
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (dialogContext) {
//       return PopScope(
//         canPop: false,
//         child: StatefulBuilder(
//           builder: (context, setStateDialog) {
//             dialogSetState = setStateDialog;
//             return AlertDialog(
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//               content: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     LinearProgressIndicator(
//                       value: progressValue,
//                       color: const Color(0xFF0284C7),
//                       backgroundColor: Colors.grey[200],
//                       minHeight: 8,
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     const SizedBox(height: 15),
//                     Text(
//                       version.isNotEmpty ? 'ĐANG CẬP NHẬT FIRMWARE ($version)' : 'ĐANG CẬP NHẬT FIRMWARE',
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0369A1)),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       '${(progressValue * 100).toInt()}% - Đang tải & nạp vào Flash...',
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     },
//   );
//   try {
//     final wsUrl = Uri.parse('ws://$ip:81');
//     var channel = WebSocketChannel.connect(wsUrl);
//     await channel.ready.timeout(const Duration(seconds: 5));
//     String payload = version.isNotEmpty ? 'UPDATE_FIRMWARE:$binUrl|$version' : 'UPDATE_FIRMWARE:$binUrl';
//     channel.sink.add(payload);
//     await Future.delayed(const Duration(milliseconds: 300));
//     await channel.sink.close();
//   } catch (e) {
//     debugPrint("Lỗi gửi lệnh WS: $e");
//   }
//   const int totalSeconds = 18;
//   for (int i = 1; i <= totalSeconds; i++) {
//     await Future.delayed(const Duration(seconds: 1));
//     if (dialogSetState != null) {
//       dialogSetState!(() {
//         progressValue = i / totalSeconds;
//       });
//     }
//   }
//   bool isReconnected = false;
//   for (int i = 0; i < 5; i++) {
//     try {
//       final testWs = WebSocketChannel.connect(Uri.parse('ws://$ip:81'));
//       await testWs.ready.timeout(const Duration(seconds: 2));
//       await testWs.sink.close();
//       isReconnected = true;
//       break;
//     } catch (_) {
//       await Future.delayed(const Duration(seconds: 1));
//     }
//   }
//   if (!mounted) return;
//   Navigator.of(context, rootNavigator: true).pop();
//   setState(() => _isLoading = false);
//   if (isReconnected) {
//     _showOTASuccessDialog();
//   } else {
//     _showErrorSnackBar('ESP32 chưa sẵn sàng. Hãy thử bấm Kết nối lại sau vài giây.');
//   }
// }
//   void _showOTASuccessDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
//               SizedBox(width: 10),
//               Text('Cập Nhật Thành Công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: const Text(
//             'Firmware mới đã được nạp thành công vào ESP32.\nMạch sa bàn đang tự khởi động lại và đã sẵn sàng hoạt động!',
//             style: TextStyle(fontSize: 14),
//           ),
//           actions: [
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               onPressed: () => Navigator.pop(context),
//               child: const Text('ĐỒNG Ý'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   void _connect() async {
//   final ip = _ipController.text.trim();
//   if (ip.isEmpty) {
//     _showErrorSnackBar('Vui lòng nhập địa chỉ IP sa bàn!');
//     return;
//   }
//   if (!_isValidIPv4(ip)) {
//     _showErrorSnackBar('Địa chỉ IP không đúng định dạng!');
//     return;
//   }
//   setState(() => _isLoading = true);
//   try {
//     final wsUrl = Uri.parse('ws://$ip:81');
//     final channel = WebSocketChannel.connect(wsUrl);
//     final results = await Future.wait([
//       channel.ready.timeout(
//         const Duration(milliseconds: 1800),
//         onTimeout: () => throw TimeoutException('Mất kết nối'),
//       ),
//       _loadRemoteConfigFast(),
//     ]);
//     final configData = results[1] as Map<String, dynamic>;
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => MasterControlScreen(
//           channel: channel,
//           ip: ip,
//           configData: configData,
//           ledStates: const {}, // 🟢 Đã thêm ledStates: const {} để sửa lỗi
//         ),
//       ),
//     );
//   } catch (e) {
//     if (!mounted) return;
//     setState(() => _isLoading = false);
//     _showErrorSnackBar(
//         'Không thể kết nối tới sa bàn ($ip). Vui lòng kiểm tra lại IP hoặc Wi-Fi!');
//   }
// }
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             const Icon(Icons.error_outline_rounded, color: Colors.white),
//             const SizedBox(width: 10),
//             Expanded(
//               child: Text(
//                 message,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
//   void _showImageEditDialog(BuildContext context) {
//     final TextEditingController urlController = TextEditingController(
//         text: _bgImagePath.startsWith('http') ? _bgImagePath : '');
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.add_a_photo_rounded, color: Color(0xFF0369A1)),
//               SizedBox(width: 10),
//               Text('Cập Nhật Ảnh Banner',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: urlController,
//                   decoration: const InputDecoration(
//                     labelText: 'Link Ảnh Google Drive / Online',
//                     hintText: 'Dán link Google Drive vào đây...',
//                     prefixIcon: Icon(Icons.link_rounded),
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 const Row(
//                   children: [
//                     Expanded(child: Divider()),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Text('HOẶC',
//                           style: TextStyle(color: Colors.grey, fontSize: 12)),
//                     ),
//                     Expanded(child: Divider()),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton.icon(
//                     onPressed: () async {
//                       final ImagePicker picker = ImagePicker();
//                       final XFile? image = await picker.pickImage(
//                         source: ImageSource.gallery,
//                       );
//                       if (image != null) {
//                         setState(() {
//                           _bgImagePath = image.path;
//                         });
//                         if (context.mounted) Navigator.pop(context);
//                       }
//                     },
//                     icon: const Icon(Icons.photo_library_rounded),
//                     label: const Text('Tải ảnh từ Thư viện'),
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Hủy'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF0284C7),
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 if (urlController.text.trim().isNotEmpty) {
//                   setState(() {
//                     _bgImagePath = _parseDriveUrl(urlController.text);
//                   });
//                 }
//                 Navigator.pop(context);
//               },
//               child: const Text('Áp Dụng'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0xFFF0F9FF),
//                   Color(0xFFE0F2FE),
//                   Color(0xFFF8FAFC),
//                 ],
//               ),
//             ),
//           ),
//           SafeArea(
//             child: Column(
//               children: [
//                 _buildTopBar(context),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0, vertical: 8.0),
//                     child: Center(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           boxShadow: [
//                             BoxShadow(
//                               color: const Color(0xFF0284C7)
//                                   .withValues(alpha: 0.2),
//                               blurRadius: 24,
//                               spreadRadius: 1,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(20),
//                           child: _bgImagePath.startsWith('http')
//                               ? Image.network(
//                                   _bgImagePath,
//                                   fit: BoxFit.contain,
//                                   loadingBuilder: (context, child, progress) {
//                                     if (progress == null) return child;
//                                     return const Center(
//                                       child: CircularProgressIndicator(
//                                           color: Color(0xFF0284C7)),
//                                     );
//                                   },
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       Image.asset(
//                                     'assets/images/background.png',
//                                     fit: BoxFit.contain,
//                                     errorBuilder:
//                                         (context, error, stackTrace) =>
//                                             Container(
//                                                 color: const Color(0xFFBAE6FD)),
//                                   ),
//                                 )
//                               : Image.asset(
//                                   _bgImagePath,
//                                   fit: BoxFit.contain,
//                                   errorBuilder: (context, error, stackTrace) =>
//                                       Container(color: const Color(0xFFBAE6FD)),
//                                 ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 20.0, vertical: 18.0),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.92),
//                       borderRadius: BorderRadius.circular(22),
//                       border: Border.all(
//                         color: const Color(0xFFBAE6FD),
//                         width: 1.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color:
//                               const Color(0xFF0284C7).withValues(alpha: 0.12),
//                           blurRadius: 20,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.tune_rounded,
//                                 color: Color(0xFF0369A1), size: 20),
//                             SizedBox(width: 8),
//                             Text(
//                               'ĐIỀU KHIỂN SA BÀN THÔNG MINH',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF0369A1),
//                                 letterSpacing: 0.8,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 14),
//                         TextField(
//                           controller: _ipController,
//                           keyboardType: TextInputType.number,
//                           style: const TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF0F172A),
//                           ),
//                           decoration: InputDecoration(
//                             labelText: 'Địa chỉ IP Sa bàn',
//                             labelStyle: const TextStyle(
//                                 color: Color(0xFF0369A1), fontSize: 13),
//                             hintText: 'VD: 192.168.0.27',
//                             prefixIcon: const Icon(Icons.wifi_rounded,
//                                 color: Color(0xFF0284C7), size: 20),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 12, horizontal: 16),
//                             filled: true,
//                             fillColor: const Color(0xFFF0F9FF),
//                             enabledBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                   color: Color(0xFFBAE6FD), width: 1.2),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: const BorderSide(
//                                   color: Color(0xFF0284C7), width: 2),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 14),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 48,
//                           child: InkWell(
//                             onTap: _isLoading ? null : _connect,
//                             borderRadius: BorderRadius.circular(12),
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               decoration: BoxDecoration(
//                                 gradient: _isLoading
//                                     ? const LinearGradient(colors: [
//                                         Color(0xFF94A3B8),
//                                         Color(0xFF64748B)
//                                       ])
//                                     : const LinearGradient(
//                                         colors: [
//                                           Color(0xFF0284C7),
//                                           Color(0xFF0369A1)
//                                         ],
//                                         begin: Alignment.topLeft,
//                                         end: Alignment.bottomRight,
//                                       ),
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: const Color(0xFF0284C7)
//                                         .withValues(alpha: 0.3),
//                                     blurRadius: 12,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: Center(
//                                 child: _isLoading
//                                     ? const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             width: 18,
//                                             height: 18,
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                           SizedBox(width: 10),
//                                           Text(
//                                             'Đang kết nối, vui lòng chờ chút ạ!',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 14,
//                                             ),
//                                           ),
//                                         ],
//                                       )
//                                     : const Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.power_settings_new_rounded,
//                                               color: Colors.white, size: 18),
//                                           SizedBox(width: 8),
//                                           Text(
//                                             'KẾT NỐI VÀ TẢI SA BÀN',
//                                             style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.bold,
//                                               letterSpacing: 0.8,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildTopBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: Colors.white.withValues(alpha: 0.9),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF0284C7).withValues(alpha: 0.12),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: PopupMenuButton<String>(
//               icon: const Icon(Icons.menu_rounded,
//                   color: Color(0xFF0369A1), size: 22),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16)),
//               onSelected: (value) {
//                 if (value == 'cloud') {
//                   _loadRemoteConfigFast();
//                 } else if (value == 'edit_image') {
//                   _showImageEditDialog(context);
//                 } else if (value == 'update_firmware') {
//                   _triggerFirmwareUpdate();
//                 }
//               },
//               itemBuilder: (BuildContext context) => [
//                 const PopupMenuItem(
//                   value: 'cloud',
//                   child: Row(
//                     children: [
//                       Icon(Icons.cloud_download_outlined,
//                           color: Color(0xFF0284C7), size: 20),
//                       SizedBox(width: 10),
//                       Text('Đồng bộ dữ liệu Cloud'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuItem(
//                   value: 'edit_image',
//                   child: Row(
//                     children: [
//                       Icon(Icons.add_a_photo_outlined,
//                           color: Color(0xFF0284C7), size: 20),
//                       SizedBox(width: 10),
//                       Text('Đổi / Tải ảnh Banner lên'),
//                     ],
//                   ),
//                 ),
//                 const PopupMenuDivider(),
//                 const PopupMenuItem(
//                   value: 'update_firmware',
//                   child: Row(
//                     children: [
//                       Icon(Icons.system_update_alt_rounded,
//                           color: Colors.orange, size: 20),
//                       SizedBox(width: 10),
//                       Text('Nạp Firmware ESP32 (Auto OTA)',
//                           style: TextStyle(fontWeight: FontWeight.bold)),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white.withValues(alpha: 0.9),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(color: const Color(0xFFBAE6FD)),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF0284C7).withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: const Row(
//               children: [
//                 CircleAvatar(radius: 4, backgroundColor: Colors.green),
//                 SizedBox(width: 6),
//                 Text(
//                   'HỆ THỐNG SẴN SÀNG',
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF0369A1),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: const Color(0xFF0284C7),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF0284C7).withValues(alpha: 0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: CircleAvatar(
//               backgroundColor: Colors.transparent,
//               child: IconButton(
//                 icon: const Icon(Icons.info_outline,
//                     color: Colors.white, size: 20),
//                 onPressed: () {
//                   InfoDialog.show(
//                     context,
//                     title: 'Ứng Dụng Điều Khiển Sa Bàn',
//                     details: {
//                       'Phiên bản': 'v2.5 Luxury Light Edition',
//                       'Kết nối': 'Realtime Controller',
//                       'Giao diện': 'Seamless Floating Banner',
//                       'Nhà phát triển': 'Đội ngũ Kỹ thuật Sa Bàn',
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import '../widgets/info_dialog.dart';
import 'master_control_screen.dart';

class ConnectScreen extends StatefulWidget {
  final String? autoConnectIp;
  const ConnectScreen({super.key, this.autoConnectIp});

  @override
  State<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  // 🟢 Đổi IP mặc định thành Server Render để Apple Review mở ra là bấm kết nối được ngay
  final TextEditingController _ipController =
      TextEditingController(text: 'saban-demo.onrender.com');
  bool _isLoading = false;
  String _bgImagePath = 'assets/images/background.png';

  // 🟢 Cho phép cả IP LAN lẫn Domain Cloud (onrender.com)
  bool _isValidServerAddress(String input) {
    if (input.trim().isEmpty) return false;
    final ipRegExp = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegExp.hasMatch(input) || input.contains('.') || input.contains('localhost');
  }

  String _parseDriveUrl(String url) {
    if (url.trim().isEmpty) return url;
    String trimmed = url.trim();
    String? fileId;
    if (trimmed.contains('drive.google.com')) {
      if (trimmed.contains('/d/')) {
        fileId = trimmed.split('/d/')[1].split('/')[0].split('?')[0];
      } else if (trimmed.contains('id=')) {
        fileId = trimmed.split('id=')[1].split('&')[0];
      }
    }
    if (fileId != null && fileId.isNotEmpty) {
      return 'https://drive.google.com/uc?export=view&id=$fileId';
    }
    return trimmed;
  }

  Future<Map<String, dynamic>> _loadRemoteConfigFast() async {
  // Ưu tiên 1: Tải trực tiếp từ API Render
  const String renderUrl = 'https://saban-demo.onrender.com/config';
  try {
    final response = await http
        .get(Uri.parse(renderUrl))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final Map<String, dynamic> remoteData =
          jsonDecode(utf8.decode(response.bodyBytes));
      String? bgUrl = remoteData['assets']?['background'];
      if (bgUrl != null && bgUrl.isNotEmpty && mounted) {
        _bgImagePath = _parseDriveUrl(bgUrl);
      }
      return remoteData;
    }
  } catch (e) {
    debugPrint('Tải Config từ Render gặp sự cố: $e');
  }

  // Ưu tiên 2: Tải từ Gist
  const String gistRawUrl =
      'https://gist.githubusercontent.com/nguyenvandungvtdt-commits/b3440aa5a5ab9e6e69bb570b389c88cb/raw/config.json';
  try {
    final response = await http
        .get(Uri.parse(gistRawUrl))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
  } catch (e) {
    debugPrint('Tải Config từ Gist gặp sự cố: $e');
  }

  // Ưu tiên 3: Fallback đọc file assets nội bộ
  try {
    final String localJson = await rootBundle.loadString('assets/config.json');
    return jsonDecode(localJson);
  } catch (e) {
    return {};
  }
}

  // 🟢 Mở Web Dashboard trên trình duyệt cho Apple Reviewer
  Future<void> _openWebDashboard() async {
    final Uri url = Uri.parse('https://saban-demo.onrender.com');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      _showErrorSnackBar('Không thể mở trang web demo!');
    }
  }

  Future<void> _triggerFirmwareUpdate() async {
    final ip = _ipController.text.trim();
    if (!_isValidServerAddress(ip)) {
      _showErrorSnackBar('Vui lòng nhập đúng IP/Địa chỉ của ESP32 trước khi nạp Firmware!');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Đang kiểm tra bản cập nhật Firmware từ Cloud...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
    try {
      String binUrl = '';
      String version = 'Mới nhất';
      try {
        final configData = await _loadRemoteConfigFast();
        final firmwareInfo = configData['firmware_info'];
        if (firmwareInfo != null && firmwareInfo['bin_url'] != null) {
          binUrl = firmwareInfo['bin_url'].toString().trim();
          version = firmwareInfo['version'] ?? 'Mới nhất';
        }
      } catch (_) {
        debugPrint("Không lấy được từ Remote Config, thử gọi GitHub API trực tiếp...");
      }
      if (binUrl.isEmpty) {
        final releaseInfo = await fetchLatestRelease();
        if (releaseInfo != null) {
          binUrl = releaseInfo['download_url']!;
          version = releaseInfo['version']!;
        }
      }
      if (binUrl.isEmpty) {
        _showErrorSnackBar('Không tìm thấy link Firmware trong cấu hình Cloud hoặc GitHub!');
        return;
      }
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.system_update_rounded, color: Color(0xFF0284C7)),
                SizedBox(width: 10),
                Text('Nâng Cấp Firmware ESP32',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Phiên bản mới: v$version',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('• Link tải: ${binUrl.substring(0, binUrl.length > 35 ? 35 : binUrl.length)}...'),
                const SizedBox(height: 12),
                const Text(
                  'ESP32 sẽ tự tải file .bin từ Cloud về tự ghi đè Flash và khởi động lại trong khoảng 15-20 giây. Bạn có muốn tiếp tục?',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.cloud_upload_rounded, size: 18),
                label: const Text('Tiến Hành Nạp'),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  _sendOTACmdToESP32(ip, binUrl, version);
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorSnackBar('Lỗi tải cấu hình Firmware: $e');
    }
  }

  Future<Map<String, String>?> fetchLatestRelease() async {
    final url = Uri.parse(
      'https://api.github.com/repos/nguyenvandungvtdt-commits/saban_firmware/releases/latest',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String tagName = data['tag_name'] ?? '';
        List assets = data['assets'] ?? [];
        var binAsset = assets.firstWhere(
          (asset) => asset['name'].toString().endsWith('.bin'),
          orElse: () => null,
        );
        if (binAsset != null) {
          return {
            'version': tagName,
            'download_url': binAsset['browser_download_url'],
          };
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin GitHub Release: $e");
    }
    return null;
  }

  Future<void> _sendOTACmdToESP32(String ip, String binUrl, [String version = '']) async {
    setState(() => _isLoading = true);
    double progressValue = 0.0;
    StateSetter? dialogSetState;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              dialogSetState = setStateDialog;
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: progressValue,
                        color: const Color(0xFF0284C7),
                        backgroundColor: Colors.grey[200],
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        version.isNotEmpty ? 'ĐANG CẬP NHẬT FIRMWARE ($version)' : 'ĐANG CẬP NHẬT FIRMWARE',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0369A1)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progressValue * 100).toInt()}% - Đang tải & nạp vào Flash...',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    try {
      final wsUrl = Uri.parse(ip.contains('onrender.com') ? 'wss://$ip' : 'ws://$ip:81');
      var channel = WebSocketChannel.connect(wsUrl);
      await channel.ready.timeout(const Duration(seconds: 5));
      String payload = version.isNotEmpty ? 'UPDATE_FIRMWARE:$binUrl|$version' : 'UPDATE_FIRMWARE:$binUrl';
      channel.sink.add(payload);
      await Future.delayed(const Duration(milliseconds: 300));
      await channel.sink.close();
    } catch (e) {
      debugPrint("Lỗi gửi lệnh WS: $e");
    }
    const int totalSeconds = 18;
    for (int i = 1; i <= totalSeconds; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (dialogSetState != null) {
        dialogSetState!(() {
          progressValue = i / totalSeconds;
        });
      }
    }
    bool isReconnected = false;
    for (int i = 0; i < 5; i++) {
      try {
        final testWs = WebSocketChannel.connect(Uri.parse(ip.contains('onrender.com') ? 'wss://$ip' : 'ws://$ip:81'));
        await testWs.ready.timeout(const Duration(seconds: 2));
        await testWs.sink.close();
        isReconnected = true;
        break;
      } catch (_) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    setState(() => _isLoading = false);
    if (isReconnected) {
      _showOTASuccessDialog();
    } else {
      _showErrorSnackBar('ESP32 chưa sẵn sàng. Hãy thử bấm Kết nối lại sau vài giây.');
    }
  }

  void _showOTASuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
              SizedBox(width: 10),
              Text('Cập Nhật Thành Công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Text(
            'Firmware mới đã được nạp thành công vào ESP32.\nMạch sa bàn đang tự khởi động lại và đã sẵn sàng hoạt động!',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('ĐỒNG Ý'),
            ),
          ],
        );
      },
    );
  }

  // 🟢 Hàm kết nối được nâng cấp xử lý thông minh cả IP LAN & Server Render
  void _connect() async {
    final ip = _ipController.text.trim();
    if (ip.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập địa chỉ IP hoặc Server Sa bàn!');
      return;
    }
    if (!_isValidServerAddress(ip)) {
      _showErrorSnackBar('Địa chỉ Server/IP không hợp lệ!');
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Tự động phân biệt Domain Cloud (wss) hay IP LAN (ws)
      Uri wsUrl;
      if (ip.contains('onrender.com') || ip.startsWith('wss://') || ip.startsWith('ws://')) {
        String formatted = ip;
        if (!formatted.startsWith('ws://') && !formatted.startsWith('wss://')) {
          formatted = 'wss://$formatted';
        }
        wsUrl = Uri.parse(formatted);
      } else {
        wsUrl = Uri.parse('ws://$ip:81');
      }

      final channel = WebSocketChannel.connect(wsUrl);
      final results = await Future.wait([
        channel.ready.timeout(
          const Duration(seconds: 4), // Tăng timeout lên 4s để Render kết nối ổn định
          onTimeout: () => throw TimeoutException('Mất kết nối'),
        ),
        _loadRemoteConfigFast(),
      ]);
      final configData = results[1] as Map<String, dynamic>;
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MasterControlScreen(
            channel: channel,
            ip: ip,
            configData: configData,
            ledStates: const {},
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar(
          'Không thể kết nối tới sa bàn ($ip). Vui lòng kiểm tra lại IP hoặc Wi-Fi!');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImageEditDialog(BuildContext context) {
    final TextEditingController urlController = TextEditingController(
        text: _bgImagePath.startsWith('http') ? _bgImagePath : '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.add_a_photo_rounded, color: Color(0xFF0369A1)),
              SizedBox(width: 10),
              Text('Cập Nhật Ảnh Banner',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'Link Ảnh Google Drive / Online',
                    hintText: 'Dán link Google Drive vào đây...',
                    prefixIcon: Icon(Icons.link_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('HOẶC',
                          style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                      );
                      if (image != null) {
                        setState(() {
                          _bgImagePath = image.path;
                        });
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Tải ảnh từ Thư viện'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (urlController.text.trim().isNotEmpty) {
                  setState(() {
                    _bgImagePath = _parseDriveUrl(urlController.text);
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Áp Dụng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF0F9FF),
                  Color(0xFFE0F2FE),
                  Color(0xFFF8FAFC),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7)
                                  .withValues(alpha: 0.2),
                              blurRadius: 24,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: _bgImagePath.startsWith('http')
                              ? Image.network(
                                  _bgImagePath,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                          color: Color(0xFF0284C7)),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/images/background.png',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                                color: const Color(0xFFBAE6FD)),
                                  ),
                                )
                              : Image.asset(
                                  _bgImagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(color: const Color(0xFFBAE6FD)),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 18.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFFBAE6FD),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF0284C7).withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tune_rounded,
                                color: Color(0xFF0369A1), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ĐIỀU KHIỂN SA BÀN THÔNG MINH',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0369A1),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _ipController,
                          keyboardType: TextInputType.url,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Địa chỉ IP / Server Sa bàn',
                            labelStyle: const TextStyle(
                                color: Color(0xFF0369A1), fontSize: 13),
                            hintText: 'VD: saban-demo.onrender.com',
                            prefixIcon: const Icon(Icons.wifi_rounded,
                                color: Color(0xFF0284C7), size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            filled: true,
                            fillColor: const Color(0xFFF0F9FF),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFFBAE6FD), width: 1.2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                  color: Color(0xFF0284C7), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: InkWell(
                            onTap: _isLoading ? null : _connect,
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                gradient: _isLoading
                                    ? const LinearGradient(colors: [
                                        Color(0xFF94A3B8),
                                        Color(0xFF64748B)
                                      ])
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF0284C7),
                                          Color(0xFF0369A1)
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Đang kết nối, vui lòng chờ chút ạ!',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.power_settings_new_rounded,
                                              color: Colors.white, size: 18),
                                          SizedBox(width: 8),
                                          Text(
                                            'KẾT NỐI VÀ TẢI SA BÀN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.8,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded,
                  color: Color(0xFF0369A1), size: 22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'cloud') {
                  _loadRemoteConfigFast();
                } else if (value == 'web_demo') {
                  _openWebDashboard();
                } else if (value == 'edit_image') {
                  _showImageEditDialog(context);
                } else if (value == 'update_firmware') {
                  _triggerFirmwareUpdate();
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'web_demo',
                  child: Row(
                    children: [
                      Icon(Icons.open_in_browser_rounded,
                          color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Xem Sa Bàn Web (Live Demo)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'cloud',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_download_outlined,
                          color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Đồng bộ dữ liệu Cloud'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit_image',
                  child: Row(
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Đổi / Tải ảnh Banner lên'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'update_firmware',
                  child: Row(
                    children: [
                      Icon(Icons.system_update_alt_rounded,
                          color: Colors.orange, size: 20),
                      SizedBox(width: 10),
                      Text('Nạp Firmware ESP32 (Auto OTA)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBAE6FD)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: Colors.green),
                SizedBox(width: 6),
                Text(
                  'HỆ THỐNG SẴN SÀNG',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}