import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:habivi/domain/services/puntos_estudio_service.dart';
import 'package:habivi/data/repositories/estudio_repository.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/core/utils/app_clock.dart';

class FocusTimerDialog extends StatefulWidget {
  final VoidCallback onSessionSaved;

  const FocusTimerDialog({
    super.key,
    required this.onSessionSaved,
  });

  static Future<void> show(BuildContext context, {required VoidCallback onSessionSaved}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Temporizador',
      barrierColor: Colors.black.withValues(alpha: 0.88),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (context, anim1, anim2) {
        return FocusTimerDialog(onSessionSaved: onSessionSaved);
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<FocusTimerDialog> createState() => _FocusTimerDialogState();
}

class _FocusTimerDialogState extends State<FocusTimerDialog> {
  late int _durationSeconds;
  late int _remainingSeconds;
  bool _isRunning = false;
  Timer? _timer;
  String _selectedMethodId = 'pomodoro';
  late EstudioRepository _estudioRepository;

  final List<int> _presetMinutes = [5, 15, 25, 45, 60];

  @override
  void initState() {
    super.initState();
    _estudioRepository = EstudioRepository();
    _durationSeconds = 25 * 60; // 25 min Pomodoro por defecto
    _remainingSeconds = _durationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds <= 0) return;
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _pauseTimer();
        setState(() {
          _remainingSeconds = 0;
        });
        _completarSesionAutomatica();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remainingSeconds = _durationSeconds;
    });
  }

  void _seleccionarPreset(int minutos) {
    _pauseTimer();
    setState(() {
      _durationSeconds = minutos * 60;
      _remainingSeconds = _durationSeconds;
    });
  }

  Future<void> _abrirDialogoCustomMinutes() async {
    int customMins = _durationSeconds ~/ 60;
    final controller = TextEditingController(text: '$customMins');

    final res = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tiempo personalizado'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              suffixText: 'minutos',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = int.tryParse(controller.text.trim());
                if (val != null && val > 0 && val <= 300) {
                  Navigator.pop(context, val);
                }
              },
              child: const Text('Establecer'),
            ),
          ],
        );
      },
    );

    if (res != null) {
      _seleccionarPreset(res);
    }
  }

  Future<void> _completarSesionAutomatica() async {
    final minutosCompletados = _durationSeconds ~/ 60;
    if (minutosCompletados > 0) {
      await _registrarSesionBD(minutosCompletados);
      if (mounted) {
        _mostrarDialogoCelebracion(minutosCompletados);
      }
    }
  }

  Future<void> _guardarSesionManual() async {
    final transcurridosSeg = _durationSeconds - _remainingSeconds;
    final minutosTranscurridos = (transcurridosSeg / 60).round();

    if (minutosTranscurridos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requiere al menos 1 minuto de enfoque para registrar.'),
        ),
      );
      return;
    }

    _pauseTimer();
    await _registrarSesionBD(minutosTranscurridos);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Se registraron $minutosTranscurridos min de enfoque.'),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _registrarSesionBD(int minutos) async {
    try {
      final now = AppClock.now();
      final fechaHoy =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final idSesion = DateTime.now().millisecondsSinceEpoch;

      final nuevaSesion = SesionEstudio(
        idSesion,
        _selectedMethodId,
        minutos,
        minutos, // puntos/minutos acumulados
        fechaHoy,
      );

      await _estudioRepository.add(nuevaSesion);
      widget.onSessionSaved();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar sesión: $e')),
        );
      }
    }
  }

  void _mostrarDialogoCelebracion(int minutos) {
    final metodo = EstudioService.metodos.firstWhere(
      (m) => m.id == _selectedMethodId,
      orElse: () => EstudioService.metodos.first,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Text('🎉 ', style: TextStyle(fontSize: 28)),
              Text('¡Gran Enfoque!'),
            ],
          ),
          content: Text(
            'Completaste $minutos minutos de concentración usando "${metodo.nombre}". ¡Tus estadísticas se han actualizado!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Cierra diálogo
                Navigator.pop(this.context); // Cierra overlay temporizador
              },
              child: const Text('¡Excelente!'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final mins = totalSeconds ~/ 60;
    final secs = totalSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = _durationSeconds > 0
        ? _remainingSeconds / _durationSeconds
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0E1A),
      body: SafeArea(
        child: Column(
          children: [
            // === BARRA SUPERIOR ELEGANTE ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.timer_rounded, color: cs.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Temporizador',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                  ),
                ],
              ),
            ),

            // === SELECTOR DE MÉTODO ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedMethodId,
                    dropdownColor: const Color(0xFF1A1B2F),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    items: EstudioService.metodos.map((metodo) {
                      return DropdownMenuItem<String>(
                        value: metodo.id,
                        child: Row(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 18,
                              color: cs.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              metodo.nombre,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: _isRunning
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedMethodId = val;
                              });
                            }
                          },
                  ),
                ),
              ),
            ),

            const Spacer(),

            // === ANILLO RADIAL DE TIEMPO INTERACTIVO ===
            Center(
              child: SizedBox(
                width: 260,
                height: 260,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anillo con gradiente y efecto neón
                    CustomPaint(
                      size: const Size(260, 260),
                      painter: _RadialTimerPainter(
                        progress: progress,
                        accentColor: _isRunning ? cs.primary : const Color(0xFF42A5F5),
                        isRunning: _isRunning,
                      ),
                    ),
                    // Texto de tiempo y estado
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: cs.primary.withValues(alpha: 0.5),
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: (_isRunning ? cs.primary : Colors.white)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _isRunning
                                ? 'EN CONCENTRACIÓN'
                                : (_remainingSeconds == 0
                                    ? '¡COMPLETADO!'
                                    : 'EN PAUSA'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _isRunning
                                  ? cs.primary
                                  : Colors.white.withValues(alpha: 0.8),
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // === PRESETS DE TIEMPO ===
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  ..._presetMinutes.map((mins) {
                    final esSeleccionado =
                        (_durationSeconds ~/ 60) == mins;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('${mins}m'),
                        selected: esSeleccionado,
                        selectedColor: cs.primary.withValues(alpha: 0.3),
                        side: BorderSide(
                          color: esSeleccionado
                              ? cs.primary
                              : Colors.white.withValues(alpha: 0.15),
                        ),
                        onSelected: _isRunning
                            ? null
                            : (selected) {
                                if (selected) _seleccionarPreset(mins);
                              },
                      ),
                    );
                  }),
                  ActionChip(
                    avatar: const Icon(Icons.edit, size: 14, color: Colors.white70),
                    label: const Text('Custom'),
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    onPressed: _isRunning ? null : _abrirDialogoCustomMinutes,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // === CONTROLES PRINCIPALES ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón Reset
                  IconButton.filledTonal(
                    onPressed: _resetTimer,
                    iconSize: 26,
                    icon: const Icon(Icons.replay_rounded),
                    tooltip: 'Reiniciar',
                  ),

                  // Botón Play / Pause Grande con Glow
                  GestureDetector(
                    onTap: _toggleTimer,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.primary,
                            cs.tertiary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),

                  // Botón Guardar Sesión Manual / Registrar
                  IconButton.filledTonal(
                    onPressed: _guardarSesionManual,
                    iconSize: 26,
                    icon: const Icon(Icons.check_rounded),
                    tooltip: 'Registrar tiempo enfocado',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

/// Painter para el anillo de tiempo radial con efecto neón
class _RadialTimerPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0
  final Color accentColor;
  final bool isRunning;

  _RadialTimerPainter({
    required this.progress,
    required this.accentColor,
    required this.isRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 16;
    const strokeWidth = 14.0;

    // Anillo de fondo translúcido
    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2;

    // Anillo de resplandor (Glow)
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..color = accentColor.withValues(alpha: isRunning ? 0.45 : 0.2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    // Anillo de progreso principal
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: [
          accentColor.withValues(alpha: 0.6),
          accentColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialTimerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isRunning != isRunning;
  }
}
