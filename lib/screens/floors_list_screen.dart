// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'rooms_list_screen.dart';

// // // // // // // class FloorsListScreen extends StatefulWidget {
// // // // // // //   final String buildingName;
// // // // // // //   final List<dynamic> floors;
// // // // // // //   final Map<int, bool> ledStates;
// // // // // // //   final Function(List<int> leds, bool state) onToggleLeds;
// // // // // // //   final bool Function(List<int> leds) isAnyLedOn;
// // // // // // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // // // // // //   final int selectedFilterType;

// // // // // // //   const FloorsListScreen({
// // // // // // //     super.key,
// // // // // // //     required this.buildingName,
// // // // // // //     required this.floors,
// // // // // // //     required this.ledStates,
// // // // // // //     required this.onToggleLeds,
// // // // // // //     required this.isAnyLedOn,
// // // // // // //     required this.extractLeds,
// // // // // // //     required this.selectedFilterType,
// // // // // // //   });

// // // // // // //   @override
// // // // // // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // // // // // }

// // // // // // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       appBar: AppBar(title: Text(widget.buildingName)),
// // // // // // //       body: Padding(
// // // // // // //         padding: const EdgeInsets.all(16.0),
// // // // // // //         child: GridView.builder(
// // // // // // //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// // // // // // //             crossAxisCount: 2,
// // // // // // //             crossAxisSpacing: 16,
// // // // // // //             mainAxisSpacing: 16,
// // // // // // //             childAspectRatio: 1.2,
// // // // // // //           ),
// // // // // // //           itemCount: widget.floors.length,
// // // // // // //           itemBuilder: (context, index) {
// // // // // // //             final f = widget.floors[index];
// // // // // // //             List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // // // // // //             bool isOn = widget.isAnyLedOn(fLeds);

// // // // // // //             return GestureDetector(
// // // // // // //               onTap: () {
// // // // // // //                 widget.onToggleLeds(fLeds, !isOn);
// // // // // // //                 setState(() {});
// // // // // // //               },
// // // // // // //               onDoubleTap: () async {
// // // // // // //                 await Navigator.push(
// // // // // // //                   context,
// // // // // // //                   MaterialPageRoute(
// // // // // // //                     builder: (context) => RoomsListScreen(
// // // // // // //                       floorName: '${widget.buildingName} - ${f['name']}',
// // // // // // //                       rooms: f['rooms'],
// // // // // // //                       ledStates: widget.ledStates,
// // // // // // //                       onToggleLeds: widget.onToggleLeds,
// // // // // // //                       isAnyLedOn: widget.isAnyLedOn,
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 );
// // // // // // //                 setState(() {});
// // // // // // //               },
// // // // // // //               child: AnimatedContainer(
// // // // // // //                 duration: const Duration(milliseconds: 200),
// // // // // // //                 decoration: BoxDecoration(
// // // // // // //                   color: isOn ? Colors.amber.shade600 : Colors.white,
// // // // // // //                   borderRadius: BorderRadius.circular(14),
// // // // // // //                   border: Border.all(color: isOn ? Colors.amber : Colors.grey.shade300, width: 2),
// // // // // // //                 ),
// // // // // // //                 child: Column(
// // // // // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //                   children: [
// // // // // // //                     Icon(Icons.layers, size: 36, color: isOn ? Colors.white : Colors.teal),
// // // // // // //                     const SizedBox(height: 6),
// // // // // // //                     Text(
// // // // // // //                       f['name'],
// // // // // // //                       style: TextStyle(
// // // // // // //                         fontSize: 16,
// // // // // // //                         fontWeight: FontWeight.bold,
// // // // // // //                         color: isOn ? Colors.white : Colors.black87,
// // // // // // //                       ),
// // // // // // //                     ),
// // // // // // //                     Text(
// // // // // // //                       '${fLeds.length} Phòng',
// // // // // // //                       style: TextStyle(fontSize: 12, color: isOn ? Colors.white70 : Colors.grey),
// // // // // // //                     ),
// // // // // // //                   ],
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             );
// // // // // // //           },
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }


// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:flutter/services.dart'; // Bắt buộc import thư viện này
// // // // // // // import 'rooms_list_screen.dart';

// // // // // // // class FloorsListScreen extends StatefulWidget {
// // // // // // //   final String buildingName;
// // // // // // //   final List<dynamic> floors;
// // // // // // //   final Map<int, bool> ledStates;
// // // // // // //   final Function(List<int> leds, bool state) onToggleLeds;
// // // // // // //   final bool Function(List<int> leds) isAnyLedOn;
// // // // // // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // // // // // //   final int selectedFilterType;

// // // // // // //   const FloorsListScreen({
// // // // // // //     super.key,
// // // // // // //     required this.buildingName,
// // // // // // //     required this.floors,
// // // // // // //     required this.ledStates,
// // // // // // //     required this.onToggleLeds,
// // // // // // //     required this.isAnyLedOn,
// // // // // // //     required this.extractLeds,
// // // // // // //     required this.selectedFilterType,
// // // // // // //   });

// // // // // // //   @override
// // // // // // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // // // // // }

// // // // // // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     // BẬT CHẾ ĐỘ FULL SCREEN 100% (Ẩn hẳn thanh Pin/Giờ và thanh gạch dưới)
// // // // // // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       // BẮT BUỘC: Không dùng Padding hay Container bọc ngoài Stack ở đây!
// // // // // // //       body: Stack(
// // // // // // //         fit: StackFit.expand, // Ép Stack kéo giãn tối đa toàn bộ màn hình
// // // // // // //         children: [
// // // // // // //           // 1. Ảnh nền floor.jpg TRÀN KHÔNG KẼ HỞ
// // // // // // //           Positioned.fill(
// // // // // // //             child: Image.asset(
// // // // // // //               'assets/images/floor.jpg',
// // // // // // //               fit: BoxFit.fill, // Dãn tràn tuyệt đối cả chiều dài lẫn rộng
// // // // // // //               errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // // // // // //             ),
// // // // // // //           ),

// // // // // // //           // 2. Lớp phủ Gradient Tối
// // // // // // //           Positioned.fill(
// // // // // // //             child: Container(
// // // // // // //               decoration: BoxDecoration(
// // // // // // //                 gradient: LinearGradient(
// // // // // // //                   begin: Alignment.topCenter,
// // // // // // //                   end: Alignment.bottomCenter,
// // // // // // //                   colors: [
// // // // // // //                     Colors.black.withValues(alpha: 0.6),
// // // // // // //                     Colors.transparent,
// // // // // // //                     Colors.black.withValues(alpha: 0.8),
// // // // // // //                   ],
// // // // // // //                   stops: const [0.0, 0.5, 1.0],
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ),

// // // // // // //           // 3. Các nút điều khiển & Tiêu đề
// // // // // // //           SafeArea(
// // // // // // //             child: Column(
// // // // // // //               children: [
// // // // // // //                 // Thanh tiêu đề Top Bar
// // // // // // //                 Padding(
// // // // // // //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // // // // //                   child: Row(
// // // // // // //                     children: [
// // // // // // //                       CircleAvatar(
// // // // // // //                         backgroundColor: Colors.black45,
// // // // // // //                         child: IconButton(
// // // // // // //                           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// // // // // // //                           onPressed: () => Navigator.pop(context),
// // // // // // //                         ),
// // // // // // //                       ),
// // // // // // //                       Expanded(
// // // // // // //                         child: Text(
// // // // // // //                           widget.buildingName,
// // // // // // //                           textAlign: TextAlign.center,
// // // // // // //                           style: const TextStyle(
// // // // // // //                             fontSize: 22,
// // // // // // //                             fontWeight: FontWeight.bold,
// // // // // // //                             color: Colors.white,
// // // // // // //                             shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                       ),
// // // // // // //                       const SizedBox(width: 40),
// // // // // // //                     ],
// // // // // // //                   ),
// // // // // // //                 ),

// // // // // // //                 const Spacer(), // Đẩy khung điều khiển xuống sát đáy

// // // // // // //                 // Khung danh sách Tầng
// // // // // // //                 Padding(
// // // // // // //                   padding: const EdgeInsets.all(16.0),
// // // // // // //                   child: Container(
// // // // // // //                     padding: const EdgeInsets.all(16),
// // // // // // //                     decoration: BoxDecoration(
// // // // // // //                       color: Colors.white.withValues(alpha: 0.92),
// // // // // // //                       borderRadius: BorderRadius.circular(20),
// // // // // // //                       boxShadow: const [
// // // // // // //                         BoxShadow(
// // // // // // //                           color: Colors.black38,
// // // // // // //                           blurRadius: 16,
// // // // // // //                           offset: Offset(0, 6),
// // // // // // //                         ),
// // // // // // //                       ],
// // // // // // //                     ),
// // // // // // //                     child: Column(
// // // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                       mainAxisSize: MainAxisSize.min,
// // // // // // //                       children: [
// // // // // // //                         const Text(
// // // // // // //                           'Chọn Tầng Để Điều Khiển:',
// // // // // // //                           style: TextStyle(
// // // // // // //                             fontSize: 15,
// // // // // // //                             fontWeight: FontWeight.bold,
// // // // // // //                             color: Colors.black87,
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                         const SizedBox(height: 12),
// // // // // // //                         SingleChildScrollView(
// // // // // // //                           scrollDirection: Axis.horizontal,
// // // // // // //                           child: Row(
// // // // // // //                             children: widget.floors.map((f) {
// // // // // // //                               List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // // // // // //                               bool isOn = widget.isAnyLedOn(fLeds);

