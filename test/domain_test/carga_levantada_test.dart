import 'package:flutter_test/flutter_test.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/carga_levantada.dart';

void main() {
  group('CargaLevantada', () {
    test('dos cargas con los mismos datos son iguales', () {
      const a = CargaLevantada(ejercicio: 'Press banca', pesoKg: 60, repeticiones: 8);
      const b = CargaLevantada(ejercicio: 'Press banca', pesoKg: 60, repeticiones: 8);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('se lee correctamente desde JSON, incluyendo peso entero disfrazado', () {
      final carga = CargaLevantada.desdeJson({
        'ejercicio': 'Fondos en paralelas',
        'pesoKg': 0, // int, no double — el caso que rompe un cast directo
        'repeticiones': 12,
      });
      expect(carga.pesoKg, 0.0);
      expect(carga.pesoKg, isA<double>());
    });

    test('repeticiones en 0 o negativas no es válido', () {
      expect(
        () => CargaLevantada(ejercicio: 'x', pesoKg: 10, repeticiones: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}