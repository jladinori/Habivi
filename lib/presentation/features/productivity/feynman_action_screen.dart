import 'package:flutter/material.dart';

class FeynmanActionScreen extends StatefulWidget {
  const FeynmanActionScreen({super.key});

  @override
  State<FeynmanActionScreen> createState() => _FeynmanActionScreenState();
}

class _FeynmanActionScreenState extends State<FeynmanActionScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Explicación Feynman'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explica el tema con palabras sencillas',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Imagina que le estás enseñando a alguien que nunca ha escuchado sobre esto. Usa un lenguaje simple y evita tecnicismos.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    minLines: 15,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu explicación aquí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarExplicacion,
                icon: const Icon(Icons.save),
                label: const Text('Guardar explicación'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _guardarExplicacion() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe una explicación')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Explicación guardada'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }
}
