import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../services/config_service.dart';
import '../widgets/info_dialog.dart';
import 'buildings_list_screen.dart';
import 'connect_screen.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'web_ota_screen.dart';
import '../services/firmware_service.dart';
import 'dart:async';
import 'package:web_socket_channel/io.dart';
import 'package:cached_network_image/cached_network_image.dart';
class MasterControlScreen extends StatefulWidget {
  final WebSocketChannel channel;
  final String ip;
  final String? cachedJson;
  final Map<String, dynamic>? configData;
  final Map<int, bool> ledStates;
  const MasterControlScreen({
    super.key,
    required this.channel,
    required this.ip,
    this.cachedJson,
    this.configData,
    required this.ledStates,
  });
  @override
  State<MasterControlScreen> createState() => _MasterControlScreenState();
}
class _MasterControlScreenState extends State<MasterControlScreen> {
  late Map<int, bool> localLedStates;
  final TextEditingController _ipController =
      TextEditingController(text: '192.168.0.27');
  String _projectName = 'Đang tải sa bàn...';
  List<Map<String, dynamic>> _buildings = [];
  Map<String, dynamic> _projectInfo = {};
  Map<String, dynamic> _dynamicUiConfig = {};
  String _overviewImage = 'assets/images/overview.jpg';
  final Map<int, bool> _ledStates = {};
  bool _isLoaded = false;
  bool _isRefreshing = false;
  bool _isMotorActive = false;
  bool _isOTAUploading = false; // 🟢 Biến cờ đánh dấu đang nạp OTA
  IOWebSocketChannel? _channel;
  String? localDownloadedBinPath;
// ignore: unused_field
  bool _isConnected = false;
  Timer? _otaWatchdogTimer;
  List<Map<String, dynamic>> _enabledEffects = [
    {"cmd": "TOGGLE_EVEN_ODD", "name": "CHẮN / LẺ", "icon": Icons.auto_awesome_rounded},
    {"cmd": "TOGGLE_METEOR", "name": "BĂNG SAO", "icon": Icons.auto_graph_rounded},
    {"cmd": "TOGGLE_BREATHING", "name": "NHỊP THỜ", "icon": Icons.air_rounded},
    {"cmd": "TOGGLE_SPARKLE", "name": "LẤP LÁNH", "icon": Icons.stars_rounded},
    {"cmd": "TOGGLE_SINEWAVE", "name": "SÓNG SIN", "icon": Icons.waves_rounded},
  ];
  String _activeEffect = 'MANUAL';
  double _evenOddSpeed = 6;
  double _meteorSpeed = 150;
  double _breathSpeed = 60;
  double _sparkleSpeed = 350;
  double _sineSpeed = 60;
  void Function(String)? _onModeChangedFromHardware;
  VoidCallback? _onConfigReloadedFromCloud;
// @override
// @override
// void initState() {
//   super.initState(); 
//   localLedStates = Map<int, bool>.from(widget.ledStates);
//   if (widget.ip.isNotEmpty) {
//     _ipController.text = widget.ip;
//   }

//   // 🟢 LẤY VÀ PARSE CẤU HÌNH AN TOÀN
//   Map<String, dynamic>? configToUse = widget.configData;

//   // Kiểm tra nếu configData rỗng hoặc chưa có mảng 'd', tự động tải backup từ Cloud
//   if (configToUse != null && configToUse.containsKey('d') && (configToUse['d'] as List).isNotEmpty) {
//     _dynamicUiConfig = configToUse['ui_config'] ?? {};
//     _parseConfigMap(configToUse);
//   } else if (widget.cachedJson != null) {
//     _parseFlatJson(widget.cachedJson!, isFromCache: true);
//   } else {
//     // Gọi tải cấu hình dự phòng trực tiếp từ Cloud/Server
//     _loadBackupConfigAndParse();
//   }

//   // LẮNG NGHE LỆNH TỪ WEBSOCKET
//   widget.channel.stream.listen(
//     (data) {
//       String message = data.toString().trim();
//       if (message.startsWith('MODE:')) {
//         String activeCmd = message.substring(5).trim();
//         if (mounted) {
//           setState(() {
//             _activeEffect = activeCmd;
//           });
//           if (_onModeChangedFromHardware != null) {
//             _onModeChangedFromHardware!(activeCmd);
//           }
//         }
//       } 
//       else if (message.startsWith('SYNCALL11:')) {
//         _parseSyncAll11(message);
//       } 
//       else if (message.startsWith('{')) {
//         _parseFlatJson(message, isFromCache: false);
//       } 
//       else if (message == 'OTA_SUCCESS') {
//         if (mounted) {
//           Navigator.of(context, rootNavigator: true).pop();
//           _showOTASuccessDialog();
//         }
//       } else if (message.startsWith('OTA_ERROR:')) {
//         String errType = message.substring(10).trim();
//         if (mounted) {
//           _handleOTAErrorFromHardware(errType);
//         }
//       }
//     },
//     onError: (_) {
//       if (!mounted) return;
//       _handleDisconnection();
//     },
//     onDone: () {
//       if (!mounted) return;
//       _handleDisconnection();
//     },
//   );
// }
@override
void initState() {
  super.initState(); 
  localLedStates = Map<int, bool>.from(widget.ledStates);
  if (widget.ip.isNotEmpty) {
    _ipController.text = widget.ip;
  }

  // 🟢 1. KIỂM TRA & NẠP CẤU HÌNH BAN ĐẦU AN TOÀN
  Map<String, dynamic>? configToUse = widget.configData;

  if (configToUse != null && configToUse.containsKey('d') && (configToUse['d'] as List).isNotEmpty) {
    _dynamicUiConfig = configToUse['ui_config'] ?? {};
    _parseConfigMap(configToUse);
  } else if (widget.cachedJson != null) {
    _parseFlatJson(widget.cachedJson!, isFromCache: true);
  } else {
    // Nếu chưa có mảng 'd' hợp lệ, tự động tải trực tiếp từ Cloud
    _loadBackupConfigAndParse();
  }

  // 🟢 2. LẮNG NGHE LỆNH TỪ WEBSOCKET (ĐÃ LỌC TIN NHẮN TRẠNG THÁI)
  widget.channel.stream.listen(
    (data) {
      String message = data.toString().trim();
      if (message.startsWith('MODE:')) {
        String activeCmd = message.substring(5).trim();
        if (mounted) {
          setState(() {
            _activeEffect = activeCmd;
          });
          if (_onModeChangedFromHardware != null) {
            _onModeChangedFromHardware!(activeCmd);
          }
        }
      } 
      else if (message.startsWith('SYNCALL11:')) {
        _parseSyncAll11(message);
      } 
      // 🎯 LỌC DỮ LIỆU JSON WEBSOCKET TẠI ĐÂY
      else if (message.startsWith('{')) {
        try {
          final Map<String, dynamic> msgJson = jsonDecode(message);
          // CHỈ parse config nếu tin nhắn chứa dữ liệu sa bàn thực tế (mảng 'd' hoặc 'buildings')
          if (msgJson.containsKey('d') || msgJson.containsKey('buildings') || msgJson.containsKey('ui_config')) {
            _dynamicUiConfig = msgJson['ui_config'] ?? {};
            _parseConfigMap(msgJson);
          } else {
            debugPrint("Bỏ qua tin nhắn hệ thống (không chứa data sa bàn): $message");
          }
        } catch (e) {
          debugPrint("Lỗi parse JSON từ WebSocket: $e");
        }
      } 
      else if (message == 'OTA_SUCCESS') {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          _showOTASuccessDialog();
        }
      } else if (message.startsWith('OTA_ERROR:')) {
        String errType = message.substring(10).trim();
        if (mounted) {
          _handleOTAErrorFromHardware(errType);
        }
      }
    },
    onError: (_) {
      if (!mounted) return;
      _handleDisconnection();
    },
    onDone: () {
      if (!mounted) return;
      _handleDisconnection();
    },
  );
}

