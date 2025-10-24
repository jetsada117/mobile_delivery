import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

class RiderDeliveryStatusPage extends StatefulWidget {
  const RiderDeliveryStatusPage({super.key});

  @override
  State<RiderDeliveryStatusPage> createState() =>
      _RiderDeliveryStatusPageState();
}

class _RiderDeliveryStatusPageState extends State<RiderDeliveryStatusPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'สถานะการส่ง',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: const LatLng(16.2458, 103.2500),
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              const MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(16.2458, 103.2500),
                    width: 36,
                    height: 36,
                    child: Icon(Icons.location_on, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusPill(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.green,
                    ),
                    _StatusPill(icon: Icons.check_circle_outline),
                    _StatusPill(icon: Icons.local_shipping_outlined),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 140,
            child: _CameraButton(
              onTap: () => _openProofPopup(context, 'รับออเดอร์'),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 140,
            child: _CameraButton(
              onTap: () => _openProofPopup(context, 'จัดส่งสำเร็จ'),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderCol),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/100?img=12',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ข้อมูลผู้รับ',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 4),
                        Text('ชื่อ: นายสมชาย เด็กดี'),
                        Text('เบอร์โทร: 012-345-6789'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openProofPopup(BuildContext context, String title) async {
    XFile? picked;
    final nameController = TextEditingController();

    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final blackBtnStyle = ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          );

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: const Color(0xFFC9A9F5),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final x = await _picker.pickImage(
                        source: ImageSource.camera,
                      );
                      if (x != null) {
                        setLocal(() {
                          picked = x;
                          nameController.text = x.name;
                        });
                      }
                    },
                    child: Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: picked == null
                          ? const Icon(
                              Icons.photo_camera_outlined,
                              size: 40,
                              color: Colors.black87,
                            )
                          : Image.file(File(picked!.path), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'ชื่อรูป',
                            isDense: true,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            final x = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (x != null) {
                              setLocal(() {
                                picked = x;
                                nameController.text = x.name;
                              });
                            }
                          },
                          style: blackBtnStyle,
                          child: const Text('อัปโหลดรูปภาพ'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          style: blackBtnStyle,
                          child: const Text('ยกเลิก'),
                        ),
                      ),
                      SizedBox(
                        width: 96,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: blackBtnStyle,
                          child: const Text('ยืนยัน'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (ok == true && context.mounted) {
      if (picked == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาถ่ายหรืออัปโหลดรูปก่อน')),
        );
        return;
      }
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, this.iconColor = Colors.black87});
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x55000000)),
      ),
      child: Icon(icon, size: 20, color: iconColor),
    );
  }
}

class _CameraButton extends StatelessWidget {
  const _CameraButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFC9A9F5),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Icon(Icons.photo_camera_outlined, size: 26),
      ),
    );
  }
}
