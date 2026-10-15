// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import '../services/websocket_service.dart';
// import '../widgets/info_dialog.dart';

// class RoomsListScreen extends StatefulWidget {
//   final String floorName;
//   final List<dynamic> rooms;
//   final Map<int, bool> ledStates;
//   final Function(List<int> leds, bool state) onToggleLeds;
//   final bool Function(List<int> leds) isAnyLedOn;
//   final String? roomImageConfig;

//   const RoomsListScreen({
//     super.key,
//     required this.floorName,
//     required this.rooms,
//     required this.ledStates,
//     required this.onToggleLeds,
//     required this.isAnyLedOn,
//     this.roomImageConfig,
//   });

//   @override
//   State<RoomsListScreen> createState() => _RoomsListScreenState();
// }

// class _RoomsListScreenState extends State<RoomsListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String roomImagePath = widget.roomImageConfig ?? 'assets/images/room.jpg';

//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           // Bán kính/Chiều rộng màn hình
//           final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
//           final bool isTablet = constraints.maxWidth > 600;

//           return Stack(
//             fit: StackFit.expand,
//             children: [
//               // 1. Ảnh nền phòng
//               Positioned.fill(
//                 child: roomImagePath.startsWith('http')
//                     ? Image.network(
//                         roomImagePath,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
//                       )
//                     : Image.asset(
//                         roomImagePath,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
//                       ),
//               ),

//               // 2. Lớp phủ Gradient Tối
//               Positioned.fill(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.black.withValues(alpha: 0.6),
//                         Colors.transparent,
//                         Colors.black.withValues(alpha: 0.8),
//                       ],
//                       stops: const [0.0, 0.45, 1.0],
//                     ),
//                   ),
//                 ),
//               ),

//               // 3. Giao diện chính Responsive
//               SafeArea(
//                 child: Column(
//                   children: [
//                     // Top Bar
//                     _buildTopBar(context),

//                     // Nội dung linh hoạt theo hướng màn hình
//                     Expanded(
//                       child: isLandscape || isTablet
//                           ? Row(
//                               children: [
//                                 const Spacer(),
//                                 Container(
//                                   width: isTablet && !isLandscape ? constraints.maxWidth * 0.8 : 420,
//                                   margin: const EdgeInsets.all(16),
//                                   child: _buildControlPanel(context, isTablet: true),
//                                 ),
//                               ],
//                             )
//                           : Column(
//                               children: [
//                                 const Spacer(),
//                                 Container(
//                                   margin: const EdgeInsets.all(16),
//                                   child: _buildControlPanel(context, isTablet: false),
//                                 ),
//                               ],
//                             ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // Top Bar
//   Widget _buildTopBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.black54,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               widget.floorName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 shadows: [Shadow(blurRadius: 10, color: Colors.black)],
//               ),
//             ),
//           ),
//           CircleAvatar(
//             backgroundColor: const Color(0xFF0284C7),
//             child: IconButton(
//               icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
//               onPressed: () {
//                 InfoDialog.show(
//                   context,
//                   title: 'Thông Tin ${widget.floorName}',
//                   details: {
//                     'Số lượng căn': '${widget.rooms.length} Căn hộ',
//                     'Loại hình': 'Căn hộ thương mại cao cấp',
//                     'Sơ đồ': 'Mặt bằng căn hộ điển hình',
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Bảng điều khiển chứa danh sách căn hộ
//   Widget _buildControlPanel(BuildContext context, {required bool isTablet}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE0F2FE).withValues(alpha: 0.94),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFBAE6FD), width: 1.8),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black38,
//             blurRadius: 20,
//             offset: Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.meeting_room, size: 16, color: Color(0xFF0369A1)),
//               SizedBox(width: 6),
//               Flexible(
//                 child: FittedBox(
//                   fit: BoxFit.scaleDown,
//                   child: Text(
//                     'ĐIỀU KHIỂN CĂN HỘ TRỰC TIẾP',
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF0369A1),
//                       letterSpacing: 1.1,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),

//           // Grid chứa nút căn hộ tự tương thích Responsive
//           LayoutBuilder(
//             builder: (context, constraints) {
//               int crossAxisCount = 2;
//               if (constraints.maxWidth > 400) crossAxisCount = 3;
//               if (constraints.maxWidth > 600) crossAxisCount = 4;

