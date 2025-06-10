export 'src/foundation_models_api.g.dart';

import 'src/foundation_models_api.g.dart';
import 'dart:io' show Platform;

/// Main class for interacting with Apple's Foundation Models framework.
///
/// This class provides a high-level interface for text summarization,
/// embedding generation, and other Foundation Models capabilities.
class FoundationModelsFramework {
  static final FoundationModelsFramework _instance =
      FoundationModelsFramework._internal();
  static FoundationModelsFramework get instance => _instance;

  FoundationModelsFramework._internal() : _isMock = false;
  FoundationModelsFramework._mock() : _isMock = true;

  final FoundationModelsApi _api = FoundationModelsApi();
  final bool _isMock;

  /// Create a mock instance for testing in simulators or development
  ///
  /// This is useful when you want to test your app's UI and logic
  /// without requiring actual Foundation Models framework availability.
  factory FoundationModelsFramework.mock() {
    return FoundationModelsFramework._mock();
  }

  /// Check if Foundation Models framework is available on the current device.
  ///
  /// Returns an [AvailabilityResponse] containing availability status,
  /// OS version, and any error messages.
  Future<AvailabilityResponse> checkAvailability() async {
    if (_isMock) {
      // Mock response for simulator/testing
      return AvailabilityResponse(
        isAvailable: false,
        osVersion: Platform.operatingSystemVersion,
        errorMessage:
            'Mock implementation - Foundation Models requires physical device with iOS 26.0+ Beta',
      );
    }
    return await _api.checkAvailability();
  }

  /// Summarize the given text using Foundation Models.
  ///
  /// [text] - The text to summarize
  /// [maxLength] - Optional maximum length for the summary
  /// [style] - Optional summarization style ('brief', 'detailed', 'keyword')
  ///
  /// Returns a [SummarizationResponse] with the summary and metadata.
  Future<SummarizationResponse> summarizeText(
    String text, {
    int? maxLength,
    String? style,
  }) async {
    if (_isMock) {
      // Mock summarization for testing
      final mockSummary = _createMockSummary(text, maxLength, style);
      return SummarizationResponse(
        summary: mockSummary,
        originalLength: text.length,
        summaryLength: mockSummary.length,
      );
    }

    final request = SummarizationRequest(
      text: text,
      maxLength: maxLength,
      style: style,
    );
    return await _api.summarizeText(request);
  }

  /// Generate text embeddings using Foundation Models.
  ///
  /// [text] - The text to generate embeddings for
  /// [model] - Optional model specification
  ///
  /// Returns an [EmbeddingResponse] with the embedding vector and dimensions.
  Future<EmbeddingResponse> generateEmbedding(
    String text, {
    String? model,
  }) async {
    if (_isMock) {
      // Mock embedding generation for testing
      final mockEmbedding = _createMockEmbedding(text);
      return EmbeddingResponse(
        embedding: mockEmbedding,
        dimensions: mockEmbedding.length,
      );
    }

    final request = EmbeddingRequest(text: text, model: model);
    return await _api.generateEmbedding(request);
  }

  // Mock implementation helpers
  String _createMockSummary(String text, int? maxLength, String? style) {
    final words = text.split(' ');
    final targetLength = maxLength ?? (words.length ~/ 3).clamp(1, 50);

    String summary;
    if (words.length <= targetLength) {
      summary = text;
    } else {
      summary = words.take(targetLength).join(' ');
      if (style?.toLowerCase() == 'keyword') {
        summary = 'Keywords: ${words.take(5).join(', ')}';
      }
    }

    return '$summary (Mock Summary)';
  }

  List<double> _createMockEmbedding(String text) {
    // Generate consistent mock embedding based on text hash
    final hash = text.hashCode;
    final dimensions = 768; // Standard embedding dimension
    final embedding = <double>[];

    for (int i = 0; i < dimensions; i++) {
      final value =
          ((hash + i) % 1000) / 1000.0 - 0.5; // Values between -0.5 and 0.5
      embedding.add(value);
    }

    return embedding;
  }
}