// 🟢 HÀM DỰ PHÒNG CẤU HÌNH TỪ CLOUD
Future<void> _loadBackupConfigAndParse() async {
  try {
    final response = await http.get(Uri.parse('https://saban-demo.onrender.com/config')).timeout(const Duration(seconds: 3));
    if (response.statusCode == 200) {
      final Map<String, dynamic> remoteData = jsonDecode(utf8.decode(response.bodyBytes));
      if (mounted) {
        setState(() {
          _dynamicUiConfig = remoteData['ui_config'] ?? {};
        });
        _parseConfigMap(remoteData);
        return;
      }
    }
  } catch (e) {
    debugPrint("Không tải được Config từ Render, chuyển sang mảng fallback: $e");
  }

  // Cấu hình dự phòng tại chỗ nếu hoàn toàn mất mạng
  if (mounted) {
    _parseConfigMap({
      "project_info": {"name": "Dự Án Sa Bàn Tòa Nhà"},
      "d": [
        ["THÁP A", "TẦNG 01", "Shophouse-A101", 100, 0, "Shophouse khối đế"],
        ["THÁP A", "TẦNG 01", "Shophouse-A102", 100, 1, "Shophouse khối đế"],
        ["THÁP A", "TẦNG 01", "Shophouse-A103", 100, 2, "Shophouse khối đế"],
        ["THÁP A", "TẦNG 01", "Sảnh AB", 200, 3, "Sảnh Tòa Nhà"],
        ["THÁP A", "TẦNG 02", "BeautySalon A", 201, 4, "BeautySalon"],
        ["THÁP A", "TẦNG 02", "Gym-SHCĐ A", 202, 5, "Gym / SHCĐ"],
        ["THÁP A", "TẦNG 02", "Game", 203, 6, "Khu Game"]
      ]
    });
  }
}
// 🟢 HÀM DỰ PHÒNG: TẢI TRỰC TIẾP TỪ RENDER HOẶC DÙNG MẶC ĐỊNH
// Future<void> _loadBackupConfigAndParse() async {
//   try {
//     final response = await http.get(Uri.parse('https://saban-demo.onrender.com/config')).timeout(const Duration(seconds: 3));
//     if (response.statusCode == 200) {
//       final Map<String, dynamic> remoteData = jsonDecode(utf8.decode(response.bodyBytes));
//       if (mounted) {
//         setState(() {
//           _dynamicUiConfig = remoteData['ui_config'] ?? {};
//         });
//         _parseConfigMap(remoteData);
//         return;
//       }
//     }
//   } catch (e) {
//     debugPrint("Không tải được Config từ Render, dùng Fallback: $e");
//   }

//   // Data dự phòng khẩn cấp đúng cấu trúc Excel nếu mất mạng hoàn toàn
//   if (mounted) {
//     _parseConfigMap({
//       "project_info": {"name": "Dự Án Sa Bàn Tòa Nhà"},
//       "ui_config": {
//         "position": "bottom",
//         "sections": [
//           {
//             "id": "apartments_column",
//             "title": "TẤT CẢ CÁC PHÒNG",
//             "rows": [[{"label": "2PN", "filter_type": 2}, {"label": "3PN", "filter_type": 3}]]
//           }
//         ]
//       },
//       "d": [
//         ["THÁP A", "TẦNG 01", "Shophouse-A101", 100, 0, "Shophouse khối đế"],
//         ["THÁP A", "TẦNG 01", "Shophouse-A102", 100, 1, "Shophouse khối đế"],
//         ["THÁP A", "TẦNG 01", "Shophouse-A103", 100, 2, "Shophouse khối đế"],
//         ["THÁP A", "TẦNG 01", "Sảnh AB", 200, 3, "Sảnh Tòa Nhà"],
//         ["THÁP A", "TẦNG 02", "BeautySalon A", 201, 4, "BeautySalon"],
//         ["THÁP A", "TẦNG 02", "Gym-SHCĐ A", 202, 5, "Gym / SHCĐ"],
//         ["THÁP A", "TẦNG 02", "Game", 203, 6, "Khu Game"]
//       ]
//     });
//   }
// }
  void _handleOTAErrorFromHardware(String errType) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    String detailMessage = 'Đã xảy ra lỗi không xác định trong quá trình nạp!';
    if (errType == 'FILE_TOO_LARGE') {
      detailMessage = '⚠️ File Firmware quá nặng!\nBộ nhớ Flash ESP32 không đủ dung lượng.';
    } else if (errType == 'STREAM_INTERRUPTED') {
      detailMessage = '⚠️ Kết nối Wi-Fi bị đứt đoạn giữa chừng!';
    } else if (errType == 'FLASH_WRITE_FAILED') {
      detailMessage = '⚠️ Lỗi ghi vào bộ nhớ Flash ESP32!';
    } else if (errType == 'ALREADY_LATEST') {
      detailMessage = 'ℹ️ Mạch sa bàn hiện đã chạy đúng phiên bản Firmware này rồi.';
    } else if (errType.startsWith('HTTP_CODE_')) {
      String code = errType.replaceAll('HTTP_CODE_', '');
      detailMessage = '⚠️ ESP32 không thể nhận file .bin (Mã lỗi HTTP: $code).';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            SizedBox(width: 10),
            Text('Nạp OTA Thất Bại', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(detailMessage, style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('ĐÃ HỂU'),
          ),
        ],
      ),
    );
  }
  void _toggleMotor(bool value) {
    setState(() {
      _isMotorActive = value;
    });
    String command = value ? 'CMD_MOTOR:ON' : 'CMD_MOTOR:OFF';
    try {
      widget.channel.sink.add(command);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'Đã bật hệ thống xe/tàu từ trường' : 'Đã dừng hệ thống xe/tàu'),
          duration: const Duration(seconds: 1),
          backgroundColor: value ? Colors.green : Colors.grey[700],
        ),
      );
    } catch (e) {
      debugPrint('Lỗi gửi lệnh mô-tơ: $e');
    }
  }
//   void _parseSyncAll11(String message) {
//   try {
//     String payload = message.substring(10);
//     List<String> parts = payload.split('|');
//     if (parts.isEmpty) return;
//     List<String> states = parts[0].split(',');
//     if (mounted) {
//       setState(() {
//         for (int i = 0; i < states.length && i < 108; i++) {
//           _ledStates[i] = (states[i] == '1'); // 👈 Sử dụng thống nhất _ledStates
//         }
//       });
//     }
//   } catch (e) {
//     debugPrint("Lỗi Parse SYNCALL11: $e");
//   }
// }
void _parseSyncAll11(String message) {
  try {
    debugPrint("📥 [WS RECV SYNCALL11]: $message"); // 👈 Log tin nhắn SYNCALL11 nhận từ Server
    String payload = message.substring(10);
    List<String> parts = payload.split('|');
    if (parts.isEmpty) return;
    List<String> states = parts[0].split(',');
    if (mounted) {
      setState(() {
        for (int i = 0; i < states.length && i < 108; i++) {
          _ledStates[i] = (states[i] == '1');
        }
      });
    }
  } catch (e) {
    debugPrint("❌ Lỗi Parse SYNCALL11: $e");
  }
}

