import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/data/repositories/user_repository.dart';
import 'package:habivi/data/models/usuario.dart';
import 'package:habivi/presentation/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late UserRepository _userRepo;
  Usuario? _usuario;
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userRepo = UserRepository();
    _cargarUsuario();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  Future<void> _cargarUsuario() async {
    try {
      final usuarios = await _userRepo.readAll();
      if (usuarios.isNotEmpty) {
        final entry = usuarios.entries.first;
        _usuario = entry.value;
        _nombreController.text = _usuario!.nombre;
        _apellidoController.text = _usuario!.apellido;
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  Future<void> _guardarNombre() async {
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre no puede estar vacío')),
      );
      return;
    }
    try {
      if (_usuario != null) {
        _usuario!.nombre = nombre;
        _usuario!.apellido = apellido;
        final usuarios = await _userRepo.readAll();
        if (usuarios.isNotEmpty) {
          final index = usuarios.keys.first;
          await _userRepo.updateAt(index, _usuario!);
        }
      } else {
        final nuevoUsuario = Usuario(
          idUsuario: DateTime.now().millisecondsSinceEpoch,
          nombre: nombre,
          apellido: apellido,
          energia: 100,
          energiaMax: 100,
          puntosProductividad: 0,
          estadoPersonaje: 'neutral',
          fechaInicio: DateTime.now().toIso8601String(),
        );
        await _userRepo.add(nuevoUsuario);
        _usuario = nuevoUsuario;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✓ Nombre guardado')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver a Inicio',
          onPressed: () => context.go('/home'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Perfil',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _apellidoController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _guardarNombre,
                      child: const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SwitchListTile(
                secondary: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('Modo oscuro'),
                subtitle: Text(isDark ? 'Tema oscuro activado' : 'Tema claro activado'),
                value: isDark,
                onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.storage_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Datos'),
              subtitle: const Text('Respaldar, restaurar y exportar datos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/data'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.login,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Iniciar sesión'),
              subtitle: const Text('Opcional, disponible solo en configuración'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/login'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Acerca de Habivi'),
              subtitle: const Text('Versión 1.0.0'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Habivi',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'App de productividad gamificada para crecimiento personal.',
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.feedback_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Enviar feedback'),
              subtitle: const Text('angel.data.dev@gmail.com'),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback: angel.data.dev@gmail.com'),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.note_alt_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Notas'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/notes'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Habivi v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
