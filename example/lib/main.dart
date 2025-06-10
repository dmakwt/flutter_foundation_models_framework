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
  final TextEditingController _textController = TextEditingController();
  String _status = 'Not checked';
  String _summary = '';
  List<double> _embedding = [];
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

  Future<void> _summarizeText() async {
    if (_textController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter some text to summarize')),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _summary = 'Generating summary...';
    });

    try {
      final response = await FoundationModelsFramework.instance.summarizeText(
        _textController.text,
        maxLength: 100,
        style: 'brief',
      );
      setState(() {
        _summary = response.summary;
      });
    } catch (e) {
      setState(() {
        _summary = 'Error: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Summarization failed: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateEmbedding() async {
    if (_textController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter some text to generate embeddings'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _embedding = [];
    });

    try {
      final response = await FoundationModelsFramework.instance
          .generateEmbedding(_textController.text);
      setState(() {
        _embedding = response.embedding;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Embedding generation failed: $e')),
        );
      }
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foundation Models Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _checkAvailability,
                      child: const Text('Refresh Status'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Text Input',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText:
                            'Enter text to summarize or generate embeddings...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _summarizeText,
                            child: const Text('Summarize'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _generateEmbedding,
                            child: const Text('Generate Embedding'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_summary.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_summary),
                    ],
                  ),
                ),
              ),
            if (_embedding.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Embedding (${_embedding.length} dimensions)',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'First 10 values: ${_embedding.take(10).map((e) => e.toStringAsFixed(4)).join(', ')}...',
                      ),
                    ],
                  ),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
