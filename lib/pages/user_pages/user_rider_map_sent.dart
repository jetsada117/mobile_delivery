import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReceiverPin {
  final String group; // <- ใส่รหัสออเดอร์/กลุ่มสี
  final String name;
  final String? note;
  final LatLng pos;
  const ReceiverPin({
    required this.group,
    required this.name,
    required this.pos,
    this.note,
  });
}

class RiderPin {
  final String group; // <- ใส่รหัสออเดอร์/กลุ่มสี
  final String riderId;
  final String name;
  final String? phone;
  final String? plate;
  final String? avatarUrl;
  final LatLng pos;
  const RiderPin({
    required this.group,
    required this.riderId,
    required this.name,
    required this.pos,
    this.phone,
    this.plate,
    this.avatarUrl,
  });

  RiderPin copyWith({LatLng? pos}) => RiderPin(
    group: group,
    riderId: riderId,
    name: name,
    pos: pos ?? this.pos,
    phone: phone,
    plate: plate,
    avatarUrl: avatarUrl,
  );
}

class CombinedLiveMapPage extends StatefulWidget {
  const CombinedLiveMapPage({
    super.key,
    required this.receivers,
    required this.riders,
    this.title = 'แผนที่รวม',
  });

  final List<ReceiverPin> receivers;
  final List<RiderPin> riders;
  final String title;

  @override
  State<CombinedLiveMapPage> createState() => _CombinedLiveMapPageState();
}

class _CombinedLiveMapPageState extends State<CombinedLiveMapPage> {
  static const bg = Color(0xFFD2C2F1);
  final MapController _map = MapController();

  late List<ReceiverPin> _receivers;
  late List<RiderPin> _riders;

  final _db = FirebaseFirestore.instance;
  final Map<String, StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>
  _riderSubs = {};

  // สีร่วมกันทุกประเภท โดย key = group (เช่น orderId ที่เป็น string)
  final Map<String, Color> _groupColors = {};
  final _random = Random();

