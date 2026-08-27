import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LocalLlamaService {
  Llama? _llama;

  bool get isLoaded => _llama != null;

  void load({
    required String libraryPath,
    required String modelPath,
  }) {
    dispose();
    Llama.libraryPath = libraryPath;
    _llama = Llama(modelPath);
  }

  Stream<String> generate(String prompt) async* {
    final llama = _llama;
    if (llama == null) {
      throw StateError('Load a model before sending a message.');
    }

    llama.setPrompt(prompt);

    while (true) {
      final (token, done) = llama.getNext();
      if (token.isNotEmpty) {
        yield token;
      }
      if (done) break;

      // Yield back to Flutter so the UI can repaint between generated tokens.
      await Future<void>.delayed(Duration.zero);
    }
  }

  void dispose() {
    _llama?.dispose();
    _llama = null;
  }
}
