// lib/pages/rider_pages/rider_accept_order_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_home.dart';
import 'package:mobile_delivery/pages/rider_pages/rider_profile_page.dart';

class RiderAcceptOrderPage extends StatefulWidget {
  const RiderAcceptOrderPage({
    super.key,
    this.productName = 'ปลากระป๋อง',
    this.productImage =
        'https://images.unsplash.com/photo-1602576666092-bf6447dd4c8e?w=640',
    this.senderName = 'นายสมชาย เด็กดี',
    this.senderPhone = '012-345-6789',
    this.receiverName = 'นายสมหมาย เด็กดี',
    this.receiverPhone = '012-345-6789',
    this.distanceKm = 3.5,
  });

  final String productName;
  final String productImage;
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final double distanceKm;

  @override
  State<RiderAcceptOrderPage> createState() => _RiderAcceptOrderPageState();
}

class _RiderAcceptOrderPageState extends State<RiderAcceptOrderPage> {
  // โทนสี
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'รับออเดอร์',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // รูปสินค้า
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    widget.productImage,
                    width: 140,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 140,
                      height: 110,
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Icon(Icons.inventory_2, size: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ชื่อสินค้า
              Center(
                child: Text(
                  'ชื่อสินค้า : ${widget.productName}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),

              // การ์ดผู้ส่ง / ผู้รับ
              _PersonCard(
                title: 'ข้อมูลผู้ส่ง',
                name: widget.senderName,
                phone: widget.senderPhone,
              ),
              const SizedBox(height: 10),
              _PersonCard(
                title: 'ข้อมูลผู้รับ',
                name: widget.receiverName,
                phone: widget.receiverPhone,
              ),
              const SizedBox(height: 12),

              // แผนที่
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                clipBehavior: Clip.hardEdge,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(16.2458, 103.2500),
                    initialZoom: 14.2,
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
              ),
              const SizedBox(height: 8),

              // ระยะทาง
              Text(
                'ระยะทางโดยประมาณ : ${widget.distanceKm.toStringAsFixed(1)} กม.',
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // ปุ่ม ยกเลิก / รับออเดอร์
              Row(
                children: [
                  // ... ภายใน Row ของปุ่ม ยกเลิก / รับออเดอร์
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ยกเลิกรับออเดอร์')),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RiderHomePage(),
                            ),
                            (route) => false, // ล้างสแต็กทั้งหมดแล้วไปหน้าหลัก
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('ยกเลิก'),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'รับออเดอร์: ${widget.productName}',
                              ),
                            ),
                          );
                          // TODO: ใส่ลอจิกรับงานจริงที่นี่
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('รับออเดอร์'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // แถบล่าง
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == _navIndex) return;
          setState(() => _navIndex = i);

          if (i == 0) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const RiderHomePage()),
            );
          }
          if (i == 1) {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RiderProfilePage()));
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

/* ---------------- Widgets ย่อย ---------------- */

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.title,
    required this.name,
    required this.phone,
  });

  final String title;
  final String name;
  final String phone;

  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=7'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text('ชื่อ : $name'),
                Text('เบอร์โทร : $phone'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