// // // // // // //                               return Padding(
// // // // // // //                                 padding: const EdgeInsets.only(right: 10.0),
// // // // // // //                                 child: InkWell(
// // // // // // //                                   onTap: () {
// // // // // // //                                     widget.onToggleLeds(fLeds, !isOn);
// // // // // // //                                     setState(() {});
// // // // // // //                                   },
// // // // // // //                                   onDoubleTap: () async {
// // // // // // //                                     await Navigator.push(
// // // // // // //                                       context,
// // // // // // //                                       MaterialPageRoute(
// // // // // // //                                         builder: (context) => RoomsListScreen(
// // // // // // //                                           floorName: '${widget.buildingName} - ${f['name']}',
// // // // // // //                                           rooms: f['rooms'],
// // // // // // //                                           ledStates: widget.ledStates,
// // // // // // //                                           onToggleLeds: widget.onToggleLeds,
// // // // // // //                                           isAnyLedOn: widget.isAnyLedOn,
// // // // // // //                                         ),
// // // // // // //                                       ),
// // // // // // //                                     );
// // // // // // //                                     setState(() {});
// // // // // // //                                   },
// // // // // // //                                   borderRadius: BorderRadius.circular(12),
// // // // // // //                                   child: Container(
// // // // // // //                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // // // // //                                     decoration: BoxDecoration(
// // // // // // //                                       color: isOn ? Colors.orange.shade600 : Colors.grey.shade100,
// // // // // // //                                       borderRadius: BorderRadius.circular(12),
// // // // // // //                                       border: Border.all(
// // // // // // //                                         color: isOn ? Colors.orange.shade800 : Colors.grey.shade300,
// // // // // // //                                         width: 1.5,
// // // // // // //                                       ),
// // // // // // //                                     ),
// // // // // // //                                     child: Row(
// // // // // // //                                       mainAxisSize: MainAxisSize.min,
// // // // // // //                                       children: [
// // // // // // //                                         Icon(
// // // // // // //                                           isOn ? Icons.lightbulb : Icons.layers,
// // // // // // //                                           size: 18,
// // // // // // //                                           color: isOn ? Colors.white : Colors.grey.shade700,
// // // // // // //                                         ),
// // // // // // //                                         const SizedBox(width: 6),
// // // // // // //                                         Column(
// // // // // // //                                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //                                           mainAxisSize: MainAxisSize.min,
// // // // // // //                                           children: [
// // // // // // //                                             Text(
// // // // // // //                                               f['name'],
// // // // // // //                                               style: TextStyle(
// // // // // // //                                                 fontSize: 14,
// // // // // // //                                                 fontWeight: FontWeight.bold,
// // // // // // //                                                 color: isOn ? Colors.white : Colors.black87,
// // // // // // //                                               ),
// // // // // // //                                             ),
// // // // // // //                                             Text(
// // // // // // //                                               '${fLeds.length} phòng • ${isOn ? "ĐANG BẬT" : "TẮT"}',
// // // // // // //                                               style: TextStyle(
// // // // // // //                                                 fontSize: 10,
// // // // // // //                                                 color: isOn ? Colors.white70 : Colors.grey.shade600,
// // // // // // //                                               ),
// // // // // // //                                             ),
// // // // // // //                                           ],
// // // // // // //                                         ),
// // // // // // //                                       ],
// // // // // // //                                     ),
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                               );
// // // // // // //                             }).toList(),
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                         const SizedBox(height: 6),
// // // // // // //                         const Center(
// // // // // // //                           child: Text(
// // // // // // //                             '• Chạm 1 lần: Bật/Tắt Tầng  |  • Nhấn đúp 2 lần: Xem danh sách căn hộ',
// // // // // // //                             style: TextStyle(fontSize: 11, color: Colors.black54),
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                       ],
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }


// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart';
// // // // // // import 'rooms_list_screen.dart';

// // // // // // class FloorsListScreen extends StatefulWidget {
// // // // // //   final String buildingName;
// // // // // //   final List<dynamic> floors;
// // // // // //   final Map<int, bool> ledStates;
// // // // // //   final Function(List<int> leds, bool state) onToggleLeds;
// // // // // //   final bool Function(List<int> leds) isAnyLedOn;
// // // // // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // // // // //   final int selectedFilterType;

// // // // // //   const FloorsListScreen({
// // // // // //     super.key,
// // // // // //     required this.buildingName,
// // // // // //     required this.floors,
// // // // // //     required this.ledStates,
// // // // // //     required this.onToggleLeds,
// // // // // //     required this.isAnyLedOn,
// // // // // //     required this.extractLeds,
// // // // // //     required this.selectedFilterType,
// // // // // //   });

// // // // // //   @override
// // // // // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // // // // }

// // // // // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // // // // //   }

// // // // // //   // Hàm hỗ trợ chia mảng floors thành N dãy (hàng)
// // // // // //   List<List<dynamic>> _splitFloorsIntoRows(List<dynamic> floorsList, int rowCount) {
// // // // // //     List<List<dynamic>> rows = List.generate(rowCount, (_) => []);
// // // // // //     for (int i = 0; i < floorsList.length; i++) {
// // // // // //       rows[i % rowCount].add(floorsList[i]);
// // // // // //     }
// // // // // //     return rows;
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     // Tự động quyết định số hàng dựa trên tổng số tầng (Nhiều tầng => Chia 3 hàng, ít tầng => 1-2 hàng)
// // // // // //     int rowCount = 1;
// // // // // //     if (widget.floors.length > 12) {
// // // // // //       rowCount = 3; // Nếu trên 12 tầng -> Chia làm 3 dãy ngang
// // // // // //     } else if (widget.floors.length > 6) {
// // // // // //       rowCount = 2; // Từ 7-12 tầng -> Chia làm 2 dãy ngang
// // // // // //     }

// // // // // //     List<List<dynamic>> floorRows = _splitFloorsIntoRows(widget.floors, rowCount);

// // // // // //     return Scaffold(
// // // // // //       body: Stack(
// // // // // //         fit: StackFit.expand,
// // // // // //         children: [
// // // // // //           // 1. Ảnh nền floor.jpg TRÀN MÀN HÌNH
// // // // // //           Positioned.fill(
// // // // // //             child: Image.asset(
// // // // // //               'assets/images/floor.jpg',
// // // // // //               fit: BoxFit.fill,
// // // // // //               errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // // // // //             ),
// // // // // //           ),

// // // // // //           // 2. Lớp phủ Gradient Tối
// // // // // //           Positioned.fill(
// // // // // //             child: Container(
// // // // // //               decoration: BoxDecoration(
// // // // // //                 gradient: LinearGradient(
// // // // // //                   begin: Alignment.topCenter,
// // // // // //                   end: Alignment.bottomCenter,
// // // // // //                   colors: [
// // // // // //                     Colors.black.withValues(alpha: 0.6),
// // // // // //                     Colors.transparent,
// // // // // //                     Colors.black.withValues(alpha: 0.8),
// // // // // //                   ],
// // // // // //                   stops: const [0.0, 0.5, 1.0],
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),

// // // // // //           // 3. Nội dung giao diện
// // // // // //           SafeArea(
// // // // // //             child: Column(
// // // // // //               children: [
// // // // // //                 // Top Bar
// // // // // //                 Padding(
// // // // // //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // // // //                   child: Row(
// // // // // //                     children: [
// // // // // //                       CircleAvatar(
// // // // // //                         backgroundColor: Colors.black45,
// // // // // //                         child: IconButton(
// // // // // //                           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// // // // // //                           onPressed: () => Navigator.pop(context),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       Expanded(
// // // // // //                         child: Text(
// // // // // //                           widget.buildingName,
// // // // // //                           textAlign: TextAlign.center,
// // // // // //                           style: const TextStyle(
// // // // // //                             fontSize: 22,
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Colors.white,
// // // // // //                             shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       const SizedBox(width: 40),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ),

// // // // // //                 const Spacer(),

// // // // // //                 // Khung danh sách Tầng
// // // // // //                 Padding(
// // // // // //                   padding: const EdgeInsets.all(16.0),
// // // // // //                   child: Container(
// // // // // //                     padding: const EdgeInsets.all(14),
// // // // // //                     decoration: BoxDecoration(
// // // // // //                       color: Colors.white.withValues(alpha: 0.92),
// // // // // //                       borderRadius: BorderRadius.circular(20),
// // // // // //                       boxShadow: const [
// // // // // //                         BoxShadow(
// // // // // //                           color: Colors.black38,
// // // // // //                           blurRadius: 16,
// // // // // //                           offset: Offset(0, 6),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                     child: Column(
// // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                       mainAxisSize: MainAxisSize.min,
// // // // // //                       children: [
// // // // // //                         const Text(
// // // // // //                           'Chọn Tầng Để Điều Khiển:',
// // // // // //                           style: TextStyle(
// // // // // //                             fontSize: 14,
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Colors.black87,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 10),

// // // // // //                         // Khung cuộn ngang chứa N dãy nút
// // // // // //                         SingleChildScrollView(
// // // // // //                           scrollDirection: Axis.horizontal,
// // // // // //                           child: Column(
// // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                             children: floorRows.map((rowFloors) {
// // // // // //                               return Padding(
// // // // // //                                 padding: const EdgeInsets.only(bottom: 8.0),
// // // // // //                                 child: Row(
// // // // // //                                   children: rowFloors.map((f) => _buildFloorButton(f)).toList(),
// // // // // //                                 ),
// // // // // //                               );
// // // // // //                             }).toList(),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 4),
// // // // // //                         const Center(
// // // // // //                           child: Text(
// // // // // //                             '• Chạm 1 lần: Bật/Tắt Tầng  |  • Nhấn đúp 2 lần: Xem danh sách căn hộ',
// // // // // //                             style: TextStyle(fontSize: 11, color: Colors.black54),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildFloorButton(dynamic f) {
// // // // // //     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // // // // //     bool isOn = widget.isAnyLedOn(fLeds);

// // // // // //     return Padding(
// // // // // //       padding: const EdgeInsets.only(right: 8.0),
// // // // // //       child: InkWell(
// // // // // //         onTap: () {
// // // // // //           widget.onToggleLeds(fLeds, !isOn);
// // // // // //           setState(() {});
// // // // // //         },
// // // // // //         onDoubleTap: () async {
// // // // // //           await Navigator.push(
// // // // // //             context,
// // // // // //             MaterialPageRoute(
// // // // // //               builder: (context) => RoomsListScreen(
// // // // // //                 floorName: '${widget.buildingName} - ${f['name']}',
// // // // // //                 rooms: f['rooms'],
// // // // // //                 ledStates: widget.ledStates,
// // // // // //                 onToggleLeds: widget.onToggleLeds,
// // // // // //                 isAnyLedOn: widget.isAnyLedOn,
// // // // // //               ),
// // // // // //             ),
// // // // // //           );
// // // // // //           setState(() {});
// // // // // //         },
// // // // // //         borderRadius: BorderRadius.circular(10),
// // // // // //         child: AnimatedContainer(
// // // // // //           duration: const Duration(milliseconds: 150),
// // // // // //           width: 130, // Chiều rộng cố định giúp giữ đúng vị trí các nút khi chạm
// // // // // //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // // // // //           decoration: BoxDecoration(
// // // // // //             color: isOn ? Colors.orange.shade600 : Colors.grey.shade100,
// // // // // //             borderRadius: BorderRadius.circular(10),
// // // // // //             border: Border.all(
// // // // // //               color: isOn ? Colors.orange.shade800 : Colors.grey.shade300,
// // // // // //               width: 1.5,
// // // // // //             ),
// // // // // //           ),
// // // // // //           child: Row(
// // // // // //             mainAxisSize: MainAxisSize.min,
// // // // // //             children: [
// // // // // //               Icon(
// // // // // //                 isOn ? Icons.lightbulb : Icons.layers,
// // // // // //                 size: 16,
// // // // // //                 color: isOn ? Colors.white : Colors.grey.shade700,
// // // // // //               ),
// // // // // //               const SizedBox(width: 6),
// // // // // //               Expanded(
// // // // // //                 child: Column(
// // // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                   mainAxisSize: MainAxisSize.min,
// // // // // //                   children: [
// // // // // //                     Text(
// // // // // //                       f['name'],
// // // // // //                       maxLines: 1,
// // // // // //                       overflow: TextOverflow.ellipsis,
// // // // // //                       style: TextStyle(
// // // // // //                         fontSize: 12,
// // // // // //                         fontWeight: FontWeight.bold,
// // // // // //                         color: isOn ? Colors.white : Colors.black87,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                     Text(
// // // // // //                       '${fLeds.length} phòng | ${isOn ? "BẬT" : "TẮT"}',
// // // // // //                       maxLines: 1,
// // // // // //                       overflow: TextOverflow.ellipsis,
// // // // // //                       style: TextStyle(
// // // // // //                         fontSize: 9.5,
// // // // // //                         color: isOn ? Colors.white.withValues(alpha: 0.9) : Colors.grey.shade600,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'rooms_list_screen.dart';

