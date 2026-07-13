import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';
import 'package:habivi/domain/services/achievement_service.dart';
import 'package:habivi/domain/services/habit_completion_service.dart';
import 'package:habivi/presentation/providers/dashboard_providers.dart';
import 'package:habivi/presentation/providers/racha_provider.dart';
import 'package:habivi/presentation/shared/widgets/achievement_unlocked_dialog.dart';
import 'package:habivi/presentation/shared/widgets/attribute_orbs.dart';
import 'package:habivi/presentation/shared/widgets/racha_widget.dart';
import 'package:habivi/presentation/shared/widgets/rive_character.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _marcarHabito(BuildContext context, WidgetRef ref, HabitoConIndice item) async {
    try {
      await HabitCompletionService().toggle(item.index, item.habito);
      final nuevos = await AchievementService().checkAndUnlock();
      ref.invalidate(dashboardDataProvider);
      ref.invalidate(dailyRachaProvider);
      ref.invalidate(weeklyRachaProvider);
      if (!context.mounted) return;
      for (final def in nuevos) {
        await showAchievementUnlockedDialog(context, def);
        if (!context.mounted) return;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al actualizar: $e')));
      }
    }
  }

  String _saludo(String nombre) {
    final hora = DateTime.now().hour;
    final base = hora < 12 ? 'Buenos días' : hora < 19 ? 'Buenas tardes' : 'Buenas noches';
    return nombre.isEmpty ? base : '$base, $nombre';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habivi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push('/achievements'),
            tooltip: 'Logros',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(dashboardDataProvider),
        child: dataAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            padding: const EdgeInsets.all(16),
            children: [Text('Error cargando el dashboard: $e')],
          ),
          data: (data) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(_saludo(data.nombreUsuario), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Center(child: RiveCharacter(mood: data.mood)),
              const SizedBox(height: 16),
              _EnergyCard(energia: data.energia),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: AttributeOrbs(atributos: data.atributos),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(icon: Icons.check_circle, value: '${data.habitosHoy}/${data.totalHabitos}', label: 'Hábitos hoy', color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(icon: Icons.local_fire_department, value: '${data.racha}', label: 'Racha (días)', color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(icon: Icons.stars, value: '${data.puntosEstudio}', label: 'Puntos', color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rachas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      const RachaIndicator(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Hábitos de hoy',
                trailing: TextButton(onPressed: () => context.go('/habits'), child: const Text('Ver todos')),
              ),
              if (data.pendientesHoy.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        const Icon(Icons.celebration, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            data.totalHabitos == 0 ? 'Aún no tienes hábitos. ¡Crea el primero!' : '¡Completaste todo por hoy!',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...data.pendientesHoy.map((item) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(value: false, onChanged: (_) => _marcarHabito(context, ref, item)),
                        title: Text(item.habito.nombreHabito),
                        subtitle: Text(item.habito.aspecto, style: Theme.of(context).textTheme.bodySmall),
                        onTap: () => _marcarHabito(context, ref, item),
                      ),
                    )),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Tareas de hoy',
                trailing: TextButton(onPressed: () => context.go('/tasks'), child: const Text('Ver todas')),
              ),
              if (data.tareasHoy.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Sin tareas para hoy.', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )
              else
                ...data.tareasHoy.map((t) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.event_note),
                        title: Text(t.nombreTarea),
                        subtitle: t.notas.isNotEmpty ? Text(t.notas) : null,
                      ),
                    )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => context.push('/productivity/pomodoro'),
                icon: const Icon(Icons.timer),
                label: const Text('Iniciar Pomodoro'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Logros (${data.logrosDesbloqueados}/${data.totalLogros})',
                trailing: TextButton(onPressed: () => context.push('/achievements'), child: const Text('Ver todos')),
              ),
              if (data.ultimosLogros.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Completa hábitos para desbloquear tu primer logro.', style: Theme.of(context).textTheme.bodyMedium),
                  ),
                )
              else
                Row(
                  children: data.ultimosLogros.map((logro) {
                    final def = achievementCatalog.where((d) => d.id == logro.idLogro).firstOrNull;
                    if (def == null) return const SizedBox.shrink();
                    return Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Icon(def.icono, color: Colors.amber, size: 28),
                              const SizedBox(height: 6),
                              Text(def.titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnergyCard extends StatelessWidget {
  const _EnergyCard({required this.energia});

  final int energia;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final energyColor = energia > 60 ? Colors.green : energia > 30 ? Colors.orange : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Energía', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('$energia%', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: energyColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: energia / 100.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(energyColor),
                  minHeight: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
