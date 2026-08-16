import 'package:flutter_test/flutter_test.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/carga_levantada.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/estado_sesion.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/sesion_entrenamiento.dart';

void main() {
  group('SesionEntrenamiento', () {
    test('ida y vuelta por JSON conserva los datos', () {
      final original = SesionEntrenamiento(
        id: 'sesion-001',
        rutina: 'Push Day',
        fechaPlaneada: DateTime.utc(2026, 8, 10, 14),
        estado:  Completada(DateTime.utc(2026, 8, 10, 15), 60),
        cargas: const [
          CargaLevantada(ejercicio: 'Press banca', pesoKg: 60, repeticiones: 8),
        ],
      );
      final reconstruida = SesionEntrenamiento.fromJson(original.toJson());
      expect(reconstruida, equals(original));
    });

   test('copyWith no cambia el id', () {
      final original = SesionEntrenamiento(
        id: 'sesion-001',
        rutina: 'Push Day',
        fechaPlaneada: DateTime.utc(2026, 8, 10, 14), // <- ESTO ROMPE A PROPÓSITO, ver abajo
        estado: Planeada(),
      );

      final copia = original.copyWith(rutina: 'Pull Day');

      expect(copia.id, original.id);
      expect(copia.rutina, 'Pull Day');
    });


    test('estaAtrasada es true si sigue Planeada y ya pasó la fecha', () {
      final sesion = SesionEntrenamiento(
        id: 'sesion-002',
        rutina: 'Pull Day',
        fechaPlaneada: DateTime.utc(2026, 8, 1),
        estado: const Planeada(),
      );
      final ahora = DateTime.utc(2026, 8, 10);
      expect(sesion.estaAtrasada(ahora), isTrue);
    });
  });
}