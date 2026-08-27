import 'package:flutter/material.dart';

import 'local_llama_service.dart';

void main() {
  runApp(const OfflineAiAssistantApp());
}

class OfflineAiAssistantApp extends StatelessWidget {
  const OfflineAiAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Offline AI Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ChatPage(),
    );
  }
}

class ChatMessage {
  ChatMessage({required this.role, required this.text});

  final String role;
  String text;
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _service = LocalLlamaService();
  final _promptController = TextEditingController();
  final _modelPathController = TextEditingController();
  final _libraryPathController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  bool _isGenerating = false;
  String? _status;

  @override
  void dispose() {
    _service.dispose();
    _promptController.dispose();
    _modelPathController.dispose();
    _libraryPathController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadModel() {
    final libraryPath = _libraryPathController.text.trim();
    final modelPath = _modelPathController.text.trim();

    if (libraryPath.isEmpty || modelPath.isEmpty) {
      setState(() => _status = 'Enter both the llama library path and GGUF model path.');
      return;
    }

    try {
      _service.load(libraryPath: libraryPath, modelPath: modelPath);
      setState(() => _status = 'Model loaded locally.');
    } catch (error) {
      setState(() => _status = 'Could not load model: $error');
    }
  }

  Future<void> _send() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty || _isGenerating) return;
    if (!_service.isLoaded) {
      setState(() => _status = 'Load a local model first.');
      return;
    }

    final userMessage = ChatMessage(role: 'user', text: prompt);
    final assistantMessage = ChatMessage(role: 'assistant', text: '');

    setState(() {
      _messages.add(userMessage);
      _messages.add(assistantMessage);
      _promptController.clear();
      _isGenerating = true;
      _status = 'Generating locally…';
    });
    _scrollToBottom();

    try {
      await for (final token in _service.generate(prompt)) {
        if (!mounted) return;
        setState(() => assistantMessage.text += token);
        _scrollToBottom();
      }
      if (mounted) setState(() => _status = 'Ready');
    } catch (error) {
      if (mounted) {
        setState(() {
          assistantMessage.text = 'Generation failed: $error';
          _status = 'Generation error';
        });
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline AI Assistant'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Chip(
                label: Text(_service.isLoaded ? 'Local model loaded' : 'No model'),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 330,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
              ),
              child: ListView(
                children: [
                  Text('Local runtime', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text(
                    'The model and prompts stay on this device. Provide local paths to the llama.cpp library and GGUF model.',
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _libraryPathController,
                    decoration: const InputDecoration(
                      labelText: 'llama.cpp library path',
                      hintText: '/path/to/libllama.dylib',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelPathController,
                    decoration: const InputDecoration(
                      labelText: 'GGUF model path',
                      hintText: '/path/to/model.gguf',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isGenerating ? null : _loadModel,
                    icon: const Icon(Icons.memory),
                    label: const Text('Load model'),
                  ),
                  if (_status != null) ...[
                    const SizedBox(height: 14),
                    Text(_status!, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text('Load a local model, then start a private chat.'),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(22),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isUser = message.role == 'user';
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 680),
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? Theme.of(context).colorScheme.primaryContainer
                                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  message.text.isEmpty && _isGenerating ? '…' : message.text,
                                ),
                              ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promptController,
                            minLines: 1,
                            maxLines: 5,
                            enabled: !_isGenerating,
                            decoration: const InputDecoration(
                              hintText: 'Message your local model…',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: _isGenerating ? null : _send,
                          icon: const Icon(Icons.send),
                          label: const Text('Send'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