// // // // // class FloorsListScreen extends StatefulWidget {
// // // // //   final String buildingName;
// // // // //   final List<dynamic> floors;
// // // // //   final Map<int, bool> ledStates;
// // // // //   final Function(List<int> leds, bool state) onToggleLeds;
// // // // //   final bool Function(List<int> leds) isAnyLedOn;
// // // // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // // // //   final int selectedFilterType;

// // // // //   const FloorsListScreen({
// // // // //     super.key,
// // // // //     required this.buildingName,
// // // // //     required this.floors,
// // // // //     required this.ledStates,
// // // // //     required this.onToggleLeds,
// // // // //     required this.isAnyLedOn,
// // // // //     required this.extractLeds,
// // // // //     required this.selectedFilterType,
// // // // //   });

// // // // //   @override
// // // // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // // // }

// // // // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // // // //   }

// // // // //   // Chia danh sách floors thành N hàng
// // // // //   List<List<dynamic>> _splitFloorsIntoRows(List<dynamic> floorsList, int rowCount) {
// // // // //     List<List<dynamic>> rows = List.generate(rowCount, (_) => []);
// // // // //     for (int i = 0; i < floorsList.length; i++) {
// // // // //       rows[i % rowCount].add(floorsList[i]);
// // // // //     }
// // // // //     return rows;
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     int rowCount = 1;
// // // // //     if (widget.floors.length > 12) {
// // // // //       rowCount = 3;
// // // // //     } else if (widget.floors.length > 6) {
// // // // //       rowCount = 2;
// // // // //     }

// // // // //     List<List<dynamic>> floorRows = _splitFloorsIntoRows(widget.floors, rowCount);

// // // // //     return Scaffold(
// // // // //       body: Stack(
// // // // //         fit: StackFit.expand,
// // // // //         children: [
// // // // //           // 1. Ảnh nền mặt bằng floor.jpg
// // // // //           Positioned.fill(
// // // // //             child: Image.asset(
// // // // //               'assets/images/floor.jpg',
// // // // //               fit: BoxFit.fill,
// // // // //               errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // // // //             ),
// // // // //           ),

// // // // //           // 2. Lớp phủ Gradient Tối nhẹ
// // // // //           Positioned.fill(
// // // // //             child: Container(
// // // // //               decoration: BoxDecoration(
// // // // //                 gradient: LinearGradient(
// // // // //                   begin: Alignment.topCenter,
// // // // //                   end: Alignment.bottomCenter,
// // // // //                   colors: [
// // // // //                     Colors.black.withValues(alpha: 0.65),
// // // // //                     Colors.transparent,
// // // // //                     Colors.black.withValues(alpha: 0.8),
// // // // //                   ],
// // // // //                   stops: const [0.0, 0.4, 1.0],
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ),

// // // // //           // 3. Nội dung giao diện
// // // // //           SafeArea(
// // // // //             child: Column(
// // // // //               children: [
// // // // //                 // Top Bar - Nút Quay lại & Tiêu đề
// // // // //                 Padding(
// // // // //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // // //                   child: Row(
// // // // //                     children: [
// // // // //                       CircleAvatar(
// // // // //                         backgroundColor: Colors.black54,
// // // // //                         child: IconButton(
// // // // //                           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// // // // //                           onPressed: () => Navigator.pop(context),
// // // // //                         ),
// // // // //                       ),
// // // // //                       Expanded(
// // // // //                         child: Text(
// // // // //                           widget.buildingName,
// // // // //                           textAlign: TextAlign.center,
// // // // //                           style: const TextStyle(
// // // // //                             fontSize: 22,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Colors.white,
// // // // //                             shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                       const SizedBox(width: 40),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),

// // // // //                 const Spacer(),

// // // // //                 // Khung danh sách Tầng - PHONG CÁCH DARK GLASS
// // // // //                 Padding(
// // // // //                   padding: const EdgeInsets.all(16.0),
// // // // //                   child: Container(
// // // // //                     padding: const EdgeInsets.all(16),
// // // // //                     decoration: BoxDecoration(
// // // // //                       color: Colors.black.withValues(alpha: 0.75), // Nền xám đen mờ sang trọng
// // // // //                       borderRadius: BorderRadius.circular(22),
// // // // //                       border: Border.all(color: Colors.white24, width: 1.2),
// // // // //                       boxShadow: const [
// // // // //                         BoxShadow(
// // // // //                           color: Colors.black87,
// // // // //                           blurRadius: 20,
// // // // //                           offset: Offset(0, 8),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                     child: Column(
// // // // //                       crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa nội dung khung
// // // // //                       mainAxisSize: MainAxisSize.min,
// // // // //                       children: [
// // // // //                         const Text(
// // // // //                           'ĐIỀU KHIỂN TẦNG SA BÀN',
// // // // //                           style: TextStyle(
// // // // //                             fontSize: 14,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Colors.orangeAccent,
// // // // //                             letterSpacing: 1.1,
// // // // //                           ),
// // // // //                         ),
// // // // //                         const SizedBox(height: 12),

// // // // //                         // Khung cuộn ngang CĂN GIỮA các dãy nút
// // // // //                         SingleChildScrollView(
// // // // //                           scrollDirection: Axis.horizontal,
// // // // //                           child: Column(
// // // // //                             crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa các hàng
// // // // //                             children: floorRows.map((rowFloors) {
// // // // //                               return Padding(
// // // // //                                 padding: const EdgeInsets.only(bottom: 10.0),
// // // // //                                 child: Row(
// // // // //                                   mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nút trong hàng
// // // // //                                   children: rowFloors.map((f) => _buildFloorButton(f)).toList(),
// // // // //                                 ),
// // // // //                               );
// // // // //                             }).toList(),
// // // // //                           ),
// // // // //                         ),

// // // // //                         const SizedBox(height: 4),
// // // // //                         const Text(
// // // // //                           '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
// // // // //                           style: TextStyle(fontSize: 11, color: Colors.white60),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // Widget Tạo Nút Bấm Tầng Sinh Động & Nổi Bật
// // // // //   Widget _buildFloorButton(dynamic f) {
// // // // //     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // // // //     bool isOn = widget.isAnyLedOn(fLeds);

// // // // //     return Padding(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 5.0),
// // // // //       child: InkWell(
// // // // //         onTap: () {
// // // // //           widget.onToggleLeds(fLeds, !isOn);
// // // // //           setState(() {});
// // // // //         },
// // // // //         onDoubleTap: () async {
// // // // //           await Navigator.push(
// // // // //             context,
// // // // //             MaterialPageRoute(
// // // // //               builder: (context) => RoomsListScreen(
// // // // //                 floorName: '${widget.buildingName} - ${f['name']}',
// // // // //                 rooms: f['rooms'],
// // // // //                 ledStates: widget.ledStates,
// // // // //                 onToggleLeds: widget.onToggleLeds,
// // // // //                 isAnyLedOn: widget.isAnyLedOn,
// // // // //               ),
// // // // //             ),
// // // // //           );
// // // // //           setState(() {});
// // // // //         },
// // // // //         borderRadius: BorderRadius.circular(12),
// // // // //         child: AnimatedContainer(
// // // // //           duration: const Duration(milliseconds: 180),
// // // // //           width: 132, // Cố định độ rộng để không bị rung/nhảy khi bấm
// // // // //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
// // // // //           decoration: BoxDecoration(
// // // // //             // Đổi màu nền cực kỳ sinh động
// // // // //             color: isOn ? Colors.orange.shade600 : Colors.blueGrey.shade900.withValues(alpha: 0.8),
// // // // //             borderRadius: BorderRadius.circular(12),
// // // // //             border: Border.all(
// // // // //               color: isOn ? Colors.orangeAccent : Colors.white24,
// // // // //               width: 1.5,
// // // // //             ),
// // // // //             boxShadow: isOn
// // // // //                 ? [
// // // // //                     BoxShadow(
// // // // //                       color: Colors.orange.withValues(alpha: 0.5),
// // // // //                       blurRadius: 10,
// // // // //                       offset: const Offset(0, 3),
// // // // //                     ),
// // // // //                   ]
// // // // //                 : [],
// // // // //           ),
// // // // //           child: Row(
// // // // //             mainAxisSize: MainAxisSize.min,
// // // // //             children: [
// // // // //               Icon(
// // // // //                 isOn ? Icons.lightbulb : Icons.layers,
// // // // //                 size: 18,
// // // // //                 color: isOn ? Colors.white : Colors.white60,
// // // // //               ),
// // // // //               const SizedBox(width: 8),
// // // // //               Expanded(
// // // // //                 child: Column(
// // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                   mainAxisSize: MainAxisSize.min,
// // // // //                   children: [
// // // // //                     Text(
// // // // //                       f['name'],
// // // // //                       maxLines: 1,
// // // // //                       overflow: TextOverflow.ellipsis,
// // // // //                       style: const TextStyle(
// // // // //                         fontSize: 13,
// // // // //                         fontWeight: FontWeight.bold,
// // // // //                         color: Colors.white,
// // // // //                       ),
// // // // //                     ),
// // // // //                     const SizedBox(height: 2),
// // // // //                     Text(
// // // // //                       '${fLeds.length} phòng | ${isOn ? "BẬT" : "TẮT"}',
// // // // //                       maxLines: 1,
// // // // //                       overflow: TextOverflow.ellipsis,
// // // // //                       style: TextStyle(
// // // // //                         fontSize: 10,
// // // // //                         fontWeight: isOn ? FontWeight.bold : FontWeight.normal,
// // // // //                         color: isOn ? Colors.white : Colors.white54,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'rooms_list_screen.dart';
// // // // import '../widgets/info_dialog.dart';
// // // // import '../services/websocket_service.dart';
// // // // class FloorsListScreen extends StatefulWidget {
// // // //   final String buildingName;
// // // //   final List<dynamic> floors;
// // // //   final Map<int, bool> ledStates;
// // // //   final Function(List<int> leds, bool state) onToggleLeds;
// // // //   final bool Function(List<int> leds) isAnyLedOn;
// // // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // // //   final int selectedFilterType;
// // // //   final String? buildingImageConfig; // Thêm khai báo thuộc tính này

