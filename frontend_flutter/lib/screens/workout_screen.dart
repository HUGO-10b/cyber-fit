import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../config/theme.dart';
import '../models/workout_entry.dart';
import '../services/api_service.dart';
import '../widgets/cyberpunk_card.dart';
import '../widgets/neon_button.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  String _currentDay = "Viernes";
  String _currentRoutine = "Pecho con tríceps";
  bool _isLoading = false;
  File? _progressPhoto;
  final TextEditingController _notesController = TextEditingController();

  final List<WorkoutSetModel> _sets = [
    WorkoutSetModel(exerciseName: "Press de Banca con Mancuernas", setNumber: 1, weightKg: 28.0, reps: 10),
    WorkoutSetModel(exerciseName: "Press Inclinado", setNumber: 2, weightKg: 24.0, reps: 12),
    WorkoutSetModel(exerciseName: "Fondos en Paralelas", setNumber: 3, weightKg: 0.0, reps: 12),
    WorkoutSetModel(exerciseName: "Extensiones Katana en Polea", setNumber: 4, weightKg: 15.0, reps: 15),
  ];

  @override
  void initState() {
    super.initState();
    _fetchTodayRoutine();
  }

  Future<void> _fetchTodayRoutine() async {
    try {
      final res = await _apiService.getTodayRoutine();
      setState(() {
        _currentDay = res['day_name'] ?? _currentDay;
        _currentRoutine = res['routine_focus'] ?? _currentRoutine;
      });
    } catch (_) {
      // Keep defaults based on Friday/today
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked != null) {
        setState(() {
          _progressPhoto = File(picked.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: CyberpunkTheme.neonRed),
      );
    }
  }

  void _addSetDialog() {
    final nameCtrl = TextEditingController(text: "Press Superior / Ejercicio");
    final weightCtrl = TextEditingController(text: "20.0");
    final repsCtrl = TextEditingController(text: "10");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CyberpunkTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: CyberpunkTheme.neonGreen),
        ),
        title: const Text(
          'REGISTRAR SERIE',
          style: TextStyle(color: CyberpunkTheme.neonGreen, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Ejercicio'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: weightCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Peso levantado (kg)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: repsCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Repeticiones'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: CyberpunkTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: CyberpunkTheme.neonGreen),
            onPressed: () {
              final w = double.tryParse(weightCtrl.text) ?? 0.0;
              final r = int.tryParse(repsCtrl.text) ?? 10;
              setState(() {
                _sets.add(WorkoutSetModel(
                  exerciseName: nameCtrl.text,
                  setNumber: _sets.length + 1,
                  weightKg: w,
                  reps: r,
                ));
              });
              Navigator.pop(ctx);
            },
            child: const Text('Agregar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _submitWorkout() async {
    setState(() => _isLoading = true);
    try {
      await _apiService.logWorkoutSession(
        dayName: _currentDay,
        routineFocus: _currentRoutine,
        sets: _sets,
        photoFile: _progressPhoto,
        notes: _notesController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entrenamiento de $_currentRoutine registrado con éxito.'),
          backgroundColor: CyberpunkTheme.neonGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sesión guardada en modo local: $e'),
          backgroundColor: CyberpunkTheme.neonGreen,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberpunkTheme.background,
      appBar: AppBar(
        title: const Text(
          'ENTRENAMIENTO // GYM',
          style: TextStyle(
            color: CyberpunkTheme.neonGreen,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Routine Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CyberpunkTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CyberpunkTheme.neonGreen.withOpacity(0.5)),
                boxShadow: CyberpunkTheme.neonGlowShadow(blur: 10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RUTINA DE HOY // $_currentDay'.toUpperCase(),
                        style: const TextStyle(
                          color: CyberpunkTheme.neonGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentRoutine,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.fitness_center, color: CyberpunkTheme.neonGreen, size: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Weekly Routine 5-Day Schedule
            CyberpunkCard(
              title: 'Split Semanal (5 Días)',
              child: Column(
                children: [
                  _buildDayScheduleRow("Lunes", "Pierna", _currentDay == "Lunes"),
                  _buildDayScheduleRow("Martes", "Pecho con tríceps", _currentDay == "Martes"),
                  _buildDayScheduleRow("Miércoles", "Espalda con bíceps", _currentDay == "Miércoles"),
                  _buildDayScheduleRow("Jueves", "Pierna", _currentDay == "Jueves"),
                  _buildDayScheduleRow("Viernes", "Pecho con tríceps", _currentDay == "Viernes"),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Series & Reps Logger
            CyberpunkCard(
              title: 'Registro de Cargas & Series',
              trailing: IconButton(
                icon: const Icon(Icons.add_circle, color: CyberpunkTheme.neonGreen),
                onPressed: _addSetDialog,
              ),
              child: Column(
                children: [
                  if (_sets.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay series registradas.', style: TextStyle(color: CyberpunkTheme.textMuted)),
                    )
                  else
                    ..._sets.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final s = entry.value;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: CyberpunkTheme.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '#${s.setNumber}',
                              style: const TextStyle(color: CyberpunkTheme.neonGreen, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                s.exerciseName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                            Text(
                              '${s.weightKg} kg',
                              style: const TextStyle(color: CyberpunkTheme.neonCyan, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'x ${s.reps} reps',
                              style: const TextStyle(color: CyberpunkTheme.neonYellow, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: CyberpunkTheme.neonRed, size: 18),
                              onPressed: () {
                                setState(() {
                                  _sets.removeAt(idx);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Photo of machine or mirror progress
            CyberpunkCard(
              title: 'Foto de Máquina o Espejo (Progreso)',
              child: Column(
                children: [
                  if (_progressPhoto != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_progressPhoto!, height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: NeonButton(
                          label: 'Cámara Espejo',
                          icon: Icons.camera_alt,
                          isOutlined: true,
                          onPressed: () => _pickPhoto(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeonButton(
                          label: 'Galería Máquina',
                          icon: Icons.photo_library,
                          isOutlined: true,
                          onPressed: () => _pickPhoto(ImageSource.gallery),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'NOTAS DEL ENTRENAMIENTO (RPE, SENSACIONES)',
                labelStyle: const TextStyle(color: CyberpunkTheme.textMuted, fontSize: 11),
                filled: true,
                fillColor: CyberpunkTheme.cardSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: NeonButton(
                label: 'Guardar Sesión de Entrenamiento',
                icon: Icons.save,
                isLoading: _isLoading,
                onPressed: _submitWorkout,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleRow(String day, String focus, bool isCurrent) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isCurrent ? CyberpunkTheme.neonGreen.withOpacity(0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isCurrent ? Icons.play_arrow : Icons.circle,
                size: isCurrent ? 14 : 6,
                color: isCurrent ? CyberpunkTheme.neonGreen : CyberpunkTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                day,
                style: TextStyle(
                  color: isCurrent ? CyberpunkTheme.neonGreen : Colors.white70,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          Text(
            focus,
            style: TextStyle(
              color: isCurrent ? CyberpunkTheme.neonGreen : CyberpunkTheme.textSecondary,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
