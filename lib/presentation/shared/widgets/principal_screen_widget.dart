import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/domain/services/habit_mood_service.dart';
import 'package:habivi/presentation/providers/dashboard_providers.dart';
import 'package:habivi/presentation/providers/dev_mode_provider.dart';
import 'package:habivi/presentation/providers/mood_provider.dart';
import 'package:habivi/presentation/shared/widgets/attribute_orbs.dart';
import 'package:habivi/presentation/shared/widgets/racha_widget.dart';
import 'dart:ui';

// ============================================================
// HomeInfoPanel: el "cubo" arrastrable que vive sobre el video.
// ============================================================
class HomeInfoPanel extends ConsumerWidget {
  // Constructor. "super.key" es un identificador interno que Flutter
  const HomeInfoPanel({super.key});

  // build() es EL método más importante de cualquier widget:
  // y lo que retornes aquí es lo que se ve en pantalla.
  // - context: información de dónde está el widget en el árbol
  // - ref: la "llave" para leer providers de Riverpod
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() = "lee este provider Y re-dibújame si cambia".
    // O sea: si mañana la energía sube, este panel se actualiza solo.
    final dashboardAsync =
        ref.watch(dashboardDataProvider); // hábitos, logros, atributos...
    final moodAsync =
        ref.watch(moodPercentageProvider); // el % de energía (0.0 a 1.0)

    // El MISMO color que decide el video de fondo (ambos salen de
    // moodPercentage), así el glow siempre combina con el video puesto.
    final moodColor = moodAsync.maybeWhen(
      data: (mood) => HabitMoodService.getGlowColor(mood),
      orElse: () => Colors.teal, // color neutro mientras carga
    );

    // DraggableScrollableSheet 
    // un panel anclado abajo que el usuario arrastra para expandir/colapsar.
    return DraggableScrollableSheet(
      // Los tamaños son FRACCIONES de la altura de la pantalla (0.0 a 1.0).
      // Por eso es responsivo: 0.30 = "30% de la pantalla" en CUALQUIER celular.
      initialChildSize: 0.30, // cuánto ocupa al abrir la app (colapsado)
      minChildSize: 0.30, // lo mínimo que puede encogerse
      maxChildSize: 0.60, // lo máximo al expandir → nunca tapa todo el video

      // snap: true = el panel no se queda a medio camino; al soltar el dedo
      // "salta" al tamaño más cercano de snapSizes (o cerrado o abierto).
      snap: true,
      snapSizes: const [0.30, 0.60],

      // builder es una función que Flutter llama para construir el contenido.
      // Nos regala "scrollController": el objeto que conecta el gesto de
      // arrastre con la expansión del panel. SIN ÉL EL ARRASTRE NO FUNCIONA.
      builder: (context, scrollController) {
        // Center: centra su hijo horizontalmente (importa en pantallas anchas)
        return Center(
          // ConstrainedBox: le pone un límite de tamaño a su hijo.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            // Container: la "caja" visual. Aquí definimos el margen,
            child: AnimatedContainer(
              // 800ms: cuando cambia el video, el glow se funde suave
              // del color viejo al nuevo
              duration: const Duration(milliseconds: 800),
              margin: const EdgeInsets.symmetric(horizontal: 12),
              curve: Curves.easeInOut,

              // decoration = la apariencia de la caja
              decoration: BoxDecoration(
                borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
                //diseno para el widget con sombras
                //halo difuso con el color del estado de ánimo (glow)
                boxShadow: [
                  // halo grande y difuso: el "aire luminoso"
                  BoxShadow(
                    color: moodColor.withValues(alpha: 0.35),
                    blurRadius: 45,
                    spreadRadius: 5,
                  ),
                  // brillo fino pegado al borde: efecto neón
                  BoxShadow(
                    color: moodColor.withValues(alpha: 0.25),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              ),
            
              // ClipRRect: "recorta" el contenido con las mismas esquinas redondeadas. Sin esto, al hacer scroll el contenido se borra.
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), // desenfoque del fondo
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                     begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // alphas altos = vidrio blanco lechoso; bajarlos
                      // vuelve el panel más transparente/oscuro
                      Colors.white.withValues(alpha: 0.8), // arriba
                      Color.lerp(Colors.white, moodColor,  0.3)!.withValues(alpha:.6), // abajo
                    ],
                  ),
                   border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5)),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                 ),
                // ScrollConfiguration: por defecto Flutter Web solo permite
                // arrastrar con DEDO.
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch, // dedo
                     PointerDeviceKind.mouse, // clic sostenido del mouse
                    PointerDeviceKind.trackpad, // trackpad del portátil
                  },
                ),
                  // ListView: una lista con scroll vertical.
                  // Le pasamos el scrollController del builder: ESA línea es la que hace que arrastrar el contenido mueva el panel.
              child: ListView(
                controller: scrollController,
                  // fromLTRB = Left, Top, Right, Bottom (izq, arriba, der, abajo)
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),

                // children = la lista de widgets que van uno debajo de otro
                children: [
                  // ---- El "asa": la barrita gris
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26, // negro suave: visible sobre el vidrio claro
                        borderRadius: BorderRadius.circular(2),
                      ),
                     ),
                  ),
                  // PARTE SIEMPRE VISIBLE (cabe en el 30% colapsado)
                  //parte de la racha de habitos, que se encuentra en el widget RachaIndicator
                  const RachaIndicator(),
                  // SizedBox sin hijo
                  const SizedBox(height: 16),
                  // La barra de energía. moodAsync.when() maneja los 3 casos:
                  moodAsync.when(
                    skipLoadingOnReload: true,
                    // mientras carga: no muestres nada (caja de tamaño 0)
                  
                    loading: () => const SizedBox.shrink(),
                    // si hay error: tampoco muestres nada
                    // (los _ significan "recibo estos parámetros pero los ignoro")
                    error: (_, __) => const SizedBox.shrink(),
                    // cuando llegan los datos: dibuja la barra
                    data: (mood) => _EnergyBar(moodPercentage: mood),
                  ),

                  const SizedBox(height: 20),
                  // PARTE ESCONDIDA: queda por debajo del pliegue y solo se ve al arrastrar el panel hacia arriba
                  dashboardAsync.when(
                    loading: () =>
                      const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text(
                        'Error: $e',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      data: (data) => Column(
                        // alinea los hijos a la izquierda
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // bolas de energía
                          // data.atributos viene del dashboardDataProvider
                          AttributeOrbs(atributos: data.atributos),
                          const SizedBox(height: 20),
                          // Filas de info extra. _InfoRow es un widget
                          _InfoRow(
                            icon: Icons.check_circle_outline,
                            label: 'Hábitos hoy',
                            // '${a}/${b}' junta dos números en un texto: "3/5"
                            value: '${data.habitosHoy}/${data.totalHabitos}',
                          ),

                          // _InfoRow(
                          //   icon: Icons.emoji_events_outlined,
                          //   label: 'Logros',
                          //   value:
                          //     '${data.logrosDesbloqueados}/${data.totalLogros}',
                          // ),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Puntos de estudio',
                            value: '${data.puntosEstudio}',
                          ),
                        ],
                      ),
                    ),
                    const _DevTimeControls(), // controles de tiempo del modo dev
                  ],
                  
                ),
              ),
            ),
          ),
        ),
        ),
      ),
      );
    },
  );
  }
}
// _EnergyBar: la barra de energía (emoji + barra + porcentaje).
class _EnergyBar extends StatelessWidget {
  // required = parámetro obligatorio al crear el widget
  const _EnergyBar({required this.moodPercentage});

