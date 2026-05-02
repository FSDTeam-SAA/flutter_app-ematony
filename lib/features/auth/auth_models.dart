class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.kycVerified = true,
    this.avatarUrl,
    this.bio,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final bool kycVerified;
  final String? avatarUrl;
  final String? bio;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final avatar = json['avatar'];
    String? url;
    if (avatar is Map) {
      url = avatar['url']?.toString();
    } else if (avatar is String && avatar.isNotEmpty) {
      url = avatar;
    }
    return AppUser(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      phone: json['phone']?.toString(),
      kycVerified: json['kycVerified'] == false ? false : true,
      avatarUrl: (url?.isNotEmpty == true) ? url : null,
      bio: json['bio']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
        'phone': phone,
        'kycVerified': kycVerified,
        'avatar': avatarUrl != null ? {'url': avatarUrl} : null,
        'bio': bio,
      };

  AppUser copyWith({
    String? name,
    String? phone,
    String? bio,
    String? avatarUrl,
    bool? kycVerified,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      role: role,
      phone: phone ?? this.phone,
      kycVerified: kycVerified ?? this.kycVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}

class AuthSession {
  AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final AppUser user;
}
