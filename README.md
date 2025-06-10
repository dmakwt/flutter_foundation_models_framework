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

A Flutter package for integrating with Apple's Foundation Models framework on iOS devices. This package provides access to on-device AI capabilities including text summarization and embedding generation, leveraging Apple Intelligence features.

## Features

- ✅ **Text Summarization**: Generate concise summaries using Apple's LanguageModelSession
- ✅ **Text Embeddings**: Create vector representations with semantic analysis simulation
- ✅ **Device Availability Check**: Verify Apple Intelligence and Foundation Models support
- ✅ **Type-safe API**: Built with Pigeon for reliable platform communication
- ✅ **iOS 26.0+ Beta Support**: Uses authentic Apple Foundation Models framework APIs
- ✅ **Privacy-First**: All processing happens on-device with Apple Intelligence

## Requirements

- **iOS**: 26.0 Beta or later
- **Flutter**: 3.0.0 or later
- **Dart**: 3.8.1 or later
- **Xcode**: 26.0 or later
- **Apple Intelligence**: Must be enabled on device

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  foundation_models_framework: ^0.0.1
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

### 3. Add Foundation Models Framework

The Foundation Models framework will be automatically linked through the podspec. No additional configuration is required.

## Usage

### Simulator vs Device Testing

> **⚠️ IMPORTANT**: Foundation Models framework **CANNOT** be tested in iOS Simulator. It requires physical hardware with Apple Intelligence support.

**Physical Device (Recommended):**
- Full Foundation Models functionality
- Real Apple Intelligence features
- Requires iOS 26.0 Beta device
- iPhone 15 Pro/Pro Max or newer with Neural Engine


Before using Foundation Models features, check if they're available on the device:

```dart
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

### Text Summarization

Generate summaries of long text content:

```dart
try {
  final summary = await foundationModels.summarizeText(
    'Your long text content here...',
    maxLength: 100,
    style: 'brief', // Options: 'brief', 'detailed', 'keyword'
  );
  
  print('Original length: ${summary.originalLength}');
  print('Summary length: ${summary.summaryLength}');
  print('Summary: ${summary.summary}');
} catch (e) {
  print('Summarization failed: $e');
}
```

### Text Embeddings

Generate vector embeddings for semantic analysis:

```dart
try {
  final embedding = await foundationModels.generateEmbedding(
    'Text to generate embeddings for',
    model: 'default', // Optional model specification
  );
  
  print('Embedding dimensions: ${embedding.dimensions}');
  print('First few values: ${embedding.embedding.take(5).toList()}');
} catch (e) {
  print('Embedding generation failed: $e');
}
```


## API Reference

### FoundationModelsFramework

The main class for accessing Foundation Models functionality.

#### Methods

##### `checkAvailability()`
- **Returns**: `Future<AvailabilityResponse>`
- **Description**: Checks if Foundation Models is available on the device

##### `summarizeText(String text, {int? maxLength, String? style})`
- **Parameters**:
  - `text`: The text to summarize
  - `maxLength`: Optional maximum length for summary
  - `style`: Optional style ('brief', 'detailed', 'keyword')
- **Returns**: `Future<SummarizationResponse>`
- **Description**: Generates a text summary

##### `generateEmbedding(String text, {String? model})`
- **Parameters**:
  - `text`: The text to generate embeddings for
  - `model`: Optional model specification
- **Returns**: `Future<EmbeddingResponse>`
- **Description**: Generates text embeddings

### Data Classes

#### `AvailabilityResponse`
- `bool isAvailable`: Whether Foundation Models is available
- `String osVersion`: The iOS version
- `String? errorMessage`: Error message if not available

#### `SummarizationResponse`
- `String summary`: The generated summary
- `int originalLength`: Length of original text
- `int summaryLength`: Length of summary

#### `EmbeddingResponse`
- `List<double> embedding`: The embedding vector
- `int dimensions`: Number of dimensions in the embedding

## Error Handling

The package throws specific exceptions for different error scenarios:

```dart
try {
  final result = await foundationModels.summarizeText('...');
} on PlatformException catch (e) {
  switch (e.code) {
    case 'unavailable':
      print('Foundation Models not available on this device');
      break;
    case 'summarization_failed':
      print('Text summarization failed: ${e.message}');
      break;
    case 'embedding_failed':
      print('Embedding generation failed: ${e.message}');
      break;
    default:
      print('Unknown error: ${e.message}');
  }
}
```

## Simulator Testing Limitations

### Why Foundation Models Cannot Run in Simulator

The Foundation Models framework has fundamental hardware and software requirements that prevent it from running in the iOS Simulator:

#### **Hardware Requirements**
- **Neural Engine**: Requires Apple's Neural Engine for on-device AI processing
- **Apple Intelligence**: Must have Apple Intelligence-enabled hardware (A17 Pro, M1, M2, etc.)
- **Memory & Storage**: Specific RAM and storage requirements for model loading
- **Simulator Limitation**: iOS Simulator runs on your Mac's hardware, not iOS-specific chips

#### **Software Architecture**
- **On-Device Only**: Foundation Models runs entirely on-device with no cloud fallback
- **Framework Availability**: Foundation Models framework is only compiled for physical iOS devices
- **Apple Intelligence Integration**: Requires full Apple Intelligence stack not available in Simulator

#### **Development Workaround**
This package provides a **mock implementation** for simulator testing:
- Simulates API responses for development
- Allows UI testing and error handling verification
- Maintains the same API interface for seamless switching

```dart
// Automatically uses mock in simulator, real implementation on device
final foundation = Platform.environment.containsKey('SIMULATOR_DEVICE_NAME') 
    ? FoundationModelsFramework.mock() 
    : FoundationModelsFramework.instance;