  static const List<Color> _baseColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.green,
    Colors.orangeAccent,
    Colors.purple,
    Colors.teal,
    Colors.pinkAccent,
    Colors.brown,
  ];

  String? _autoFollowRiderId;
  Timer? _moveDebounce;

  @override
  void initState() {
    super.initState();
    _receivers = List<ReceiverPin>.from(widget.receivers);
    _riders = List<RiderPin>.from(widget.riders);

    // สร้างสีตาม group เดียวกันให้เหมือนกัน
    final used = <Color>{};
    for (final r in _receivers) {
      _groupColors[r.group] = _groupColors[r.group] ?? _pickDistinctColor(used);
      used.add(_groupColors[r.group]!);
    }
    for (final r in _riders) {
      _groupColors[r.group] = _groupColors[r.group] ?? _pickDistinctColor(used);
      used.add(_groupColors[r.group]!);
    }

    _listenRidersLive();
  }

  @override
  void dispose() {
    for (final sub in _riderSubs.values) {
      sub.cancel();
    }
    _riderSubs.clear();
    _moveDebounce?.cancel();
    super.dispose();
  }

  void _listenRidersLive() {
    for (final r in _riders) {
      if (r.riderId.isEmpty) continue;
      _riderSubs[r.riderId]?.cancel();
      _riderSubs[r.riderId] = _db
          .collection('riders')
          .doc(r.riderId)
          .snapshots()
          .listen((snap) {
            if (!snap.exists) return;
            final data = snap.data()!;
            final lat = (data['lat'] as num?)?.toDouble();
            final lng = (data['lng'] as num?)?.toDouble();
            if (lat == null || lng == null) return;

            final idx = _riders.indexWhere((x) => x.riderId == r.riderId);
            if (idx < 0) return;

            final newPos = LatLng(lat, lng);
            if (!mounted) return;
            setState(() {
              _riders[idx] = _riders[idx].copyWith(pos: newPos);
            });

            if (_autoFollowRiderId == r.riderId) {
              _moveSmooth(newPos);
            }
          });
    }
  }

  void _moveSmooth(LatLng p) {
    _moveDebounce?.cancel();
    _moveDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      try {
        final z = (_map.camera.zoom == 0) ? 13.5 : _map.camera.zoom;
        _map.move(p, z);
      } catch (_) {}
    });
  }

  void _focus(LatLng p, {double? zoom}) {
    final z = zoom ?? (_map.camera.zoom == 0 ? 14.5 : _map.camera.zoom);
    _map.move(p, z);
  }

  @override
  Widget build(BuildContext context) {
    final initialCenter =
        (_receivers.isNotEmpty
            ? _receivers.first.pos
            : (_riders.isNotEmpty ? _riders.first.pos : null)) ??
        const LatLng(16.2458, 103.25);

    min(MediaQuery.of(context).size.height * 0.55, 420.0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_autoFollowRiderId != null)
            TextButton.icon(
              onPressed: () => setState(() => _autoFollowRiderId = null),
              icon: const Icon(Icons.gps_off, color: Colors.black87),
              label: const Text(
                'หยุดติดตาม',
                style: TextStyle(color: Colors.black87),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.2,
              onMapEvent: (_) {
                if (_autoFollowRiderId != null) {
                  setState(() => _autoFollowRiderId = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              MarkerLayer(
                markers: [
                  // ผู้รับ (ใช้สีตาม group)
                  for (final rcv in _receivers)
                    Marker(
                      point: rcv.pos,
                      width: 36,
                      height: 36,
                      child: Icon(
                        Icons.home,
                        color: _groupColors[rcv.group] ?? Colors.blueAccent,
                        size: 32,
                      ),
                    ),
                  // ไรเดอร์ (ใช้สีตาม group เดียวกัน)
                  for (final rd in _riders)
                    Marker(
                      point: rd.pos,
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.delivery_dining,
                        color: _groupColors[rd.group] ?? Colors.redAccent,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // แผงข้อมูลแบบเลื่อนขึ้นลงได้
          Positioned.fill(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: DraggableScrollableSheet(
                initialChildSize: 0.28, // ความสูงเริ่มต้น (28% ของหน้าจอ)
                minChildSize: 0.18, // สูงสุดที่ยุบได้
                maxChildSize: 0.65, // สูงสุดที่กางได้
                snap: true,
                snapSizes: const [0.18, 0.40, 0.65], // จุดที่ปล่อยแล้วจะสแนป
                builder: (context, scrollController) {
                  return Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4EBFF),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x22000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: ListView(
                      controller: scrollController, // 👈 สำคัญ
                      physics: const BouncingScrollPhysics(), // เลื่อนลื่น ๆ
                      children: [
                        const _SectionHeader(
                          icon: Icons.home,
                          iconColor: Colors.blueAccent,
                          title: 'ผู้รับทั้งหมด',
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _receivers.length; i++)
                          _ListTileCard(
                            leading: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  _groupColors[_receivers[i].group] ??
                                  Colors.blueAccent,
                            ),
                            title: '${i + 1}. ${_receivers[i].name}',
                            subtitle:
                                'สี: ${_colorName(_groupColors[_receivers[i].group])}    (ออเดอร์: ${_receivers[i].group})',
                            onTap: () => _focus(_receivers[i].pos, zoom: 15),
                          ),

                        const SizedBox(height: 12),
                        const _SectionHeader(
                          icon: Icons.delivery_dining,
                          iconColor: Colors.redAccent,
                          title: 'ไรเดอร์ทั้งหมด',
                        ),
                        const SizedBox(height: 8),
                        for (int i = 0; i < _riders.length; i++)
                          _ListTileCard(
                            leading: CircleAvatar(
                              radius: 10,
                              backgroundColor:
                                  _groupColors[_riders[i].group] ??
                                  Colors.redAccent,
                            ),
                            title: '${i + 1}. ${_riders[i].name}',
                            subtitle: [
                              'สี: ${_colorName(_groupColors[_riders[i].group])}    (ออเดอร์: ${_riders[i].group})',
                              if (_riders[i].phone != null &&
                                  _riders[i].phone!.isNotEmpty)
                                'โทร: ${_riders[i].phone}',
                              if (_riders[i].plate != null &&
                                  _riders[i].plate!.isNotEmpty)
                                'ทะเบียน: ${_riders[i].plate}',
                            ].join('\n'),
                            onTap: () {
                              _focus(_riders[i].pos, zoom: 15);
                              setState(
                                () => _autoFollowRiderId = _riders[i].riderId,
                              );
                            },
                          ),

                        const SizedBox(height: 8),
                        const SafeArea(top: false, child: SizedBox(height: 0)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _pickDistinctColor(Set<Color> used) {
    final available = _baseColors.where((c) => !used.contains(c)).toList();
    if (available.isNotEmpty) {
      return available[_random.nextInt(available.length)];
    }
    // หมดพาเลต → สร้างสี HSL แบบกระจายโทน
    for (int i = 0; i < 360; i++) {
      final h = _random.nextInt(360).toDouble();
      final c = HSLColor.fromAHSL(1, h, 0.6, 0.55).toColor();
      if (!used.contains(c)) return c;
    }
    return Colors.grey;
  }

  String _colorName(Color? c) {
    if (c == null) return 'ไม่ทราบ';
    if (c == Colors.redAccent) return 'แดง';
    if (c == Colors.blueAccent) return 'น้ำเงิน';
    if (c == Colors.green) return 'เขียว';
    if (c == Colors.orangeAccent) return 'ส้ม';
    if (c == Colors.purple) return 'ม่วง';
    if (c == Colors.teal) return 'เขียวอมฟ้า';
    if (c == Colors.pinkAccent) return 'ชมพู';
    if (c == Colors.brown) return 'น้ำตาล';
    return '#${c.value.toRadixString(16)}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: leading,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: (subtitle == null || subtitle!.isEmpty)
            ? null
            : Text(subtitle!),
        onTap: onTap,
      ),
    );
  }
}