//               return ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.45,
//                 ),
//                 child: SingleChildScrollView(
//                   child: GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: crossAxisCount,
//                       crossAxisSpacing: 8,
//                       mainAxisSpacing: 8,
//                       childAspectRatio: 2.1,
//                     ),
//                     itemCount: widget.rooms.length,
//                     itemBuilder: (context, index) => _buildRoomButton(widget.rooms[index]),
//                   ),
//                 ),
//               );
//             },
//           ),

//           const SizedBox(height: 10),
//           const FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               '• Chạm 1 lần: Bật/Tắt Đèn Căn Hộ   |   • Nhấn đúp 2 lần: Xem Chi Tiết Căn Hộ',
//               style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Nút Căn Hộ
//   Widget _buildRoomButton(dynamic room) {
//     int ledIdx = room['led_index'] ?? room['hardwareIndex'] ?? 0;
//     bool isOn = widget.ledStates[ledIdx] ?? false;
//     String roomName = room['room_number'] ?? room['name'] ?? 'Phòng';
//     int roomType = room['room_type'] ?? room['type'] ?? 0;
//     String roomInfo = room['info'] ?? 'Loại ${roomType + 1}PN';

//     return InkWell(
//       onTap: () {
//         bool newState = !isOn;
//         widget.onToggleLeds([ledIdx], newState);
//         WebSocketService().sendSingleRoom(ledIdx, newState);
//         setState(() {});
//       },
//       onDoubleTap: () {
//         InfoDialog.show(
//           context,
//           title: 'Chi Tiết $roomName',
//           details: {
//             'Tên căn hộ': roomName,
//             'Loại căn': '${roomType + 1} Phòng Ngủ',
//             'Chỉ số LED': 'HardwareIndex #$ledIdx',
//             'Thông tin': roomInfo,
//           },
//         );
//       },
//       borderRadius: BorderRadius.circular(14),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//         decoration: BoxDecoration(
//           gradient: isOn
//               ? const LinearGradient(
//                   colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 )
//               : const LinearGradient(
//                   colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(
//             color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
//             width: 1.5,
//           ),
//           boxShadow: isOn
//               ? [
//                   BoxShadow(
//                     color: Colors.orange.withValues(alpha: 0.4),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [
//                   BoxShadow(
//                     color: Colors.pink.withValues(alpha: 0.1),
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(4),
//               decoration: BoxDecoration(
//                 color: isOn
//                     ? Colors.white.withValues(alpha: 0.25)
//                     : const Color(0xFFF472B6).withValues(alpha: 0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isOn ? Icons.lightbulb : Icons.king_bed_outlined,
//                 size: 14,
//                 color: isOn ? Colors.white : const Color(0xFFDB2777),
//               ),
//             ),
//             const SizedBox(width: 6),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       roomName,
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                         color: isOn ? Colors.white : const Color(0xFF831843),
//                       ),
//                     ),
//                   ),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     child: Text(
//                       'LED #$ledIdx | ${isOn ? "BẬT" : "TẮT"}',
//                       style: TextStyle(
//                         fontSize: 9,
//                         fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
//                         color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/websocket_service.dart';
import '../widgets/info_dialog.dart';

class RoomsListScreen extends StatefulWidget {
  final String floorName;
  final List<dynamic> rooms;
  final Map<int, bool> ledStates;
  final Function(List<int> leds, bool state) onToggleLeds;
  final bool Function(List<int> leds) isAnyLedOn;
  final String? roomImageConfig;

  const RoomsListScreen({
    super.key,
    required this.floorName,
    required this.rooms,
    required this.ledStates,
    required this.onToggleLeds,
    required this.isAnyLedOn,
    this.roomImageConfig,
  });

  @override
  State<RoomsListScreen> createState() => _RoomsListScreenState();
}

class _RoomsListScreenState extends State<RoomsListScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  List<List<dynamic>> _chunkRooms(List<dynamic> list, int itemsPerRow) {
    List<List<dynamic>> chunks = [];
    for (int i = 0; i < list.length; i += itemsPerRow) {
      int end = (i + itemsPerRow < list.length) ? i + itemsPerRow : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final String roomImagePath = widget.roomImageConfig ?? 'assets/images/room.jpg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. NỀN MỜ GLASSMORPHISM TONE SÁNG
          Positioned.fill(
            child: roomImagePath.startsWith('http')
                ? Image.network(
                    roomImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFE0F2FE)),
                  )
                : Image.asset(
                    roomImagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(color: const Color(0xFFE0F2FE)),
                  ),
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

          // 2. NỘI DUNG GIAO DIỆN CHÍNH
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                bool isPhone = screenWidth < 600;