```


## Important Notes

### Foundation Models Framework Implementation
- **Authentic Implementation**: Based on [real-world examples](https://github.com/rudrankriyam/Foundation-Models-Framework-Example) and [WWDC25 patterns](https://developer.apple.com/videos/play/wwdc2025/286/)
- **SystemLanguageModel Integration**: Uses `SystemLanguageModel.availability` for proper device compatibility checking
- **LanguageModelSession Usage**: Implements text processing through `LanguageModelSession` with custom instructions
- **Service Architecture**: Clean separation of concerns with dedicated `FoundationModelsService` class
- **Error Handling**: Comprehensive error handling following Apple's recommended patterns
- **Embedding Generation**: Uses semantic analysis approach consistent with Foundation Models philosophy
- **Beta Status**: This framework requires iOS 26.0 Beta and is subject to changes

### Device Compatibility
- Foundation Models requires iOS 26.0 Beta or later
- Only works on Apple Intelligence-enabled devices in supported regions
- The framework checks device support, region availability, and feature enablement
- Some features may require specific hardware capabilities

### Privacy and Performance
- All processing happens on-device using Apple's Foundation Models
- No data is sent to external servers
- Performance may vary based on device capabilities
- Large texts may take longer to process

### Development Considerations
- Always check availability before using features using `SystemLanguageModel.availability`
- Handle errors gracefully for better user experience
- Consider providing fallback options for unsupported devices
- Test on actual devices with Apple Intelligence enabled


## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details about changes in each version.

## Support

For issues and questions:
- Create an issue on GitHub
- Check the example app for usage patterns
- Review Apple's Foundation Models documentation: https://developer.apple.com/documentation/foundationmodels
- Check Apple's iOS 26.0 Beta release notes for hardware compatibility

## References & Examples

This package implementation is based on authentic Foundation Models examples and Apple's official documentation:

- **[Foundation Models Framework Example by Rudrank Riyam](https://github.com/rudrankriyam/Foundation-Models-Framework-Example)**: Comprehensive Swift implementation showing real-world usage patterns
- **[WWDC25: Meet the Foundation Models framework](https://developer.apple.com/videos/play/wwdc2025/286/)**: Official Apple presentation covering framework features and best practices
- **[Apple Developer Documentation](https://developer.apple.com/documentation/foundationmodels)**: Official API reference and technical documentation


---

**Important Notes**: 
- This package integrates with Apple's Foundation Models framework, which is currently in Beta (iOS 26.0+)
- The framework APIs are subject to changes as they're still in development
- Requires devices with Apple Intelligence enabled and in supported regions
- Please review Apple's documentation and licensing requirements for production use
- This package is for development and testing purposes with the beta framework
