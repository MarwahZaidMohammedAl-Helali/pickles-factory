class User {
  final String id;
  final String username;
  final String role;
  final String? passwordHash; // For admin to view staff passwords

  User({
    required this.id,
    required this.username,
    required this.role,
    this.passwordHash,
  });

  // Check if user is admin
  bool get isAdmin => role.toLowerCase() == 'admin';
  
  // Check if user is staff
  bool get isStaff => role.toLowerCase() == 'staff';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      role: json['role'] as String,
      passwordHash: json['passwordHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      if (passwordHash != null) 'passwordHash': passwordHash,
    };
  }

  // Create a copy with updated fields
  User copyWith({
    String? id,
    String? username,
    String? role,
    String? passwordHash,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      role: role ?? this.role,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
