import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_delivery/models/order_record.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/send_item_view.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:mobile_delivery/models/user_data.dart';

final _db = FirebaseFirestore.instance;

Stream<List<SentItemView>> receivedItemViewsStream(String receiverId) {
  return _db
      .collection('orders')
      .where('receive_id', isEqualTo: receiverId)
      .where('current_status', isGreaterThanOrEqualTo: 1)
      .orderBy('current_status')
      .snapshots()
      .asyncMap((qs) async {
        final futures = qs.docs.map((doc) async {
          final order = OrderRecord.fromDoc(doc);

          Product? product;
          final pSnap = await _db
              .collection('products')
              .where('order_id', isEqualTo: order.orderId)
              .limit(1)
              .get();
          if (pSnap.docs.isNotEmpty) {
            product = Product.fromDoc(pSnap.docs.first);
          }

          UserData? sender;
          if ((order.sendId).isNotEmpty) {
            final uDoc = await _db.collection('users').doc(order.sendId).get();
            if (uDoc.exists) {
              sender = UserData.fromMap(uDoc.id, uDoc.data() ?? {});
            }
          }

          Future<UserAddress?> fetchAddressByPath(String? path) async {
            if (path == null || path.trim().isEmpty) return null;
            final d = await _db.doc(path).get();
            return d.exists ? UserAddress.fromDoc(d) : null;
          }

          final sendAddr = await fetchAddressByPath(order.sendAt);
          final receiveAddr = await fetchAddressByPath(order.receiveAt);

          return SentItemView(
            order: order,
            product: product,
            sendAddress: sendAddr,
            receiveAddress: receiveAddr,
          )..extra = sender;
        }).toList();

        return Future.wait(futures);
      });
}