                return Column(
                  children: [
                    _buildTopBar(context),

                    // KHU VỰC HIỂN THỊ MẶT BẰNG CĂN HỘ (BỎ KHUNG THỪA - BO TRÒN ẢNH VỚI BÓNG 3D)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 12.0 : 16.0,
                          vertical: isPhone ? 4.0 : 8.0,
                        ),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.22),
                                  blurRadius: 24,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: InteractiveViewer(
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: roomImagePath.startsWith('http')
                                    ? Image.network(
                                        roomImagePath,
                                        fit: BoxFit.contain, // Hiển thị 100% hình ảnh vừa khít
                                        alignment: Alignment.center,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                            child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(color: Colors.white),
                                      )
                                    : Image.asset(
                                        roomImagePath,
                                        fit: BoxFit.contain, // Hiển thị 100% hình ảnh vừa khít
                                        alignment: Alignment.center,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // BẢNG ĐIỀU KHIỂN CĂN HỘ GỌN GÀNG
                    Padding(
                      padding: EdgeInsets.all(isPhone ? 8.0 : 12.0),
                      child: _buildAdaptiveRoomPanel(context, isPhone),
                    ),
                  ],
                );
              },
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
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0369A1), size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
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
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.meeting_room_rounded,
                      size: 18,
                      color: Color(0xFF0369A1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.floorName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0369A1),
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
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
                  InfoDialog.show(
                    context,
                    title: 'Thông Tin ${widget.floorName}',
                    details: {
                      'Số lượng căn': '${widget.rooms.length} Căn hộ',
                      'Loại hình': 'Căn hộ thương mại cao cấp',
                      'Sơ đồ': 'Mặt bằng căn hộ điển hình',
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdaptiveRoomPanel(BuildContext context, bool isPhone) {
    int itemsPerRow = isPhone ? 4 : 5;
    List<List<dynamic>> roomRows = _chunkRooms(widget.rooms, itemsPerRow);

    double spacing = isPhone ? 4.0 : 12.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isPhone ? 8 : 16, vertical: isPhone ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.1),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune, size: isPhone ? 13 : 15, color: const Color(0xFF0369A1)),
              const SizedBox(width: 4),
              Text(
                'ĐIỀU KHIỂN CĂN HỘ TRỰC TIẾP',
                style: TextStyle(
                  fontSize: isPhone ? 11 : 12.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0369A1),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          SizedBox(height: isPhone ? 6 : 10),

          Column(
            children: roomRows.map((rowRooms) {
              return Padding(
                padding: EdgeInsets.only(bottom: isPhone ? 4 : 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: rowRooms.asMap().entries.map((entry) {
                    int idx = entry.key;
                    var room = entry.value;

                    Widget item = _buildCompactRoomButton(room, isPhone);

                    return isPhone
                        ? Flexible(
                            fit: FlexFit.tight,
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: idx == rowRooms.length - 1 ? 0 : spacing,
                              ),
                              child: item,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                              right: idx == rowRooms.length - 1 ? 0 : spacing,
                            ),
                            child: SizedBox(width: 140.0, child: item),
                          );
                  }).toList(),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '• Chạm 1 lần: Bật/Tắt Đèn Căn Hộ   |   • Nhấn đúp 2 lần: Xem Chi Tiết Căn Hộ',
              style: TextStyle(
                fontSize: isPhone ? 9.0 : 10.5,
                color: const Color(0xFF0284C7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildCompactRoomButton(dynamic room, bool isPhone) {
  //   int ledIdx = room['led_index'] ?? room['hardwareIndex'] ?? 0;
  //   bool isOn = widget.ledStates[ledIdx] ?? false;
  //   String roomName = room['room_number'] ?? room['name'] ?? 'Phòng';

  //   return InkWell(
  //     onTap: () {
  //       bool newState = !isOn;
  //       widget.onToggleLeds([ledIdx], newState);
  //       WebSocketService().sendSingleRoom(ledIdx, newState);
  //       setState(() {});
  //     },
  //     onDoubleTap: () {
  //       int roomType = room['room_type'] ?? room['type'] ?? 0;
  //       String roomInfo = room['info'] ?? 'Loại ${roomType + 1}PN';
  //       InfoDialog.show(
  //         context,
  //         title: 'Chi Tiết $roomName',
  //         details: {
  //           'Tên căn hộ': roomName,
  //           'Loại căn': '${roomType + 1} Phòng Ngủ',
  //           'Chỉ số LED': 'HardwareIndex #$ledIdx',
  //           'Thông tin': roomInfo,
  //         },
  //       );
  //     },
  //     borderRadius: BorderRadius.circular(10),
  //     child: AnimatedContainer(
  //       duration: const Duration(milliseconds: 180),
  //       padding: EdgeInsets.symmetric(
  //         horizontal: isPhone ? 2 : 8,
  //         vertical: isPhone ? 6 : 8,
  //       ),
  //       decoration: BoxDecoration(
  //         gradient: isOn
  //             ? const LinearGradient(
  //                 colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //               )
  //             : const LinearGradient(
  //                 colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //               ),
  //         borderRadius: BorderRadius.circular(10),
  //         border: Border.all(
  //           color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
  //           width: 1.2,
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             padding: EdgeInsets.all(isPhone ? 2 : 4),
  //             decoration: BoxDecoration(
  //               color: isOn
  //                   ? Colors.white.withValues(alpha: 0.25)
  //                   : const Color(0xFFF472B6).withValues(alpha: 0.2),
  //               shape: BoxShape.circle,
  //             ),
  //             child: Icon(
  //               isOn ? Icons.lightbulb : Icons.king_bed_outlined,
  //               size: isPhone ? 11 : 13,
  //               color: isOn ? Colors.white : const Color(0xFFDB2777),
  //             ),
  //           ),
  //           SizedBox(width: isPhone ? 3 : 6),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     roomName,
  //                     style: TextStyle(
  //                       fontSize: isPhone ? 10.0 : 12.0,
  //                       fontWeight: FontWeight.bold,
  //                       color: isOn ? Colors.white : const Color(0xFF831843),
  //                     ),
  //                   ),
  //                 ),
  //                 FittedBox(
  //                   fit: BoxFit.scaleDown,
  //                   alignment: Alignment.centerLeft,
  //                   child: Text(
  //                     'LED #$ledIdx | ${isOn ? "BẬT" : "TẮT"}',
  //                     style: TextStyle(
  //                       fontSize: isPhone ? 7.5 : 8.5,
  //                       fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
  //                       color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget _buildCompactRoomButton(dynamic room, bool isPhone) {
  // 🟢 1. Ép kiểu int chắc chắn để tránh lỗi đọc Mismatch Type Key
  int ledIdx = int.tryParse('${room['led_index'] ?? room['hardwareIndex'] ?? 0}') ?? 0;
  
  // 🟢 2. Dùng widget.isAnyLedOn đọc trạng thái chuẩn từ State tổng (y hệt bên Floor)
  bool isOn = widget.isAnyLedOn([ledIdx]);
  String roomName = room['room_number'] ?? room['name'] ?? 'Phòng';

  return InkWell(
    onTap: () {
      bool newState = !isOn;
      // 🟢 3. Cập nhật Map cục bộ + gọi Callback + bắn WebSocket
      widget.ledStates[ledIdx] = newState;
      widget.onToggleLeds([ledIdx], newState);
      WebSocketService().sendSingleRoom(ledIdx, newState);
      
      // 🟢 4. Ép Widget re-render lại lập tức
      setState(() {});
    },
    onDoubleTap: () {
      int roomType = int.tryParse('${room['room_type'] ?? room['type'] ?? 0}') ?? 0;
      String roomInfo = room['info'] ?? 'Loại ${roomType + 1}PN';
      InfoDialog.show(
        context,
        title: 'Chi Tiết $roomName',
        details: {
          'Tên căn hộ': roomName,
          'Loại căn': '${roomType + 1} Phòng Ngủ',
          'Chỉ số LED': 'HardwareIndex #$ledIdx',
          'Thông tin': roomInfo,
        },
      );
    },
    borderRadius: BorderRadius.circular(10),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 2 : 8,
        vertical: isPhone ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: isOn
            ? const LinearGradient(
                colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isPhone ? 2 : 4),
            decoration: BoxDecoration(
              color: isOn
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFFF472B6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOn ? Icons.lightbulb : Icons.king_bed_outlined,
              size: isPhone ? 11 : 13,
              color: isOn ? Colors.white : const Color(0xFFDB2777),
            ),
          ),
          SizedBox(width: isPhone ? 3 : 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    roomName,
                    style: TextStyle(
                      fontSize: isPhone ? 10.0 : 12.0,
                      fontWeight: FontWeight.bold,
                      color: isOn ? Colors.white : const Color(0xFF831843),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'LED #$ledIdx | ${isOn ? "BẬT" : "TẮT"}',
                    style: TextStyle(
                      fontSize: isPhone ? 7.5 : 8.5,
                      fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
                      color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}