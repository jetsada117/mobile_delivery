import 'package:mobile_delivery/models/order_record.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/models/user_address.dart';

class SentItemView {
  final OrderRecord order;
  final Product? product; // หนึ่งออเดอร์มี 1 สินค้า (optional เผื่อยังไม่เจอ)
  final UserData? receiver; // ผู้รับ
  final UserAddress? sendAddress; // ที่อยู่ผู้ส่ง
  final UserAddress? receiveAddress; // ที่อยู่ผู้รับ
  dynamic extra;

  SentItemView({
    required this.order,
    this.product,
    this.receiver,
    this.sendAddress,
    this.receiveAddress,
    this.extra,
  });
}
