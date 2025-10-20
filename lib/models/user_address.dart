import 'package:cloud_firestore/cloud_firestore.dart';

class UserAddress {
  final String id;
  final String address;
  final double? lat;
  final double? lng;
  final DateTime? createdAt;

  UserAddress({
    required this.id,
    required this.address,
    this.lat,
    this.lng,
    this.createdAt,
  });

  factory UserAddress.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return UserAddress(
      id: doc.id,
      address: (m['address'] ?? '').toString(),
      lat: (m['lat'] is num) ? (m['lat'] as num).toDouble() : null,
      lng: (m['lng'] is num) ? (m['lng'] as num).toDouble() : null,
      createdAt: (m['created_at'] is Timestamp)
          ? (m['created_at'] as Timestamp).toDate()
          : null,
    );
  }
}

Stream<List<UserAddress>> userAddressesStream(String uid) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('addresses')
      .orderBy('created_at', descending: false)
      .snapshots()
      .map((q) => q.docs.map(UserAddress.fromDoc).toList());
}
