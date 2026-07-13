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
          SizedBox(
            width: 100,
            child: weeklyRachaAsync.when(
              loading: () => _buildRachaSquare(emoji: '🔥', label: 'Semanas', value: '–', color: Colors.purple),
              error: (_, __) => _buildRachaSquare(emoji: '🔥', label: 'Semanas', value: '0', color: Colors.purple),
              data: (racha) => _buildRachaSquare(
                emoji: '🔥',
                label: 'Semanas',
                value: '${racha?.cantidad ?? 0}',
                color: (racha?.enRiesgo ?? false) ? Colors.grey : Colors.purple,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: dailyRachaAsync.when(
              loading: () => _buildRachaSquare(emoji: '🔥', label: 'Días', value: '–', color: Colors.red),
              error: (_, __) => _buildRachaSquare(emoji: '🔥', label: 'Días', value: '0', color: Colors.red),
              data: (racha) => _buildRachaSquare(
                emoji: '🔥',
                label: 'Días',
                value: '${racha?.cantidad ?? 0}',
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRachaSquare({required String emoji, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
