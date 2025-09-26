import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/pages/user_pages/user_addaddress.dart';
import 'package:mobile_delivery/pages/user_pages/user_editaddress.dart';
import 'package:mobile_delivery/pages/user_pages/user_home.dart';
import 'package:mobile_delivery/pages/user_pages/user_createparcel.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  // ข้อมูลผู้ใช้ (ตัวอย่าง)
  final String _name = 'นายทดสอบ อินทร์ศักดา';
  final String _phone = '061-279-4147';
  final String _avatarUrl = 'https://i.pravatar.cc/160?img=23';

  // ที่อยู่ (แก้ไข/เพิ่มได้)
  final List<TextEditingController> _addresses = [
    TextEditingController(text: 'บ้านเลขที่111'),
    TextEditingController(text: 'บ้านเลขที่222'),
  ];
  final List<bool> _editing = [false, false];

  int _navIndex = 3; // โปรไฟล์

  @override
  void dispose() {
    for (final c in _addresses) {
      c.dispose();
    }
    super.dispose();
  }

  void _addAddress() {
    setState(() {
      _addresses.add(TextEditingController());
      _editing.add(true);
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
          'โปรไฟล์',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Image.network(
                      _avatarUrl,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // การ์ดข้อมูลผู้ใช้
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderCol),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ข้อมูลผู้ใช้',
                      style: TextStyle(
                        color: linkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ชื่อ : $_name',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text('เบอร์โทร : $_phone'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ส่วนที่อยู่ของฉัน
              Text(
                'ที่อยู่ของฉัน',
                style: TextStyle(
                  color: linkBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              for (int i = 0; i < _addresses.length; i++) ...[
                _addressItem(index: i),
                const SizedBox(height: 12),
              ],

              Row(
                children: [
                  const Spacer(),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text(' เพิ่มที่อยู่'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: linkBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final String? newAddr = await Get.to<String>(
                        () => const AddAddressPage(),
                      );
                      if (newAddr != null && newAddr.trim().isNotEmpty) {
                        setState(() {
                          _addresses.add(
                            TextEditingController(text: newAddr.trim()),
                          );
                          _editing.add(false);
                        });
                      }
                    },
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
          switch (i) {
            case 0:
              Get.off(() => const UserHomePage());
              return;
            case 1:
              // ไปหน้าสินค้าที่ส่ง/สร้างพัสดุ แล้วแต่ที่คุณตั้ง
              Get.off(() => const CreateParcelPage());
              return;
            case 2:
              // TODO: ไปหน้าสินค้าที่ได้รับ (ถ้ามี)
              // Get.off(() => const ReceivedPage());
              return;
            case 3:
              // หน้าปัจจุบัน
              return;
          }
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

  Widget _addressItem({required int index}) {
    final label = 'ที่อยู่${index + 1}';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderCol),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // หัวข้อ + ปุ่มแก้ไข
          Row(
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                tooltip: 'แก้ไขที่อยู่',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () async {
                  final newAddress = await Get.to<String>(
                    () =>
                        EditAddressPage(initialAddress: _addresses[index].text),
                  );

                  if (newAddress != null && newAddress.trim().isNotEmpty) {
                    setState(() => _addresses[index].text = newAddress.trim());
                  }
                },
              ),

              // ลบที่อยู่ (ถ้าต้องการ)
              if (_addresses.length > 1)
                IconButton(
                  tooltip: 'ลบ',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    setState(() {
                      _addresses.removeAt(index).dispose();
                      _editing.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _addresses[index],
            readOnly: !_editing[index],
            maxLines: 3,
            minLines: 2,
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
        ],
      ),
    );
  }
}
