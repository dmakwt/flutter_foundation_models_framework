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

> **⚠️ DEVELOPMENT STATUS**: This package is still under development and not ready for production use. 

A Flutter package for integrating with Apple's Foundation Models framework on iOS devices. This package provides access to on-device AI capabilities through language model sessions, leveraging Apple Intelligence features.

## Features

- ✅ **Language Model Sessions**: Create sessions and interact with Apple's Foundation Models
- ✅ **Prompt-Response Interface**: Send prompts and receive responses from on-device AI models
- ✅ **Device Availability Check**: Verify Apple Intelligence and Foundation Models support
- ✅ **Type-safe API**: Built with Pigeon for reliable platform communication
- ✅ **iOS 26.0+ Support**: Uses authentic Apple Foundation Models framework APIs
- ✅ **Privacy-First**: All processing happens on-device with Apple Intelligence

## Requirements

- **iOS**: 26.0 or later
- **Flutter**: 3.0.0 or later
- **Dart**: 3.8.1 or later
- **Xcode**: 16.0 or later
- **Apple Intelligence**: Must be enabled on device

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  foundation_models_framework: ^0.1.0
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
// Create a session
final session = foundationModels.createSession();

// Send a prompt and get a response
try {
  final response = await session.respond(prompt: 'Hello, how are you?');
  
  if (response.errorMessage == null) {
    print('Response: ${response.content}');
  } else {
    print('Error: ${response.errorMessage}');
  }
} catch (e) {
  print('Failed to get response: $e');
}
```

### Convenience Method for Single Prompts

For single interactions, you can use the convenience method:

```dart
try {
  final response = await foundationModels.sendPrompt('What is the weather like today?');
  
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
```

## API Reference

### FoundationModelsFramework

The main class for accessing Foundation Models functionality.

#### Methods

##### `checkAvailability()`
- **Returns**: `Future<AvailabilityResponse>`
- **Description**: Checks if Foundation Models is available on the device
- **Note**: Returns true only if iOS version is 26.0+ and Apple Intelligence is available

##### `createSession()`
- **Returns**: `LanguageModelSession`
- **Description**: Creates a new language model session for interacting with Foundation Models

##### `sendPrompt(String prompt)`
- **Parameters**: `prompt` - The text prompt to send
- **Returns**: `Future<ChatResponse>`
- **Description**: Convenience method to send a single prompt without managing a session

### LanguageModelSession

A session for interacting with Apple's Foundation Models.

#### Methods

##### `respond({required String prompt})`
- **Parameters**: `prompt` - The text prompt to send to the model
- **Returns**: `Future<ChatResponse>`
- **Description**: Sends a prompt to the language model and returns the response

### Data Classes

#### `AvailabilityResponse`
- `bool isAvailable`: Whether Foundation Models is available
- `String osVersion`: The iOS version
- `String? errorMessage`: Error message if not available

#### `ChatRequest`
- `String prompt`: The prompt text to send to the model

#### `ChatResponse`
- `String content`: The response content from the model
- `String? errorMessage`: Error message if the request failed

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