// // // //   const FloorsListScreen({
// // // //     super.key,
// // // //     required this.buildingName,
// // // //     required this.floors,
// // // //     required this.ledStates,
// // // //     required this.onToggleLeds,
// // // //     required this.isAnyLedOn,
// // // //     required this.extractLeds,
// // // //     required this.selectedFilterType,
// // // //     this.buildingImageConfig, // Thêm tham số tùy chọn vào constructor
// // // //   });

// // // //   @override
// // // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // // }

// // // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // // //   }

// // // //   // Chia danh sách Tầng nối tiếp nhau: Hàng 1 (Tầng 1 -> N), Hàng 2 (N+1 -> M)...
// // // //   List<List<dynamic>> _splitFloorsSequentially(List<dynamic> floorsList, int rowCount) {
// // // //     List<List<dynamic>> rows = [];
// // // //     int itemsPerRow = (floorsList.length / rowCount).ceil();

// // // //     for (int i = 0; i < floorsList.length; i += itemsPerRow) {
// // // //       int end = (i + itemsPerRow < floorsList.length) ? i + itemsPerRow : floorsList.length;
// // // //       rows.add(floorsList.sublist(i, end));
// // // //     }
// // // //     return rows;
// // // //   }
// // // //   @override
// // // // Widget build(BuildContext context) {
// // // //   int rowCount = 1;
// // // //   if (widget.floors.length > 12) {
// // // //     rowCount = 3; // >12 tầng => 3 hàng
// // // //   } else if (widget.floors.length > 6) {
// // // //     rowCount = 2; // 7 - 12 tầng => 2 hàng
// // // //   }

// // // //   List<List<dynamic>> floorRows = _splitFloorsSequentially(widget.floors, rowCount);

// // // //   // Lấy đường dẫn ảnh động từ config nếu có, mặc định là 'assets/images/floor.jpg'
// // // //   final String floorImagePath = widget.buildingImageConfig ?? 'assets/images/floor.jpg';

// // // //   return Scaffold(
// // // //     body: Stack(
// // // //       fit: StackFit.expand,
// // // //       children: [
// // // //         // 1. Ảnh nền mặt bằng TRÀN MÀN HÌNH (Hỗ trợ cả Local Asset & URL Online)
// // // //         Positioned.fill(
// // // //           child: floorImagePath.startsWith('http')
// // // //               ? Image.network(
// // // //                   floorImagePath,
// // // //                   fit: BoxFit.fill,
// // // //                   errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // // //                 )
// // // //               : Image.asset(
// // // //                   floorImagePath,
// // // //                   fit: BoxFit.fill,
// // // //                   errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // // //                 ),
// // // //         ),

// // // //         // 2. Lớp phủ Gradient Tối làm nổi khung nút
// // // //         Positioned.fill(
// // // //           child: Container(
// // // //             decoration: BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.topCenter,
// // // //                 end: Alignment.bottomCenter,
// // // //                 colors: [
// // // //                   Colors.black.withValues(alpha: 0.6),
// // // //                   Colors.transparent,
// // // //                   Colors.black.withValues(alpha: 0.8),
// // // //                 ],
// // // //                 stops: const [0.0, 0.45, 1.0],
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),

// // // //         // 3. Nội dung giao diện
// // // //         SafeArea(
// // // //           child: Column(
// // // //             children: [
// // // //               // Thay thế đoạn Top Bar trong SafeArea:
// // // // Padding(
// // // //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // // //   child: Row(
// // // //     children: [
// // // //       CircleAvatar(
// // // //         backgroundColor: Colors.black54,
// // // //         child: IconButton(
// // // //           icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// // // //           onPressed: () => Navigator.pop(context),
// // // //         ),
// // // //       ),
// // // //       Expanded(
// // // //         child: Text(
// // // //           widget.buildingName,
// // // //           textAlign: TextAlign.center,
// // // //           style: const TextStyle(
// // // //             fontSize: 22,
// // // //             fontWeight: FontWeight.bold,
// // // //             color: Colors.white,
// // // //             shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //       // NÚT BẤM XEM THÔNG TIN TÒA NHÀ / TẦNG
// // // //       CircleAvatar(
// // // //         backgroundColor: const Color(0xFF0284C7),
// // // //         child: IconButton(
// // // //           icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
// // // //           onPressed: () {
// // // //             InfoDialog.show(
// // // //               context,
// // // //               title: 'Thông Tin ${widget.buildingName}',
// // // //               details: {
// // // //                 'Quy mô': '20 Tầng nổi, 2 Tầng hầm',
// // // //                 'Tổng số căn': '120 Căn hộ cao cấp',
// // // //                 'Thang máy': '4 Thang máy Hyundai tốc độ cao',
// // // //                 'Trạng thái': 'Đang mở bán đợt 1',
// // // //               },
// // // //             );
// // // //           },
// // // //         ),
// // // //       ),
// // // //     ],
// // // //   ),
// // // // ),

// // // //               const Spacer(),

// // // //               // KHUNG CHỨA NGOÀI: TÔNG XANH PASTEL / XANH NGỌC NHẠT
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(16.0),
// // // //                 child: Container(
// // // //                   padding: const EdgeInsets.all(16),
// // // //                   decoration: BoxDecoration(
// // // //                     // Màu nền Xanh Ngọc Nhạt mờ trong suốt nhẹ
// // // //                     color: const Color(0xFFE0F2FE).withValues(alpha: 0.94),
// // // //                     borderRadius: BorderRadius.circular(24),
// // // //                     border: Border.all(color: const Color(0xFFBAE6FD), width: 1.8),
// // // //                     boxShadow: const [
// // // //                       BoxShadow(
// // // //                         color: Colors.black38,
// // // //                         blurRadius: 20,
// // // //                         offset: Offset(0, 8),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.center, // CĂN GIỮA
// // // //                     mainAxisSize: MainAxisSize.min,
// // // //                     children: [
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // //                         children: const [
// // // //                           Icon(Icons.tune, size: 16, color: Color(0xFF0369A1)),
// // // //                           SizedBox(width: 6),
// // // //                           Text(
// // // //                             'ĐIỀU KHIỂN TẦNG SA BÀN',
// // // //                             style: TextStyle(
// // // //                               fontSize: 13,
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Color(0xFF0369A1),
// // // //                               letterSpacing: 1.1,
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 14),

// // // //                       // Cuộn ngang CĂN GIỮA các dãy nút Tầng
// // // //                       SingleChildScrollView(
// // // //                         scrollDirection: Axis.horizontal,
// // // //                         child: Column(
// // // //                           crossAxisAlignment: CrossAxisAlignment.center, // CĂN GIỮA NÚT
// // // //                           children: floorRows.map((rowFloors) {
// // // //                             return Padding(
// // // //                               padding: const EdgeInsets.only(bottom: 10.0),
// // // //                               child: Row(
// // // //                                 mainAxisAlignment: MainAxisAlignment.center, // CĂN GIỮA NÚT TRONG HÀNG
// // // //                                 children: rowFloors.map((f) => _buildFloorButton(f)).toList(),
// // // //                               ),
// // // //                             );
// // // //                           }).toList(),
// // // //                         ),
// // // //                       ),

// // // //                       const SizedBox(height: 4),
// // // //                       const Text(
// // // //                         '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
// // // //                         style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w500),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     ),
// // // //   );
// // // // }

// // // //   // Widget NÚT BẤM MÀU HỒNG NHẠT (OFF) & CAM NỔI BẬT (ON)
// // // //   Widget _buildFloorButton(dynamic f) {
// // // //     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // // //     bool isOn = widget.isAnyLedOn(fLeds);

// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 5.0),
// // // //       child: InkWell(
// // // // onTap: () {
// // // //   bool newState = !isOn;
  
// // // //   // 1. Cập nhật giao diện App
// // // //   widget.onToggleLeds(fLeds, newState);
  
// // // //   // 2. Gửi lệnh nhóm qua WebSocket tới ESP32 ngay lập tức!
// // // //   WebSocketService().sendGroupRooms(fLeds, newState);
  
// // // //   setState(() {});
// // // // },
// // // //         onDoubleTap: () async {
// // // //           await Navigator.push(
// // // //             context,
// // // //             MaterialPageRoute(
// // // //               builder: (context) => RoomsListScreen(
// // // //                 floorName: '${widget.buildingName} - ${f['name']}',
// // // //                 rooms: f['rooms'],
// // // //                 ledStates: widget.ledStates,
// // // //                 onToggleLeds: widget.onToggleLeds,
// // // //                 isAnyLedOn: widget.isAnyLedOn,
// // // //               ),
// // // //             ),
// // // //           );
// // // //           setState(() {});
// // // //         },
// // // //         borderRadius: BorderRadius.circular(14),
// // // //         child: AnimatedContainer(
// // // //           duration: const Duration(milliseconds: 180),
// // // //           width: 132, // Cố định chiều rộng giúp giữ vị trí tuyệt đối khi bấm
// // // //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
// // // //           decoration: BoxDecoration(
// // // //             // ON: Gradient Cam Hổ Phách
// // // //             // OFF: Nền Hồng Nhạt Pastel (Màu khác hoàn toàn so với khung Xanh ngoài)
// // // //             gradient: isOn
// // // //                 ? const LinearGradient(
// // // //                     colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
// // // //                     begin: Alignment.topLeft,
// // // //                     end: Alignment.bottomRight,
// // // //                   )
// // // //                 : const LinearGradient(
// // // //                     colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)], // Hồng Nhạt Pastel
// // // //                     begin: Alignment.topLeft,
// // // //                     end: Alignment.bottomRight,
// // // //                   ),
// // // //             borderRadius: BorderRadius.circular(14),
// // // //             border: Border.all(
// // // //               color: isOn ? Colors.amberAccent : const Color(0xFFF472B6), // Viền Hồng Đậm khi Tắt
// // // //               width: 1.5,
// // // //             ),
// // // //             boxShadow: isOn
// // // //                 ? [
// // // //                     BoxShadow(
// // // //                       color: Colors.orange.withValues(alpha: 0.4),
// // // //                       blurRadius: 10,
// // // //                       offset: const Offset(0, 3),
// // // //                     ),
// // // //                   ]
// // // //                 : [
// // // //                     BoxShadow(
// // // //                       color: Colors.pink.withValues(alpha: 0.1),
// // // //                       blurRadius: 4,
// // // //                       offset: const Offset(0, 2),
// // // //                     ),
// // // //                   ],
// // // //           ),
// // // //           child: Row(
// // // //             mainAxisSize: MainAxisSize.min,
// // // //             children: [
// // // //               // Icon
// // // //               Container(
// // // //                 padding: const EdgeInsets.all(5),
// // // //                 decoration: BoxDecoration(
// // // //                   color: isOn ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFF472B6).withValues(alpha: 0.2),
// // // //                   shape: BoxShape.circle,
// // // //                 ),
// // // //                 child: Icon(
// // // //                   isOn ? Icons.lightbulb : Icons.layers,
// // // //                   size: 16,
// // // //                   color: isOn ? Colors.white : const Color(0xFFDB2777),
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(width: 8),
// // // //               Expanded(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   mainAxisSize: MainAxisSize.min,
// // // //                   children: [
// // // //                     Text(
// // // //                       f['name'],
// // // //                       maxLines: 1,
// // // //                       overflow: TextOverflow.ellipsis,
// // // //                       style: TextStyle(
// // // //                         fontSize: 13,
// // // //                         fontWeight: FontWeight.bold,
// // // //                         color: isOn ? Colors.white : const Color(0xFF831843), // Tím/Hồng Sẫm dễ đọc
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(height: 2),
// // // //                     Text(
// // // //                       '${fLeds.length} phòng | ${isOn ? "BẬT" : "TẮT"}',
// // // //                       maxLines: 1,
// // // //                       overflow: TextOverflow.ellipsis,
// // // //                       style: TextStyle(
// // // //                         fontSize: 10,
// // // //                         fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
// // // //                         color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'rooms_list_screen.dart';
// // // import '../widgets/info_dialog.dart';
// // // import '../services/websocket_service.dart';

