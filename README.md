<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Foundation Models Framework

> **⚠️ BETA STATUS**: This package is in beta. Core functionality including streaming is stable, but structured generation and tool calling features are still in development.

A Flutter package for integrating with Apple's Foundation Models framework on iOS and macOS devices. This package provides access to on-device AI capabilities through language model sessions, leveraging Apple Intelligence features.

## Features

- ✅ **Cross-Platform Support**: Works on both iOS 26.0+ and macOS 15.0+
- ✅ **Persistent Sessions**: Maintain conversation context across multiple interactions
- ✅ **Streaming Responses**: Real-time token streaming with delta updates
- ✅ **Generation Options**: Control temperature, token limits, and sampling strategies
- ✅ **Transcript History**: Access full conversation history with role-based entries
- ✅ **Guardrail Levels**: Configure content safety levels (strict/standard/permissive)
- ✅ **Rich Responses**: Get detailed responses with raw content and transcript metadata
- ✅ **Security Features**: Built-in prompt validation and injection protection
- ✅ **Type-safe API**: Built with Pigeon for reliable platform communication
- ✅ **Privacy-First**: All processing happens on-device with Apple Intelligence

## Requirements

- **iOS**: 26.0 or later
- **macOS**: 15.0 or later
- **Flutter**: 3.0.0 or later
- **Dart**: 3.8.1 or later
- **Xcode**: 16.0 or later
- **Apple Intelligence**: Must be enabled on device

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  foundation_models_framework: ^0.2.0
```

Then run:

```bash
flutter pub get
```

## iOS Setup

### 1. Update iOS Deployment Target

In your `ios/Podfile`, ensure the iOS deployment target is set to 26.0 or higher:

```ruby
platform :ios, '26.0'
```

### 2. Update iOS Project Settings

In your `ios/Runner.xcodeproj`, set:
- **iOS Deployment Target**: 26.0
- **Swift Language Version**: 5.0


## Usage


**Physical Device (Recommended):**
- Full Foundation Models functionality
- Real Apple Intelligence features
- Requires iOS 26.0+ device

### Checking Availability

Before using Foundation Models features, check if they're available on the device:

```dart
import 'package:foundation_models_framework/foundation_models_framework.dart';

final foundationModels = FoundationModelsFramework.instance;

try {
  final availability = await foundationModels.checkAvailability();
  
  if (availability.isAvailable) {
    print('Foundation Models is available on iOS ${availability.osVersion}');
    // Proceed with AI operations
  } else {
    print('Foundation Models not available: ${availability.errorMessage}');
  }
} catch (e) {
  print('Error checking availability: $e');
}
```

### Creating a Language Model Session

Create a session to interact with Apple's Foundation Models:

```dart
// Create a basic session
final session = foundationModels.createSession();

// Create a session with custom instructions and guardrails
final customSession = foundationModels.createSession(
  instructions: 'You are a helpful assistant. Keep responses concise.',
  guardrailLevel: GuardrailLevel.standard,
);

// Send a prompt and get a response
try {
  final response = await session.respond(prompt: 'Hello, how are you?');

  if (response.errorMessage == null) {
    print('Response: ${response.content}');

    // Access transcript history
    if (response.transcriptEntries != null) {
      for (final entry in response.transcriptEntries!) {
        print('${entry?.role}: ${entry?.content}');
      }
    }
  } else {
    print('Error: ${response.errorMessage}');
  }
} catch (e) {
  print('Failed to get response: $e');
}

// Don't forget to dispose when done
await session.dispose();
```

### Using Generation Options

Control the model's generation behavior:

```dart
final session = foundationModels.createSession();

// Configure generation options
final options = GenerationOptionsRequest(
  temperature: 0.7,  // 0.0 = deterministic, 1.0 = creative
  maximumResponseTokens: 500,
  samplingTopK: 40,  // Top-K sampling
);

