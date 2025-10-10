/// Basic user model for authentication.
class User {
  final String id;
  final String email;
  final String role; // e.g., 'advertiser', 'promoter'
  final String? accessToken;
  final DateTime? tokenExpiry;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.accessToken,
    this.tokenExpiry,
    this.username,
    this.photoUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      accessToken: json['accessToken'] as String?,
      tokenExpiry: json['tokenExpiry'] != null ? DateTime.parse(json['tokenExpiry'] as String) : null,
      username: json['username'] as String?,
      photoUrl: json['photoUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'accessToken': accessToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}