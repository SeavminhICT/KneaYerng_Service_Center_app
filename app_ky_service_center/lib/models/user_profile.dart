class UserProfile {
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final String? birth;
  final String? gender;
  final String? avatarUrl;

  const UserProfile({
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.birth,
    this.gender,
    this.avatarUrl,
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
      email: map['email'],
      phone: map['phone'],
      birth: map['birth'],
      gender: map['gender'],
      avatarUrl: map['avatar_url'] ?? map['avatar'],
    );
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
    };
  }
}
