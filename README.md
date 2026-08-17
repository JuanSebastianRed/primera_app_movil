# flutter_aplicacion_01

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# GymSaaS Móvil — Rutinas de entrenamiento

Los usuarios del gimnasio siguen rutinas en papel o notas del celular, y no
llevan registro de qué peso levantaron ni si completaron los ejercicios del
día. Esta app modela y guarda esas sesiones de entrenamiento localmente.

## El dominio

- `SesionEntrenamiento` — entidad principal. Identidad: `id`.
- `CargaLevantada` — objeto de valor (ejercicio, peso, repeticiones).
- `EstadoSesion` — sellada: `Planeada → EnCurso → Completada / Saltada`.

Decisión: modelo escrito a mano, no generado con freezed, para mantener
control total sobre los mensajes de `CampoInvalido` al leer JSON inválido.

## Cómo correrlo

flutter pub get
flutter test
flutter run