# Vaidya

## An intelligent health companion for Nepal that securely stores your medical history, tracks your vitals, and offers smart medicine suggestions, symptom analysis, and early disease predictions, helping you stay informed and healthy every day.

## API config (Android emulator)

Default emulator config already works without extra flags:

```bash
flutter run
```

It resolves to:

```text
http://10.0.2.2:5000/v1/api
```

Override with a full URL:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5000/v1/api
```

Or override by parts:

```bash
flutter run \
  --dart-define=API_SCHEME=http \
  --dart-define=API_HOST=10.0.2.2 \
  --dart-define=API_PORT=5000 \
  --dart-define=API_PREFIX=/v1/api
```

Physical device example (same LAN as backend):

```bash
flutter run --dart-define=API_HOST=192.168.1.4
```