final response = await session.respond(
  prompt: 'Write a short story',
  options: options,
);

print('Generated: ${response.content}');
```

### Convenience Method for Single Prompts

For single interactions, you can use the convenience method:

```dart
try {
  final response = await foundationModels.sendPrompt(
    'What is the weather like today?',
    instructions: 'Be brief and factual',
    guardrailLevel: GuardrailLevel.strict,
    options: GenerationOptionsRequest(temperature: 0.3),
  );

  if (response.errorMessage == null) {
    print('Response: ${response.content}');
  } else {
    print('Error: ${response.errorMessage}');
  }
} catch (e) {
  print('Failed to send prompt: $e');
}
```

### Session-Based Conversation

For multi-turn conversations, reuse the same session:

```dart
final session = foundationModels.createSession();

// First interaction
var response = await session.respond(prompt: 'Tell me about Swift programming.');
print('AI: ${response.content}');

// Continue the conversation
response = await session.respond(prompt: 'Can you give me an example?');
print('AI: ${response.content}');

// Ask follow-up questions
response = await session.respond(prompt: 'How does that compare to Dart?');
print('AI: ${response.content}');

// Don't forget to dispose when done
await session.dispose();
```

### Streaming Responses

For real-time token streaming:

```dart
final session = foundationModels.createSession(
  instructions: 'You are a helpful assistant',
  guardrailLevel: GuardrailLevel.standard,
);

// Stream tokens as they're generated
final stream = session.streamResponse(
  prompt: 'Write a detailed explanation of quantum computing',
  options: GenerationOptionsRequest(
    temperature: 0.7,
    maximumResponseTokens: 1000,
  ),
);

// Process tokens as they arrive
await for (final chunk in stream) {
  if (chunk.delta != null) {
    print('New tokens: ${chunk.delta}');
  }

  if (chunk.isFinal) {
    print('Complete response: ${chunk.cumulative}');
  }

  if (chunk.hasError) {
    print('Error: ${chunk.errorMessage}');
    break;
  }
}
```

### Handling Stream Cancellation

You can cancel a stream at any time:

```dart
final stream = session.streamResponse(prompt: 'Long text generation...');

