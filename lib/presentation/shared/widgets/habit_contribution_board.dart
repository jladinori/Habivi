import 'package:flutter/material.dart';
import 'package:habivi/core/utils/app_clock.dart';

class HabitContributionBoard extends StatefulWidget {
  final List<String> fechasCompletadas;
  final Color baseColor;
  final List<String>? restDays;

  const HabitContributionBoard({
    super.key,
    required this.fechasCompletadas,
    required this.baseColor,
    this.restDays,
  });

  @override
  State<HabitContributionBoard> createState() => _HabitContributionBoardState();
}

class _HabitContributionBoardState extends State<HabitContributionBoard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Deslizar automáticamente al final (donde está la semana actual) tras cargar la vista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ahora = AppClock.now();
    final hoy = DateTime(ahora.year, ahora.month, ahora.day);

    const numColumnas = 53; // 53 semanas para cubrir todo el año calendario

    // Encontrar el lunes de la semana actual (1 = Lunes, 7 = Domingo)
    final lunesEstaSemana = hoy.subtract(Duration(days: hoy.weekday - 1));

    // El primer lunes es 52 semanas antes del lunes de esta semana
    final primerLunes = lunesEstaSemana.subtract(const Duration(days: (numColumnas - 1) * 7));

    return Container(
      height: 86, // Altura segura para celdas de 8x8 y márgenes (7 * 11px = 77px)
      alignment: Alignment.center,
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(numColumnas, (colIndex) {
              final lunesSemana = primerLunes.add(Duration(days: colIndex * 7));
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1.5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(7, (rowIndex) {
                    final dia = lunesSemana.add(Duration(days: rowIndex));
                    final fechaStr =
                        '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
                    final completado = widget.fechasCompletadas.contains(fechaStr);
                    final esRestDay = widget.restDays != null && widget.restDays!.contains(fechaStr);
                    final esHoy = dia.year == hoy.year &&
                        dia.month == hoy.month &&
                        dia.day == hoy.day;
                    final restColor = const Color(0xFF80D8FF);
                    final backgroundColor = esRestDay
                        ? restColor
                        : (completado
                            ? widget.baseColor
                            : widget.baseColor.withValues(alpha: 0.12));
 
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(vertical: 1.5),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(2.0),
                        border: esHoy
                            ? Border.all(
                                color: esRestDay
                                    ? restColor.withValues(alpha: 0.95)
                                    : Colors.white.withValues(alpha: 0.8),
                                width: 1.0,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
