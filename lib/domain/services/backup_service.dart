import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:habivi/core/constants/hive_box_names.dart';
import 'package:habivi/data/models/backup.dart';
import 'package:habivi/data/models/cuenta.dart';
import 'package:habivi/data/models/evento.dart';
import 'package:habivi/data/models/habito.dart';
import 'package:habivi/data/models/logro.dart';
import 'package:habivi/data/models/nota.dart';
import 'package:habivi/data/models/racha.dart';
import 'package:habivi/data/models/registro_habito.dart';
import 'package:habivi/data/models/sesion_estudio.dart';
import 'package:habivi/data/models/sesion_pomodoro.dart';
import 'package:habivi/data/models/tarea.dart';
import 'package:habivi/data/models/usuario.dart';

class BackupService {
  static const _boxUser = HiveBoxNames.usuario;
  static const _boxCuenta = HiveBoxNames.cuenta;
  static const _boxHabito = HiveBoxNames.habito;
  static const _boxRegistro = HiveBoxNames.registroHabito;
  static const _boxTarea = HiveBoxNames.tarea;
  static const _boxPomodoro = HiveBoxNames.sesionPomodoro;
  static const _boxNota = HiveBoxNames.nota;
  static const _boxEvento = HiveBoxNames.evento;
  static const _boxBackup = HiveBoxNames.backup;
  static const _boxEstudio = HiveBoxNames.sesionEstudio;
  static const _boxLogro = HiveBoxNames.logro;
  static const _boxRacha = HiveBoxNames.racha;

