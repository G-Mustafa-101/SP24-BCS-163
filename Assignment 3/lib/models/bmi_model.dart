class BMIModel {
  int? id;
  double bmi;
  String category;
  double height;
  double weight;

  BMIModel({
    this.id,
    required this.bmi,
    required this.category,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bmi': bmi,
      'category': category,
      'height': height,
      'weight': weight,
    };
  }

  factory BMIModel.fromMap(Map<String, dynamic> map) {
    return BMIModel(
      id: map['id'],
      bmi: map['bmi'],
      category: map['category'],
      height: map['height'],
      weight: map['weight'],
    );
  }
}