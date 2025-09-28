/// Basic user model for authentication.
class User {
  final String id;
  final String email;
  final String role; // e.g., 'advertiser', 'promoter'
  final String? token;

  const User({
    required this.id,
    required this.email,
    required this.role,
    this.token,
  });

  // Add copyWith, fromJson, toJson as needed for implementations
}