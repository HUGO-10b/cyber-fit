class AppConstants {
  // User Profile
  static const double userHeightM = 1.71;
  static const double userWeightKg = 90.8;
  static const int calorieTargetMin = 1800;
  static const int calorieTargetMax = 1900;
  
  // Supplements
  static const String wheyProductName = "Whey Pro (Universe Nutrition)";
  static const double maxWheyScoopsPerLiftingDay = 1.0;

  // Network API Base URL
  // Use 10.0.2.2 for Android Emulator, localhost for iOS simulator/desktop, or your LAN IP for physical device
  static const String defaultBaseUrl = "http://10.0.2.2:5000";

  // Weekly Routines
  static const Map<int, String> dayRoutines = {
    1: "Pierna",
    2: "Pecho con tríceps",
    3: "Espalda con bíceps",
    4: "Pierna",
    5: "Pecho con tríceps",
  };
}
