import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:habivi/core/utils/file_export.dart';
import 'package:habivi/domain/services/backup_service.dart';

class DataSettingsScreen extends StatefulWidget {
  const DataSettingsScreen({super.key});

  @override
  State<DataSettingsScreen> createState() => _DataSettingsScreenState();
}

class _DataSettingsScreenState extends State<DataSettingsScreen> {
  final _backupService = BackupService();
  bool _exporting = false;
  bool _importing = false;

  Future<void> _exportar() async {
    setState(() => _exporting = true);
    try {
      final json = await _backupService.exportToJson();
      final filename = 'habivi_backup_${_dateTag()}.json';
      await saveFile(json, filename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb
                ? '✓ Respaldo descargado como $filename'
                : '✓ Respaldo listo — compártelo donde quieras'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al exportar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _importar() async {
    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final bytes = result.files.first.bytes;
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo leer el archivo'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final json = String.fromCharCodes(bytes);
      await _backupService.importFromJson(json);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('✓ Respaldo restaurado'),
            content: const Text(
              'Los datos han sido importados correctamente.\n'
              'Reinicia la app para ver los cambios reflejados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al importar: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  String _dateTag() {
    final now = DateTime.now();
    return '${now.year}${_p(now.month)}${_p(now.day)}_${_p(now.hour)}${_p(now.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Datos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(icon: Icons.download, text: 'Exportar respaldo', cs: cs),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.save_alt, color: cs.primary),
              title: const Text('Guardar copia local'),
              subtitle: Text(kIsWeb
                  ? 'Descarga un archivo .json con todos tus datos'
                  : 'Genera un archivo .json que puedes guardar o compartir'),
              trailing: _exporting
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: _exporting ? null : _exportar,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.cloud_upload, color: cs.primary),
              title: const Text('Compartir a Google Drive'),
              subtitle: const Text('Exporta y comparte el archivo vía Drive, WhatsApp u otras apps'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _exportar,
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(icon: Icons.upload, text: 'Importar respaldo', cs: cs),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.file_open, color: cs.primary),
              title: const Text('Restaurar desde archivo'),
              subtitle: const Text('Selecciona un archivo .json de respaldo para restaurar todos los datos'),
              trailing: _importing
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.chevron_right),
              onTap: _importing ? null : _importar,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: cs.errorContainer.withValues(alpha: 0.3),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: cs.error, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Importar un respaldo reemplazará todos los datos actuales. '
                      'Se recomienda hacer una copia antes de restaurar.',
                      style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme cs;

  const _SectionTitle({required this.icon, required this.text, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: cs.primary),
        const SizedBox(width: 10),
        Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
