import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../config/theme.dart';
import '../models/dashboard_summary.dart';
import '../services/api_service.dart';
import '../widgets/cyberpunk_card.dart';
import '../widgets/macro_ring_chart.dart';
import '../widgets/stat_badge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardSummaryModel? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await _apiService.getDashboardSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      // Provide demo/fallback data in case API server is starting up or in demo mode
      setState(() {
        _summary = _getDemoSummary();
        _isLoading = false;
        _errorMessage = "Modo Demo Activo (Conectar Backend en ajustes si se desea sincronización remota).";
      });
    }
  }

  DashboardSummaryModel _getDemoSummary() {
    return DashboardSummaryModel(
      heightM: 1.71,
      currentWeightKg: 90.8,
      goal: "Pérdida de Grasa Corporal",
      dailyCalorieTarget: 1800,
      todayCaloriesConsumed: 1240,
      todayRemainingCalories: 560,
      isCaloricSurplus: false,
      proteinG: 110,
      carbsG: 120,
      fatG: 34,
      cardioMinutes: 25.0,
      cardioKm: 3.8,
      cardioCalories: 260.0,
      workoutCompleted: true,
      workoutFocus: "Pecho con tríceps",
      wheyProTaken: true,
      weeklyWorkoutsCompleted: 3,
      weeklyDays: [
        DashboardDayProgress(dayIndex: 0, dayLabel: "Lun", date: "2026-10-06", calories: 1780, targetCalories: 1800, cardioKm: 3.5, workoutCompleted: true, isToday: false),
        DashboardDayProgress(dayIndex: 1, dayLabel: "Mar", date: "2026-10-07", calories: 1820, targetCalories: 1800, cardioKm: 4.0, workoutCompleted: true, isToday: false),
        DashboardDayProgress(dayIndex: 2, dayLabel: "Mié", date: "2026-10-08", calories: 1690, targetCalories: 1800, cardioKm: 0.0, workoutCompleted: false, isToday: false),
        DashboardDayProgress(dayIndex: 3, dayLabel: "Jue", date: "2026-10-09", calories: 1750, targetCalories: 1800, cardioKm: 4.2, workoutCompleted: true, isToday: false),
        DashboardDayProgress(dayIndex: 4, dayLabel: "Vie", date: "2026-10-10", calories: 1240, targetCalories: 1800, cardioKm: 3.8, workoutCompleted: true, isToday: true),
        DashboardDayProgress(dayIndex: 5, dayLabel: "Sáb", date: "2026-10-11", calories: 0, targetCalories: 1800, cardioKm: 0.0, workoutCompleted: false, isToday: false),
        DashboardDayProgress(dayIndex: 6, dayLabel: "Dom", date: "2026-10-12", calories: 0, targetCalories: 1800, cardioKm: 0.0, workoutCompleted: false, isToday: false),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: CyberpunkTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: CyberpunkTheme.neonGreen),
        ),
      );
    }

    final summary = _summary!;

    return Scaffold(
      backgroundColor: CyberpunkTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: CyberpunkTheme.neonGreen,
                shape: BoxShape.circle,
                boxShadow: CyberpunkTheme.neonGlowShadow(blur: 8),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'CYBERFIT // OS',
              style: TextStyle(
                color: CyberpunkTheme.neonGreen,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: CyberpunkTheme.neonGreen),
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        color: CyberpunkTheme.neonGreen,
        backgroundColor: CyberpunkTheme.cardSurface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: CyberpunkTheme.neonYellow.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: CyberpunkTheme.neonYellow.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: CyberpunkTheme.neonYellow, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: CyberpunkTheme.neonYellow, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),

              // Profile HUD
              _buildUserProfileHud(summary),
              const SizedBox(height: 16),

              // Nutrition & Calories Ring
              CyberpunkCard(
                title: 'Nutrición Diaria (Objetivo 1,800 kcal)',
                hasGlow: summary.isCaloricSurplus,
                borderColor: summary.isCaloricSurplus
                    ? CyberpunkTheme.neonRed
                    : CyberpunkTheme.neonGreen,
                child: Column(
                  children: [
                    MacroRingChart(
                      consumedCalories: summary.todayCaloriesConsumed,
                      targetCalories: summary.dailyCalorieTarget.toDouble(),
                      proteinG: summary.proteinG,
                      carbsG: summary.carbsG,
                      fatG: summary.fatG,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          summary.isCaloricSurplus
                              ? '⚠️ SUPERÁVIT: +${(summary.todayCaloriesConsumed - summary.dailyCalorieTarget).toInt()} kcal'
                              : 'DÉFICIT ACTIVO: -${summary.todayRemainingCalories.toInt()} kcal restantes',
                          style: TextStyle(
                            color: summary.isCaloricSurplus
                                ? CyberpunkTheme.neonRed
                                : CyberpunkTheme.neonGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Meta: 1800-1900 kcal',
                          style: TextStyle(
                            color: CyberpunkTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Whey Pro Universe Nutrition Rule Card
              _buildWheyRuleCard(summary),
              const SizedBox(height: 16),

              // Weekly Progress Graph (fl_chart)
              CyberpunkCard(
                title: 'Ingesta Semanal vs Límite 1,800 kcal',
                child: SizedBox(
                  height: 200,
                  child: _buildWeeklyBarChart(summary),
                ),
              ),
              const SizedBox(height: 16),

              // Life Fitness Cardio & Gym Training HUD
              Row(
                children: [
                  Expanded(
                    child: StatBadge(
                      label: 'Cardio Life Fitness',
                      value: '${summary.cardioKm}',
                      unit: 'km',
                      icon: Icons.directions_run,
                      accentColor: CyberpunkTheme.neonCyan,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatBadge(
                      label: 'Gym Semanal',
                      value: '${summary.weeklyWorkoutsCompleted}/5',
                      unit: 'días',
                      icon: Icons.fitness_center,
                      accentColor: CyberpunkTheme.neonGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfileHud(DashboardSummaryModel summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CyberpunkTheme.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CyberpunkTheme.neonGreen.withOpacity(0.3)),
        gradient: LinearGradient(
          colors: [
            CyberpunkTheme.cardSurfaceLight,
            CyberpunkTheme.neonGreen.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERFIL ATLETA // BIO-METRICS',
                    style: TextStyle(
                      color: CyberpunkTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    summary.goal.toUpperCase(),
                    style: const TextStyle(
                      color: CyberpunkTheme.neonGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: CyberpunkTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: CyberpunkTheme.neonGreen.withOpacity(0.5)),
                ),
                child: const Text(
                  'DÉFICIT ON',
                  style: TextStyle(
                    color: CyberpunkTheme.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHudMetric('ALTURA', '${summary.heightM} m'),
              Container(width: 1, height: 26, color: Colors.white.withOpacity(0.1)),
              _buildHudMetric('PESO ACTUAL', '${summary.currentWeightKg} kg'),
              Container(width: 1, height: 26, color: Colors.white.withOpacity(0.1)),
              _buildHudMetric('OBJETIVO DIARIO', '1,800 kcal'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHudMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: CyberpunkTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: CyberpunkTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            fontFamily: 'Rajdhani',
          ),
        ),
      ],
    );
  }

  Widget _buildWheyRuleCard(DashboardSummaryModel summary) {
    return CyberpunkCard(
      title: 'Suplemento: Whey Pro (Universe Nutrition)',
      borderColor: CyberpunkTheme.neonYellow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                summary.wheyProTaken ? Icons.check_circle : Icons.radio_button_unchecked,
                color: summary.wheyProTaken ? CyberpunkTheme.neonGreen : CyberpunkTheme.neonYellow,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary.wheyProTaken
                      ? '1 Scoop Post-Entrenamiento Registrado Hoy.'
                      : 'Pendiente de registrar (Solo post-pesas).',
                  style: TextStyle(
                    color: summary.wheyProTaken ? CyberpunkTheme.neonGreen : CyberpunkTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '⚠️ REGLA ESTRICTA: Alto contenido de carbohidratos. Máximo 1 scoop post-entrenamiento exclusivamente los días de pesas para no sabotear el déficit calórico.',
            style: TextStyle(color: CyberpunkTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(DashboardSummaryModel summary) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 2400,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = summary.weeklyDays[groupIndex];
              return BarTooltipItem(
                '${day.dayLabel}: ${rod.toY.toInt()} kcal\nTarget: 1800',
                const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < summary.weeklyDays.length) {
                  final day = summary.weeklyDays[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      day.dayLabel,
                      style: TextStyle(
                        color: day.isToday ? CyberpunkTheme.neonGreen : CyberpunkTheme.textSecondary,
                        fontWeight: day.isToday ? FontWeight.w900 : FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: 600,
              getTitlesWidget: (val, meta) => Text(
                '${val.toInt()}',
                style: const TextStyle(color: CyberpunkTheme.textMuted, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 600,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withOpacity(0.06),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: summary.weeklyDays.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isOver = item.calories > 1800;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.calories,
                color: isOver ? CyberpunkTheme.neonRed : (item.isToday ? CyberpunkTheme.neonGreen : CyberpunkTheme.neonGreen.withOpacity(0.65)),
                width: 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1800,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
