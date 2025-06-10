import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/foundation_models_api.g.dart',
    swiftOut: 'ios/Classes/FoundationModelsApi.g.swift',
    dartPackageName: 'foundation_models_framework',
  ),
)
/// Data class for text summarization request
class SummarizationRequest {
  const SummarizationRequest({required this.text, this.maxLength, this.style});

  final String text;
  final int? maxLength;
  final String? style; // 'brief', 'detailed', 'keyword'
}

/// Data class for text summarization response
class SummarizationResponse {
  const SummarizationResponse({
    required this.summary,
    required this.originalLength,
    required this.summaryLength,
  });

  final String summary;
  final int originalLength;
  final int summaryLength;
}

/// Data class for text embedding request
class EmbeddingRequest {
  const EmbeddingRequest({required this.text, this.model});

  final String text;
  final String? model; // Optional model specification
}

/// Data class for text embedding response
class EmbeddingResponse {
  const EmbeddingResponse({required this.embedding, required this.dimensions});

  final List<double> embedding;
  final int dimensions;
}

/// Data class for availability check response
class AvailabilityResponse {
  const AvailabilityResponse({
    required this.isAvailable,
    required this.osVersion,
    this.errorMessage,
  });

  final bool isAvailable;
  final String osVersion;
  final String? errorMessage;
}

/// Host API for Foundation Models operations
@HostApi()
abstract class FoundationModelsApi {
  /// Check if Foundation Models framework is available on the device
  @async
  AvailabilityResponse checkAvailability();

  /// Summarize the given text using Foundation Models
  @async
  SummarizationResponse summarizeText(SummarizationRequest request);

  /// Generate text embeddings using Foundation Models
  @async
  EmbeddingResponse generateEmbedding(EmbeddingRequest request);
}
