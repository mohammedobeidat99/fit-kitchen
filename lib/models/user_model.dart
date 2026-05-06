class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? imageUrl;
  final bool emailVerified;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.imageUrl,
    this.emailVerified = false,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'imageUrl': imageUrl,
        'emailVerified': emailVerified,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        imageUrl: json['imageUrl'],
        emailVerified: json['emailVerified'] ?? false,
      );

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? imageUrl,
    bool? emailVerified,
  }) =>
      UserModel(
        uid: uid ?? this.uid,
        name: name ?? this.name,
        email: email ?? this.email,
        imageUrl: imageUrl ?? this.imageUrl,
        emailVerified: emailVerified ?? this.emailVerified,
      );
}
