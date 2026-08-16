import '../../../core/json.dart';

/// Objeto de valor: no tiene id, se compara por contenido.
/// Dos cargas con los mismos tres campos son la misma carga.
class CargaLevantada {
  const CargaLevantada({
    required this.ejercicio,
    required this.pesoKg,
    required this.repeticiones,
  })  : assert(pesoKg >= 0, 'pesoKg no puede ser negativo'),
        assert(repeticiones > 0, 'repeticiones debe ser mayor a 0');

  final String ejercicio;
  final double pesoKg;
  final int repeticiones;

  factory CargaLevantada.desdeJson(Map<String, dynamic> json) {
    return CargaLevantada(
      ejercicio: leerTexto(json, 'ejercicio'),
      pesoKg: leerDecimal(json, 'pesoKg'),
      repeticiones: leerEntero(json, 'repeticiones'),
    );
  }

  Map<String, dynamic> aJson() => {
        'ejercicio': ejercicio,
        'pesoKg': pesoKg,
        'repeticiones': repeticiones,
      };

  @override
  bool operator ==(Object other) =>
      other is CargaLevantada &&
      other.ejercicio == ejercicio &&
      other.pesoKg == pesoKg &&
      other.repeticiones == repeticiones;

  @override
  int get hashCode => Object.hash(ejercicio, pesoKg, repeticiones);

  @override
  String toString() =>
      'CargaLevantada($ejercicio: ${pesoKg}kg × $repeticiones)';
}