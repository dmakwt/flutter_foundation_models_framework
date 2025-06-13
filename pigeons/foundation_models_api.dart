import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/foundation_models_api.g.dart',
    swiftOut: 'ios/Classes/FoundationModelsApi.g.swift',
    dartPackageName: 'foundation_models_framework',
  ),
)
/// Data class for chat request
class ChatRequest {
  const ChatRequest({required this.prompt});

  final String prompt;
}

/// Data class for chat response
class ChatResponse {
  const ChatResponse({required this.content, this.errorMessage});

  final String content;
  final String? errorMessage;
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

  /// Create a new language model session and send a prompt
  @async
  ChatResponse sendPrompt(ChatRequest request);
}
