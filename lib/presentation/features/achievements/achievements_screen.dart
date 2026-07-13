import 'package:flutter/material.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/domain/gamification/achievement_definitions.dart';
import 'package:habivi/domain/services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, Logro> _desbloqueados = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final logros = await AchievementService().unlockedLogros();
      if (mounted) {
        setState(() {
          _desbloqueados = {for (final l in logros) l.idLogro: l};
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logros (${_desbloqueados.length}/${achievementCatalog.length})'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: achievementCatalog.length,
              itemBuilder: (context, index) {
                final def = achievementCatalog[index];
                final logro = _desbloqueados[def.id];
                final unlocked = logro != null;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: unlocked ? Colors.amber.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(unlocked ? def.icono : Icons.lock, size: 36, color: unlocked ? Colors.amber : Colors.white24),
                        ),
                        const SizedBox(height: 12),
                        Text(def.titulo, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: unlocked ? null : Colors.white38)),
                        const SizedBox(height: 4),
                        Text(def.descripcion, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: unlocked ? null : Colors.white24)),
                        if (unlocked) ...[
                          const SizedBox(height: 4),
                          Text(logro.fechaDesbloqueo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.amber, fontSize: 10)),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
