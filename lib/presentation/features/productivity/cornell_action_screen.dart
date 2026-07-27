import 'package:flutter/material.dart';

class CornellActionScreen extends StatefulWidget {
  const CornellActionScreen({super.key});

  @override
  State<CornellActionScreen> createState() => _CornellActionScreenState();
}

class _CornellActionScreenState extends State<CornellActionScreen> {
  final _cuestionesController = TextEditingController();
  final _notasController = TextEditingController();
  final _resumenController = TextEditingController();

  @override
  void dispose() {
    _cuestionesController.dispose();
    _notasController.dispose();
    _resumenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📝 Hoja Cornell'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cuestiones (30% izquierda)
            Text(
              'Cuestiones clave',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cuestionesController,
              maxLines: null,
              minLines: 4,
              decoration: InputDecoration(
                hintText: '¿Qué preguntas importantes cubre esto?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 20),

            // Notas (70% derecha)
            Text(
              'Notas de clase/lectura',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notasController,
              maxLines: null,
              minLines: 6,
              decoration: InputDecoration(
                hintText: 'Escribe las notas principales...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
            const SizedBox(height: 20),

            // Resumen (inferior)
            Text(
              'Resumen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _resumenController,
              maxLines: null,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Resumen breve de lo más importante...',
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
                onPressed: _guardarHojaCornell,
                icon: const Icon(Icons.save),
                label: const Text('Guardar hoja Cornell'),
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

  void _guardarHojaCornell() {
    if (_notasController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa notas')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Hoja Cornell guardada'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