void _toggleLedList(List<int> ledIndices, bool targetState) {
  if (ledIndices.isEmpty) return;
  
  debugPrint("🔘 [USER CLICK TOGGLE]: Đang đổi trạng thái ${ledIndices.length} đèn -> TargetState: $targetState");
  
  setState(() {
    _activeEffect = 'MANUAL';
    for (int ledIdx in ledIndices) {
      _ledStates[ledIdx] = targetState;
    }
  });

  if (ledIndices.length == 1) {
    String payload = '${ledIndices.first}:${targetState ? 1 : 0}';
    debugPrint("🚀 [WS SEND SINGLE LED]: $payload"); // 👈 Log lệnh bật/tắt 1 LED
    widget.channel.sink.add(payload);
  } else {
    String idsJoined = ledIndices.join(',');
    String payload = 'ALL:${targetState ? 1 : 0}:$idsJoined';
    debugPrint("🚀 [WS SEND GROUP LED]: $payload"); // 👈 Log lệnh bật/tắt nhóm LED
    widget.channel.sink.add(payload);
  }
}

void _sendWsCommand(String cmd) {
  try {
    debugPrint("🚀 [WS SEND GENERIC COMMAND]: $cmd"); // 👈 Log các lệnh hiệu ứng hoặc mode khác
    widget.channel.sink.add(cmd);
  } catch (e) {
    debugPrint("❌ Lỗi gửi WS: $e");
  }
}
  void _parseConfigMap(Map<String, dynamic> raw) {
    debugPrint("======== [DEBUG] BẮT ĐẦU PARSE CONFIG MAP ========");
    debugPrint("Raw keys nhận được: ${raw.keys.toList()}");
    
    String projectName = 'Sa Bàn Tòa Nhà';
    Map<String, dynamic> projectInfo = {};
    String overviewImg = 'assets/images/overview.jpg';
    List<Map<String, dynamic>> parsedBuildings = [];
    List<Map<String, dynamic>> parsedEffects = [];

    try {
      if (raw.containsKey('active_effects') && raw['active_effects'] is List) {
        List<dynamic> rawEffects = raw['active_effects'];
        for (var eff in rawEffects) {
          if (eff['enabled'] == true) {
            IconData iconData = Icons.tune_rounded;
            String cmd = eff['cmd'] ?? '';
            if (cmd == 'TOGGLE_EVEN_ODD') iconData = Icons.auto_awesome_rounded;
            if (cmd == 'TOGGLE_METEOR') iconData = Icons.auto_graph_rounded;
            if (cmd == 'TOGGLE_BREATHING') iconData = Icons.air_rounded;
            if (cmd == 'TOGGLE_SPARKLE') iconData = Icons.stars_rounded;
            if (cmd == 'TOGGLE_SINEWAVE') iconData = Icons.waves_rounded;
            parsedEffects.add({
              'cmd': cmd,
              'name': eff['name'] ?? cmd,
              'icon': iconData,
            });
          }
        }
        if (mounted) {
          setState(() {
            _enabledEffects = parsedEffects;
          });
        }
      }

      projectName = raw['project_info']?['name'] ?? raw['p'] ?? 'Sa Bàn Tòa Nhà';
      projectInfo = raw['project_info'] ?? {};
      overviewImg = raw['assets']?['overview'] ?? 'assets/images/overview.jpg';

      List<dynamic> rows = raw['d'] ?? [];
      debugPrint("Số lượng dòng trong mảng 'd': ${rows.length}");

      Map<String, Map<String, List<Map<String, dynamic>>>> structured = {};

      // for (var row in rows) {
      //   String bName = row[0].toString();
      //   String fName = row[1].toString();
      //   String rNum = row[2].toString();
      //   int rType = int.tryParse(row[3].toString()) ?? 0;
      //   int ledIdx = int.tryParse(row[4].toString()) ?? 0;
      //   String rInfo = (row.length > 5)
      //       ? row[5].toString()
      //       : (rType >= 100 ? 'Shophouse / Tiện ích' : 'Loại $rType PN');

      //   structured.putIfAbsent(bName, () => {});
      //   structured[bName]!.putIfAbsent(fName, () => []);
      //   structured[bName]![fName]!.add({
      //     'room_number': rNum,
      //     'room_type': rType,
      //     'led_index': ledIdx,
      //     'info': rInfo,
      //   });
      // }
      // 🟢 1. Hàm làm sạch tên Tòa nhà (Thêm ngay phía trên hoặc trong class)
      String parseBuildingName(String rawStr) {
        if (rawStr.trim().isEmpty) return 'THÁP KHÁC';
        String clean = rawStr.trim().toUpperCase();
        if (clean.contains('A')) return 'THÁP A';
        if (clean.contains('B')) return 'THÁP B';
        if (clean.contains('C')) return 'THÁP C';
        if (clean.contains('D')) return 'THÁP D';
        if (clean.contains('E')) return 'THÁP E';
        return 'THÁP KHÁC';
      }

      // 🟢 2. Cập nhật vòng lặp for của bạn:
      for (var row in rows) {
        // Ép tên Tháp về chuẩn THÁP A, THÁP B... để không bao giờ bị đẻ thêm nút lỗi
        String bName = parseBuildingName(row[0].toString()); 
        String fName = row[1].toString();
        String rNum = row[2].toString();
        int rType = int.tryParse(row[3].toString()) ?? 0;
        int ledIdx = int.tryParse(row[4].toString()) ?? 0;
        String rInfo = (row.length > 5)
            ? row[5].toString()
            : (rType >= 100 ? 'Shophouse / Tiện ích' : 'Loại $rType PN');

        structured.putIfAbsent(bName, () => {});
        structured[bName]!.putIfAbsent(fName, () => []);
        structured[bName]![fName]!.add({
          'room_number': rNum,
          'room_type': rType,
          'led_index': ledIdx,
          'info': rInfo,
        });
      }

      structured.forEach((bName, floorsMap) {
        List<Map<String, dynamic>> floorsList = [];
        floorsMap.forEach((fName, roomsList) {
          floorsList.add({'name': fName, 'rooms': roomsList});
        });
        parsedBuildings.add({'name': bName, 'floors': floorsList});
      });

      debugPrint("Số lượng tòa đã parse thành công: ${parsedBuildings.length}");

    } catch (e, stackTrace) {
      debugPrint("❌❌ LỖI TRONG CÂU LỆNH CATCH _parseConfigMap: $e");
      debugPrint("Stack trace: $stackTrace");
    }

    if (mounted) {
      setState(() {
        _projectName = projectName;
        _projectInfo = projectInfo;
        _overviewImage = overviewImg;
        _buildings = parsedBuildings;
        _isLoaded = true; // 👈 CHÚ Ý: CỜ NÀY PHẢI ĐƯỢC CHUYỂN SANG TRUE
      });
      debugPrint("✅ CẬP NHẬT SETSTATE THÀNH CÔNG: _isLoaded = $_isLoaded, _buildings count = ${_buildings.length}");

      if (_onConfigReloadedFromCloud != null) {
        _onConfigReloadedFromCloud!();
      }
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
  void _parseFlatJson(String jsonStr, {required bool isFromCache}) async {
    try {
      final Map<String, dynamic> raw = jsonDecode(jsonStr);
      if (mounted) {
        setState(() {
          _dynamicUiConfig = raw['ui_config'] ?? {};
        });
      }  
      _parseConfigMap(raw);
      if (!isFromCache) {
        await ConfigService.saveConfig(widget.ip, jsonStr);
      }
    } catch (e) {
      debugPrint("Lỗi Parse Flat JSON: $e");
    }
  }
//   Future<Map<String, dynamic>> _loadRemoteConfigFast() async {
//   // 🟢 1. Load ngay config từ Asset Local để app mở vèo vèo (0.01 giây)
//   Map<String, dynamic>? localConfig;
//   try {
//     final String localJson = await rootBundle.loadString('assets/config.json');
//     localConfig = jsonDecode(localJson);
//   } catch (e) {
//     debugPrint("Lỗi đọc config local: $e");
//   }

//   // 🟢 2. Thử cập nhật ngầm từ Gist mạng
//   final String gistRawUrl =
//       'https://gist.githubusercontent.com/nguyenvandungvtdt-commits/b3440aa5a5ab9e6e69bb570b389c88cb/raw/config.json?t=${DateTime.now().millisecondsSinceEpoch}';
//   try {
//     final response = await http
//         .get(Uri.parse(gistRawUrl))
//         .timeout(const Duration(milliseconds: 1800));

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> remoteData =
//           jsonDecode(utf8.decode(response.bodyBytes));
//       return remoteData; // Trả về bản mới nhất từ Gist nếu tải xong nhanh
//     }
//   } catch (e) {
//     debugPrint('Mạng chậm/lỗi, dùng Config nội bộ: $e');
//   }

//   // Trả về bản local nếu Gist bị timeout
//   return localConfig ?? {};
// }
Future<Map<String, dynamic>> _loadRemoteConfigFast() async {
  // 1. Thử tải config từ Render Server
  final String renderConfigUrl = 'https://saban-demo.onrender.com/config';
  try {
    final response = await http
        .get(Uri.parse(renderConfigUrl))
        .timeout(const Duration(seconds: 2));
    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
  } catch (e) {
    debugPrint('Không tải được config từ Render, dùng config nội bộ: $e');
  }

  // 2. Dự phòng: Đọc file assets/config.json trực tiếp trong App
  try {
    final String localJson = await rootBundle.loadString('assets/config.json');
    return jsonDecode(localJson);
  } catch (e) {
    debugPrint('Lỗi đọc local config: $e');
    return {};
  }
}
final logger = Logger(
  printer: PrettyPrinter(methodCount: 0), 
);
Future<bool> uploadToElegantOTA(String filePath, String esp32Ip) async {
  try {
    var uri = Uri.parse("http://$esp32Ip/update");
    var request = http.MultipartRequest('POST', uri);
    var fileBytes = await File(filePath).readAsBytes();

    // 🟢 Lấy tên file thực tế từ đường dẫn (Ví dụ: "v1.0.5.bin")
    String fileName = filePath.split(RegExp(r'[/\\]')).last;

    var multipartFile = http.MultipartFile.fromBytes(
      'raw_file',
      fileBytes,
      filename: fileName, // 👈 Truyền tên file động thay vì 'sketch_oct6a.ino.bin'
    );

    request.files.add(multipartFile);
    logger.i("[OTA] Đang gửi $fileName tới $uri ...");

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      logger.i("[OTA] Nạp $fileName thành công! ESP32 đang khởi động lại...");
      return true;
    } else {
      logger.e("[OTA] Thất bại. Mã lỗi HTTP: ${response.statusCode}");
      return false;
    }
  } catch (e) {
    logger.e("[OTA] Lỗi kết nối: $e");
    return false;
  }
}
  void _resetToConnectScreen() async {
    await ConfigService.clearConfig();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ConnectScreen()),
    );
  }
  List<int> _extractLeds(List<dynamic> roomsList, {int? filterRoomType}) {
    List<int> leds = [];
    for (var r in roomsList) {
      if (filterRoomType == null || filterRoomType == 0 || r['room_type'] == filterRoomType) {
        leds.add(r['led_index']);
      }
    }
    return leds;
  }
