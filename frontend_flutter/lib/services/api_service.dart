import 'dart:io';
import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/dashboard_summary.dart';
import '../models/nutrition_entry.dart';
import '../models/workout_entry.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;
  String _baseUrl = AppConstants.defaultBaseUrl;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 25),
      headers: {
        'Accept': 'application/json',
      },
    ));
  }

  void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
    _dio.options.baseUrl = newUrl;
  }

  String get currentBaseUrl => _baseUrl;

  // 1. DASHBOARD
  Future<DashboardSummaryModel> getDashboardSummary() async {
    final response = await _dio.get('/api/dashboard/summary');
    return DashboardSummaryModel.fromJson(response.data);
  }

  // 2. NUTRITION WITH GEMINI AI
  Future<Map<String, dynamic>> analyzeFoodPlate({
    required double weightGrams,
    File? imageFile,
  }) async {
    FormData formData = FormData.fromMap({
      'weight_grams': weightGrams,
    });

    if (imageFile != null && await imageFile.exists()) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    final response = await _dio.post('/api/nutrition/analyze', data: formData);
    return response.data;
  }

  // 3. SUPPLEMENT: WHEY PRO UNIVERSE NUTRITION
  Future<Map<String, dynamic>> logWheySupplement({
    double scoops = 1.0,
    bool isPostWorkout = true,
    bool isLiftingDay = true,
  }) async {
    final response = await _dio.post(
      '/api/nutrition/log-whey',
      data: {
        'scoops': scoops,
        'is_post_workout': isPostWorkout,
        'is_lifting_day': isLiftingDay,
      },
    );
    return response.data;
  }

  // 4. WORKOUT
  Future<Map<String, dynamic>> getTodayRoutine() async {
    final response = await _dio.get('/api/workout/routine/today');
    return response.data;
  }

  Future<Map<String, dynamic>> logWorkoutSession({
    required String dayName,
    required String routineFocus,
    required List<WorkoutSetModel> sets,
    File? photoFile,
    String? notes,
  }) async {
    FormData formData = FormData.fromMap({
      'day_name': dayName,
      'routine_focus': routineFocus,
      'notes': notes ?? '',
      'sets_json': sets.map((s) => s.toJson()).toList().toString(),
    });

    if (photoFile != null && await photoFile.exists()) {
      formData.files.add(MapEntry(
        'photo',
        await MultipartFile.fromFile(
          photoFile.path,
          filename: photoFile.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    final response = await _dio.post('/api/workout/log', data: formData);
    return response.data;
  }

  // 5. CARDIO: LIFE FITNESS QR SCANNER
  Future<Map<String, dynamic>> syncCardioQr(String qrPayload) async {
    final response = await _dio.post(
      '/api/cardio/scan-qr',
      data: {'qr_payload': qrPayload},
    );
    return response.data;
  }
}
