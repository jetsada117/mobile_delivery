import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_delivery/models/order_record.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/send_item_view.dart';
import 'package:mobile_delivery/models/user_address.dart';
import 'package:mobile_delivery/models/user_data.dart';

final _db = FirebaseFirestore.instance;

Stream<List<SentItemView>> sentItemViewsStream(String senderId) {
  return _db
      .collection('orders')
      .where('send_id', isEqualTo: senderId)
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

          UserData? receiver;
          final rid = order.receiveId;
          if (rid != null && rid.isNotEmpty) {
            final uDoc = await _db.collection('users').doc(rid).get();
            if (uDoc.exists) {
              receiver = UserData.fromMap(uDoc.id, uDoc.data() ?? {});
            }
          }

          String clean(String p) => p.startsWith('/') ? p.substring(1) : p;

          Future<UserAddress?> fetchAddressByPath(String? path) async {
            if (path == null || path.trim().isEmpty) return null;
            final ref = _db.doc(clean(path));
            final d = await ref.get();
            return d.exists ? UserAddress.fromDoc(d) : null;
          }

          final sendAddr = await fetchAddressByPath(order.sendAt);
          final receiveAddr = await fetchAddressByPath(order.receiveAt);

          return SentItemView(
            order: order,
            product: product,
            receiver: receiver,
            sendAddress: sendAddr,
            receiveAddress: receiveAddr,
          );
        }).toList();

        return Future.wait(futures);
      });
}
