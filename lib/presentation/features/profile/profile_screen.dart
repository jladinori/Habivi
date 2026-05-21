import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:habivi/presentation/shared/widgets/placeholder_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const PlaceholderCard(
          title: 'Perfil universitario',
          subtitle: 'Usuario, cuenta y preferencias.',
        ),
        const SizedBox(height: 12),
        ListTile(
          leading: const Icon(Icons.note_alt_outlined),
          title: const Text('Notas'),
          onTap: () => context.push('/notes'),
        ),
      ],
    );
  }
}
