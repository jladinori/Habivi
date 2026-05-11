import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:flutter_habivi_bd/habivi_bd/cuenta.dart';

class CuentaProvider {

  late Box<Cuenta> box;

  Future<bool> inicializarBox() async {
    final directorio = await getApplicationDocumentsDirectory();
    Hive.init(directorio.path);
    box = await Hive.openBox<Cuenta>('cuentaBox');
    return box.isOpen;
  }

  Future<bool> anadirCuenta(Cuenta cuenta) async {
    await box.add(cuenta);
    return true;
  }

  Map<dynamic, Cuenta> leerCuenta() {
    return box.toMap();
  }

  Future<bool> eliminarCuenta(int indice) async {
    await box.deleteAt(indice);
    return true;
  }

  Future<bool> actualizarCuenta(int indice, Cuenta cuenta) async {
    await box.putAt(indice, cuenta);
    return true;
  }

  Future<void> dispose() async {
    await box.close();
  }
}