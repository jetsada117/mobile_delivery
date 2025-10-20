class UserData {
  final String uid;
  final String name;
  final String phone;
  final String imageUrl;

  UserData({
    required this.uid,
    required this.name,
    required this.phone,
    required this.imageUrl,
  });

  factory UserData.fromMap(String id, Map<String, dynamic> map) {
    return UserData(
      uid: id,
      name: map['name'],
      phone: map['phone'],
      imageUrl: map['user_image'],
    );
  }
}
