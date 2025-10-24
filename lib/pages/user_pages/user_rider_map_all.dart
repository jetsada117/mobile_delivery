import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReceiverPin {
  final String name;
  final String? note;
  final LatLng pos;
  const ReceiverPin({required this.name, required this.pos, this.note});
}

class RiderPin {
  final String name;
  final String? phone;
  final String? plate;
  final String? avatarUrl;
  final LatLng pos;
  const RiderPin({
    required this.name,
    required this.pos,
    this.phone,
    this.plate,
    this.avatarUrl,
  });
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

  // ให้ซูมครอบทุกจุดครั้งแรก
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitAll());
  }

  void _fitAll() {
    final points = <LatLng>[
      ...widget.receivers.map((e) => e.pos),
      ...widget.riders.map((e) => e.pos),
    ];
    if (points.isEmpty) return;

    // หา bounds แบบง่าย ๆ
    double minLat = points.first.latitude, maxLat = points.first.latitude;
    double minLng = points.first.longitude, maxLng = points.first.longitude;
    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    final currentZoom = _map.camera.zoom == 0 ? 12.5 : _map.camera.zoom;

    _map.move(center, currentZoom);
  }

  void _focus(LatLng p, {double? zoom}) {
    final z = zoom ?? (_map.camera.zoom == 0 ? 14.5 : _map.camera.zoom);
    _map.move(p, z);
  }

  @override
  Widget build(BuildContext context) {
    // ถ้าไม่มีจุดเลยให้ตั้งค่า default
    final initialCenter =
        (widget.receivers.isNotEmpty
            ? widget.receivers.first.pos
            : (widget.riders.isNotEmpty ? widget.riders.first.pos : null)) ??
        const LatLng(16.2458, 103.25);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 13.2,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=6949d257c8de4157a028c7a44b05af3d',
                userAgentPackageName: 'com.example.mobile_delivery',
              ),
              MarkerLayer(
                markers: [
                  // ผู้รับทั้งหมด = บ้าน (สีน้ำเงิน)
                  for (final rcv in widget.receivers)
                    Marker(
                      point: rcv.pos,
                      width: 36,
                      height: 36,
                      child: const Icon(
                        Icons.home,
                        color: Colors.blueAccent,
                        size: 32,
                      ),
                    ),
                  // ไรเดอร์ทั้งหมด = มอเตอร์ไซค์ (สีแดง)
                  for (final rd in widget.riders)
                    Marker(
                      point: rd.pos,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.redAccent,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Legend
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.blueAccent, size: 18),
                  SizedBox(width: 4),
                  Text('ผู้รับ'),
                  SizedBox(width: 12),
                  Icon(
                    Icons.delivery_dining,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  SizedBox(width: 4),
                  Text('ไรเดอร์'),
                ],
              ),
            ),
          ),

          // ลิสต์ผู้รับ + ลิสต์ไรเดอร์ (ยาวลงมา)
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
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
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 340,
                ), // ให้เลื่อนภายในกล่องได้
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ผู้รับทั้งหมด
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            color: Colors.blueAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ผู้รับทั้งหมด (${widget.receivers.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(widget.receivers.length, (i) {
                        final r = widget.receivers[i];
                        return _ListTileCard(
                          leading: const Icon(
                            Icons.place,
                            color: Colors.blueAccent,
                          ),
                          title: '${i + 1}. ${r.name}',
                          subtitle: r.note ?? '',
                          trailing: IconButton(
                            icon: const Icon(Icons.center_focus_strong),
                            onPressed: () => _focus(r.pos, zoom: 15),
                          ),
                          onTap: () => _focus(r.pos, zoom: 15),
                        );
                      }),

                      const SizedBox(height: 12),
                      // ไรเดอร์ทั้งหมด
                      Row(
                        children: [
                          const Icon(
                            Icons.delivery_dining,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ไรเดอร์ทั้งหมด (${widget.riders.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(widget.riders.length, (i) {
                        final r = widget.riders[i];
                        return _ListTileCard(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            backgroundImage:
                                (r.avatarUrl != null && r.avatarUrl!.isNotEmpty)
                                ? NetworkImage(r.avatarUrl!)
                                : null,
                            child: (r.avatarUrl == null || r.avatarUrl!.isEmpty)
                                ? const Icon(Icons.person_outline)
                                : null,
                          ),
                          title: '${i + 1}. ${r.name}',
                          subtitle: [
                            if (r.phone != null && r.phone!.isNotEmpty)
                              'โทร: ${r.phone}',
                            if (r.plate != null && r.plate!.isNotEmpty)
                              'ทะเบียน: ${r.plate}',
                          ].join('\n'),
                          trailing: IconButton(
                            icon: const Icon(Icons.center_focus_strong),
                            onPressed: () => _focus(r.pos, zoom: 15),
                          ),
                          onTap: () => _focus(r.pos, zoom: 15),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTileCard extends StatelessWidget {
  const _ListTileCard({
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
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
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
