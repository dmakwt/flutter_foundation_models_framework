export 'src/foundation_models_api.g.dart';

import 'src/foundation_models_api.g.dart';
import 'dart:io' show Platform;

/// A language model session for interacting with Apple's Foundation Models framework.
///
/// This class provides a session-based interface for sending prompts and receiving
/// responses from Apple's on-device language models.
class LanguageModelSession {
  final FoundationModelsApi _api = FoundationModelsApi();
  final bool _isMock;

  /// Create a new language model session.
  LanguageModelSession() : _isMock = false;

  /// Create a mock session for testing in simulators or development.
  ///
  /// This is useful when you want to test your app's UI and logic
  /// without requiring actual Foundation Models framework availability.
  LanguageModelSession._mock() : _isMock = true;

  /// Create a mock instance for testing in simulators or development
  factory LanguageModelSession.mock() {
    return LanguageModelSession._mock();
  }

  /// Send a prompt to the language model and get a response.
  ///
  /// [prompt] - The text prompt to send to the model
  ///
  /// Returns a [ChatResponse] with the model's response content or error message.
  Future<ChatResponse> respond({required String prompt}) async {
    if (_isMock) {
      // Mock response for testing
      return ChatResponse(
        content: 'Mock response to: $prompt',
        errorMessage: null,
      );
    }

    final request = ChatRequest(prompt: prompt);
    return await _api.sendPrompt(request);
  }
}

/// Main class for interacting with Apple's Foundation Models framework.
///
/// This class provides a high-level interface for checking availability
/// and creating language model sessions.
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
  ///
  /// Returns true only if the iOS version is 26 or later and Apple Intelligence is available.
  Future<AvailabilityResponse> checkAvailability() async {
    if (_isMock) {
      // Mock response for simulator/testing
      return AvailabilityResponse(
        isAvailable: false,
        osVersion: Platform.operatingSystemVersion,
        errorMessage:
            'Mock implementation - Foundation Models requires physical device with iOS 26.0+ and Apple Intelligence',
      );
    }
    return await _api.checkAvailability();
  }

  /// Create a new language model session.
  ///
  /// Returns a [LanguageModelSession] that can be used to send prompts
  /// and receive responses from Apple's Foundation Models.
  LanguageModelSession createSession() {
    if (_isMock) {
      return LanguageModelSession.mock();
    }
    return LanguageModelSession();
  }

  /// Convenience method to send a single prompt without managing a session.
  ///
  /// [prompt] - The text prompt to send to the model
  ///
  /// Returns a [ChatResponse] with the model's response content or error message.
  ///
  /// For multiple interactions, consider using [createSession] instead for better performance.
  Future<ChatResponse> sendPrompt(String prompt) async {
    final session = createSession();
    return await session.respond(prompt: prompt);
  }
}
