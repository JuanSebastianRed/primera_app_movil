import 'sesion_entrenamiento.dart';

/// Lo que la aplicación necesita saber de las sesiones de entrenamiento.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo. Es la declaración de intenciones más explícita que hay.
abstract interface class SesionesRepository {
  Future<List<SesionEntrenamiento>> obtenerTodas();
  Future<SesionEntrenamiento?> obtenerPorId(String id);

  /// Sesiones que todavía no se resolvieron: siguen Planeadas o EnCurso.
  /// Es el método propio de este dominio — lo que un usuario real preguntaría
  /// al abrir la app: "¿qué me falta por hacer?"
  Future<List<SesionEntrenamiento>> obtenerPendientes();
}