/// Basic user model for authentication.
class User {
  final String id;
  final String email;
  final String role; // e.g., 'advertiser', 'promoter'
  final String? token;
  final String? username;
  final String? photoUrl;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.token,
    this.username,
    this.photoUrl,
    this.createdAt,
  });

  // Add copyWith, fromJson, toJson as needed for implementations
}