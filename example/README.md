# Foundation Models Framework Example

A complete example app demonstrating the Flutter Foundation Models Framework integration with Apple's on-device AI.

## Features Demonstrated

- ✅ Availability checking for Apple Intelligence
- ✅ Session creation and management
- ✅ Prompt-response interactions
- ✅ Streaming responses with real-time token updates
- ✅ Generation options configuration
- ✅ Guardrail level settings
- ✅ Error handling and recovery
- ✅ Multi-turn conversations with context

## Getting Started

### Prerequisites

- iOS 26.0+ or macOS 15.0+ (with Apple Intelligence enabled)
- Xcode 16.0+
- Physical device (simulator uses mock responses)

### Running the Example

```bash
cd example
flutter run
```

## Usage Examples

The example app includes:

1. **Status Check**: Verify Foundation Models availability
2. **Session Management**: Create and reuse sessions
3. **Chat Interface**: Interactive conversation UI
4. **Streaming Demo**: Real-time token streaming display
5. **Options Panel**: Configure generation parameters

## Key Code Examples

### Basic Response
```dart
final response = await session.respond(prompt: 'Hello!');
print(response.content);
```

### Streaming
```dart
final stream = session.streamResponse(prompt: 'Tell me a story');
await for (final chunk in stream) {
  print('New tokens: ${chunk.delta}');
}
```

### With Options
```dart
final response = await session.respond(
  prompt: 'Explain quantum physics',
  options: GenerationOptionsRequest(
    temperature: 0.7,
    maximumResponseTokens: 500,
  ),
);
```
