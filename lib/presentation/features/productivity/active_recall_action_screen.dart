import 'package:flutter/material.dart';

class ActiveRecallActionScreen extends StatefulWidget {
  const ActiveRecallActionScreen({super.key});

  @override
  State<ActiveRecallActionScreen> createState() => _ActiveRecallActionScreenState();
}

class _ActiveRecallActionScreenState extends State<ActiveRecallActionScreen> {
  final _preguntaController = TextEditingController();
  final _respuestaController = TextEditingController();

  @override
  void dispose() {
    _preguntaController.dispose();
    _respuestaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔄 Práctica de Recall'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pregunta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _preguntaController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: '¿Cuál es la pregunta?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu respuesta',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _respuestaController,
              maxLines: null,
              minLines: 4,
              decoration: InputDecoration(
                hintText: 'Intenta responder de memoria...',
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
                onPressed: _guardarPractica,
                icon: const Icon(Icons.check_circle),
                label: const Text('Guardar práctica'),
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

  void _guardarPractica() {
    if (_preguntaController.text.trim().isEmpty || _respuestaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa la pregunta y respuesta')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Práctica guardada'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
