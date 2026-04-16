class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool emailVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.emailVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'emailVerified': emailVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        emailVerified: json['emailVerified'] ?? false,
      );

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    bool? emailVerified,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        emailVerified: emailVerified ?? this.emailVerified,
      );
}
