class User {
  final int? id;
  final String fullName;
  final String nik;
  final String email;
  final String address;
  final String phoneNumber;
  final String username;
  final String password;
  final DateTime createdAt;

  User({
    this.id,
    required this.fullName,
    required this.nik,
    required this.email,
    required this.address,
    required this.phoneNumber,
    required this.username,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'nik': nik,
      'email': email,
      'address': address,
      'phone_number': phoneNumber,
      'username': username,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      fullName: map['full_name'] as String,
      nik: map['nik'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      phoneNumber: map['phone_number'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  User copyWith({
    int? id,
    String? fullName,
    String? nik,
    String? email,
    String? address,
    String? phoneNumber,
    String? username,
    String? password,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nik: nik ?? this.nik,
      email: email ?? this.email,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
