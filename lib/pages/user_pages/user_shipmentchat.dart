import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ถ้ามีหน้าเหล่านี้อยู่แล้วให้ import ของจริงแทน
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_sentItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_receivedItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';

class ShipmentChatPage extends StatefulWidget {
  const ShipmentChatPage({super.key});

  @override
  State<ShipmentChatPage> createState() => _ShipmentChatPageState();
}

class _ShipmentChatPageState extends State<ShipmentChatPage> {
  // โทนสีเดียวกับโปรเจ็กต์
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const innerCard = Color(0xFFC9A9F5);
  static const borderCol = Color(0x55000000);

  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _navIndex = 1; // อยู่แท็บ "สินค้าที่ส่ง"

  final List<_Msg> _msgs = [
    const _Msg(
      text: '[1] รอไปรับสินค้า',
      side: _Side.left,
    ),
    const _Msg(
      text: '[2] ไรเดอร์รับงาน',
      side: _Side.right,
      imageUrl: 'https://picsum.photos/seed/rider/96',
    ),
    const _Msg(
      text: '[3] ไรเดอร์รับสินค้าแล้ว',
      side: _Side.right,
      imageUrl: 'https://picsum.photos/seed/pickup/96',
    ),
    const _Msg(
      text: '[4] ไรเดอร์กำลังไปส่ง',
      side: _Side.right,
      imageUrl: 'https://picsum.photos/seed/deliver/96',
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final t = _input.text.trim();
    if (t.isEmpty) return;
    setState(() {
      _msgs.add(_Msg(text: t, side: _Side.left));
      _input.clear();
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('สถานะสินค้าที่ส่ง',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // การ์ดห้องแชต
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: innerCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderCol),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: ListView.builder(
                      controller: _scroll,
                      itemCount: _msgs.length,
                      itemBuilder: (_, i) => _Bubble(msg: _msgs[i]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // แถบพิมพ์ข้อความ
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      decoration: InputDecoration(
                        hintText: 'พิมพ์ข้อความ...',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _send,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('ส่ง'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        backgroundColor: cardBg,
        onTap: (i) {
          if (i == 0) {
            Get.off(() => const UserHomePage());
            return;
          }
          if (i == 1) {
            Get.off(() => const SentItemsPage());
            return;
          }
          if (i == 2) {
            Get.off(() => const ReceivedItemsPage());
            return;
          }
          if (i == 3) {
            Get.off(() => const UserProfilePage());
            return;
          }
          setState(() => _navIndex = i);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping_outlined),
            label: 'สินค้าที่ส่ง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            label: 'สินค้าที่ได้รับ',
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

/* ---------- Models & UI pieces ---------- */

enum _Side { left, right }

class _Msg {
  final String text;
  final _Side side;
  final String? imageUrl;
  const _Msg({required this.text, required this.side, this.imageUrl});
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.msg});

  final _Msg msg;

  @override
  Widget build(BuildContext context) {
    final isRight = msg.side == _Side.right;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRight) const SizedBox(width: 4),
          // ข้อความ
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isRight ? 14 : 2),
                  bottomRight: Radius.circular(isRight ? 2 : 14),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  )
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(msg.text),
            ),
          ),
          // รูปเล็กสำหรับสถานะ (ถ้ามี) — วางด้านขวาเหมือนในภาพ
          if (msg.imageUrl != null) ...[
            const SizedBox(width: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                msg.imageUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
          ],
          if (isRight) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
