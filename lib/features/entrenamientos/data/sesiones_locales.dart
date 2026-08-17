import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../core/json.dart';
import '../domain/sesion_entrenamiento.dart';
import '../domain/sesiones_repository.dart';
import '../domain/estado_sesion.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class SesionesLocales implements SesionesRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en
  /// las pruebas, una función que devuelve una cadena. Esa costura de dos
  /// líneas es lo que hace que las pruebas no necesiten ni Flutter ni el
  /// bundle.
  SesionesLocales({
    LectorDeAssets? lector,
    this.ruta = 'assets/data/entrenamientos.json',
  }) : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<SesionEntrenamiento>? _cache;

  @override
  Future<List<SesionEntrenamiento>> obtenerTodas() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => SesionEntrenamiento.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<SesionEntrenamiento?> obtenerPorId(String id) async {
    // firstWhere sin orElse lanza "Bad state: No element" cuando no encuentra.
    // Un bucle explícito devuelve null y se lee mejor que el orElse con truco.
    for (final sesion in await obtenerTodas()) {
      if (sesion.id == id) return sesion;
    }
    return null;
  }

  @override
  Future<List<SesionEntrenamiento>> obtenerPendientes() async {
    final todas = await obtenerTodas();
    return todas
        .where((s) => s.estado is Planeada || s.estado is EnCurso)
        .toList(growable: false);
  }
}