  // El dato que recibe: un número entre 0.0 (0%) y 1.0 (100%)
  final double moodPercentage;

  @override
  Widget build(BuildContext context) {
    // Le preguntamos a tu servicio existente el color según el ánimo
    final moodColor = HabitMoodService.getGlowColor(moodPercentage);
    // Y el texto del estado, ej: "Feliz 😊"
    final moodStateStr = HabitMoodService.getMoodState(moodPercentage);
    // Del texto sacamos solo el emoji: split(' ') corta por espacios
    // y .last toma el último pedazo ("😊"). Si viene vacío, usamos 😐
    final emoji = moodStateStr.isNotEmpty ? moodStateStr.split(' ').last : '😐';

    // Row = widgets en FILA (horizontal). Column sería en vertical.
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12), // espacio horizontal
        // Expanded = "ocupa todo el espacio horizontal que sobre".
        // Así la barra se estira y el emoji y el % quedan a los lados.
        // Esto también es parte de lo responsivo: la barra se adapta
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(6), // barra con puntas redondeadas
            child: LinearProgressIndicator(
              value: moodPercentage, // qué tan llena está (0.0 a 1.0)
              backgroundColor:
                  Colors.black.withValues(alpha: 0.08), // fondo de la barra
              valueColor:
                  AlwaysStoppedAnimation(moodColor), // color del relleno
              minHeight: 8, // grosor de la barra
            ),
          ),
        ),
        const SizedBox(width: 10),

        // El porcentaje como texto: 0.75 * 100 = 75, .toInt() quita decimales
        Text(
          '${(moodPercentage * 100).toInt()}%',
          style: TextStyle(
            color: moodColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// _InfoRow: una fila reutilizable de "icono + etiqueta + valor".
class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon; // el iconito de la izquierda
  final String label; // el texto descriptivo ("Logros")
  final String value; // el dato ("5/20")

  @override
  Widget build(BuildContext context) {
    return Padding(
      // espacio arriba y abajo de cada fila para que respiren
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          // Expanded empuja el valor hasta la derecha
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.black54)),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
// Controles del modo desarrollador: botones para avanzar el reloj.
// Solo aparecen si el modo dev está activo en Configuración.
// Controles del modo desarrollador con estilo glass, a juego con el panel.
class _DevTimeControls extends ConsumerWidget {
  const _DevTimeControls();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devMode = ref.watch(devModeProvider);
    if (!devMode) return const SizedBox.shrink(); // oculto si está apagado

    final offset = ref.watch(timeOffsetProvider);
    final notifier = ref.read(timeOffsetProvider.notifier);

    // Texto amigable del reloj
    String textoOffset() {
      if (offset.inHours == 0) return 'Reloj en hora real';
      final d = offset.inDays;
      final h = offset.inHours % 24;
      return d > 0
          ? 'Reloj adelantado: +${d}d ${h}h'
          : 'Reloj adelantado: +${h}h';
    }

    // Una "píldora" reutilizable
    Widget pill(String label, Duration d, {bool reset = false}) {
      final bg = reset
          ? Colors.red.withValues(alpha: 0.15)
          : Colors.white.withValues(alpha: 0.30);
      final borde = reset
          ? Colors.red.withValues(alpha: 0.40)
          : Colors.white.withValues(alpha: 0.55);
      final texto = reset ? Colors.red.shade700 : Colors.black87;

      return Material(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => reset ? notifier.reset() : notifier.avanzar(d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borde),
            ),
            child: Text(
              label,
              style: TextStyle(
                  color: texto, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.developer_mode,
                    color: Colors.black54, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Modo desarrollador',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(textoOffset(),
              style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              pill('+24 h', const Duration(hours: 24)),
              pill('+1 semana', const Duration(days: 7)),
              pill('Reset', Duration.zero, reset: true),
            ],
          ),
        ],
      ),
    );
  }
}
