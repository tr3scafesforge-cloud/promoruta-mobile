/// User role enumeration for type-safe role handling.
enum UserRole {
  promoter,
  advertiser;

  /// Convert string to UserRole enum.
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'promotor':
      case 'promoter':
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
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final UserRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? accessToken;
  final DateTime? tokenExpiry;
  final String? refreshToken;
  final DateTime? refreshExpiresIn;
  final String? username;
  final String? photoUrl;
  final bool twoFactorEnabled;
  final DateTime? twoFactorConfirmedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.role,
    this.createdAt,
    this.updatedAt,
    this.accessToken,
    this.tokenExpiry,
    this.refreshToken,
    this.refreshExpiresIn,
    this.username,
    this.photoUrl,
    this.twoFactorEnabled = false,
    this.twoFactorConfirmedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerifiedAt: json['email_verified_at'] != null ? DateTime.parse(json['email_verified_at'] as String) : null,
      role: UserRole.fromString(json['role'] as String),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      accessToken: json['accessToken'] as String?,
      tokenExpiry: json['tokenExpiry'] != null ? DateTime.parse(json['tokenExpiry'] as String) : null,
      refreshToken: json['refreshToken'] as String?,
      refreshExpiresIn: json['refreshExpiresIn'] != null ? DateTime.parse(json['refreshExpiresIn'] as String) : null,
      username: json['username'] as String?,
      photoUrl: json['photoUrl'] as String?,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
      twoFactorConfirmedAt: json['two_factor_confirmed_at'] != null ? DateTime.parse(json['two_factor_confirmed_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'role': role.toStringValue(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'accessToken': accessToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'refreshToken': refreshToken,
      'refreshExpiresIn': refreshExpiresIn?.toIso8601String(),
      'username': username,
      'photoUrl': photoUrl,
      'two_factor_enabled': twoFactorEnabled,
      'two_factor_confirmed_at': twoFactorConfirmedAt?.toIso8601String(),
    };
  }

  /// Create a copy of this User with some fields replaced
  User copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? emailVerifiedAt,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? accessToken,
    DateTime? tokenExpiry,
    String? refreshToken,
    DateTime? refreshExpiresIn,
    String? username,
    String? photoUrl,
    bool? twoFactorEnabled,
    DateTime? twoFactorConfirmedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      refreshToken: refreshToken ?? this.refreshToken,
      refreshExpiresIn: refreshExpiresIn ?? this.refreshExpiresIn,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      twoFactorConfirmedAt: twoFactorConfirmedAt ?? this.twoFactorConfirmedAt,
    );
  }
}