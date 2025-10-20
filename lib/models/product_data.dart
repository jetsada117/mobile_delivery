import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // Firestore doc id (เช่น "1","2")
  final int productId; // ฟิลด์ product_id
  final int orderId; // ฟิลด์ order_id
  final String name; // ฟิลด์ product_name
  final String imageUrl; // ฟิลด์ image_url

  Product({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.name,
    required this.imageUrl,
  });

  factory Product.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      productId: (m['product_id'] is num)
          ? (m['product_id'] as num).toInt()
          : 0,
      orderId: (m['order_id'] is num) ? (m['order_id'] as num).toInt() : 0,
      name: (m['product_name'] ?? '').toString(),
      imageUrl: (m['image_url'] ?? '').toString(),
    );
  }
}
