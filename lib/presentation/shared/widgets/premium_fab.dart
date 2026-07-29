import 'dart:math' as math;
import 'package:flutter/material.dart';

/// FAB premium con anillo de gradiente brillante y centro oscuro.
/// Diseño inspirado en la imagen de referencia del usuario.
class PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const PremiumFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _GlowRingPainter(),
        child: Center(
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A2E),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                splashColor: Colors.white.withValues(alpha: 0.12),
                highlightColor: Colors.white.withValues(alpha: 0.06),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pinta el anillo de gradiente brillante alrededor del botón
class _GlowRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Glow exterior difuminado
    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Glow rosa
    glowPaint.color = const Color(0xFFEC407A).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(center.dx - 6, center.dy - 6), radius - 2, glowPaint);

    // Glow azul
    glowPaint.color = const Color(0xFF42A5F5).withValues(alpha: 0.25);
    canvas.drawCircle(Offset(center.dx + 6, center.dy + 6), radius - 2, glowPaint);

    // Anillo de gradiente muy fino
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = const SweepGradient(
        center: Alignment.center,
        startAngle: 0,
        endAngle: 2 * math.pi,
        colors: [
          Color(0xFFEC407A), // Rosa
          Color(0xFFAB47BC), // Púrpura
          Color(0xFF42A5F5), // Azul
          Color(0xFF00BFA5), // Teal
          Color(0xFFEC407A), // Rosa (cierra el ciclo)
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 1));

    canvas.drawCircle(center, radius - 1, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