// // // class FloorsListScreen extends StatefulWidget {
// // //   final String buildingName;
// // //   final List<dynamic> floors;
// // //   final Map<int, bool> ledStates;
// // //   final Function(List<int> leds, bool state) onToggleLeds;
// // //   final bool Function(List<int> leds) isAnyLedOn;
// // //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// // //   final int selectedFilterType;
// // //   final String? buildingImageConfig;

// // //   const FloorsListScreen({
// // //     super.key,
// // //     required this.buildingName,
// // //     required this.floors,
// // //     required this.ledStates,
// // //     required this.onToggleLeds,
// // //     required this.isAnyLedOn,
// // //     required this.extractLeds,
// // //     required this.selectedFilterType,
// // //     this.buildingImageConfig,
// // //   });

// // //   @override
// // //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // // }

// // // class _FloorsListScreenState extends State<FloorsListScreen> {
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// // //   }

// // //   // Thuật toán chia danh sách Tầng chuẩn của giao diện gốc
// // //   List<List<dynamic>> _splitFloorsSequentially(List<dynamic> floorsList, int rowCount) {
// // //     List<List<dynamic>> rows = [];
// // //     int itemsPerRow = (floorsList.length / rowCount).ceil();

// // //     for (int i = 0; i < floorsList.length; i += itemsPerRow) {
// // //       int end = (i + itemsPerRow < floorsList.length) ? i + itemsPerRow : floorsList.length;
// // //       rows.add(floorsList.sublist(i, end));
// // //     }
// // //     return rows;
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final String floorImagePath = widget.buildingImageConfig ?? 'assets/images/floor.jpg';

// // //     return Scaffold(
// // //       backgroundColor: Colors.black,
// // //       body: LayoutBuilder(
// // //         builder: (context, constraints) {
// // //           double screenWidth = constraints.maxWidth;
// // //           bool isPhone = screenWidth < 600; // Nhận diện Điện thoại vs Tablet

// // //           // 1. Tự động tính số hàng/cột tối ưu cho từng loại màn hình
// // //           int rowCount = 1;
// // //           if (isPhone) {
// // //             // Trên điện thoại: Tự chia nhiều hàng hơn để nút ngắn lại không tràn lề
// // //             rowCount = (widget.floors.length / 2).ceil(); 
// // //             if (rowCount < 2) rowCount = 2;
// // //           } else {
// // //             // Trên Tablet/iPad: Giữ chuẩn thuật toán gốc của bạn
// // //             if (widget.floors.length > 12) {
// // //               rowCount = 3;
// // //             } else if (widget.floors.length > 6) {
// // //               rowCount = 2;
// // //             }
// // //           }

// // //           List<List<dynamic>> floorRows = _splitFloorsSequentially(widget.floors, rowCount);

// // //           // Kích thước nút bấm tinh chỉnh theo màn hình
// // //           double buttonWidth = isPhone ? (screenWidth - 60) / 2 : 126.0;

// // //           return Stack(
// // //             fit: StackFit.expand,
// // //             children: [
// // //               // 1. Ảnh nền mặt bằng TRÀN MÀN HÌNH
// // //               Positioned.fill(
// // //                 child: floorImagePath.startsWith('http')
// // //                     ? Image.network(
// // //                         floorImagePath,
// // //                         fit: BoxFit.cover,
// // //                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // //                       )
// // //                     : Image.asset(
// // //                         floorImagePath,
// // //                         fit: BoxFit.cover,
// // //                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// // //                       ),
// // //               ),

// // //               // 2. Lớp phủ Gradient Tối
// // //               Positioned.fill(
// // //                 child: Container(
// // //                   decoration: BoxDecoration(
// // //                     gradient: LinearGradient(
// // //                       begin: Alignment.topCenter,
// // //                       end: Alignment.bottomCenter,
// // //                       colors: [
// // //                         Colors.black.withValues(alpha: 0.6),
// // //                         Colors.transparent,
// // //                         Colors.black.withValues(alpha: 0.8),
// // //                       ],
// // //                       stops: const [0.0, 0.45, 1.0],
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),

// // //               // 3. Nội dung giao diện
// // //               SafeArea(
// // //                 child: Column(
// // //                   children: [
// // //                     // Top Bar
// // //                     Padding(
// // //                       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// // //                       child: Row(
// // //                         children: [
// // //                           CircleAvatar(
// // //                             backgroundColor: Colors.black54,
// // //                             child: IconButton(
// // //                               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// // //                               onPressed: () => Navigator.pop(context),
// // //                             ),
// // //                           ),
// // //                           Expanded(
// // //                             child: Text(
// // //                               widget.buildingName,
// // //                               textAlign: TextAlign.center,
// // //                               style: const TextStyle(
// // //                                 fontSize: 22,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.white,
// // //                                 shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// // //                               ),
// // //                             ),
// // //                           ),
// // //                           CircleAvatar(
// // //                             backgroundColor: const Color(0xFF0284C7),
// // //                             child: IconButton(
// // //                               icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
// // //                               onPressed: () {
// // //                                 InfoDialog.show(
// // //                                   context,
// // //                                   title: 'Thông Tin ${widget.buildingName}',
// // //                                   details: {
// // //                                     'Quy mô': '${widget.floors.length} Tầng nổi',
// // //                                     'Tổng số căn': 'Căn hộ cao cấp',
// // //                                     'Trạng thái': 'Đang mở bán',
// // //                                   },
// // //                                 );
// // //                               },
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),

// // //                     const Spacer(),

// // //                     // KHUNG CHỨA NGOÀI chuẩn thiết kế gốc
// // //                     Padding(
// // //                       padding: const EdgeInsets.all(16.0),
// // //                       child: Container(
// // //                         padding: const EdgeInsets.all(14),
// // //                         decoration: BoxDecoration(
// // //                           color: const Color(0xFFE0F2FE).withValues(alpha: 0.94),
// // //                           borderRadius: BorderRadius.circular(24),
// // //                           border: Border.all(color: const Color(0xFFBAE6FD), width: 1.8),
// // //                           boxShadow: const [
// // //                             BoxShadow(
// // //                               color: Colors.black38,
// // //                               blurRadius: 20,
// // //                               offset: Offset(0, 8),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.center, // CĂN GIỮA
// // //                           mainAxisSize: MainAxisSize.min,
// // //                           children: [
// // //                             const Row(
// // //                               mainAxisAlignment: MainAxisAlignment.center,
// // //                               children: [
// // //                                 Icon(Icons.tune, size: 16, color: Color(0xFF0369A1)),
// // //                                 SizedBox(width: 6),
// // //                                 Text(
// // //                                   'ĐIỀU KHIỂN TẦNG SA BÀN',
// // //                                   style: TextStyle(
// // //                                     fontSize: 13,
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF0369A1),
// // //                                     letterSpacing: 1.1,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             const SizedBox(height: 12),

// // //                             // Các dãy nút căn giữa tự nhiên đúng chuẩn gốc
// // //                             ConstrainedBox(
// // //                               constraints: BoxConstraints(
// // //                                 maxHeight: MediaQuery.of(context).size.height * 0.42,
// // //                               ),
// // //                               child: SingleChildScrollView(
// // //                                 child: SingleChildScrollView(
// // //                                   scrollDirection: Axis.horizontal,
// // //                                   child: Column(
// // //                                     crossAxisAlignment: CrossAxisAlignment.center, // CĂN GIỮA NÚT
// // //                                     children: floorRows.map((rowFloors) {
// // //                                       return Padding(
// // //                                         padding: const EdgeInsets.only(bottom: 8.0),
// // //                                         child: Row(
// // //                                           mainAxisAlignment: MainAxisAlignment.center, // CĂN GIỮA NÚT TRONG HÀNG
// // //                                           children: rowFloors.map((f) => _buildFloorButton(f, buttonWidth)).toList(),
// // //                                         ),
// // //                                       );
// // //                                     }).toList(),
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),

// // //                             const SizedBox(height: 4),
// // //                             const FittedBox(
// // //                               fit: BoxFit.scaleDown,
// // //                               child: Text(
// // //                                 '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
// // //                                 style: TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w500),
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // Widget Nút Bấm Tầng
// // //   Widget _buildFloorButton(dynamic f, double width) {
// // //     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// // //     bool isOn = widget.isAnyLedOn(fLeds);

// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(horizontal: 4.0),
// // //       child: InkWell(
// // //         onTap: () {
// // //           bool newState = !isOn;
// // //           widget.onToggleLeds(fLeds, newState);
// // //           WebSocketService().sendGroupRooms(fLeds, newState);
// // //           setState(() {});
// // //         },
// // //         onDoubleTap: () async {
// // //           await Navigator.push(
// // //             context,
// // //             MaterialPageRoute(
// // //               builder: (context) => RoomsListScreen(
// // //                 floorName: '${widget.buildingName} - ${f['name']}',
// // //                 rooms: f['rooms'],
// // //                 ledStates: widget.ledStates,
// // //                 onToggleLeds: widget.onToggleLeds,
// // //                 isAnyLedOn: widget.isAnyLedOn,
// // //               ),
// // //             ),
// // //           );
// // //           setState(() {});
// // //         },
// // //         borderRadius: BorderRadius.circular(14),
// // //         child: AnimatedContainer(
// // //           duration: const Duration(milliseconds: 180),
// // //           width: width, // Chiều rộng linh hoạt theo Tablet / Phone
// // //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
// // //           decoration: BoxDecoration(
// // //             gradient: isOn
// // //                 ? const LinearGradient(
// // //                     colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
// // //                     begin: Alignment.topLeft,
// // //                     end: Alignment.bottomRight,
// // //                   )
// // //                 : const LinearGradient(
// // //                     colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
// // //                     begin: Alignment.topLeft,
// // //                     end: Alignment.bottomRight,
// // //                   ),
// // //             borderRadius: BorderRadius.circular(14),
// // //             border: Border.all(
// // //               color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
// // //               width: 1.5,
// // //             ),
// // //             boxShadow: isOn
// // //                 ? [
// // //                     BoxShadow(
// // //                       color: Colors.orange.withValues(alpha: 0.4),
// // //                       blurRadius: 8,
// // //                       offset: const Offset(0, 2),
// // //                     ),
// // //                   ]
// // //                 : [
// // //                     BoxShadow(
// // //                       color: Colors.pink.withValues(alpha: 0.1),
// // //                       blurRadius: 4,
// // //                       offset: const Offset(0, 2),
// // //                     ),
// // //                   ],
// // //           ),
// // //           child: Row(
// // //             mainAxisSize: MainAxisSize.min,
// // //             children: [
// // //               Container(
// // //                 padding: const EdgeInsets.all(4),
// // //                 decoration: BoxDecoration(
// // //                   color: isOn
// // //                       ? Colors.white.withValues(alpha: 0.25)
// // //                       : const Color(0xFFF472B6).withValues(alpha: 0.2),
// // //                   shape: BoxShape.circle,
// // //                 ),
// // //                 child: Icon(
// // //                   isOn ? Icons.lightbulb : Icons.layers,
// // //                   size: 14,
// // //                   color: isOn ? Colors.white : const Color(0xFFDB2777),
// // //                 ),
// // //               ),
// // //               const SizedBox(width: 6),
// // //               Expanded(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     FittedBox(
// // //                       fit: BoxFit.scaleDown,
// // //                       child: Text(
// // //                         f['name'] ?? 'TẦNG',
// // //                         style: TextStyle(
// // //                           fontSize: 12,
// // //                           fontWeight: FontWeight.bold,
// // //                           color: isOn ? Colors.white : const Color(0xFF831843),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     FittedBox(
// // //                       fit: BoxFit.scaleDown,
// // //                       child: Text(
// // //                         '${fLeds.length} phòng | ${isOn ? "BẬT" : "TẮT"}',
// // //                         style: TextStyle(
// // //                           fontSize: 9,
// // //                           fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
// // //                           color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'rooms_list_screen.dart';
// // import '../widgets/info_dialog.dart';
// // import '../services/websocket_service.dart';

// // class FloorsListScreen extends StatefulWidget {
// //   final String buildingName;
// //   final List<dynamic> floors;
// //   final Map<int, bool> ledStates;
// //   final Function(List<int> leds, bool state) onToggleLeds;
// //   final bool Function(List<int> leds) isAnyLedOn;
// //   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
// //   final int selectedFilterType;
// //   final String? buildingImageConfig;

// //   const FloorsListScreen({
// //     super.key,
// //     required this.buildingName,
// //     required this.floors,
// //     required this.ledStates,
// //     required this.onToggleLeds,
// //     required this.isAnyLedOn,
// //     required this.extractLeds,
// //     required this.selectedFilterType,
// //     this.buildingImageConfig,
// //   });

// //   @override
// //   State<FloorsListScreen> createState() => _FloorsListScreenState();
// // }

// // class _FloorsListScreenState extends State<FloorsListScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
// //   }

// //   // Thuật toán chia danh sách thành các hàng nút
// //   List<List<dynamic>> _chunkFloors(List<dynamic> floorsList, int itemsPerRow) {
// //     List<List<dynamic>> chunks = [];
// //     for (int i = 0; i < floorsList.length; i += itemsPerRow) {
// //       int end = (i + itemsPerRow < floorsList.length) ? i + itemsPerRow : floorsList.length;
// //       chunks.add(floorsList.sublist(i, end));
// //     }
// //     return chunks;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final String floorImagePath = widget.buildingImageConfig ?? 'assets/images/floor.jpg';

// //     return Scaffold(
// //       backgroundColor: Colors.black,
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           double screenWidth = constraints.maxWidth;
// //           bool isPhone = screenWidth < 600;

// //           return Stack(
// //             fit: StackFit.expand,
// //             children: [
// //               // 1. Ảnh nền mặt bằng
// //               Positioned.fill(
// //                 child: floorImagePath.startsWith('http')
// //                     ? Image.network(
// //                         floorImagePath,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// //                       )
// //                     : Image.asset(
// //                         floorImagePath,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey.shade900),
// //                       ),
// //               ),

// //               // 2. Lớp phủ Gradient Tối
// //               Positioned.fill(
// //                 child: Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       begin: Alignment.topCenter,
// //                       end: Alignment.bottomCenter,
// //                       colors: [
// //                         Colors.black.withValues(alpha: 0.6),
// //                         Colors.transparent,
// //                         Colors.black.withValues(alpha: 0.85),
// //                       ],
// //                       stops: const [0.0, 0.45, 1.0],
// //                     ),
// //                   ),
// //                 ),
// //               ),

// //               // 3. Nội dung giao diện
// //               SafeArea(
// //                 child: Column(
// //                   children: [
// //                     _buildTopBar(context),
// //                     const Spacer(),
// //                     Padding(
// //                       padding: EdgeInsets.all(isPhone ? 8.0 : 16.0),
// //                       child: _buildCompactCenteredControlPanel(context, screenWidth, isPhone),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildTopBar(BuildContext context) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //       child: Row(
// //         children: [
// //           CircleAvatar(
// //             backgroundColor: Colors.black54,
// //             child: IconButton(
// //               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
// //               onPressed: () => Navigator.pop(context),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               widget.buildingName,
// //               textAlign: TextAlign.center,
// //               style: const TextStyle(
// //                 fontSize: 22,
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.white,
// //                 shadows: [Shadow(blurRadius: 10, color: Colors.black)],
// //               ),
// //             ),
// //           ),
// //           CircleAvatar(
// //             backgroundColor: const Color(0xFF0284C7),
// //             child: IconButton(
// //               icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
// //               onPressed: () {
// //                 InfoDialog.show(
// //                   context,
// //                   title: 'Thông Tin ${widget.buildingName}',
// //                   details: {
// //                     'Quy mô': '${widget.floors.length} Tầng nổi',
// //                     'Tổng số căn': 'Căn hộ cao cấp',
// //                     'Trạng thái': 'Đang mở bán',
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCompactCenteredControlPanel(BuildContext context, double screenWidth, bool isPhone) {
// //     int itemsPerRow = isPhone ? 3 : (screenWidth > 900 ? 6 : 4);
// //     List<List<dynamic>> floorRows = _chunkFloors(widget.floors, itemsPerRow);
    
// //     // Khoảng cách giữa các nút được nới rộng hợp lý
// //     double horizontalSpacing = isPhone ? 6.0 : 10.0;
// //     double verticalSpacing = isPhone ? 6.0 : 8.0;

// //     // Kích thước nút gọn đẹp cố định (không bị ép giãn to quá đà)
// //     double buttonWidth = isPhone ? 104.0 : 126.0;

// //     return Container(
// //       width: double.infinity,
// //       padding: EdgeInsets.symmetric(horizontal: isPhone ? 8 : 16, vertical: isPhone ? 10 : 14),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFE0F2FE).withValues(alpha: 0.94),
// //         borderRadius: BorderRadius.circular(20),
// //         border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
// //         boxShadow: const [
// //           BoxShadow(
// //             color: Colors.black38,
// //             blurRadius: 15,
// //             offset: Offset(0, 6),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.tune, size: isPhone ? 14 : 16, color: const Color(0xFF0369A1)),
// //               const SizedBox(width: 6),
// //               Text(
// //                 'ĐIỀU KHIỂN TẦNG SA BÀN',
// //                 style: TextStyle(
// //                   fontSize: isPhone ? 11.5 : 13,
// //                   fontWeight: FontWeight.bold,
// //                   color: const Color(0xFF0369A1),
// //                   letterSpacing: 1.0,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: isPhone ? 10 : 12),

// //           // Render các hàng nút căn giữa
// //           Column(
// //             children: floorRows.map((rowItems) {
// //               return Padding(
// //                 padding: EdgeInsets.only(bottom: verticalSpacing),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.center, // CĂN GIỮA MỌI HÀNG (CẢ 3 NÚT LẪN 2 NÚT)
// //                   children: rowItems.map((f) {
// //                     return Padding(
// //                       padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
// //                       child: _buildExactButton(f, buttonWidth, isPhone),
// //                     );
// //                   }).toList(),
// //                 ),
// //               );
// //             }).toList(),
// //           ),

// //           const SizedBox(height: 2),
// //           FittedBox(
// //             fit: BoxFit.scaleDown,
// //             child: Text(
// //               '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
// //               style: TextStyle(
// //                 fontSize: isPhone ? 9.5 : 11,
// //                 color: const Color(0xFF0284C7),
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildExactButton(dynamic f, double width, bool isPhone) {
// //     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
// //     bool isOn = widget.isAnyLedOn(fLeds);

// //     return InkWell(
// //       onTap: () {
// //         bool newState = !isOn;
// //         widget.onToggleLeds(fLeds, newState);
// //         WebSocketService().sendGroupRooms(fLeds, newState);
// //         setState(() {});
// //       },
// //       onDoubleTap: () async {
// //         await Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => RoomsListScreen(
// //               floorName: '${widget.buildingName} - ${f['name']}',
// //               rooms: f['rooms'],
// //               ledStates: widget.ledStates,
// //               onToggleLeds: widget.onToggleLeds,
// //               isAnyLedOn: widget.isAnyLedOn,
// //             ),
// //           ),
// //         );
// //         setState(() {});
// //       },
// //       borderRadius: BorderRadius.circular(10),
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 180),
// //         width: width, // Kích thước nút xinh xắn vừa vặn
// //         padding: EdgeInsets.symmetric(
// //           horizontal: isPhone ? 4 : 6,
// //           vertical: isPhone ? 6 : 8,
// //         ),
// //         decoration: BoxDecoration(
// //           gradient: isOn
// //               ? const LinearGradient(
// //                   colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                 )
// //               : const LinearGradient(
// //                   colors: [Color(0xFFFCE7F3), Color(0xFFFBCFE8)],
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                 ),
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(
// //             color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
// //             width: 1.2,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               padding: EdgeInsets.all(isPhone ? 3 : 4),
// //               decoration: BoxDecoration(
// //                 color: isOn
// //                     ? Colors.white.withValues(alpha: 0.25)
// //                     : const Color(0xFFF472B6).withValues(alpha: 0.2),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 isOn ? Icons.lightbulb : Icons.layers,
// //                 size: isPhone ? 11 : 13,
// //                 color: isOn ? Colors.white : const Color(0xFFDB2777),
// //               ),
// //             ),
// //             SizedBox(width: isPhone ? 4 : 6),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   FittedBox(
// //                     fit: BoxFit.scaleDown,
// //                     alignment: Alignment.centerLeft,
// //                     child: Text(
// //                       f['name'] ?? 'TẦNG',
// //                       style: TextStyle(
// //                         fontSize: isPhone ? 10.5 : 12,
// //                         fontWeight: FontWeight.bold,
// //                         color: isOn ? Colors.white : const Color(0xFF831843),
// //                       ),
// //                     ),
// //                   ),
// //                   FittedBox(
// //                     fit: BoxFit.scaleDown,
// //                     alignment: Alignment.centerLeft,
// //                     child: Text(
// //                       '${fLeds.length} phòng | ${isOn ? "BẬT" : "TẮT"}',
// //                       style: TextStyle(
// //                         fontSize: isPhone ? 8.0 : 9.0,
// //                         fontWeight: isOn ? FontWeight.bold : FontWeight.w600,
// //                         color: isOn ? Colors.yellow.shade100 : const Color(0xFF9D174D),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'rooms_list_screen.dart';
// import '../widgets/info_dialog.dart';
// import '../services/websocket_service.dart';

// class FloorsListScreen extends StatefulWidget {
//   final String buildingName;
//   final List<dynamic> floors;
//   final Map<int, bool> ledStates;
//   final Function(List<int> leds, bool state) onToggleLeds;
//   final bool Function(List<int> leds) isAnyLedOn;
//   final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
//   final int selectedFilterType;
//   final String? buildingImageConfig;

//   const FloorsListScreen({
//     super.key,
//     required this.buildingName,
//     required this.floors,
//     required this.ledStates,
//     required this.onToggleLeds,
//     required this.isAnyLedOn,
//     required this.extractLeds,
//     required this.selectedFilterType,
//     this.buildingImageConfig,
//   });

//   @override
//   State<FloorsListScreen> createState() => _FloorsListScreenState();
// }

// class _FloorsListScreenState extends State<FloorsListScreen> {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//   }

//   // Thuật toán chia nhóm danh sách
//   List<List<dynamic>> _chunkFloors(List<dynamic> floorsList, int itemsPerRow) {
//     List<List<dynamic>> chunks = [];
//     for (int i = 0; i < floorsList.length; i += itemsPerRow) {
//       int end = (i + itemsPerRow < floorsList.length) ? i + itemsPerRow : floorsList.length;
//       chunks.add(floorsList.sublist(i, end));
//     }
//     return chunks;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String floorImagePath = widget.buildingImageConfig ?? 'assets/images/floor.jpg';

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF0F172A), // Slate 900
//               Color(0xFF1E293B), // Slate 800
//               Color(0xFF0F172A),
//             ],
//           ),
//         ),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             double screenWidth = constraints.maxWidth;
//             bool isPhone = screenWidth < 600;

