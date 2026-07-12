import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/domain/services/racha_service.dart';
import 'package:habivi/presentation/providers/racha_provider.dart';

/// Widget que muestra las rachas diaria y semanal con animaciones
class RachaIndicator extends ConsumerWidget {
  const RachaIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyRachaAsync = ref.watch(dailyRachaProvider);
    final weeklyRachaAsync = ref.watch(weeklyRachaProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Racha Diaria
        dailyRachaAsync.when(
          loading: () => _buildSkeletonRacha(),
          error: (_, __) => const SizedBox.shrink(),
          data: (racha) {
            if (racha == null) return const SizedBox.shrink();
            return _buildRachaItem(
              racha: racha,
              tipo: 'diaria',
              enRiesgo: false,
            );
          },
        ),
        const SizedBox(height: 12),
        // Racha Semanal
        weeklyRachaAsync.when(
          loading: () => _buildSkeletonRacha(),
          error: (_, __) => const SizedBox.shrink(),
          data: (racha) {
            if (racha == null) return const SizedBox.shrink();
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRachaItem(
                  racha: racha,
                  tipo: 'semanal',
                  enRiesgo: racha.enRiesgo,
                ),
                if (racha.enRiesgo) ...[const SizedBox(height: 8), _buildRecuperationMessage()],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRachaItem({
    required Racha racha,
    required String tipo,
    required bool enRiesgo,
  }) {
    final color = _getColorForRacha(tipo, enRiesgo);
    final message = RachaService.getRachaMessage(
      cantidad: racha.cantidad,
      tipo: tipo,
      enRiesgo: enRiesgo,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Emoji con animación pulse
          _buildAnimatedEmoji(),
          const SizedBox(width: 12),
          // Texto
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedEmoji() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.2),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      onEnd: () {},
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Text(
            '🔥',
            style: TextStyle(
              fontSize: 20,
              shadows: [
                Shadow(
                  color: Colors.red.withValues(alpha: 0.5),
                  blurRadius: 8,
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecuperationMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF808080).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: const Color(0xFF808080),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              RachaService.getRecuperationMessage(),
              style: const TextStyle(
                color: Color(0xFF808080),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonRacha() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForRacha(String tipo, bool enRiesgo) {
    if (tipo == 'diaria') {
      return const Color(0xFFFF4444); // Rojo para racha diaria
    } else {
      return enRiesgo
          ? const Color(0xFF808080) // Gris en riesgo
          : const Color(0xFF6B5FFF); // Morado cuando activa
    }
  }
}
