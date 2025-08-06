class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? profileImageUrl;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImageUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      profileImageUrl: json['profileImageUrl'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }
}