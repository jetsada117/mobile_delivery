class RiderData {
  final String id;
  final String name;
  final String phone;
  final String password;
  final String plateNo;
  final String riderImage;
  final String vehicleImage;
  final double? lat;
  final double? lng;

  RiderData({
    required this.id,
    required this.name,
    required this.phone,
    required this.password,
    required this.plateNo,
    required this.riderImage,
    required this.vehicleImage,
    this.lat,
    this.lng,
  });

  factory RiderData.fromMap(String id, Map<String, dynamic> data) {
    return RiderData(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      password: data['password'] ?? '',
      plateNo: data['plate_no'] ?? '',
      riderImage: data['rider_image'] ?? '',
      vehicleImage: data['vehicle_image'] ?? '',
      lat: (data['lat'] != null)
          ? double.tryParse(data['lat'].toString())
          : null,
      lng: (data['lng'] != null)
          ? double.tryParse(data['lng'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'plate_no': plateNo,
      'rider_image': riderImage,
      'vehicle_image': vehicleImage,
      'lat': lat,
      'lng': lng,
    };
  }
}
