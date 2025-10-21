import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id; // document id
  final int productId; // field product_id
  final int orderId; // field order_id
  final String name; // field product_name
  final String imageUrl; // field image_url

  const Product({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.name,
    required this.imageUrl,
  });

  factory Product.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Product(
      id: doc.id,
      productId: (data['product_id'] is num)
          ? (data['product_id'] as num).toInt()
          : 0,
      orderId: (data['order_id'] is num)
          ? (data['order_id'] as num).toInt()
          : 0,
      name: (data['product_name'] ?? '').toString(),
      imageUrl: (data['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'order_id': orderId,
      'product_name': name,
      'image_url': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, productId: $productId, orderId: $orderId, name: $name)';
  }
}
