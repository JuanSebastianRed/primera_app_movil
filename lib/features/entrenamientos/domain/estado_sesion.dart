import '../../../core/json.dart';

/// En qué punto de su vida está una sesión de entrenamiento.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir
/// un estado, y el compilador conoce la lista completa. Eso es lo que
/// hace que los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoSesion {
  const EstadoSesion();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoSesion.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'planeada' => const Planeada(),
      'en_curso' => EnCurso(leerFecha(json, 'inicioEn')),
      'completada' => Completada(
        leerFecha(json, 'finEn'),
        leerEntero(json, 'duracionMinutos'),
      ),
      'saltada' => Saltada(leerTexto(json, 'motivo')),
      _ => throw CampoInvalido('estado.tipo', 'no es un estado conocido', tipo),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    Planeada() => {'tipo': 'planeada'},
    EnCurso(:final inicioEn) => {
      'tipo': 'en_curso',
      'inicioEn': inicioEn.toIso8601String(),
    },
    Completada(:final finEn, :final duracionMinutos) => {
      'tipo': 'completada',
      'finEn': finEn.toIso8601String(),
      'duracionMinutos': duracionMinutos,
    },
    Saltada(:final motivo) => {'tipo': 'saltada', 'motivo': motivo},
  };
}

final class Planeada extends EstadoSesion {
  const Planeada();

  @override
  bool operator ==(Object other) => other is Planeada;
  @override
  int get hashCode => runtimeType.hashCode;
  @override
  String toString() => 'Planeada()';
}

final class EnCurso extends EstadoSesion {
  const EnCurso(this.inicioEn);

  final DateTime inicioEn;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EnCurso && other.inicioEn == inicioEn;
  @override
  int get hashCode => Object.hash(runtimeType, inicioEn);
  @override
  String toString() => 'EnCurso($inicioEn)';
}

final class Completada extends EstadoSesion {
  const Completada(this.finEn, this.duracionMinutos)
    : assert(duracionMinutos > 0, 'duracionMinutos debe ser mayor a 0');

  final DateTime finEn;
  final int duracionMinutos;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Completada &&
          other.finEn == finEn &&
          other.duracionMinutos == duracionMinutos;
  @override
  int get hashCode => Object.hash(runtimeType, finEn, duracionMinutos);
  @override
  String toString() => 'Completada($finEn, $duracionMinutos min)';
}

final class Saltada extends EstadoSesion {
  // El assert documenta la regla y la caza en depuración. La GARANTÍA es
  // leerTexto, que rechaza la cadena vacía también en producción.
  const Saltada(this.motivo) : assert(motivo != '', 'saltar exige motivo');

  final String motivo; // saltar SIN motivo no se puede ni escribir

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Saltada && other.motivo == motivo;
  @override
  int get hashCode => Object.hash(runtimeType, motivo);
  @override
  String toString() => 'Saltada($motivo)';
}
