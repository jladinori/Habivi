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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // === RACHA SEMANAL (Izquierda) ===
          Expanded(
            child: weeklyRachaAsync.when(
              loading: () => _buildRachaSquare(
                label: 'Semanas',
                value: '–',
                color: Colors.purple,
              ),
              error: (_, __) => _buildRachaSquare(
                label: 'Semanas',
                value: '0',
                color: Colors.purple,
              ),
              data: (racha) {
                if (racha == null) {
                  return _buildRachaSquare(
                    label: 'Semanas',
                    value: '0',
                    color: Colors.purple,
                  );
                }
                return _buildRachaSquare(
                  label: 'Semanas',
                  value: '${racha.cantidad}',
                  color: racha.enRiesgo ? Colors.grey : Colors.purple,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          
          // === RACHA DIARIA (Derecha) ===
          Expanded(
            child: dailyRachaAsync.when(
              loading: () => _buildRachaSquare(
                label: 'Días',
                value: '–',
                color: Colors.red,
              ),
              error: (_, __) => _buildRachaSquare(
                label: 'Días',
                value: '0',
                color: Colors.red,
              ),
              data: (racha) {
                if (racha == null) {
                  return _buildRachaSquare(
                    label: 'Días',
                    value: '0',
                    color: Colors.red,
                  );
                }
                return _buildRachaSquare(
                  label: 'Días',
                  value: '${racha.cantidad}',
                  color: Colors.red,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un cuadrado de racha con etiqueta y número
  Widget _buildRachaSquare({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
