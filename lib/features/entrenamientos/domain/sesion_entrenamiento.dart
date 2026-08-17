import '../../../core/comparaciones.dart';
import '../../../core/json.dart';
import 'carga_levantada.dart';
import 'estado_sesion.dart';

/// Un día de entrenamiento.
///
/// Es una **entidad**: tiene identidad propia. Dos sesiones con los mismos
/// datos son dos sesiones distintas si tienen `id` distinto.
class SesionEntrenamiento {
  const SesionEntrenamiento({
    required this.id,
    required this.rutina,
    required this.fechaPlaneada,
    required this.estado,
    this.cargas = const <CargaLevantada>[],
  });

  factory SesionEntrenamiento.fromJson(Map<String, dynamic> json) =>
      SesionEntrenamiento(
        id: leerTexto(json, 'id'),
        rutina: leerTexto(json, 'rutina'),
        fechaPlaneada: leerFecha(json, 'fechaPlaneada'),
        estado: EstadoSesion.fromJson(leerMapa(json, 'estado')),
        cargas: leerMapas(
          json,
          'cargas',
        ).map(CargaLevantada.fromJson).toList(growable: false),
      );

  final String id;
  final String rutina;
  final DateTime fechaPlaneada;
  final EstadoSesion estado;
  final List<CargaLevantada> cargas;

  Map<String, dynamic> toJson() => {
    'id': id,
    'rutina': rutina,
    'fechaPlaneada': fechaPlaneada.toUtc().toIso8601String(),
    'estado': estado.toJson(),
    'cargas': cargas.map((c) => c.toJson()).toList(growable: false),
  };

  // --- Reglas de negocio ---------------------------------------------
  // Viven aquí, no en el widget. Un widget no se puede probar en 3 ms.

  /// Depende solo de los campos — no necesita reloj.
  bool get tieneRegistroDeCargas => cargas.isNotEmpty;

  /// El reloj entra como parámetro, no se lee dentro.
  ///
  /// Con `DateTime.now()` dentro, esta regla no se puede probar: el
  /// resultado depende del día en que se corra la prueba.
  bool estaAtrasada(DateTime ahora) =>
      estado is Planeada && ahora.isAfter(fechaPlaneada);

  // --- Copia -----------------------------------------------------------

  SesionEntrenamiento copyWith({
    String? rutina,
    DateTime? fechaPlaneada,
    EstadoSesion? estado,
    List<CargaLevantada>? cargas,
  }) => SesionEntrenamiento(
    id: id, // la identidad NO se copia con cambios
    rutina: rutina ?? this.rutina,
    fechaPlaneada: fechaPlaneada ?? this.fechaPlaneada,
    estado: estado ?? this.estado,
    cargas: cargas ?? this.cargas,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SesionEntrenamiento &&
          other.id == id &&
          other.rutina == rutina &&
          other.fechaPlaneada == fechaPlaneada &&
          other.estado == estado &&
          listasIguales(other.cargas, cargas);

  @override
  int get hashCode => Object.hash(
    id,
    rutina,
    fechaPlaneada,
    estado,
    Object.hashAll(cargas), // NO Object.hash(cargas): eso hashea
  ); // la referencia, no el contenido

  @override
  String toString() => 'SesionEntrenamiento($id, $rutina, $estado)';
}