  Future<String> exportToJson() async {
    final data = <String, dynamic>{
      'app': 'Habivi',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'boxes': <String, dynamic>{},
    };

    data['boxes'][_boxUser] = await _exportUsuario();
    data['boxes'][_boxCuenta] = await _exportCuenta();
    data['boxes'][_boxHabito] = await _exportHabito();
    data['boxes'][_boxRegistro] = await _exportRegistro();
    data['boxes'][_boxTarea] = await _exportTarea();
    data['boxes'][_boxPomodoro] = await _exportPomodoro();
    data['boxes'][_boxNota] = await _exportNota();
    data['boxes'][_boxEvento] = await _exportEvento();
    data['boxes'][_boxBackup] = await _exportBackupM();
    data['boxes'][_boxEstudio] = await _exportEstudio();
    data['boxes'][_boxLogro] = await _exportLogro();
    data['boxes'][_boxRacha] = await _exportRacha();

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> importFromJson(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    final boxes = data['boxes'] as Map<String, dynamic>;

    await _importUsuario(boxes[_boxUser]);
    await _importCuenta(boxes[_boxCuenta]);
    await _importHabito(boxes[_boxHabito]);
    await _importRegistro(boxes[_boxRegistro]);
    await _importTarea(boxes[_boxTarea]);
    await _importPomodoro(boxes[_boxPomodoro]);
    await _importNota(boxes[_boxNota]);
    await _importEvento(boxes[_boxEvento]);
    await _importBackupM(boxes[_boxBackup]);
    await _importEstudio(boxes[_boxEstudio]);
    await _importLogro(boxes[_boxLogro]);
    await _importRacha(boxes[_boxRacha]);
  }

  // --------------- Export helpers ---------------

  Future<List<Map<String, dynamic>>> _exportUsuario() async {
    final box = await Hive.openBox<Usuario>(_boxUser);
    return box.values.map((u) => {
          'idUsuario': u.idUsuario,
          'nombre': u.nombre,
          'apellido': u.apellido,
          'energia': u.energia,
          'energiaMax': u.energiaMax,
          'puntosProductividad': u.puntosProductividad,
          'estadoPersonaje': u.estadoPersonaje,
          'fechaInicio': u.fechaInicio,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportCuenta() async {
    final box = await Hive.openBox<Cuenta>(_boxCuenta);
    return box.values.map((c) => {
          'idUsuario': c.idUsuario,
          'nickname': c.nickname,
          'contrasena': c.contrasena,
          'correo': c.correo,
          'telefono': c.telefono,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportHabito() async {
    final box = await Hive.openBox<Habito>(_boxHabito);
    return box.values.map((h) => {
          'idHabito': h.idHabito,
          'nombreHabito': h.nombreHabito,
          'atributo': h.atributo,
          'tipo': h.tipo,
          'completadoHoy': h.completadoHoy,
          'fechaUltimoCompletado': h.fechaUltimoCompletado,
          'fechasCompletadas': h.safeFechasCompletadas,
          'vecesPorSemana': h.vecesPorSemana,
          'fechaCreacion': h.fechaCreacion,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportRegistro() async {
    final box = await Hive.openBox<RegistroHabito>(_boxRegistro);
    return box.values.map((r) => {
          'idRegistro': r.idRegistro,
          'fecha': r.fecha,
          'completado': r.completado,
          'impacto': r.impacto,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportTarea() async {
    final box = await Hive.openBox<Tarea>(_boxTarea);
    return box.values.map((t) => {
          'idTarea': t.idTarea,
          'nombreTarea': t.nombreTarea,
          'puntaje': t.puntaje,
          'metadata': t.metadata,
          'fecha': t.fecha,
          'notas': t.notas,
          'completada': t.completada,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportPomodoro() async {
    final box = await Hive.openBox<SesionPomodoro>(_boxPomodoro);
    return box.values.map((s) => {
          'idSesion': s.idSesion,
          'fechaInicio': s.fechaInicio,
          'fechaFinal': s.fechaFinal,
          'duracion': s.duracion,
          'completada': s.completada,
          'tipoSesion': s.tipoSesion,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportNota() async {
    final box = await Hive.openBox<Nota>(_boxNota);
    return box.values.map((n) => {
          'idNota': n.idNota,
          'valor': n.valor,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportEvento() async {
    final box = await Hive.openBox<Evento>(_boxEvento);
    return box.values.map((e) => {
          'idEvento': e.idEvento,
          'fechaEvento': e.fechaEvento,
          'finalizado': e.finalizado,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportBackupM() async {
    final box = await Hive.openBox<Backup>(_boxBackup);
    return box.values.map((b) => {
          'idBackup': b.idBackup,
          'fechaBackup': b.fechaBackup,
          'descripcion': b.descripcion,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportEstudio() async {
    final box = await Hive.openBox<SesionEstudio>(_boxEstudio);
    return box.values.map((s) => {
          'idSesion': s.idSesion,
          'metodo': s.metodo,
          'duracionMinutos': s.duracionMinutos,
          'puntosObtenidos': s.puntosObtenidos,
          'fecha': s.fecha,
          'nota': s.nota,
        }).toList();
  }

  Future<List<Map<String, dynamic>>> _exportLogro() async {
    final box = await Hive.openBox<Logro>(_boxLogro);
    return box.values.map((l) => {
          'idLogro': l.idLogro,
          'fechaDesbloqueo': l.fechaDesbloqueo,
        }).toList();
  }

  Future<Map<String, dynamic>> _exportRacha() async {
    final box = await Hive.openBox<Racha>(_boxRacha);
    final map = <String, dynamic>{};
    for (final entry in box.toMap().entries) {
      final r = entry.value;
      map[entry.key.toString()] = {
        'idRacha': r.idRacha,
        'tipo': r.tipo,
        'cantidad': r.cantidad,
        'fechaUltimoCompletado': r.fechaUltimoCompletado,
        'enRiesgo': r.enRiesgo,
        'fechaInicioPeriodoRecuperacion': r.fechaInicioPeriodoRecuperacion,
        'fechaCreacion': r.fechaCreacion,
      };
    }
    return map;
  }

  // --------------- Import helpers ---------------

  Future<void> _importUsuario(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Usuario>(_boxUser);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Usuario(
        idUsuario: (item['idUsuario'] as num).toInt(),
        nombre: item['nombre'] as String,
        apellido: item['apellido'] as String,
        energia: (item['energia'] as num).toInt(),
        energiaMax: (item['energiaMax'] as num).toInt(),
        puntosProductividad: (item['puntosProductividad'] as num).toInt(),
        estadoPersonaje: item['estadoPersonaje'] as String,
        fechaInicio: item['fechaInicio'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importCuenta(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Cuenta>(_boxCuenta);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Cuenta(
        (item['idUsuario'] as num).toInt(),
        item['nickname'] as String,
        item['contrasena'] as String,
        item['correo'] as String,
        (item['telefono'] as num).toInt(),
      ));
    }
    await box.flush();
  }

  Future<void> _importHabito(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Habito>(_boxHabito);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Habito(
        (item['idHabito'] as num).toInt(),
        item['nombreHabito'] as String,
        item['atributo'] as String,
        item['tipo'] as String,
        completadoHoy: item['completadoHoy'] as bool,
        fechaUltimoCompletado: item['fechaUltimoCompletado'] as String,
        fechasCompletadas: (item['fechasCompletadas'] as List?)?.cast<String>(),
        vecesPorSemana: (item['vecesPorSemana'] as num?)?.toInt(),
        fechaCreacion: item['fechaCreacion'] as String?,
      ));
    }
    await box.flush();
  }

  Future<void> _importRegistro(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<RegistroHabito>(_boxRegistro);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(RegistroHabito(
        (item['idRegistro'] as num).toInt(),
        item['fecha'] as String,
        item['completado'] as bool,
        (item['impacto'] as num).toInt(),
      ));
    }
    await box.flush();
  }

  Future<void> _importTarea(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Tarea>(_boxTarea);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Tarea(
        (item['idTarea'] as num).toInt(),
        item['nombreTarea'] as String,
        (item['puntaje'] as num).toInt(),
        metadata: item['metadata'] as String,
        fecha: item['fecha'] as String,
        notas: item['notas'] as String,
        completada: item['completada'] as bool,
      ));
    }
    await box.flush();
  }

  Future<void> _importPomodoro(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<SesionPomodoro>(_boxPomodoro);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(SesionPomodoro(
        (item['idSesion'] as num).toInt(),
        item['fechaInicio'] as String,
        item['fechaFinal'] as String,
        (item['duracion'] as num).toInt(),
        item['completada'] as bool,
        item['tipoSesion'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importNota(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Nota>(_boxNota);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Nota(
        (item['idNota'] as num).toInt(),
        item['valor'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importEvento(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Evento>(_boxEvento);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Evento(
        (item['idEvento'] as num).toInt(),
        item['fechaEvento'] as String,
        item['finalizado'] as bool,
      ));
    }
    await box.flush();
  }

  Future<void> _importBackupM(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Backup>(_boxBackup);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Backup(
        (item['idBackup'] as num).toInt(),
        item['fechaBackup'] as String,
        item['descripcion'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importEstudio(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<SesionEstudio>(_boxEstudio);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(SesionEstudio(
        (item['idSesion'] as num).toInt(),
        item['metodo'] as String,
        (item['duracionMinutos'] as num).toInt(),
        (item['puntosObtenidos'] as num).toInt(),
        item['fecha'] as String,
        nota: item['nota'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importLogro(dynamic data) async {
    if (data == null || (data is List && data.isEmpty)) return;
    final box = await Hive.openBox<Logro>(_boxLogro);
    await box.clear();
    for (final item in (data as List)) {
      await box.add(Logro(
        item['idLogro'] as String,
        item['fechaDesbloqueo'] as String,
      ));
    }
    await box.flush();
  }

  Future<void> _importRacha(dynamic data) async {
    if (data == null) return;
    final box = await Hive.openBox<Racha>(_boxRacha);
    await box.clear();
    final map = data as Map<String, dynamic>;
    for (final entry in map.entries) {
      final r = entry.value as Map<String, dynamic>;
      final key = int.tryParse(entry.key) ?? 0;
      await box.put(key, Racha(
        idRacha: (r['idRacha'] as num).toInt(),
        tipo: r['tipo'] as String,
        cantidad: (r['cantidad'] as num).toInt(),
        fechaUltimoCompletado: r['fechaUltimoCompletado'] as String,
        enRiesgo: r['enRiesgo'] as bool,
        fechaInicioPeriodoRecuperacion: r['fechaInicioPeriodoRecuperacion'] as String,
        fechaCreacion: r['fechaCreacion'] as String?,
      ));
    }
    await box.flush();
  }
}
