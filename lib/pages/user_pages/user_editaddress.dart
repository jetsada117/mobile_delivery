import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:mobile_delivery/pages/user_pages/user_profile.dart';

class EditAddressPage extends StatefulWidget {
  final String uid;
  final UserAddress address;

  const EditAddressPage({super.key, required this.uid, required this.address});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  static const bg = Color(0xFFD2C2F1);
  static const cardBg = Color(0xFFF4EBFF);
  static const borderCol = Color(0x55000000);
  static const linkBlue = Color(0xFF2D72FF);

  late final TextEditingController _addrCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;

  bool _saving = false;

  late final ll.LatLng _defaultCenter;
  ll.LatLng? _pickedLatLng;

  @override
  void initState() {
    super.initState();
    _addrCtrl = TextEditingController(text: widget.address.address);
    _latCtrl = TextEditingController(
      text: widget.address.lat?.toString() ?? '',
    );
    _lngCtrl = TextEditingController(
      text: widget.address.lng?.toString() ?? '',
    );

    if (widget.address.lat != null && widget.address.lng != null) {
      _pickedLatLng = ll.LatLng(widget.address.lat!, widget.address.lng!);
    } else if (_latCtrl.text.isNotEmpty && _lngCtrl.text.isNotEmpty) {
      final lat = double.tryParse(_latCtrl.text);
      final lng = double.tryParse(_lngCtrl.text);
      if (lat != null && lng != null) {
        _pickedLatLng = ll.LatLng(lat, lng);
      }
    }
  }

  @override
  void dispose() {
    _addrCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ll.LatLng center = _pickedLatLng ?? _defaultCenter;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'แก้ไขที่อยู่',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  border: Border.all(color: borderCol),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'ที่อยู่',
                      style: TextStyle(
                        color: linkBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _addrCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
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
                        hintText: 'กรอกที่อยู่ให้ครบถ้วน',
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _latCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'ละติจูด (ไม่บังคับ)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                            ),
                            onChanged: (v) {
                              final lat = double.tryParse(v);
                              final lng = double.tryParse(_lngCtrl.text);
                              if (lat != null && lng != null) {
                                setState(() {
                                  _pickedLatLng = ll.LatLng(lat, lng);
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _lngCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'ลองจิจูด (ไม่บังคับ)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              filled: true,
                            ),
                            onChanged: (v) {
                              final lng = double.tryParse(v);
                              final lat = double.tryParse(_latCtrl.text);
                              if (lat != null && lng != null) {
                                setState(() {
                                  _pickedLatLng = ll.LatLng(lat, lng);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 260,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: 13,
                            onTap: _onMapTap,
                            interactionOptions: const InteractionOptions(
                              flags: ~InteractiveFlag.rotate,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                              userAgentPackageName:
                                  'com.example.mobile_delivery',
                            ),
                            if (_pickedLatLng != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _pickedLatLng!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 40,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.touch_app, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _pickedLatLng == null
                                ? 'แตะบนแผนที่เพื่อเลือกพิกัด'
                                : 'เลือกแล้ว: ${_pickedLatLng!.latitude.toStringAsFixed(6)}, ${_pickedLatLng!.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        if (_pickedLatLng != null)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _pickedLatLng = null;
                                _latCtrl.clear();
                                _lngCtrl.clear();
                              });
                            },
                            child: const Text('ล้างพิกัด'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black54,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('ยกเลิก'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _confirmAndSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('ยืนยัน'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onMapTap(TapPosition tapPosition, ll.LatLng latLng) {
    setState(() {
      _pickedLatLng = latLng;
      _latCtrl.text = latLng.latitude.toStringAsFixed(6);
      _lngCtrl.text = latLng.longitude.toStringAsFixed(6);
    });
    Get.snackbar(
      'เลือกพิกัดแล้ว',
      'lat: ${_latCtrl.text}, lng: ${_lngCtrl.text}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _confirmAndSave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการบันทึก'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('คุณต้องการบันทึกที่อยู่นี้ใช่หรือไม่?'),
            const SizedBox(height: 8),
            Text(
              _addrCtrl.text.trim().isEmpty
                  ? '(ยังไม่ได้กรอกที่อยู่)'
                  : _addrCtrl.text.trim(),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (_latCtrl.text.trim().isNotEmpty &&
                _lngCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'พิกัด: ${_latCtrl.text.trim()}, ${_lngCtrl.text.trim()}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ยืนยัน'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _onSave();
    }
  }

  Future<void> _onSave() async {
    final address = _addrCtrl.text.trim();
    final latText = _latCtrl.text.trim();
    final lngText = _lngCtrl.text.trim();

    if (address.isEmpty) {
      Get.snackbar('กรอกไม่ครบ', 'กรุณากรอกรายละเอียดที่อยู่');
      return;
    }

    final double? lat = latText.isEmpty ? null : double.tryParse(latText);
    final double? lng = lngText.isEmpty ? null : double.tryParse(lngText);

    setState(() => _saving = true);
    try {
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .collection('addresses')
          .doc(widget.address.id);

      final data = <String, dynamic>{
        'address': address,
        'lat': lat ?? FieldValue.delete(),
        'lng': lng ?? FieldValue.delete(),
      };

      await ref.update(data);

      Get.snackbar(
        'สำเร็จ',
        'บันทึกที่อยู่เรียบร้อย',
        snackPosition: SnackPosition.BOTTOM,
      );

      Get.to(() => UserProfilePage());
    } catch (e) {
      Get.snackbar(
        'ผิดพลาด',
        'บันทึกไม่สำเร็จ: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
