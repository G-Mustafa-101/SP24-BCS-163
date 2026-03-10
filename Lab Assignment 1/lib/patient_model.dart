class Patient {
  int? id;
  String name;
  String age;
  String disease;
  String phone;
  String? image;
  String? document;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.disease,
    required this.phone,
    this.image,
    this.document,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'disease': disease,
      'phone': phone,
      'image': image,
      'document': document,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      disease: map['disease'],
      phone: map['phone'],
      image: map['image'],
      document: map['document'],
    );
  }
}