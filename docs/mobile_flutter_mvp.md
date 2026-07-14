# Growly Flutter MVP

The first Growly Flutter client lives in `mobile/`. It demonstrates the complete
local learning loop against the Phoenix mobile API without production auth,
payments, advertising, or analytics.

## What is built

- deterministic demo bootstrap without hardcoded database IDs;
- child mode with child-safe tasks and backend-side grading;
- gentle backend feedback, staged hints, explanations, and next-task flow;
- parent progress summary, per-skill metrics, and recommendations;
- curriculum and child lesson map;
- connection settings and backend health check;
- reusable loading, retry, task option, feedback, and progress widgets;
- offline model, URL, and widget tests.

The app uses only Flutter SDK packages and `package:http`. State is deliberately
kept in `StatefulWidget`, `FutureBuilder`, and `setState` for this MVP.

## Application structure

```text
mobile/lib/
  main.dart
  app.dart
  config/api_config.dart
  api/api_exception.dart
  api/growly_api_client.dart
  models/
  screens/
  widgets/
```

## Backend endpoints

- `GET /api/mobile/v1/health`
- `GET /api/mobile/v1/demo/bootstrap`
- `GET /api/mobile/v1/children/:child_id/session`
- `POST /api/mobile/v1/children/:child_id/tasks/:task_id/answer`
- `GET /api/mobile/v1/children/:child_id/progress`
- `GET /api/mobile/v1/catalog`
- `GET /api/mobile/v1/children/:child_id/lesson_map`

Bootstrap supplies the stable demo child ID and links. It creates missing demo
records idempotently but never resets attempts or diagnostic progress.

## Run the backend

```powershell
cd backend
mix setup
mix phx.server
```

The development backend listens on `http://localhost:4000`.

## Run Flutter

Install Flutter Stable and Android Studio, accept Android licenses, then verify:

```powershell
flutter doctor -v
```

Android emulator:

```powershell
cd mobile
flutter pub get
flutter run --dart-define=GROWLY_API_BASE_URL=http://10.0.2.2:4000
```

Windows desktop:

```powershell
cd mobile
flutter run -d windows --dart-define=GROWLY_API_BASE_URL=http://localhost:4000
```

Windows builds require Visual Studio with the Desktop development with C++
workload. Android Studio alone is not sufficient for Windows desktop builds.

Physical Android phone on the same network:

```powershell
cd mobile
flutter run --dart-define=GROWLY_API_BASE_URL=http://YOUR_PC_LAN_IP:4000
```

Phoenix must listen on an interface reachable from the phone, and Windows
Firewall must permit the development port. Do not expose the unauthenticated
demo or admin endpoints to the public internet.

## Development HTTP

The default base URL is `http://10.0.2.2:4000` and can be overridden through
`GROWLY_API_BASE_URL`. Android cleartext traffic is enabled only in
`android/app/src/debug/AndroidManifest.xml`. Release and production builds must
use HTTPS.

## Child-facing safety rules

- `GrowlyTask` has no `correctAnswer` field;
- the app never grades an answer locally;
- only `selected_answer` and `hint_used` are submitted;
- `feedback.message` is the primary child-facing response;
- hints and explanations appear only when returned by the backend;
- `review_later` continues to the backend-provided next task;
- no tracking, ads, payments, or external links exist in child mode.

## Checks

```powershell
cd mobile
dart format .
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Flutter tests are offline and do not require a running backend.

## Current limitations

- no production parent authentication or secure child selection;
- demo data is used for initial startup;
- no persistent runtime API setting;
- no payments, subscriptions, advertising, or analytics;
- local HTTP is development-only;
- UI needs usability and accessibility testing with real families;
- Windows desktop requires the separate Visual Studio C++ workload.
# Роли и навигация

На первом запуске устройство выбирает роль, но сам тап не сохраняет её сразу: сначала открывается отдельный экран подтверждения/настройки. Ошибочный выбор всегда можно отменить, а из неподключённого родительского режима есть явная кнопка «Выбрать другую роль».

Детский режим содержит только обучение, карту уровней, подсказки и экран кода для родителя. Ребёнок может начать без телефона родителя или подключить его сразу; позднее подключение доступно в настройках. Родительский режим содержит только подключение по коду, прогресс и карту обучения. Выбор и идентификаторы устройств сохраняются локально через `shared_preferences`.

Ручное подключение по 8-значному коду полностью работает. QR-код отображается, а сканер камеры будет добавлен отдельным безопасным шагом.

# Обучение

Экран задания ориентирован на landscape: вопрос расположен выше центра, а варианты — ниже. Есть мягкая обратная связь, анимации Flutter SDK, интерактивное перетаскивание яблок в корзинки и приключенческая карта уровней с пунктирным маршрутом. Emoji являются временными визуальными заглушками.

Визуальная система использует кремовый фон, мягкие зелёные и жёлтые акценты, большие скруглённые карточки и спокойные тени. Это оригинальная интерпретация дизайн-направления, без копирования чужих персонажей или ассетов.
