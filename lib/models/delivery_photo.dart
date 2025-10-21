import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryPhoto {
  final String id;
  final int orderId; // order_id
  final int status; // สถานะที่อัปโหลดรูปนั้น
  final String imageUrl; // url supabase (อาจว่างได้)
  final String uploadBy; // uid ผู้ที่อัปโหลด
  final DateTime? createdAt;

  const DeliveryPhoto({
    required this.id,
    required this.orderId,
    required this.status,
    required this.imageUrl,
    required this.uploadBy,
    this.createdAt,
  });

  factory DeliveryPhoto.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data() ?? {};
    return DeliveryPhoto(
      id: doc.id,
      orderId: (m['order_id'] as num?)?.toInt() ?? 0,
      status: (m['status'] as num?)?.toInt() ?? 0,
      imageUrl: (m['image_url'] ?? '').toString(),
      uploadBy: (m['upload_by'] ?? '').toString(),
      createdAt: (m['created_at'] is Timestamp)
          ? (m['created_at'] as Timestamp).toDate()
          : null,
    );
  }
}
