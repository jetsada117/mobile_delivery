import 'package:cloud_firestore/cloud_firestore.dart';

class OrderRecord {
  final String id;
  final int orderId;
  final int currentStatus;
  final bool isActive;
  final String sendId;
  final String? receiveId;
  final String? riderId;

  /// path ของ doc address (อาจมาจาก String หรือ DocumentReference)
  final String? sendAt;
  final String? receiveAt;

  const OrderRecord({
    required this.id,
    required this.orderId,
    required this.currentStatus,
    required this.isActive,
    required this.sendId,
    this.receiveId,
    this.riderId,
    this.sendAt,
    this.receiveAt,
  });

  static String? _asPath(dynamic v) {
    if (v == null) return null;
    if (v is DocumentReference) return v.path; // แปลง ref → path
    if (v is String) return v; // คงเดิมถ้าเป็นสตริงอยู่แล้ว
    return null;
  }

  factory OrderRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return OrderRecord(
      id: doc.id,
      orderId: (m['order_id'] as num?)?.toInt() ?? 0,
      currentStatus: (m['current_status'] as num?)?.toInt() ?? 0,
      isActive: (m['is_active'] as bool?) ?? true,
      sendId: (m['send_id'] ?? '').toString(),
      receiveId: m['receive_id'] as String?,
      riderId: m['rider_id'] as String?,
      sendAt: _asPath(m['send_at']),
      receiveAt: _asPath(m['receive_at']),
    );
  }
}
