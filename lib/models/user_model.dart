class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String profileUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileUrl': profileUrl,
    };
  }
}