Future<void> _downloadFirmwareToPhone() async {
  if (!mounted) return;
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
          Text('Đang kiểm tra link Firmware từ Cloud...'),
        ],
      ),
      duration: Duration(seconds: 2),
    ),
  );
  try {
    String binUrl = '';
    String version = '1.0.2';
    try {
      final configData = await _loadRemoteConfigFast();
      final firmwareInfo = configData['firmware_info'];
      if (firmwareInfo != null && firmwareInfo['bin_url'] != null) {
        binUrl = firmwareInfo['bin_url'].toString().trim();
        version = firmwareInfo['version'] ?? '1.0.2';
      }
    } catch (_) {}
    if (binUrl.isEmpty) {
      final releaseInfo = await fetchLatestRelease();
      if (releaseInfo != null) {
        binUrl = releaseInfo['download_url']!;
        version = releaseInfo['version']!;
      }
    }
    if (binUrl.isEmpty) {
      if (mounted) _showErrorSnackBar('Không tìm thấy link Firmware!');
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) {
        double downloadProgress = 0.0;
        bool isDownloading = false;
        StateSetter? setDialogState;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            setDialogState = setStateDialog;
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.download_for_offline_rounded, color: Color(0xFF0284C7)),
                  SizedBox(width: 10),
                  Text('Tải Firmware Về Máy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Phiên bản: v$version', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (isDownloading) ...[
                    LinearProgressIndicator(value: downloadProgress, color: const Color(0xFF0284C7)),
                    const SizedBox(height: 8),
                    Text('${(downloadProgress * 100).toInt()}% - Đang tải file .bin...'),
                  ] else ...[
                    const Text('File .bin sẽ được tải về lưu trữ tại thư mục Download/bin_esp32 của điện thoại.'),
                  ],
                ],
              ),
              actions: [
                if (!isDownloading) ...[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Hủy'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Bắt Đầu Tải'),
onPressed: () async {
  final messengerState = ScaffoldMessenger.of(context);
  if (setDialogState != null) {
    setDialogState!(() {
      isDownloading = true;
      downloadProgress = 0.3; // Bắt đầu hiệu ứng chạy progress
    });
  }
  try {
    final savedPath = await FirmwareService.downloadToBinFolder(binUrl, version: version);
    if (savedPath != null) {
      if (mounted) {
        setState(() {
          localDownloadedBinPath = savedPath;
        });
      }
      if (setDialogState != null) {
        setDialogState!(() {
          downloadProgress = 1.0;
        });
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      messengerState.showSnackBar(
        SnackBar(
          content: Text('Đã tải v$version vào thư mục bin_esp32!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      throw Exception("Không thể lưu file .bin vào bộ nhớ.");
    }
  } catch (e) {
    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }
    if (mounted) {
      _showErrorSnackBar('Tải file thất bại: $e');
    }
  }
},
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  } catch (e) {
    if (mounted) _showErrorSnackBar('Lỗi tải cấu hình: $e');
  }
}
Future<void> _uploadLocalBinToESP32() async {
  setState(() {
    _isOTAUploading = true;
  });
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WebOTAScreen(ip: widget.ip),
    ),
  );
  if (mounted) {
    setState(() {
      _isOTAUploading = false;
    });
    _connect(); 
  }
}
void _connect() {
  final ip = widget.ip.isNotEmpty ? widget.ip : _ipController.text.trim();
  if (ip.isEmpty) {
    debugPrint('[WS] IP không hợp lệ, không thể khởi tạo kết nối WebSocket.');
    return;
  }
  try {
    _channel?.sink.close();
    final wsUrl = Uri.parse('ws://$ip:81'); // Cổng WebSocket mặc định của ESP32 (thường là 81)
    debugPrint('[WS] Đang kết nối lại WebSocket tại: $wsUrl');
    _channel = IOWebSocketChannel.connect(
      wsUrl,
      pingInterval: const Duration(seconds: 5), // Gửi Ping giữ kết nối
    );
    if (mounted) {
      setState(() {
        _isConnected = false; // Tạm thời đặt false trong lúc chờ dữ liệu gửi về
      });
    }
    _channel!.stream.listen(
      (data) {
        debugPrint('[WS] Nhận dữ liệu từ ESP32: $data');
        if (mounted) {
          setState(() {
            _isConnected = true; // Kết nối thành công khi bắt đầu nhận dữ liệu
          });
        }
      },
      onError: (error) {
        debugPrint('[WS] Lỗi kết nối WebSocket: $error');
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          _handleDisconnection();
        }
      },
      onDone: () {
        debugPrint('[WS] Kết nối WebSocket đã đóng (onDone).');
        if (mounted) {
          setState(() {
            _isConnected = false;
          });
          _handleDisconnection();
        }
      },
      cancelOnError: true,
    );
  } catch (e) {
    debugPrint('[WS] Ngoại lệ khi khởi tạo kết nối WebSocket: $e');
    if (mounted) {
      setState(() {
        _isConnected = false;
      });
      _handleDisconnection();
    }
  }
}
void _handleDisconnection() {
  debugPrint('[WS] Kết nối ngắt. Cờ _isOTAUploading = $_isOTAUploading');
  if (_isOTAUploading) {
    debugPrint('[OTA] Đang nạp Firmware, giữ nguyên giao diện WebView.');
  } else {
    _resetToConnectScreen();
  }
}
Future<void> openWebOTAInChrome(String esp32Ip) async {
  final Uri url = Uri.parse('http://$esp32Ip/update');
  try {
    if (mounted) {
      setState(() {
        _isOTAUploading = true;
      });
      debugPrint('[OTA] Đã bật cờ _isOTAUploading = true (Trình duyệt ngoài)');
    }
    bool launched = await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    );
    if (launched) {
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && _isOTAUploading) {
          setState(() {
            _isOTAUploading = false;
          });
          debugPrint('[OTA] Tự động reset cờ _isOTAUploading sau 30s timeout');
        }
      });
    } else {
      debugPrint('[OTA] Không thể mở trình duyệt Chrome.');
      if (mounted) {
        setState(() {
          _isOTAUploading = false; // Reset cờ nếu mở thất bại
        });
      }
    }
  } catch (e) {
    debugPrint('[OTA] Lỗi mở Chrome: $e');
    if (mounted) {
      setState(() {
        _isOTAUploading = false; // Reset cờ nếu gặp lỗi
      });
    }
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
Future<void> _refreshDataFromCloud() async {
    if (_isRefreshing) {
      debugPrint('⚠️ [REFRESH] Đang trong quá trình cập nhật, bỏ qua yêu cầu!');
      return;
    }
    setState(() {
      _isRefreshing = true;
    });
    debugPrint('🚀 [REFRESH] Bắt đầu tải JSON mới từ GitHub Gist...');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang tải cấu hình & hình ảnh mới nhất...'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    final int timestamp = DateTime.now().millisecondsSinceEpoch;
    final String rawGistUrl =
        'https://gist.githubusercontent.com/nguyenvandungvtdt-commits/b3440aa5a5ab9e6e69bb570b389c88cb/raw/config.json?t=$timestamp';
    try {
      debugPrint('🌐 [REFRESH] URL Fetch: $rawGistUrl');
      final response = await http.get(
        Uri.parse(rawGistUrl),
        headers: {
          'Cache-Control': 'no-cache, no-store, must-revalidate, max-age=0',
          'Pragma': 'no-cache',
          'Expires': '0',
        },
      ).timeout(const Duration(seconds: 8));
      debugPrint('📡 [REFRESH] HTTP Response Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final String rawJsonStr = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> newData = jsonDecode(rawJsonStr);
        debugPrint('📦 [REFRESH] Đã parse JSON thành công! Tổng số phòng trong "d": ${(newData['d'] as List?)?.length}');
        await ConfigService.saveConfig(widget.ip, rawJsonStr);
        debugPrint('⚡ [REFRESH] Gửi lệnh RESET_ALL sang ESP32...');
        widget.channel.sink.add("RESET_ALL");
        debugPrint('✅ [REFRESH] Đã bắn lệnh RESET_ALL sang ESP32!');
        debugPrint('🖼️ [REFRESH] Đang xóa ImageCache Flutter...');
        debugPrint('⚙️ [REFRESH] Đang parse lại Config Map sang UI...');
        setState(() {
          localLedStates.clear(); // Clear trạng thái LED cũ
          _dynamicUiConfig = newData['ui_config'] ?? {}; // Cập nhật ngay layout nút bấm & position mới
          _parseConfigMap(newData); // Parse lại danh sách phòng, tòa nhà
        });
        debugPrint('🎉 [REFRESH] Hoàn tất toàn bộ tiến trình cập nhật!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thành công! Đã reset toàn bộ sa bàn.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        debugPrint('❌ [REFRESH] Lỗi HTTP: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thất bại! Mã lỗi: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('💥 [REFRESH] Lỗi Catch Exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối máy chủ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
      debugPrint('🏁 [REFRESH] Hoàn thành hàm _refreshDataFromCloud()');
    }
  }
//   void _toggleLedList(List<int> ledIndices, bool targetState) {
//   if (ledIndices.isEmpty) return;
//   setState(() {
//     _activeEffect = 'MANUAL';
//     for (int ledIdx in ledIndices) {
//       _ledStates[ledIdx] = targetState; // 👈 Sử dụng thống nhất _ledStates
//     }
//   });
//   if (ledIndices.length == 1) {
//     widget.channel.sink.add('${ledIndices.first}:${targetState ? 1 : 0}');
//   } else {
//     String idsJoined = ledIndices.join(',');
//     String payload = 'ALL:${targetState ? 1 : 0}:$idsJoined';
//     widget.channel.sink.add(payload);
//   }
// }
//   void _sendWsCommand(String cmd) {
//     try {
//       widget.channel.sink.add(cmd);
//     } catch (e) {
//       debugPrint("Lỗi gửi WS: $e");
//     }
//   }
  void _showQuickEditDialog(BuildContext context) {
  final TextEditingController urlController = TextEditingController(text: _overviewImage);
  final TextEditingController nameController = TextEditingController(text: _projectName);
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: Color(0xFF0369A1)),
            SizedBox(width: 8),
            Text('Cập Nhật Trực Tiếp Sa Bàn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên Dự Án',
                  prefixIcon: Icon(Icons.business),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'URL Ảnh Sa Bàn (GitHub CDN / Direct Link)',
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _overviewImage = image.path;
                    });
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Chọn ảnh từ Thư viện'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _projectName = nameController.text.trim();
                // 🟢 Đã bỏ _parseDriveUrl, gán trực tiếp URL đã trim()
                _overviewImage = urlController.text.trim();
              });
              Navigator.pop(dialogContext);
            },
            child: const Text('Áp Dụng Ngay'),
          ),
        ],
      );
    },
  );
}
  void _showEffectControlBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            _onModeChangedFromHardware = (newMode) {
              setModalState(() {});
            };
            _onConfigReloadedFromCloud = () {
              setModalState(() {});
            };
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune_rounded, color: Color(0xFF0284C7), size: 20),
                          SizedBox(width: 6),
                          Text(
                            'CẤU HÌNH HIỆU ỨNG & TỐC ĐỘ',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(modalContext),
                        icon: const Icon(Icons.close_rounded, color: Colors.grey, size: 20),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  ..._enabledEffects.map((eff) {
                    String cmd = eff['cmd'];
                    String title = eff['name'];
                    IconData icon = eff['icon'];
                    double val = 60;
                    double min = 20;
                    double max = 200;
                    String unit = 'ms';
                    if (cmd == 'TOGGLE_EVEN_ODD') {
                      val = _evenOddSpeed; min = 1; max = 10; unit = 'giây';
                    } else if (cmd == 'TOGGLE_METEOR') {
                      val = _meteorSpeed; min = 50; max = 500; unit = 'ms';
                    } else if (cmd == 'TOGGLE_BREATHING') {
                      val = _breathSpeed; min = 20; max = 200; unit = 'ms';
                    } else if (cmd == 'TOGGLE_SPARKLE') {
                      val = _sparkleSpeed; min = 100; max = 1000; unit = 'ms';
                    } else if (cmd == 'TOGGLE_SINEWAVE') {
                      val = _sineSpeed; min = 20; max = 200; unit = 'ms';
                    }
                    return _buildCompactEffectRow(
                      title: title,
                      cmd: cmd,
                      icon: icon,
                      value: val,
                      min: min,
                      max: max,
                      unit: unit,
                      setModalState: setModalState,
                      onChanged: (newVal) {
                        setModalState(() {
                          if (cmd == 'TOGGLE_EVEN_ODD') _evenOddSpeed = newVal;
                          if (cmd == 'TOGGLE_METEOR') _meteorSpeed = newVal;
                          if (cmd == 'TOGGLE_BREATHING') _breathSpeed = newVal;
                          if (cmd == 'TOGGLE_SPARKLE') _sparkleSpeed = newVal;
                          if (cmd == 'TOGGLE_SINEWAVE') _sineSpeed = newVal;
                        });
                        setState(() {});
                        String speedCmd = 'SPEED_BREATHING:${newVal.toInt()}';
                        if (cmd == 'TOGGLE_EVEN_ODD') speedCmd = 'SPEED_EVEN_ODD:${(newVal * 1000).toInt()}';
                        if (cmd == 'TOGGLE_METEOR') speedCmd = 'SPEED_METEOR:${newVal.toInt()}';
                        if (cmd == 'TOGGLE_SPARKLE') speedCmd = 'SPEED_SPARKLE:${newVal.toInt()}';
                        if (cmd == 'TOGGLE_SINEWAVE') speedCmd = 'SPEED_SINEWAVE:${newVal.toInt()}';
                        _sendWsCommand(speedCmd);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      _onModeChangedFromHardware = null;
      _onConfigReloadedFromCloud = null;
    });
  }
  Widget _buildCompactEffectRow({
    required String title,
    required String cmd,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String unit,
    required StateSetter setModalState,
    required ValueChanged<double> onChanged,
  }) {
    bool isActive = _activeEffect == cmd;
    return Container(
      margin: const EdgeInsets.only(bottom: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFF0284C7) : const Color(0xFFE2E8F0),
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  setModalState(() {
                    _activeEffect = isActive ? 'MANUAL' : cmd;
                  });
                  setState(() {
                    _activeEffect = isActive ? 'MANUAL' : cmd;
                  });
                  _sendWsCommand(cmd);
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)])
                        : const LinearGradient(colors: [Color(0xFFF1F5F9), Color(0xFFE2E8F0)]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 15, color: isActive ? Colors.white : const Color(0xFF0369A1)),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.white : const Color(0xFF0369A1),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isActive ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Tốc độ: ',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              Text(
                '${value.toInt()} $unit',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF0284C7) : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 24,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: isActive ? 3.5 : 2.5,
                activeTrackColor: isActive ? const Color(0xFF0284C7) : Colors.grey.shade400,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                thumbColor: isActive ? const Color(0xFF0284C7) : Colors.grey.shade500,
                overlayColor: const Color(0xFF0284C7).withValues(alpha: 0.12),
                thumbShape: RoundSliderThumbShape(enabledThumbRadius: isActive ? 6.5 : 5.0),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
  bool _areAllLedsOn(List<int> ledIndices) {
  if (ledIndices.isEmpty) return false;
  for (int ledIdx in ledIndices) {
    if (!(_ledStates[ledIdx] ?? false)) {
      return false; 
    }
  }
  return true; // Tất cả LED trong nhóm đều đang BẬT
}
  List<int> _getAllSabanLeds({int? filterType}) {
  List<int> allLeds = [];
  for (var b in _buildings) {
    for (var f in b['floors']) {
      List<dynamic> rooms = f['rooms'] ?? [];
      if (filterType == null) {
        allLeds.addAll(_extractLeds(rooms));
      } 
      else if (filterType == 0) {
        var apartmentRooms = rooms.where((r) {
          int rType = int.tryParse(r['room_type'].toString()) ?? 0;
          return rType < 100;
        }).toList();
        allLeds.addAll(_extractLeds(apartmentRooms));
      } 
      else if (filterType == 1000) {
        var utilityRooms = rooms.where((r) {
          int rType = int.tryParse(r['room_type'].toString()) ?? 0;
          return rType >= 100;
        }).toList();
        allLeds.addAll(_extractLeds(utilityRooms));
      } 
      else {
        allLeds.addAll(_extractLeds(rooms, filterRoomType: filterType));
      }
    }
  }
  return allLeds;
}
Widget _buildDynamicControlPanel(
  BuildContext context,
  double screenWidth,
  bool isPhone,
  List<int> allSabanLeds,
  bool isMasterOn,
  Map<String, dynamic> uiLayoutConfig,
) {
  List<dynamic> sections = uiLayoutConfig['sections'] ?? [];
  if (sections.isEmpty) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: isPhone ? 10 : 16,
      vertical: isPhone ? 8 : 10,
    ),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFE0F2FE).withValues(alpha: 0.92),
          const Color(0xFFF0F9FF).withValues(alpha: 0.96),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
        width: 1.5,
      ),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: InkWell(
            onTap: () => _toggleLedList(allSabanLeds, !isMasterOn),
            onDoubleTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BuildingsListScreen(
        buildings: _buildings,
        ledStates: localLedStates, // Dùng biến localLedStates đang lưu trạng thái LED
        onToggleLeds: _toggleLedList,
        isAnyLedOn: _areAllLedsOn,
        extractLeds: _extractLeds,
        selectedFilterType: 0,
      ),
    ),
  );
},
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                vertical: isPhone ? 6 : 8,
                horizontal: isPhone ? 20 : 36,
              ),
              decoration: BoxDecoration(
                gradient: isMasterOn
                    ? const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)])
                    : const LinearGradient(colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMasterOn ? Colors.amberAccent : const Color(0xFF0284C7),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMasterOn ? Icons.lightbulb : Icons.lightbulb_outline,
                    size: isPhone ? 15 : 17,
                    color: isMasterOn ? Colors.white : const Color(0xFF0369A1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TỔNG SA BÀN (${isMasterOn ? "BẬT" : "TẮT"})',
                    style: TextStyle(
                      fontSize: isPhone ? 11.5 : 13.0,
                      fontWeight: FontWeight.bold,
                      color: isMasterOn ? Colors.white : const Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: isPhone ? 8 : 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(sections.length, (sectionIdx) {
              var section = sections[sectionIdx];
              List<dynamic> rows = section['rows'] ?? [];
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          UnconstrainedBox(
                            child: _buildCommercialButton(
                              label: section['title'] ?? '',
                              filterType: section['master_filter_type'] ?? 0,
                              isPhone: isPhone,
                              isHeaderGroup: true,
                            ),
                          ),
                          SizedBox(height: isPhone ? 6 : 8),
                          ...rows.map((rowItems) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: (rowItems as List).map((btn) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                      child: _buildCommercialButton(
                                        label: btn['label'],
                                        filterType: btn['filter_type'],
                                        isPhone: isPhone,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    if (sectionIdx < sections.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: VerticalDivider(
                          color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          thickness: 1.2,
                          width: 1,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '• Chạm 1 lần: Bật/Tắt Căn   |   • Nhấn đúp 2 lần: Danh sách Tòa nhà',
          style: TextStyle(
            fontSize: isPhone ? 8.5 : 10.0,
            color: const Color(0xFF0284C7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
Widget _buildCommercialButton({
  required String label,
  required int filterType,
  required bool isPhone,
  bool isHeaderGroup = false, // Thêm cờ để nhận diện nút tiêu đề nhóm
}) {
  List<int> ledsOfThisType = _getAllSabanLeds(filterType: filterType);
  bool isTypeOn = _areAllLedsOn(ledsOfThisType);
  return InkWell(
    onTap: () => _toggleLedList(ledsOfThisType, !isTypeOn),
    borderRadius: BorderRadius.circular(8),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        vertical: isPhone ? (isHeaderGroup ? 8 : 6) : (isHeaderGroup ? 10 : 8),
        horizontal: isPhone ? (isHeaderGroup ? 16 : 10) : (isHeaderGroup ? 20 : 14),
      ),
      decoration: BoxDecoration(
        gradient: isTypeOn
            ? const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFF57C00)])
            : const LinearGradient(colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)]),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isTypeOn ? Colors.amberAccent : const Color(0xFFF472B6),
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isPhone ? (isHeaderGroup ? 11.0 : 10.0) : (isHeaderGroup ? 12.5 : 11.0),
          fontWeight: isTypeOn || isHeaderGroup ? FontWeight.bold : FontWeight.w600,
          color: isTypeOn ? Colors.white : const Color(0xFF831843),
        ),
      ),
    ),
  );
}
  Widget _buildTopBar(BuildContext context, bool isPhone) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.85),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded, color: Color(0xFF0369A1), size: 22),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onSelected: (value) {
                if (value == 'reset') {
                  _resetToConnectScreen();
                } else if (value == 'cloud') {
                  _refreshDataFromCloud();
                } else if (value == 'edit') {
                  _showQuickEditDialog(context);
                } else if (value == 'effects') {
                  _showEffectControlBottomSheet(context);
                } else if (value == 'motor') {
                  _toggleMotor(!_isMotorActive);
                } else if (value == 'download_ota') {
                  _downloadFirmwareToPhone();
                } else if (value == 'upload_ota') {
                  _uploadLocalBinToESP32();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'motor',
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_car_filled_rounded,
                        color: _isMotorActive ? const Color(0xFF0284C7) : Colors.grey[600],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Mô-tơ Xe/Tàu Từ Trường',
                          style: TextStyle(
                            fontWeight: _isMotorActive ? FontWeight.bold : FontWeight.normal,
                            color: _isMotorActive ? const Color(0xFF0284C7) : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isMotorActive ? Colors.green : Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'effects',
                  child: Row(
                    children: [
                      Icon(Icons.tune_rounded, color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Chế độ & Tốc độ Hiệu ứng'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'download_ota',
                  child: Row(
                    children: [
                      Icon(Icons.download_for_offline_rounded, color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('1. Tải Firmware về Máy (.bin)'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'upload_ota',
                  child: Row(
                    children: [
                      Icon(Icons.upload_file_rounded, color: Colors.green, size: 20),
                      SizedBox(width: 10),
                      Text('2. Nạp File .bin Sang Sa Bàn'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'cloud',
                  child: Row(
                    children: [
                      Icon(Icons.cloud_download_outlined, color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Đồng bộ dữ liệu Cloud'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Color(0xFF0284C7), size: 20),
                      SizedBox(width: 10),
                      Text('Chỉnh sửa tên & ảnh sa bàn'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.sync_disabled_outlined, color: Colors.redAccent, size: 20),
                      SizedBox(width: 10),
                      Text('Đổi IP / Đặt lại kết nối', style: TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 12.0 : 20.0,
                    vertical: 7.0,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_city_rounded,
                          size: 17,
                          color: Color(0xFF0369A1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _projectName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0369A1),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0284C7),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => InfoDialog(
                      title: _projectName,
                      details: _projectInfo.map(
                        (key, value) => MapEntry(key.toString(), value.toString()),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
void dispose() {
  _otaWatchdogTimer?.cancel();
  super.dispose();
}
  @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded) {
//       return const Scaffold(
//         backgroundColor: Color(0xFFF0F9FF),
//         body: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               CircularProgressIndicator(color: Color(0xFF0284C7)),
//               SizedBox(height: 16),
//               Text(
//                 'Đang tải dữ liệu sa bàn mới nhất...',
//                 style: TextStyle(
//                   color: Color(0xFF0369A1),
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//     List<int> allSabanLeds = _getAllSabanLeds();
//     bool isMasterOn = _areAllLedsOn(allSabanLeds);
//     return Scaffold(
//       body: Stack(
//         fit: StackFit.expand,
//         children: [
//           Positioned.fill(
//             child: _overviewImage.startsWith('http')
//                 ? Image.network(_overviewImage, fit: BoxFit.cover)
//                 : Image.asset(_overviewImage, fit: BoxFit.cover),
//           ),
//           Positioned.fill(
//             child: BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       const Color(0xFFF0F9FF).withValues(alpha: 0.88),
//                       const Color(0xFFE0F2FE).withValues(alpha: 0.82),
//                       const Color(0xFFF8FAFC).withValues(alpha: 0.92),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
// SafeArea(
//   child: LayoutBuilder(
//     builder: (context, constraints) {
//       double screenWidth = constraints.maxWidth;
//       bool isPhone = screenWidth < 600;
//       String position = _dynamicUiConfig['position'] ?? 'bottom';
//       Widget imageWidget = Expanded(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: isPhone ? 8.0 : 12.0,
//             vertical: isPhone ? 4.0 : 6.0,
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(20),
//             child: InteractiveViewer(
//   minScale: 1.0,
//   maxScale: 4.0,
//   child: Center(
//     child: _overviewImage.startsWith('http')
//         ? CachedNetworkImage(
//             imageUrl: _overviewImage,
//             width: double.infinity,
//             height: double.infinity,
//             fit: isPhone ? BoxFit.contain : BoxFit.fitWidth,
//             alignment: isPhone ? Alignment.center : Alignment.topCenter,
//             placeholder: (context, url) => const Center(
//               child: CircularProgressIndicator(color: Color(0xFF0284C7)),
//             ),
//             errorWidget: (context, url, error) => const Icon(Icons.error),
//           )
//         : Image.asset(
//             _overviewImage,
//             width: double.infinity,
//             height: double.infinity,
//             fit: isPhone ? BoxFit.contain : BoxFit.fitWidth,
//             alignment: isPhone ? Alignment.center : Alignment.topCenter,
//           ),
//   ),
// ),
//           ),
//         ),
//       );
//       Widget controlPanelWidget = _buildDynamicControlPanel(
//         context,
//         screenWidth,
//         isPhone,
//         allSabanLeds,
//         isMasterOn,
//         _dynamicUiConfig,
//       );
//       Widget contentBody;
//       if (position == 'top') {
//         contentBody = Column(
//           children: [
//             controlPanelWidget, // Bảng nút ở trên
//             imageWidget,        // Ảnh ở dưới
//           ],
//         );
//       } else if (position == 'left') {
//         contentBody = Row(
//           children: [
//             SizedBox(
//               width: screenWidth * 0.35, // Chiếm 35% chiều rộng bên trái
//               child: SingleChildScrollView(child: controlPanelWidget),
//             ),
//             imageWidget, // Ảnh nằm bên phải
//           ],
//         );
//       } else if (position == 'right') {
//         contentBody = Row(
//           children: [
//             imageWidget, // Ảnh nằm bên trái
//             SizedBox(
//               width: screenWidth * 0.35, // Chiếm 35% chiều rộng bên phải
//               child: SingleChildScrollView(child: controlPanelWidget),
//             ),
//           ],
//         );
//       } else {
//         contentBody = Column(
//           children: [
//             imageWidget,        // Ảnh ở trên
//             controlPanelWidget, // Bảng nút ở dưới
//           ],
//         );
//       }
//       return Column(
//         children: [
//           _buildTopBar(context, isPhone),
//           Expanded(child: contentBody), // Hiển thị bố cục đã linh hoạt sắp xếp
//         ],
//       );
//     },
//   ),
// ),
//         ],
//       ),
//     );
//   }

// @override
// Widget build(BuildContext context) {
//   if (!_isLoaded) {
//     return const Scaffold(
//       backgroundColor: Color(0xFFF0F9FF),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(color: Color(0xFF0284C7)),
//             SizedBox(height: 16),
//             Text(
//               'Đang tải dữ liệu sa bàn mới nhất...',
//               style: TextStyle(
//                 color: Color(0xFF0369A1),
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<int> allSabanLeds = _getAllSabanLeds();
//   bool isMasterOn = _areAllLedsOn(allSabanLeds);

//   return Scaffold(
//     body: Stack(
//       fit: StackFit.expand,
//       children: [
//         // Background ảnh mờ phía sau
//         Positioned.fill(
//           child: _overviewImage.startsWith('http')
//               ? Image.network(_overviewImage, fit: BoxFit.cover)
//               : Image.asset(_overviewImage, fit: BoxFit.cover),
//         ),
//         Positioned.fill(
//           child: BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     const Color(0xFFF0F9FF).withValues(alpha: 0.88),
//                     const Color(0xFFE0F2FE).withValues(alpha: 0.82),
//                     const Color(0xFFF8FAFC).withValues(alpha: 0.92),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               double screenWidth = constraints.maxWidth;
//               bool isPhone = screenWidth < 600;
//               String position = _dynamicUiConfig['position'] ?? 'bottom';

//               // 🟢 Widget hiển thị ảnh Sa bàn đã tối ưu (Offline-first & BoxFit.contain)
//               Widget imageWidget = Expanded(
//   child: Padding(
//     padding: EdgeInsets.symmetric(
//       horizontal: isPhone ? 8.0 : 12.0,
//       vertical: isPhone ? 4.0 : 6.0,
//     ),
//     child: ClipRRect(
//       borderRadius: BorderRadius.circular(20),
//       child: InteractiveViewer(
//         minScale: 1.0,
//         maxScale: 4.0,
//         child: SizedBox(
//           width: double.infinity,
//           height: double.infinity,
//           child: _overviewImage.startsWith('http')
//               ? CachedNetworkImage(
//                   imageUrl: _overviewImage,
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover, // 🟢 Đổi sang BoxFit.cover để tràn đẹp 100% hai bên như bên Building
//                   alignment: Alignment.center,
//                   placeholder: (context, url) => Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       Image.asset(
//                         'assets/images/overview.jpg',
//                         fit: BoxFit.cover,
//                       ),
//                       const Center(
//                         child: CircularProgressIndicator(color: Color(0xFF0284C7)),
//                       ),
//                     ],
//                   ),
//                   errorWidget: (context, url, error) => Image.asset(
//                     'assets/images/overview.jpg',
//                     fit: BoxFit.cover,
//                   ),
//                 )
//               : Image.asset(
//                   _overviewImage,
//                   width: double.infinity,
//                   height: double.infinity,
//                   fit: BoxFit.cover, // 🟢 Phủ kín full tràn viền
//                   alignment: Alignment.center,
//                   errorBuilder: (context, error, stackTrace) => Image.asset(
//                     'assets/images/overview.jpg',
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//         ),
//       ),
//     ),
//   ),
// );

//               Widget controlPanelWidget = _buildDynamicControlPanel(
//                 context,
//                 screenWidth,
//                 isPhone,
//                 allSabanLeds,
//                 isMasterOn,
//                 _dynamicUiConfig,
//               );

//               Widget contentBody;
//               if (position == 'top') {
//                 contentBody = Column(
//                   children: [
//                     controlPanelWidget, // Bảng nút ở trên
//                     imageWidget,        // Ảnh ở dưới
//                   ],
//                 );
//               } else if (position == 'left') {
//                 contentBody = Row(
//                   children: [
//                     SizedBox(
//                       width: screenWidth * 0.35, // Chiếm 35% chiều rộng bên trái
//                       child: SingleChildScrollView(child: controlPanelWidget),
//                     ),
//                     imageWidget, // Ảnh nằm bên phải
//                   ],
//                 );
//               } else if (position == 'right') {
//                 contentBody = Row(
//                   children: [
//                     imageWidget, // Ảnh nằm bên trái
//                     SizedBox(
//                       width: screenWidth * 0.35, // Chiếm 35% chiều rộng bên phải
//                       child: SingleChildScrollView(child: controlPanelWidget),
//                     ),
//                   ],
//                 );
//               } else {
//                 contentBody = Column(
//                   children: [
//                     imageWidget,        // Ảnh ở trên
//                     controlPanelWidget, // Bảng nút ở dưới
//                   ],
//                 );
//               }

//               return Column(
//                 children: [
//                   _buildTopBar(context, isPhone),
//                   Expanded(child: contentBody), // Hiển thị bố cục linh hoạt
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     ),
//   );
// }
@override
Widget build(BuildContext context) {
  debugPrint("🔍 [DEBUG BUILD] _isLoaded = $_isLoaded | _buildings length = ${_buildings.length} | _dynamicUiConfig = $_dynamicUiConfig");
  if (!_isLoaded) {
    return const Scaffold(
      backgroundColor: Color(0xFFF0F9FF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF0284C7)),
            SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu sa bàn mới nhất...',
              style: TextStyle(
                color: Color(0xFF0369A1),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<int> allSabanLeds = _getAllSabanLeds();
  bool isMasterOn = _areAllLedsOn(allSabanLeds);

  return Scaffold(
    body: Stack(
      fit: StackFit.expand,
      children: [
        // Background ảnh mờ phía sau
        Positioned.fill(
          child: _overviewImage.startsWith('http')
              ? Image.network(_overviewImage, fit: BoxFit.cover)
              : Image.asset(_overviewImage, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF0F9FF).withValues(alpha: 0.88),
                    const Color(0xFFE0F2FE).withValues(alpha: 0.82),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;
              bool isPhone = screenWidth < 600;
              String position = _dynamicUiConfig['position'] ?? 'bottom';

              // 🟢 imageWidget được đặt trong Expanded để vừa vặn với không gian còn lại trên màn hình
              Widget imageWidget = Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isPhone ? 8.0 : 12.0,
                    vertical: isPhone ? 4.0 : 6.0,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _overviewImage.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: _overviewImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover, // Tràn đẹp full 2 bên như màn Building
                                alignment: Alignment.bottomCenter, // 👈 Ưu tiên hiển thị phần chân tòa nhà và mặt đường
                                placeholder: (context, url) => Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(
                                      'assets/images/overview.jpg',
                                      fit: BoxFit.cover,
                                      alignment: Alignment.bottomCenter,
                                    ),
                                    const Center(
                                      child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                                    ),
                                  ],
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/overview.jpg',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.bottomCenter,
                                ),
                              )
                            : Image.asset(
                                _overviewImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                alignment: Alignment.bottomCenter, // 👈 Căn sát đáy để không mất mặt đường
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/images/overview.jpg',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.bottomCenter,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              );

              Widget controlPanelWidget = _buildDynamicControlPanel(
                context,
                screenWidth,
                isPhone,
                allSabanLeds,
                isMasterOn,
                _dynamicUiConfig,
              );

              Widget contentBody;
              if (position == 'top') {
                contentBody = Column(
                  children: [
                    controlPanelWidget, // Bảng nút ở trên
                    imageWidget,        // Ảnh ở dưới
                  ],
                );
              } else if (position == 'left') {
                contentBody = Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.35,
                      child: SingleChildScrollView(child: controlPanelWidget),
                    ),
                    imageWidget,
                  ],
                );
              } else if (position == 'right') {
                contentBody = Row(
                  children: [
                    imageWidget,
                    SizedBox(
                      width: screenWidth * 0.35,
                      child: SingleChildScrollView(child: controlPanelWidget),
                    ),
                  ],
                );
              } else {
                contentBody = Column(
                  children: [
                    imageWidget,        // Ảnh chiếm không gian phía trên
                    controlPanelWidget, // Bảng nút bấm xuất hiện đầy đủ phía dưới
                  ],
                );
              }

              return Column(
                children: [
                  _buildTopBar(context, isPhone),
                  Expanded(child: contentBody),
                ],
              );
            },
          ),
        ),
      ],
    ),
  );
}
}