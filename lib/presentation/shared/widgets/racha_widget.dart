import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/presentation/providers/racha_provider.dart';

class RachaIndicator extends ConsumerWidget {
  const RachaIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyRachaAsync = ref.watch(dailyRachaProvider);
    final weeklyRachaAsync = ref.watch(weeklyRachaProvider);

    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          // === RACHA DIARIA ===
          Expanded(
            child: dailyRachaAsync.when(
              loading: () => _buildRachaCard(
                emoji: '🔥',
                label: 'Días',
                value: '–',
                gradientColors: const [Color(0xFFFF5722), Color(0xFFFF9800)],
                isInactiveOrRisk: false,
              ),
              error: (_, __) => _buildRachaCard(
                emoji: '🔥',
                label: 'Días',
                value: '0',
                gradientColors: const [Color(0xFFFF5722), Color(0xFFFF9800)],
                isInactiveOrRisk: true,
              ),
              data: (racha) {
                final isZeroOrRisk = racha == null || racha.cantidad == 0 || racha.enRiesgo;
                final val = racha == null ? '0' : '${racha.cantidad}';
                return _buildRachaCard(
                  emoji: '🔥',
                  label: 'Días en racha',
                  value: val,
                  gradientColors: const [Color(0xFFFF4500), Color(0xFFFF8C00)],
                  isInactiveOrRisk: isZeroOrRisk,
                );
              },
            ),
          ),

          const SizedBox(width: 12),

          // === RACHA SEMANAL ===
          Expanded(
            child: weeklyRachaAsync.when(
              loading: () => _buildRachaCard(
                emoji: '⚡',
                label: 'Semanas',
                value: '–',
                gradientColors: const [Color(0xFF8E24AA), Color(0xFFD81B60)],
                isInactiveOrRisk: false,
              ),
              error: (_, __) => _buildRachaCard(
                emoji: '⚡',
                label: 'Semanas',
                value: '0',
                gradientColors: const [Color(0xFF8E24AA), Color(0xFFD81B60)],
                isInactiveOrRisk: true,
              ),
              data: (racha) {
                final isZeroOrRisk = racha == null || racha.cantidad == 0 || racha.enRiesgo;
                final val = racha == null ? '0' : '${racha.cantidad}';
                return _buildRachaCard(
                  emoji: '⚡',
                  label: 'Semanas seguidas',
                  value: val,
                  gradientColors: const [Color(0xFF9C27B0), Color(0xFFE91E63)],
                  isInactiveOrRisk: isZeroOrRisk,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta horizontal elegante y bien proporcionada para la racha
  Widget _buildRachaCard({
    required String emoji,
    required String label,
    required String value,
    required List<Color> gradientColors,
    required bool isInactiveOrRisk,
  }) {
    final activeGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );

    final inactiveBg = Colors.black.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isInactiveOrRisk ? inactiveBg : null,
        gradient: isInactiveOrRisk ? null : activeGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isInactiveOrRisk
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          if (!isInactiveOrRisk)
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.35),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          // Icono grande en contenedor redondeado
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: isInactiveOrRisk ? 0.08 : 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Valor grande y Etiqueta descriptiva
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isInactiveOrRisk ? Colors.white70 : Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isInactiveOrRisk
                        ? Colors.white.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
