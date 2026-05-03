class UserModel {
  final String id;
  final String name;
  final String phone;
  final String nationalId;
  final String address;
  final int score;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.nationalId,
    required this.address,
    required this.score,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      nationalId: json['national_id'] ?? '',
      address: json['address'] ?? '',
      score: json['score'] ?? 0,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? nationalId,
    String? address,
    int? score,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      score: score ?? this.score,
    );
  }
}
