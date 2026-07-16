import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habivi/domain/services/habit_mood_service.dart';
import 'package:habivi/presentation/providers/dashboard_providers.dart';
import 'package:habivi/presentation/providers/mood_provider.dart';
import 'package:habivi/presentation/shared/widgets/attribute_orbs.dart';
import 'package:habivi/presentation/shared/widgets/racha_widget.dart';

// ============================================================
// HomeInfoPanel: el "cubo" arrastrable que vive sobre el video.
//
// "class ... extends ConsumerWidget" significa: esto es un widget
// que puede LEER providers de Riverpod (por eso Consumer).
// Usamos ConsumerWidget en vez de StatelessWidget porque
// necesitamos ref.watch() para leer la energía y las rachas.
// ============================================================
class HomeInfoPanel extends ConsumerWidget {
  // Constructor. "super.key" es un identificador interno que Flutter
  // usa para saber qué widget es cuál cuando re-dibuja. Siempre se pone.
  const HomeInfoPanel({super.key});

  // build() es EL método más importante de cualquier widget:
  // Flutter lo llama cada vez que necesita dibujar este widget,
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

    // DraggableScrollableSheet es el widget MÁGICO de todo esto:
    // un panel anclado abajo que el usuario arrastra para expandir/colapsar.
    // Es el mismo patrón del panel de Google Maps.
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
          // Aquí: "nunca más ancho que 480 píxeles". En un celular no afecta
          // (la pantalla es más angosta), pero en web/PC evita que el panel
          // se estire feo a lo ancho de todo el monitor.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),

            // Container: la "caja" visual. Aquí definimos el margen,
            // el fondo, los bordes redondeados... el look del cubo.
            child: Container(
              // margin = espacio POR FUERA de la caja (separa del borde de pantalla)
              margin: const EdgeInsets.symmetric(horizontal: 12),

              // decoration = la apariencia de la caja
              decoration: BoxDecoration(
                // Negro semi-transparente (alpha 0.45 = 45% opaco)
                // para que el video se vea un poquito a través del panel
                color: Colors.black.withValues(alpha: 0.45),

                // Esquinas redondeadas SOLO arriba (24 px de radio),
                // porque abajo el panel se pega al borde de la pantalla
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),

                // Un borde blanco sutil (15% opaco) para separarlo del video
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),

              // ClipRRect: "recorta" el contenido con las mismas esquinas
              // redondeadas. Sin esto, al hacer scroll el contenido se
              // saldría por las esquinas del cubo.
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),

                // ScrollConfiguration: por defecto Flutter Web solo permite
                // arrastrar con DEDO. Aquí le decimos "también acepta arrastre
                // con clic de mouse y trackpad", que fue lo que pediste.
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch, // dedo
                      PointerDeviceKind.mouse, // clic sostenido del mouse
                      PointerDeviceKind.trackpad, // trackpad del portátil
                    },
                  ),

                  // ListView: una lista con scroll vertical.
                  // Le pasamos el scrollController del builder: ESA línea es
                  // la que hace que arrastrar el contenido mueva el panel.
                  child: ListView(
                    controller: scrollController,

                    // padding = espacio POR DENTRO de la caja
                    // fromLTRB = Left, Top, Right, Bottom (izq, arriba, der, abajo)
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),

                    // children = la lista de widgets que van uno debajo de otro
                    children: [
                      // ---- El "asa": la barrita gris que indica "arrástrame" ----
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white38, // blanco al 38% de opacidad
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // ================================================
                      // PARTE SIEMPRE VISIBLE (cabe en el 30% colapsado)
                      // ================================================

                      // Tus rachas (widget que YA existe en tu proyecto)
                      const RachaIndicator(),

                      // SizedBox sin hijo = simplemente un espacio en blanco
                      const SizedBox(height: 16),

                      // La barra de energía. moodAsync.when() maneja los 3 casos:
                      moodAsync.when(
                        // mientras carga: no muestres nada (caja de tamaño 0)
                        loading: () => const SizedBox.shrink(),
                        // si hay error: tampoco muestres nada
                        // (los _ significan "recibo estos parámetros pero los ignoro")
                        error: (_, __) => const SizedBox.shrink(),
                        // cuando llegan los datos: dibuja la barra
                        data: (mood) => _EnergyBar(moodPercentage: mood),
                      ),

                      const SizedBox(height: 20),

                      // ================================================
                      // PARTE "ESCONDIDA": queda por debajo del pliegue
                      // y solo se ve al arrastrar el panel hacia arriba
                      // ================================================
                      dashboardAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text(
                          'Error: $e',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        data: (data) => Column(
                          // alinea los hijos a la izquierda
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tus bolas de energía (widget que YA existe).
                            // data.atributos viene del dashboardDataProvider
                            AttributeOrbs(atributos: data.atributos),
                            const SizedBox(height: 20),

                            // Filas de info extra. _InfoRow es un widget
                            // nuestro definido más abajo en este archivo
                            _InfoRow(
                              icon: Icons.check_circle_outline,
                              label: 'Hábitos hoy',
                              // '${a}/${b}' junta dos números en un texto: "3/5"
                              value: '${data.habitosHoy}/${data.totalHabitos}',
                            ),
                            _InfoRow(
                              icon: Icons.emoji_events_outlined,
                              label: 'Logros',
                              value:
                                  '${data.logrosDesbloqueados}/${data.totalLogros}',
                            ),
                            _InfoRow(
                              icon: Icons.school_outlined,
                              label: 'Puntos de estudio',
                              value: '${data.puntosEstudio}',
                            ),
                          ],
                        ),
                      ),
                    ],
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

// ============================================================
// _EnergyBar: la barra de energía (emoji + barra + porcentaje).
// Es la MISMA que tenías en home_screen, solo que extraída aquí.
// Empieza con _ = privada, solo se usa en este archivo.
// Es StatelessWidget (no Consumer) porque no lee providers:
// el porcentaje se lo pasan ya listo por el constructor.
// ============================================================
class _EnergyBar extends StatelessWidget {
  // required = parámetro obligatorio al crear el widget
  const _EnergyBar({required this.moodPercentage});

  // El dato que recibe: un número entre 0.0 (0%) y 1.0 (100%)
  final double moodPercentage;

  @override
  Widget build(BuildContext context) {
    // Le preguntamos a tu servicio existente el color según el ánimo
    final moodColor = HabitMoodService.getMoodColor(moodPercentage);
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
        // sola al ancho de cualquier pantalla.
        Expanded(
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(6), // barra con puntas redondeadas
            child: LinearProgressIndicator(
              value: moodPercentage, // qué tan llena está (0.0 a 1.0)
              backgroundColor:
                  Colors.white.withValues(alpha: 0.1), // fondo de la barra
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

// ============================================================
// _InfoRow: una fila reutilizable de "icono + etiqueta + valor".
// La definimos una vez y la usamos 3 veces arriba. Esa es la
// gracia de los widgets: piezas reutilizables.
// ============================================================
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
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          // Expanded empuja el valor hasta la derecha
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white70)),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
