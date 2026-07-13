import 'package:flutter/material.dart';

class SpacedRepetitionActionScreen extends StatefulWidget {
  const SpacedRepetitionActionScreen({super.key});

  @override
  State<SpacedRepetitionActionScreen> createState() => _SpacedRepetitionActionScreenState();
}

class _SpacedRepetitionActionScreenState extends State<SpacedRepetitionActionScreen> {
  final _temaController = TextEditingController();
  final List<int> _intervalos = [1, 3, 7, 14, 30];
  late List<DateTime> _proximosRepasos;

  @override
  void initState() {
    super.initState();
    _calcularRepasos();
  }

  void _calcularRepasos() {
    final hoy = DateTime.now();
    _proximosRepasos = _intervalos.map((dias) => hoy.add(Duration(days: dias))).toList();
  }

  @override
  void dispose() {
    _temaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Programar Repasos'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema a repasar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _temaController,
              decoration: InputDecoration(
                hintText: 'Ej: Verbos irregulares en inglés',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Próximos repasos programados',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ..._proximosRepasos.asMap().entries.map((e) {
              final index = e.key;
              final fecha = e.value;
              final dias = _intervalos[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Repaso $dias - ${_formatDate(fecha)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'en $dias día${dias > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarRepasos,
                icon: const Icon(Icons.save),
                label: const Text('Guardar programa'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _guardarRepasos() {
    if (_temaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa el tema a repasar')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Programa de repasos guardado'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
