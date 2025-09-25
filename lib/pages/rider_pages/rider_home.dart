import 'package:flutter/material.dart';

class RiderHomePage extends StatefulWidget {
  final String riderName;
  const RiderHomePage({super.key, this.riderName = 'ชื่อไรเดอร์'});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final _search = TextEditingController();
  int _navIndex = 0;

  final List<_OrderItem> _orders = const [
    _OrderItem(
      name: 'ปลากระป๋อง',
      imageUrl: 'https://picsum.photos/seed/can/200',
    ),
    _OrderItem(
      name: 'มาม่า',
      imageUrl: 'https://picsum.photos/seed/noodle/200',
    ),
    _OrderItem(name: 'ไข่ไก่', imageUrl: 'https://picsum.photos/seed/egg/200'),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // สีตามดีไซน์
    const bg = Color(0xFFD2C2F1);
    const cardBg = Color(0xFFF4EBFF);
    const borderCol = Color(0x55000000);

    // กรองตามคำค้น
    final q = _search.text.trim().toLowerCase();
    final filtered = _orders
        .where((o) => o.name.toLowerCase().contains(q))
        .toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ทักทาย + avatar
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Image.network(
                        'https://i.pravatar.cc/100?img=5',
                        errorBuilder: (context, error, st) =>
                            const Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'สวัสดี, ${widget.riderName}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ช่องค้นหา
              TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ค้นหา......',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: borderCol),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'รายการออเดอร์ :',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),

              // การ์ดออเดอร์ (กดได้ทั้งใบ)
              ...filtered.map(
                (o) => _OrderCard(item: o, onTap: () => _confirmOrder(o)),
              ),

              if (filtered.isEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  alignment: Alignment.center,
                  child: const Text('ไม่พบออเดอร์ที่ตรงกับคำค้น'),
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
        onTap: (i) => setState(() => _navIndex = i),
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

  Future<void> _confirmOrder(_OrderItem item) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFC9A9F5),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'คุณต้องการรับออเดอร์นี้หรือไม่',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('ยกเลิก'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('ยืนยัน'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // ทดสอบ: แจ้งผลด้วย SnackBar แล้วอยู่หน้าเดิม
    if (!mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ยืนยันออเดอร์: ${item.name}')));
    } else if (ok == false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยกเลิก')));
    }
  }
}

class _OrderItem {
  final String name;
  final String imageUrl;
  const _OrderItem({required this.name, required this.imageUrl});
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({super.key, required this.item, this.onTap});
  final _OrderItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const borderCol = Color(0x55000000);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderCol),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                item.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.white,
                  child: const Icon(Icons.inventory_2, size: 32),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
