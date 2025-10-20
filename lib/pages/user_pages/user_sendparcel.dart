import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/user_pages/user_createparcel.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';

class SendParcelPage extends StatefulWidget {
  const SendParcelPage({super.key});

  @override
  State<SendParcelPage> createState() => _SendParcelPageState();
}

class _SendParcelPageState extends State<SendParcelPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const innerCard = Color(0xFFC9A9F5);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  final _phoneSearch = TextEditingController();
  final _addr1 = TextEditingController(text: 'บ้านเลขที่111');
  final _addr2 = TextEditingController(text: 'บ้านเลขที่222');

  int _navIndex = 1;
  int? _selectedAddr;
  _Recipient? _recipient;

  @override
  void dispose() {
    _phoneSearch.dispose();
    _addr1.dispose();
    _addr2.dispose();
    super.dispose();
  }

  void _mockSearch() {
    setState(() {
      _recipient = const _Recipient(
        name: 'นายสมชาย',
        phone: '088-888-8888',
        avatarUrl: 'https://i.pravatar.cc/100?img=13',
      );
      _selectedAddr = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'ส่งสินค้า',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ค้นหาผู้รับ
              const Text(
                'ค้นหาผู้รับ',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneSearch,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'เบอร์โทรศัพท์',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: _mockSearch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: linkBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('ค้นหา'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // การ์ดข้อมูลผู้รับ + ที่อยู่
              Card(
                color: cardBg,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: borderCol),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: innerCard,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== ข้อมูลผู้รับ =====
                      _recipientInfo(_recipient),

                      const SizedBox(height: 16),

                      // ===== ที่อยู่ 1 =====
                      const Text(
                        'ที่อยู่1',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _addressTile(
                        controller: _addr1,
                        checked: _selectedAddr == 1,
                        onCheck: (v) =>
                            setState(() => _selectedAddr = v ? 1 : null),
                      ),
                      const SizedBox(height: 14),

                      // ===== ที่อยู่ 2 =====
                      const Text(
                        'ที่อยู่2',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _addressTile(
                        controller: _addr2,
                        checked: _selectedAddr == 2,
                        onCheck: (v) =>
                            setState(() => _selectedAddr = v ? 2 : null),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ปุ่มส่ง
              Center(
                child: SizedBox(
                  width: 120,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const UserHomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: linkBlue,
                      disabledBackgroundColor: linkBlue.withOpacity(.4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('ส่ง'),
                  ),
                ),
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
            // ไปหน้า "หน้าหลัก" และแทนหน้าปัจจุบัน
            Get.off(() => const UserHomePage());
            return;
          }
          if (i == 1) {
            Get.off(() => const CreateParcelPage());
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

  Widget _addressTile({
    required TextEditingController controller,
    required bool checked,
    required ValueChanged<bool> onCheck,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderCol),
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 6, 10),
      child: Row(
        children: [
          // แผนที่หลอก
          Container(
            width: 72,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.map, size: 28, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          // ช่องกรอกที่อยู่
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'รายละเอียดที่อยู่',
                isDense: true,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // เลือกทีละรายการ
          Checkbox(
            value: checked,
            onChanged: (v) => onCheck(v ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recipientInfo(_Recipient? r) {
    // ถ้ายังไม่ค้นหา โชว์ placeholder ตามสไตล์ภาพ
    final name = r?.name ?? 'ชื่อผู้รับ : -';
    final phone = r?.phone ?? 'เบอร์โทร : -';
    final avatar = r?.avatarUrl;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: avatar == null
                  ? const Icon(Icons.person, size: 28)
                  : Image.network(
                      avatar,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 28),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ข้อมูลรับ : ${r?.name ?? '—'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'เบอร์โทร : ${r?.phone ?? '—'}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Recipient {
  final String name;
  final String phone;
  final String avatarUrl;
  const _Recipient({
    required this.name,
    required this.phone,
    required this.avatarUrl,
  });
}
