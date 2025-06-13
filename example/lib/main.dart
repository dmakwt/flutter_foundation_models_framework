import 'package:flutter/material.dart';
import 'package:foundation_models_framework/foundation_models_framework.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foundation Models Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Foundation Models Framework Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _promptController = TextEditingController();
  final List<Message> _messages = [];
  LanguageModelSession? _session;
  String _status = 'Not checked';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking availability...';
    });

    try {
      final response = await FoundationModelsFramework.instance
          .checkAvailability();
      setState(() {
        _status = response.isAvailable
            ? 'Available (iOS ${response.osVersion})'
            : 'Not available: ${response.errorMessage}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking availability: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createSession() async {
    setState(() {
      _session = FoundationModelsFramework.instance.createSession();
      _messages.clear();
      _messages.add(
        Message(
          content: 'New session created. You can now send prompts!',
          isUser: false,
          isSystem: true,
        ),
      );
    });
  }

  Future<void> _sendPrompt() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter a prompt')));
      }
      return;
    }

    if (_session == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create a session first')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add(Message(content: prompt, isUser: true));
      _promptController.clear();
    });

    try {
      final response = await _session!.respond(prompt: prompt);

      setState(() {
        if (response.errorMessage != null) {
          _messages.add(
            Message(
              content: 'Error: ${response.errorMessage}',
              isUser: false,
              isError: true,
            ),
          );
        } else {
          _messages.add(Message(content: response.content, isUser: false));
        }
      });
    } catch (e) {
      setState(() {
        _messages.add(
          Message(content: 'Error: $e', isUser: false, isError: true),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          // Status Card
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foundation Models Status',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_status),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _checkAvailability,
                        child: const Text('Refresh Status'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createSession,
                        child: Text(
                          _session == null ? 'Create Session' : 'New Session',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Create a session to start chatting with Foundation Models',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),

          // Input Field
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your prompt...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendPrompt(),
                    enabled: !_isLoading && _session != null,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading || _session == null
                      ? null
                      : _sendPrompt,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}

class Message {
  final String content;
  final bool isUser;
  final bool isSystem;
  final bool isError;

  Message({
    required this.content,
    required this.isUser,
    this.isSystem = false,
    this.isError = false,
  });
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: message.isSystem
                  ? Colors.blue
                  : message.isError
                  ? Colors.red
                  : Colors.green,
              child: Icon(
                message.isSystem
                    ? Icons.info
                    : message.isError
                    ? Icons.error
                    : Icons.smart_toy,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).primaryColor
                    : message.isSystem
                    ? Colors.blue.shade100
                    : message.isError
                    ? Colors.red.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
          ],
        ],
      ),
    );
  }
}
