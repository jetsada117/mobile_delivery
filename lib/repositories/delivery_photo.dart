import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_delivery/models/delivery_photo.dart';

final _db = FirebaseFirestore.instance;

Stream<List<DeliveryPhoto>> deliveryPhotosStream(int orderId) {
  return _db
      .collection('delivery_photos')
      .where('order_id', isEqualTo: orderId)
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((qs) => qs.docs.map(DeliveryPhoto.fromDoc).toList());
}
