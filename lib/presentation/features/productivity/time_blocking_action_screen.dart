import 'package:flutter/material.dart';

class TimeBlockingActionScreen extends StatefulWidget {
  const TimeBlockingActionScreen({super.key});

  @override
  State<TimeBlockingActionScreen> createState() => _TimeBlockingActionScreenState();
}

class _TimeBlockingActionScreenState extends State<TimeBlockingActionScreen> {
  List<_Bloque> bloques = [];

  @override
  void initState() {
    super.initState();
    _agregarBloqueDefault();
  }

  void _agregarBloqueDefault() {
    setState(() {
      bloques.add(_Bloque(
        hora: '09:00',
        actividad: '',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📅 Crear bloques'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planifica tu día',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...bloques.asMap().entries.map((e) {
              final index = e.key;
              final bloque = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: bloque.horaController,
                            decoration: InputDecoration(
                              hintText: 'HH:MM',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: bloque.actividadController,
                            decoration: InputDecoration(
                              hintText: 'Actividad',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            setState(() {
                              bloques[index].horaController.dispose();
                              bloques[index].actividadController.dispose();
                              bloques.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _agregarBloqueDefault,
              icon: const Icon(Icons.add),
              label: const Text('Agregar bloque'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _guardarBloques,
                icon: const Icon(Icons.save),
                label: const Text('Guardar bloques'),
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

  void _guardarBloques() {
    if (bloques.isEmpty || bloques.any((b) => b.actividadController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los bloques')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Bloques guardados'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (var bloque in bloques) {
      bloque.horaController.dispose();
      bloque.actividadController.dispose();
    }
    super.dispose();
  }
}

class _Bloque {
  late TextEditingController horaController;
  late TextEditingController actividadController;

  _Bloque({required String hora, required String actividad}) {
    horaController = TextEditingController(text: hora);
    actividadController = TextEditingController(text: actividad);
  }
}
