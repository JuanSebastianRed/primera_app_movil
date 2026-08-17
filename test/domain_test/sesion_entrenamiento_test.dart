import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gymsaas_movil/core/json.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/carga_levantada.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/estado_sesion.dart';
import 'package:gymsaas_movil/features/entrenamientos/domain/sesion_entrenamiento.dart';

SesionEntrenamiento ejemplo({
  EstadoSesion? estado,
  List<CargaLevantada>? cargas,
}) => SesionEntrenamiento(
  id: 'sesion-001',
  rutina: 'Push Day',
  fechaPlaneada: DateTime.utc(2026, 8, 10, 14),
  estado: estado ?? const Planeada(),
  cargas: cargas ?? const <CargaLevantada>[],
);

void main() {
  group('serializacion', () {
    test('una sesión sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Completada(DateTime.utc(2026, 8, 10, 15, 10), 70),
        cargas: const [
          CargaLevantada(ejercicio: 'Press banca', pesoKg: 60, repeticiones: 8),
        ],
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las
      // fechas y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = SesionEntrenamiento.fromJson(
        jsonDecode(texto) as Map<String, dynamic>,
      );

      expect(vuelta, equals(original));
    });

    test('una sesión sin la clave cargas se lee con la lista vacía', () {
      final json = ejemplo().toJson()..remove('cargas');
      expect(SesionEntrenamiento.fromJson(json).cargas, isEmpty);
    });

    test('una sesión sin rutina dice qué campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('rutina');
      expect(
        () => SesionEntrenamiento.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'rutina')),
      );
    });

    test('una fecha que no es ISO 8601 se rechaza', () {
      final json = ejemplo().toJson()..['fechaPlaneada'] = '10 de agosto';
      expect(
        () => SesionEntrenamiento.fromJson(json),
        throwsA(isA<CampoInvalido>()),
      );
    });

    test('la hora se conserva en UTC y no se corre cinco horas', () {
      final json = ejemplo().toJson();
      expect(json['fechaPlaneada'], '2026-08-10T14:00:00.000Z');
    });
  });

  group('igualdad y copia', () {
    test('dos sesiones con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos sesiones con los mismos datos comparten hashCode', () {
      // Sin esto, meterlas en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos sesiones con cargas distintas NO son iguales', () {
      expect(
        ejemplo(
          cargas: const [
            CargaLevantada(
              ejercicio: 'Sentadilla',
              pesoKg: 80,
              repeticiones: 5,
            ),
          ],
        ),
        isNot(
          equals(
            ejemplo(
              cargas: const [
                CargaLevantada(
                  ejercicio: 'Peso muerto',
                  pesoKg: 100,
                  repeticiones: 5,
                ),
              ],
            ),
          ),
        ),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(rutina: 'Pull Day');
      expect(copia.rutina, 'Pull Day');
      expect(copia.id, original.id);
      expect(copia.fechaPlaneada, original.fechaPlaneada);
    });
  });

  group('reglas de negocio', () {
    test('una sesión sin cargas registradas no tiene registro de cargas', () {
      expect(ejemplo(cargas: const []).tieneRegistroDeCargas, isFalse);
    });

    test('una sesión con cargas registradas sí tiene registro', () {
      expect(
        ejemplo(
          cargas: const [
            CargaLevantada(ejercicio: 'Curl', pesoKg: 15, repeticiones: 12),
          ],
        ).tieneRegistroDeCargas,
        isTrue,
      );
    });

    test('una sesión planeada cuya fecha ya pasó está atrasada', () {
      final ahora = DateTime.utc(2026, 8, 20);
      expect(ejemplo(estado: const Planeada()).estaAtrasada(ahora), isTrue);
    });
  });
}