//             return SafeArea(
//               child: Column(
//                 children: [
//                   // 1. Top Bar
//                   _buildTopBar(context),

//                   // 2. KHU VỰC SA BÀN RỘNG THOÁNG (Interactive Zoom)
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: InteractiveViewer(
//                           minScale: 1.0,
//                           maxScale: 4.0,
//                           child: Center(
//                             child: floorImagePath.startsWith('http')
//                                 ? Image.network(
//                                     floorImagePath,
//                                     fit: BoxFit.contain,
//                                     errorBuilder: (context, error, stackTrace) =>
//                                         Container(color: Colors.grey.shade900),
//                                   )
//                                 : Image.asset(
//                                     floorImagePath,
//                                     fit: BoxFit.contain,
//                                     errorBuilder: (context, error, stackTrace) =>
//                                         Container(color: Colors.grey.shade900),
//                                   ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   // 3. BẢNG TẦNG CẤU TRÚC ADAPTIVE RESPONSIVE
//                   Padding(
//                     padding: EdgeInsets.all(isPhone ? 6.0 : 10.0),
//                     child: _buildAdaptiveControlPanel(context, screenWidth, isPhone),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.white12,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               widget.buildingName,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 shadows: [Shadow(blurRadius: 10, color: Colors.black45)],
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
//                   title: 'Thông Tin ${widget.buildingName}',
//                   details: {
//                     'Quy mô': '${widget.floors.length} Tầng nổi',
//                     'Tổng số căn': 'Căn hộ cao cấp',
//                     'Trạng thái': 'Đang mở bán',
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAdaptiveControlPanel(BuildContext context, double screenWidth, bool isPhone) {
//     // Tự động phân bổ số cột phù hợp với độ rộng thiết bị:
//     // Điện thoại màn hẹp: 3 hoặc 4 nút / hàng (vừa khít 100%)
//     // iPad / Tablet màn rộng: 10 nút / hàng (đúng 2 hàng mỏng)
//     int itemsPerRow = isPhone ? (screenWidth < 380 ? 3 : 4) : 10;
//     List<List<dynamic>> floorRows = _chunkFloors(widget.floors, itemsPerRow);

//     double horizontalSpacing = isPhone ? 4.0 : 6.0;
//     double verticalSpacing = isPhone ? 4.0 : 6.0;

//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 12, vertical: isPhone ? 6 : 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE0F2FE).withValues(alpha: 0.95),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black45,
//             blurRadius: 16,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.tune, size: isPhone ? 13 : 15, color: const Color(0xFF0369A1)),
//               const SizedBox(width: 4),
//               Text(
//                 'ĐIỀU KHIỂN TẦNG SA BÀN',
//                 style: TextStyle(
//                   fontSize: isPhone ? 11 : 12.5,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF0369A1),
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isPhone ? 5 : 8),

//           // Render hàng nút tự co giãn đều bằng Expanded, không bao giờ bị bục viền
//           Column(
//             children: floorRows.map((rowItems) {
//               bool isFullRow = rowItems.length == itemsPerRow;

//               return Padding(
//                 padding: EdgeInsets.only(bottom: verticalSpacing),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: rowItems.map((f) {
//                     Widget btnWidget = Padding(
//                       padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
//                       child: _buildCompactButton(f, isPhone),
//                     );

//                     // Hàng đầy nút -> Tự chia đều chiều rộng không bao giờ tràn
//                     // Hàng lẻ cuối cùng -> Căn giữa giữ nguyên tỉ lệ
//                     if (isFullRow) {
//                       return Expanded(child: btnWidget);
//                     } else {
//                       return Flexible(child: btnWidget);
//                     }
//                   }).toList(),
//                 ),
//               );
//             }).toList(),
//           ),

//           const SizedBox(height: 1),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
//               style: TextStyle(
//                 fontSize: isPhone ? 9.0 : 10.5,
//                 color: const Color(0xFF0284C7),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCompactButton(dynamic f, bool isPhone) {
//     List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
//     bool isOn = widget.isAnyLedOn(fLeds);

//     return InkWell(
//       onTap: () {
//         bool newState = !isOn;
//         widget.onToggleLeds(fLeds, newState);
//         WebSocketService().sendGroupRooms(fLeds, newState);
//         setState(() {});
//       },
//       onDoubleTap: () async {
//         await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => RoomsListScreen(
//               floorName: '${widget.buildingName} - ${f['name']}',
//               rooms: f['rooms'],
//               ledStates: widget.ledStates,
//               onToggleLeds: widget.onToggleLeds,
//               isAnyLedOn: widget.isAnyLedOn,
//             ),
//           ),
//         );
//         setState(() {});
//       },
//       borderRadius: BorderRadius.circular(8),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 180),
//         padding: EdgeInsets.symmetric(
//           horizontal: isPhone ? 2 : 4,
//           vertical: isPhone ? 4 : 5,
//         ),
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
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isOn ? Colors.amberAccent : const Color(0xFFF472B6),
//             width: 1.2,
//           ),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: EdgeInsets.all(isPhone ? 1.8 : 3.0),
//               decoration: BoxDecoration(
//                 color: isOn
//                     ? Colors.white.withValues(alpha: 0.25)
//                     : const Color(0xFFF472B6).withValues(alpha: 0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 isOn ? Icons.lightbulb : Icons.layers,
//                 size: isPhone ? 9.0 : 11.5,
//                 color: isOn ? Colors.white : const Color(0xFFDB2777),
//               ),
//             ),
//             SizedBox(width: isPhone ? 2 : 3),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       f['name'] ?? 'TẦNG',
//                       style: TextStyle(
//                         fontSize: isPhone ? 9.0 : 10.5,
//                         fontWeight: FontWeight.bold,
//                         color: isOn ? Colors.white : const Color(0xFF831843),
//                       ),
//                     ),
//                   ),
//                   FittedBox(
//                     fit: BoxFit.scaleDown,
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       '${fLeds.length} p | ${isOn ? "BẬT" : "TẮT"}',
//                       style: TextStyle(
//                         fontSize: isPhone ? 6.5 : 7.5,
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
import 'rooms_list_screen.dart';
import '../widgets/info_dialog.dart';
import '../services/websocket_service.dart';

class FloorsListScreen extends StatefulWidget {
  final String buildingName;
  final List<dynamic> floors;
  final Map<int, bool> ledStates;
  final Function(List<int> leds, bool state) onToggleLeds;
  final bool Function(List<int> leds) isAnyLedOn;
  final List<int> Function(List<dynamic> rooms, {int? filterRoomType}) extractLeds;
  final int selectedFilterType;
  final String? buildingImageConfig;

  const FloorsListScreen({
    super.key,
    required this.buildingName,
    required this.floors,
    required this.ledStates,
    required this.onToggleLeds,
    required this.isAnyLedOn,
    required this.extractLeds,
    required this.selectedFilterType,
    this.buildingImageConfig,
  });

  @override
  State<FloorsListScreen> createState() => _FloorsListScreenState();
}

class _FloorsListScreenState extends State<FloorsListScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  List<List<dynamic>> _chunkFloors(List<dynamic> floorsList, int itemsPerRow) {
    List<List<dynamic>> chunks = [];
    for (int i = 0; i < floorsList.length; i += itemsPerRow) {
      int end = (i + itemsPerRow < floorsList.length) ? i + itemsPerRow : floorsList.length;
      chunks.add(floorsList.sublist(i, end));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final String floorImagePath = widget.buildingImageConfig ?? 'assets/images/floor.jpg';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Ảnh Sa bàn phóng to làm nền mờ phía sau
          Positioned.fill(
            child: floorImagePath.startsWith('http')
                ? Image.network(floorImagePath, fit: BoxFit.cover)
                : Image.asset(floorImagePath, fit: BoxFit.cover),
          ),

          // 2. NỀN SÁNG BỪNG CAO CẤP: Gradient Trắng & Xanh Sa Bàn mờ
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFFF0F9FF).withValues(alpha: 0.88), // Sky 50
                      const Color(0xFFE0F2FE).withValues(alpha: 0.82), // Sky 100
                      const Color(0xFFF8FAFC).withValues(alpha: 0.92), // Slate 50
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. NỘI DUNG CHÍNH
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                bool isPhone = screenWidth < 600;

                return Column(
                  children: [
                    // Top Bar Tone Sáng Sang Trọng
                    _buildTopBar(context),

                    // KHU VỰC SA BÀN CHÍNH NỔI BẬT
                    // KHU VỰC HIỂN THỊ MẶT BẰNG TẦNG - SEAMLESS FLOATING BANNER
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
            child: floorImagePath.startsWith('http')
                ? Image.network(
                    floorImagePath,
                    fit: BoxFit.contain, // Hiển thị 100% nguyên bản ảnh tầng, không che khuất
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
                    floorImagePath,
                    fit: BoxFit.contain, // Hiển thị 100% nguyên bản ảnh tầng, không che khuất
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

                    // BẢNG ĐIỀU KHIỂN NỀN TRẮNG XANH
                    Padding(
                      padding: EdgeInsets.all(isPhone ? 8.0 : 12.0),
                      child: _buildAdaptiveControlPanel(context, screenWidth, isPhone),
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
          // Nút Quay lại (Back) dạng Glassmorphic
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

          // TIÊU ĐỀ "TÒA A" DẠNG BADGE LUXURY SANG TRỌNG
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE0F2FE), // Light Sky
                      Color(0xFFBAE6FD), // Sky Blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
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
                      Icons.apartment_rounded,
                      size: 18,
                      color: Color(0xFF0369A1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.buildingName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0369A1), // Màu xanh biển đậm nổi bật
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Nút Thông tin (Info)
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
                    title: 'Thông Tin ${widget.buildingName}',
                    details: {
                      'Quy mô': '${widget.floors.length} Tầng nổi',
                      'Tổng số căn': 'Căn hộ cao cấp',
                      'Trạng thái': 'Đang mở bán',
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
//   Widget _buildAdaptiveControlPanel(BuildContext context, double screenWidth, bool isPhone) {
//     int itemsPerRow = isPhone ? (screenWidth < 380 ? 3 : 4) : 10;
//     List<List<dynamic>> floorRows = _chunkFloors(widget.floors, itemsPerRow);
//     double horizontalSpacing = isPhone ? 4.0 : 6.0;
//     double verticalSpacing = isPhone ? 4.0 : 6.0;
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 12, vertical: isPhone ? 6 : 8),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.92),
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: const Color(0xFFBAE6FD), width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF0284C7).withValues(alpha: 0.1),
//             blurRadius: 18,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.tune, size: isPhone ? 13 : 15, color: const Color(0xFF0369A1)),
//               const SizedBox(width: 4),
//               Text(
//                 'ĐIỀU KHIỂN TẦNG SA BÀN',
//                 style: TextStyle(
//                   fontSize: isPhone ? 11 : 12.5,
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF0369A1),
//                   letterSpacing: 0.8,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: isPhone ? 5 : 8),
//           // Trong _buildAdaptiveControlPanel:
// Column(
//   children: floorRows.map((rowItems) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: verticalSpacing),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         mainAxisSize: MainAxisSize.min, // 🟢 Giúp hàng co lại đúng kích thước phần tử
//         children: rowItems.map((f) {
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
//             child: _buildCompactButton(f, isPhone), // 🟢 Bỏ totalItems & itemsPerRow
//           );
//         }).toList(),
//       ),
//     );
//   }).toList(),
// ),

//           const SizedBox(height: 1),
//           FittedBox(
//             fit: BoxFit.scaleDown,
//             child: Text(
//               '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
//               style: TextStyle(
//                 fontSize: isPhone ? 9.0 : 10.5,
//                 color: const Color(0xFF0284C7),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

Widget _buildAdaptiveControlPanel(BuildContext context, double screenWidth, bool isPhone) {
  // 🟢 Chia tổng số tầng làm tròn lên cho 3 hàng (luôn tạo ra tối đa 3 hàng đều nhau)
  int targetRows = 3;
  int itemsPerRow = (widget.floors.length / targetRows).ceil();
  if (itemsPerRow < 1) itemsPerRow = 1;

  // Dùng hàm _chunkFloors sẵn có của bạn
  List<List<dynamic>> floorRows = _chunkFloors(widget.floors, itemsPerRow);

  double horizontalSpacing = isPhone ? 4.0 : 6.0;
  double verticalSpacing = isPhone ? 4.0 : 6.0;

  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: isPhone ? 6 : 12, vertical: isPhone ? 6 : 8),
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
              'ĐIỀU KHIỂN TẦNG SA BÀN',
              style: TextStyle(
                fontSize: isPhone ? 11 : 12.5,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0369A1),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        SizedBox(height: isPhone ? 5 : 8),

        // 🟢 BỌC FITTEDBOX GIÚP GIỮ NGUYÊN SHAPE NÚT BẤM VÀ TỰ SCALE KHUÔN 3 HÀNG VỪA MÀN HÌNH
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: floorRows.map((rowItems) {
              return Padding(
                padding: EdgeInsets.only(bottom: verticalSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: rowItems.map((f) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalSpacing / 2),
                      child: _buildCompactButton(f, isPhone), // 🟢 Nút gốc nét đẹp
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 1),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '• Chạm 1 lần: Bật/Tắt Tầng   |   • Nhấn đúp 2 lần: Danh sách căn hộ',
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

//   Widget _buildCompactButton(dynamic f, bool isPhone) { // 🟢 Bỏ các tham số dư thừa
//   List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
//   bool isOn = widget.isAnyLedOn(fLeds);

//   // 🟢 Cố định chiều rộng vừa đẹp (không bị giãn tràn khi có 1 tầng)
//   double buttonWidth = isPhone ? 90.0 : 135.0; 

//   return InkWell(
//     onTap: () {
//       bool newState = !isOn;
//       widget.onToggleLeds(fLeds, newState);
//       WebSocketService().sendGroupRooms(fLeds, newState);
//       setState(() {});
//     },
//     onDoubleTap: () async {
//       await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => RoomsListScreen(
//             floorName: '${widget.buildingName} - ${f['name']}',
//             rooms: f['rooms'],
//             ledStates: widget.ledStates,
//             onToggleLeds: widget.onToggleLeds,
//             isAnyLedOn: widget.isAnyLedOn,
//           ),
//         ),
//       );
//       setState(() {});
//     },
//     borderRadius: BorderRadius.circular(8),
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 180),
//       width: buttonWidth, // 🟢 Giữ nút co gọn gàng ở giữa
//       padding: EdgeInsets.symmetric(
//         horizontal: isPhone ? 4 : 8,
//         vertical: isPhone ? 5 : 7,
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
//         borderRadius: BorderRadius.circular(8),
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
//             padding: EdgeInsets.all(isPhone ? 2.0 : 3.5),
//             decoration: BoxDecoration(
//               color: isOn
//                   ? Colors.white.withValues(alpha: 0.25)
//                   : const Color(0xFFF472B6).withValues(alpha: 0.2),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               isOn ? Icons.lightbulb : Icons.layers,
//               size: isPhone ? 10.0 : 13.0,
//               color: isOn ? Colors.white : const Color(0xFFDB2777),
//             ),
//           ),
//           SizedBox(width: isPhone ? 4 : 6),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     f['name'] ?? 'TẦNG',
//                     style: TextStyle(
//                       fontSize: isPhone ? 9.5 : 11.0,
//                       fontWeight: FontWeight.bold,
//                       color: isOn ? Colors.white : const Color(0xFF831843),
//                     ),
//                   ),
//                 ),
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     '${fLeds.length} p | ${isOn ? "BẬT" : "TẮT"}',
//                     style: TextStyle(
//                       fontSize: isPhone ? 7.0 : 8.5,
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
Widget _buildCompactButton(dynamic f, bool isPhone) {
  List<int> fLeds = widget.extractLeds(f['rooms'], filterRoomType: widget.selectedFilterType);
  bool isOn = widget.isAnyLedOn(fLeds);

  // 🟢 Khôi phục chiều rộng button chuẩn đẹp ban đầu
  double buttonWidth = isPhone ? 90.0 : 135.0; 

  return InkWell(
    onTap: () {
      bool newState = !isOn;
      widget.onToggleLeds(fLeds, newState);
      WebSocketService().sendGroupRooms(fLeds, newState);
      setState(() {});
    },
    onDoubleTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoomsListScreen(
            floorName: '${widget.buildingName} - ${f['name']}',
            rooms: f['rooms'],
            ledStates: widget.ledStates,
            onToggleLeds: widget.onToggleLeds,
            isAnyLedOn: widget.isAnyLedOn,
          ),
        ),
      );
      setState(() {});
    },
    borderRadius: BorderRadius.circular(8),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: buttonWidth, // 🟢 Chuẩn kích thước ban đầu
      padding: EdgeInsets.symmetric(
        horizontal: isPhone ? 4 : 8,
        vertical: isPhone ? 5 : 7,
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
        borderRadius: BorderRadius.circular(8),
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
            padding: EdgeInsets.all(isPhone ? 2.0 : 3.5),
            decoration: BoxDecoration(
              color: isOn
                  ? Colors.white.withValues(alpha: 0.25)
                  : const Color(0xFFF472B6).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOn ? Icons.lightbulb : Icons.layers,
              size: isPhone ? 10.0 : 13.0,
              color: isOn ? Colors.white : const Color(0xFFDB2777),
            ),
          ),
          SizedBox(width: isPhone ? 4 : 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    f['name'] ?? 'TẦNG',
                    style: TextStyle(
                      fontSize: isPhone ? 9.5 : 11.0,
                      fontWeight: FontWeight.bold,
                      color: isOn ? Colors.white : const Color(0xFF831843),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${fLeds.length} p | ${isOn ? "BẬT" : "TẮT"}',
                    style: TextStyle(
                      fontSize: isPhone ? 7.0 : 8.5,
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