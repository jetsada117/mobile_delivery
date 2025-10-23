import 'package:mobile_delivery/models/order_record.dart';
import 'package:mobile_delivery/models/product_data.dart';
import 'package:mobile_delivery/models/rider_data.dart';
import 'package:mobile_delivery/models/user_data.dart';
import 'package:mobile_delivery/models/user_address.dart';

class SentItemView {
  final OrderRecord order;
  final Product? product;
  final UserData? receiver;
  final UserAddress? sendAddress;
  final UserAddress? receiveAddress;
  final RiderData? rider;
  dynamic extra;

  SentItemView({
    required this.order,
    this.product,
    this.receiver,
    this.sendAddress,
    this.receiveAddress,
    this.rider,
    this.extra,
  });
}
