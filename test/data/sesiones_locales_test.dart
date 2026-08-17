import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:gymsaas_movil/core/json.dart';
import 'package:gymsaas_movil/features/entrenamientos/data/sesiones_locales.dart';

const _json = '''
[
  {
    "id": "sesion-001",
    "rutina": "Push Day",
    "fechaPlaneada": "2026-08-10T14:00:00Z",
    "estado": { "tipo": "completada", "finEn": "2026-08-10T15:10:00Z", "duracionMinutos": 70 },
    "cargas": [
      { "ejercicio": "Press banca", "pesoKg": 60.0, "repeticiones": 8 }
    ]
  },
  {
    "id": "sesion-002",
    "rutina": "Pull Day",
    "fechaPlaneada": "2026-08-11T14:00:00Z",
    "estado": { "tipo": "en_curso", "inicioEn": "2026-08-11T14:05:00Z" }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = SesionesLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodas()).length, 2);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = SesionesLocales(lector: (_) async => _json);
    expect((await repo.obtenerPorId('sesion-001'))?.rutina, 'Push Day');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test('un archivo que no es una lista se rechaza', () async {
    final repo = SesionesLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodas(), throwsA(isA<CampoInvalido>()));
  });

  test('obtenerPendientes excluye las sesiones ya completadas', () async {
    final repo = SesionesLocales(lector: (_) async => _json);
    final pendientes = await repo.obtenerPendientes();
    expect(pendientes.length, 1);
    expect(pendientes.single.id, 'sesion-002');
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      // Esta SÍ toca el bundle: es la única que caza "olvidé el pubspec".
      TestWidgetsFlutterBinding.ensureInitialized();
      final repo = SesionesLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodas()).length, greaterThanOrEqualTo(3));
    },
  );
}
