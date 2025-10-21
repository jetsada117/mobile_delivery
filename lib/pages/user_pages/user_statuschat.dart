import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_sentItems.dart';
import 'package:mobile_delivery/pages/user_pages/user_receiveditems.dart';
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';

class StatusChatPage extends StatefulWidget {
  const StatusChatPage({super.key, required this.orderId, required this.title});

  final int orderId;
  final String title;

  @override
  State<StatusChatPage> createState() => _StatusChatPageState();
}

class _StatusChatPageState extends State<StatusChatPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const innerCard = Color(0xFFC9A9F5);
  static const borderCol = Color(0x55000000);

  final _input = TextEditingController();
  final _scroll = ScrollController();
  int _navIndex = 1;

  final List<_Msg> _msgs = [
    const _Msg(text: '[1] รอไปรับสินค้า', side: _Side.left),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
            ],
          ),
        ),
      ),

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
        mainAxisAlignment: isRight
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isRight) const SizedBox(width: 4),
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
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(msg.text),
            ),
          ),
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
