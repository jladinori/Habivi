import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider que almacena la acción del FAB para la pantalla activa.
/// Cada pantalla lo establece en su build(). Si es null, no se muestra FAB.
final fabActionProvider = StateProvider<VoidCallback?>((ref) => null);
