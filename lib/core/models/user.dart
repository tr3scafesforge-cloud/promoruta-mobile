/// User role enumeration for type-safe role handling.
enum UserRole {
  promoter,
  advertiser;

  /// Convert string to UserRole enum.
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'promotor':
        return UserRole.promoter;
      case 'advertiser':
        return UserRole.advertiser;
      default:
        throw ArgumentError('Unknown role: $role');
    }
  }

  /// Convert UserRole enum to string.
  String toStringValue() {
    switch (this) {
      case UserRole.promoter:
        return 'promotor';
      case UserRole.advertiser:
        return 'advertiser';
    }
  }
}

/// Basic user model for authentication.
class User {
  final String id;
  final String email;
  final UserRole role;
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
      role: UserRole.fromString(json['role'] as String),
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
      'role': role.toStringValue(),
      'accessToken': accessToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'username': username,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}