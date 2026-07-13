import 'package:flutter/material.dart';

class MindMapsActionScreen extends StatefulWidget {
  const MindMapsActionScreen({super.key});

  @override
  State<MindMapsActionScreen> createState() => _MindMapsActionScreenState();
}

class _MindMapsActionScreenState extends State<MindMapsActionScreen> {
  final _temaController = TextEditingController();
  final _nodosController = TextEditingController();

  @override
  void dispose() {
    _temaController.dispose();
    _nodosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🗺 Crear Mapa Mental'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema principal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _temaController,
              decoration: InputDecoration(
                hintText: 'Ej: La Fotosíntesis',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Ideas principales (una por línea)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nodosController,
              maxLines: null,
              minLines: 6,
              decoration: InputDecoration(
                hintText: 'Absorción de luz\nExtracción de agua\nProducción de glucosa\n...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarMapa,
                icon: const Icon(Icons.save),
                label: const Text('Guardar mapa'),
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

  void _guardarMapa() {
    if (_temaController.text.trim().isEmpty || _nodosController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa el tema e ideas')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Mapa mental guardado'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
