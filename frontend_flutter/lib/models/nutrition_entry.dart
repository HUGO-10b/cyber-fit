class NutritionEntryModel {
  final int id;
  final String date;
  final String timestamp;
  final String mealName;
  final String? imagePath;
  final double weightGrams;
  final double calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String? aiAnalysis;

  NutritionEntryModel({
    required this.id,
    required this.date,
    required this.timestamp,
    required this.mealName,
    this.imagePath,
    required this.weightGrams,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.aiAnalysis,
  });

  factory NutritionEntryModel.fromJson(Map<String, dynamic> json) {
    return NutritionEntryModel(
      id: json['id'] ?? 0,
      date: json['date'] ?? '',
      timestamp: json['timestamp'] ?? '',
      mealName: json['meal_name'] ?? 'Comida',
      imagePath: json['image_path'],
      weightGrams: (json['weight_grams'] as num?)?.toDouble() ?? 0.0,
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      proteinGrams: (json['protein_grams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbs_grams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fat_grams'] as num?)?.toDouble() ?? 0.0,
      aiAnalysis: json['ai_analysis'],
    );
  }
}