final subscription = stream.listen((chunk) {
  print('Received: ${chunk.delta}');

  // Cancel after receiving some content
  if (chunk.cumulative?.length ?? 0 > 100) {
    subscription.cancel(); // This will stop the stream
  }
});
```

## API Reference

### FoundationModelsFramework

The main class for accessing Foundation Models functionality.

#### Methods

##### `checkAvailability()`
- **Returns**: `Future<AvailabilityResponse>`
- **Description**: Checks if Foundation Models is available on the device
- **Note**: Returns true only if iOS 26.0+/macOS 15.0+ and Apple Intelligence is available

##### `createSession({String? instructions, GuardrailLevel? guardrailLevel})`
- **Parameters**:
  - `instructions`: Optional system instructions for the session
  - `guardrailLevel`: Content safety level (strict/standard/permissive)
- **Returns**: `LanguageModelSession`
- **Description**: Creates a new language model session with optional configuration

##### `sendPrompt(String prompt, {String? instructions, GuardrailLevel? guardrailLevel, GenerationOptionsRequest? options})`
- **Parameters**:
  - `prompt`: The text prompt to send
  - `instructions`: Optional system instructions
  - `guardrailLevel`: Optional content safety level
  - `options`: Optional generation configuration
- **Returns**: `Future<ChatResponse>`
- **Description**: Convenience method to send a single prompt without managing a session

### LanguageModelSession

A persistent session for interacting with Apple's Foundation Models.

#### Methods

##### `respond({required String prompt, GenerationOptionsRequest? options})`
- **Parameters**:
  - `prompt`: The text prompt to send to the model
  - `options`: Optional generation configuration
- **Returns**: `Future<ChatResponse>`
- **Description**: Sends a prompt to the language model and returns the response

##### `prewarm()`
- **Returns**: `Future<void>`
- **Description**: Pre-warms the session to reduce first-token latency

##### `dispose()`
- **Returns**: `Future<void>`
- **Description**: Disposes of the session and releases resources

##### `streamResponse({required String prompt, GenerationOptionsRequest? options})`
- **Parameters**:
  - `prompt`: The text prompt to send to the model
  - `options`: Optional generation configuration
- **Returns**: `Stream<StreamChunk>`
- **Description**: Streams response tokens in real-time as they are generated

### Data Classes

#### `AvailabilityResponse`
- `bool isAvailable`: Whether Foundation Models is available
- `String osVersion`: The OS version
- `String? reasonCode`: Structured reason code if unavailable
- `String? errorMessage`: Human-readable error message

#### `ChatResponse`
- `String content`: The response content from the model
- `String? rawContent`: Raw response data
- `List<TranscriptEntry?>? transcriptEntries`: Conversation history
- `String? errorMessage`: Error message if the request failed

#### `TranscriptEntry`
- `String id`: Unique identifier for the entry
- `String role`: Role (user/assistant/instructions/etc.)
- `String content`: The text content
- `List<String>? segments`: Individual text segments

#### `GenerationOptionsRequest`
- `double? temperature`: Controls randomness (0.0-1.0)
- `int? maximumResponseTokens`: Maximum tokens to generate
- `int? samplingTopK`: Top-K sampling parameter
- `double? samplingProbabilityThreshold`: Probability threshold for sampling

#### `GuardrailLevel`
- `strict`: Maximum content safety
- `standard`: Balanced safety and flexibility
- `permissive`: More permissive content transformations

#### `StreamChunk`
- `String streamId`: Unique identifier for the stream
- `String? delta`: New tokens in this chunk
- `String? cumulative`: All tokens received so far
- `String? rawContent`: Raw response data
- `bool isFinal`: Whether this is the last chunk
- `String? errorCode`: Error code if streaming failed
- `String? errorMessage`: Error message if streaming failed
- `bool hasError`: Convenience getter for error checking

## Error Handling

The package handles errors gracefully and returns them in the response:

```dart
try {
  final response = await session.respond(prompt: 'Your prompt here');
  
  if (response.errorMessage != null) {
    // Handle specific errors
    switch (response.errorMessage) {
             case 'Foundation Models requires iOS 26.0 or later':
        print('Device not supported');
        break;
      case 'Foundation Models not available on this device':
        print('Apple Intelligence not available');
        break;
      default:
        print('Error: ${response.errorMessage}');
    }
  } else {
    print('Success: ${response.content}');
  }
} catch (e) {
  print('Unexpected error: $e');
}
```



## Important Notes

### Device Compatibility
- Foundation Models requires iOS 26.0 or later
- Only works on Apple Intelligence-enabled devices in supported regions

### Privacy and Performance
- All processing happens on-device using Apple's Foundation Models
- No data is sent to external servers
- Performance may vary based on device capabilities

### Development Considerations
- Always check availability before using features
- Handle errors gracefully for better user experience
- Consider providing fallback options for unsupported devices
- Test on actual devices with Apple Intelligence enabled

## Example App

The package includes a complete example app demonstrating:
- Availability checking
- Session creation and management
- Prompt-response interactions
- Error handling

Run the example:

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details about changes in each version.

## Support

For issues and questions:
- Create an issue on GitHub
- Check the example app for usage patterns
- Review Apple's Foundation Models documentation
- Check Apple's iOS 26.0+ release notes for hardware compatibility

## References

This package implementation is based on Apple's Foundation Models framework:

- **[Apple Developer Documentation](https://developer.apple.com/documentation/foundationmodels)**: Official API reference
---

**Important**: This package integrates with Apple's Foundation Models framework. Ensure you comply with Apple's terms of service and review their documentation for production use.
