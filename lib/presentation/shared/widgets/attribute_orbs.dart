import 'package:flutter/material.dart';
import 'package:habivi/domain/services/energy_service.dart';

class AttributeOrbs extends StatelessWidget {
  const AttributeOrbs({super.key, required this.atributos});

  final EnergiaAtributos atributos;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _Orb(label: 'Cuerpo', valor: atributos.cuerpo, activo: atributos.tieneCuerpo, icon: Icons.fitness_center, color: Colors.orange),
        _Orb(label: 'Mente', valor: atributos.mente, activo: atributos.tieneMente, icon: Icons.psychology, color: Colors.lightBlue),
        _Orb(label: 'Alma', valor: atributos.alma, activo: atributos.tieneAlma, icon: Icons.spa, color: Colors.purpleAccent),
      ],
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.label, required this.valor, required this.activo, required this.icon, required this.color});

  final String label;
  final int valor;
  final bool activo;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final displayColor = activo ? color : Colors.white24;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: activo ? valor / 100.0 : 0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, progress, _) => SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    backgroundColor: displayColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(displayColor),
                  ),
                ),
              ),
              Icon(icon, color: displayColor, size: 28),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(activo ? '$valor%' : 'Sin hábitos', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: activo ? displayColor : Colors.white38)),
      ],
    );
  }
}
