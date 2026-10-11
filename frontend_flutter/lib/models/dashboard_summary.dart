class DashboardDayProgress {
  final int dayIndex;
  final String dayLabel;
  final String date;
  final double calories;
  final double targetCalories;
  final double cardioKm;
  final bool workoutCompleted;
  final bool isToday;

  DashboardDayProgress({
    required this.dayIndex,
    required this.dayLabel,
    required this.date,
    required this.calories,
    required this.targetCalories,
    required this.cardioKm,
    required this.workoutCompleted,
    required this.isToday,
  });

  factory DashboardDayProgress.fromJson(Map<String, dynamic> json) =>
      DashboardDayProgress(
        dayIndex: json['day_index'] ?? 0,
        dayLabel: json['day_label'] ?? '',
        date: json['date'] ?? '',
        calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
        targetCalories: (json['target_calories'] as num?)?.toDouble() ?? 1800.0,
        cardioKm: (json['cardio_km'] as num?)?.toDouble() ?? 0.0,
        workoutCompleted: json['workout_completed'] ?? false,
        isToday: json['is_today'] ?? false,
      );
}

class DashboardSummaryModel {
  final double heightM;
  final double currentWeightKg;
  final String goal;
  final int dailyCalorieTarget;
  final double todayCaloriesConsumed;
  final double todayRemainingCalories;
  final bool isCaloricSurplus;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double cardioMinutes;
  final double cardioKm;
  final double cardioCalories;
  final bool workoutCompleted;
  final String? workoutFocus;
  final bool wheyProTaken;
  final int weeklyWorkoutsCompleted;
  final List<DashboardDayProgress> weeklyDays;

  DashboardSummaryModel({
    required this.heightM,
    required this.currentWeightKg,
    required this.goal,
    required this.dailyCalorieTarget,
    required this.todayCaloriesConsumed,
    required this.todayRemainingCalories,
    required this.isCaloricSurplus,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.cardioMinutes,
    required this.cardioKm,
    required this.cardioCalories,
    required this.workoutCompleted,
    this.workoutFocus,
    required this.wheyProTaken,
    required this.weeklyWorkoutsCompleted,
    required this.weeklyDays,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final profile = json['user_profile'] ?? {};
    final today = json['today'] ?? {};
    final macros = today['macros'] ?? {};
    final cardio = today['cardio'] ?? {};
    final weekly = json['weekly_progress'] ?? {};

    return DashboardSummaryModel(
      heightM: (profile['height_m'] as num?)?.toDouble() ?? 1.71,
      currentWeightKg: (profile['current_weight_kg'] as num?)?.toDouble() ?? 90.8,
      goal: profile['goal'] ?? 'Pérdida de grasa corporal',
      dailyCalorieTarget: profile['daily_calorie_target'] ?? 1800,
      todayCaloriesConsumed: (today['calories_consumed'] as num?)?.toDouble() ?? 0.0,
      todayRemainingCalories: (today['remaining_calories'] as num?)?.toDouble() ?? 1800.0,
      isCaloricSurplus: today['is_caloric_surplus'] ?? false,
      proteinG: (macros['protein_g'] as num?)?.toDouble() ?? 0.0,
      carbsG: (macros['carbs_g'] as num?)?.toDouble() ?? 0.0,
      fatG: (macros['fat_g'] as num?)?.toDouble() ?? 0.0,
      cardioMinutes: (cardio['time_minutes'] as num?)?.toDouble() ?? 0.0,
      cardioKm: (cardio['distance_km'] as num?)?.toDouble() ?? 0.0,
      cardioCalories: (cardio['burned_calories'] as num?)?.toDouble() ?? 0.0,
      workoutCompleted: today['workout_completed'] ?? false,
      workoutFocus: today['workout_focus'],
      wheyProTaken: today['whey_pro_taken'] ?? false,
      weeklyWorkoutsCompleted: weekly['workouts_completed'] ?? 0,
      weeklyDays: (weekly['days'] as List? ?? [])
          .map((d) => DashboardDayProgress.fromJson(d))
          .toList(),
    );
  }
}
