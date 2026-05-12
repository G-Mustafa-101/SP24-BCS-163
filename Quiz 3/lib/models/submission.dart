class Submission {
  final String? id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String gender;
  final int? createdAt;
  final int? updatedAt;

  Submission({
    this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.gender,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullname': fullName,
      'email': email,
      'phonenumber': phoneNumber,
      'address': address,
      'gender': gender,
      'createdat': createdAt ?? DateTime.now().millisecondsSinceEpoch,
      'updatedat': updatedAt ?? DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['id'],
      fullName: json['fullname'],
      email: json['email'],
      phoneNumber: json['phonenumber'],
      address: json['address'],
      gender: json['gender'],
      createdAt: json['createdat'],
      updatedAt: json['updatedat'],
    );
  }
}
