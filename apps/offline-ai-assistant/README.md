# Offline AI Assistant

A **local-first AI chat application** built with Flutter/Dart and `llama.cpp` through `llama_cpp_dart`.

The goal of the project is simple: run a GGUF language model on the user's own device and keep prompts/responses local instead of sending every message to a hosted AI API.

## What the app does

- loads a local `.gguf` model;
- connects to a local `llama.cpp` shared library;
- provides a chat-style Flutter interface;
- generates assistant replies token by token;
- keeps the current conversation in memory on the device;
- does not require a cloud AI API key for inference.

## Stack

- Flutter
- Dart
- llama.cpp
- llama_cpp_dart
- GGUF models

The original project direction used a small Qwen-family GGUF model for local inference; the app accepts any compatible local GGUF model path.

## Project structure

```text
offline-ai-assistant/
├── lib/
│   ├── main.dart
│   └── local_llama_service.dart
├── pubspec.yaml
└── .gitignore
```

## Run

1. Install Flutter.
2. Build a `llama.cpp` shared library for your platform (`.dll`, `.so`, or `.dylib`).
3. Download a compatible GGUF model.
4. Run:

```bash
flutter pub get
flutter run
```

Inside the app, enter the path to the llama shared library and the local GGUF model, then press **Load model**.

## Privacy

Inference is designed to happen locally. This demo does not upload prompts or model data to an external AI provider.

## Notes

Native `llama.cpp` setup is platform-specific. The source code uses the high-level `llama_cpp_dart` API and keeps native binaries/model weights out of Git because they are large and platform-dependent.
