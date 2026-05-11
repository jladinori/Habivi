// usuario_provider.dart

import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/usuario.dart';

class UsuarioProvider {

  late Box<Usuario> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<Usuario>('usuarioBox');
    return box.isOpen;
  }

  Future<bool> anadirUsuario(Usuario usuario) async {
    await box.add(usuario);
    return true;
  }

  Map<dynamic, Usuario> leerUsuario() {
    return box.toMap();
  }

  Future<bool> eliminarUsuario(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarUsuario(int indice, Usuario usuario) async {
    await box.putAt(indice, usuario);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}