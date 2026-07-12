class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? birth;
  final String? gender;
  final String? avatarUrl;
  final String? role;
  final bool isAdmin;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.birth,
    this.gender,
    this.avatarUrl,
    this.role,
    this.isAdmin = false,
  });

  String get displayName {
    final parts = [
      if (firstName != null && firstName!.isNotEmpty) firstName!,
      if (lastName != null && lastName!.isNotEmpty) lastName!,
    ];
    return parts.isNotEmpty ? parts.join(' ') : 'User';
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      firstName: map['first_name'],
      lastName: map['last_name'],
      email: _normalizeOptionalEmail(map['email']),
      phone: map['phone'],
      birth: map['birth'],
      gender: map['gender'],
      avatarUrl: map['avatar_url'] ?? map['avatar'],
      role: map['role']?.toString(),
      isAdmin:
          map['is_admin'] == true ||
          map['is_admin']?.toString().toLowerCase() == 'true' ||
          map['role']?.toString().toLowerCase() == 'admin',
    );
  }

  static String? _normalizeOptionalEmail(dynamic value) {
    final email = value?.toString().trim() ?? '';
    if (email.isEmpty) return null;

    final validEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return validEmail.hasMatch(email) ? email : null;
  }

  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'birth': birth,
      'gender': gender,
      'avatar_url': avatarUrl,
      'role': role,
      'is_admin': isAdmin,
    };
  }
}
