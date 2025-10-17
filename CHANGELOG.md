## 0.2.0

**MAJOR UPDATE**: Complete implementation overhaul with proper Apple Foundation Models API compliance, cross-platform support, streaming capabilities, and enhanced features.

### 🎉 New Features
- **Streaming Support**: Real-time token streaming with delta updates and cancellation support
- **macOS Support**: Full macOS 15.0+ platform support alongside iOS 26.0+
- **Persistent Sessions**: Proper session lifecycle management with transcript history
- **Generation Options**: Control temperature, token limits, and sampling strategies
- **Guardrail Levels**: Configure content safety (strict/standard/permissive)
- **Session Instructions**: Provide system-level instructions for behavior guidance
- **Rich Responses**: Access raw content, transcript entries, and structured metadata
- **Session Pre-warming**: Reduce first-token latency with `prewarm()` method
- **Resource Management**: Proper session disposal with `dispose()` method

### 🔧 API Improvements
- **Session Management**: Sessions now persist across multiple interactions
- **Error Handling**: Structured error codes and sanitized error messages
- **Security**: Built-in prompt validation and injection protection
- **Performance**: Session reuse instead of recreation per request
- **Type Safety**: Enhanced Pigeon schema with new data classes

### 🐛 Bug Fixes
- Fixed incorrect `LanguageModelSession()` instantiation
- Updated availability enum to match Apple's final API
- Corrected response method signatures
- Fixed session lifecycle issues causing performance degradation
- Resolved memory management concerns

### 🛠 Technical Changes
- Implemented native streaming with EventChannel for real-time token delivery
- Unified iOS/macOS implementation with platform conditionals
- Added `SessionManager` for proper resource management
- Implemented `SecurityManager` for prompt validation
- Updated to use correct `SystemLanguageModel.Availability.UnavailableReason` enum
- Added proper generation options mapping
- Implemented transcript entry serialization with segments
- Thread-safe streaming with proper task cancellation and cleanup

### 📱 Platform Updates
- iOS: 26.0+ (unchanged)
- macOS: 15.0+ (new)
- Both platforms use unified Swift implementation

### 📚 Documentation
- Updated README with new API features
- Added generation options examples
- Documented guardrail levels
- Enhanced API reference with all new methods
- Added cross-platform setup instructions

### ⚠️ Known Limitations
- Structured generation (`@Generable`) not yet supported
- Tool/function calling not available
- Requires physical device with Apple Intelligence enabled
- iOS version numbers are placeholders pending Apple's final release

## 0.1.0

**BREAKING CHANGES**: Complete API redesign to focus on session-based Foundation Models framework.

### 🔄 API Changes
- **REMOVED**: Text summarization and embedding features
- **NEW**: Session-based language model interaction using `LanguageModelSession`
- **NEW**: Prompt-response interface with `respond()` method
- **NEW**: Convenience `sendPrompt()` method for single interactions

### ✨ New Features
- **Language Model Sessions**: Create persistent sessions for multi-turn conversations
- **Session Management**: Easy session creation via `FoundationModelsFramework.createSession()`
- **Mock Implementation**: Full mock support for development and testing
- **Enhanced Error Handling**: Graceful error handling with detailed error messages

### 🛠 Technical Changes
- Updated Pigeon API definition to use `ChatRequest` and `ChatResponse`
- Simplified Swift implementation using `LanguageModelSession()` directly
- Improved availability checking for iOS 26.0+ and Apple Intelligence
- Updated example app with modern chat interface
- Comprehensive test coverage for new API

### 📱 Example App
- Beautiful chat-like interface
- Session management demonstration
- Real-time prompt-response interactions
- Error handling and availability checking

### 📚 Documentation
- Complete README update with new usage examples
- Session-based conversation patterns
- Mock testing guidelines
- Updated API reference

## 0.0.1

Initial release of Foundation Models Framework for Flutter.

### Features
- **Text Summarization**: Generate concise summaries using Apple's Foundation Models
- **Text Embeddings**: Create vector representations for semantic analysis
- **Device Availability Check**: Verify Foundation Models support on iOS devices
- **Type-safe API**: Built with Pigeon for reliable platform communication
- **iOS 26.0+ Support**: Full integration with Apple's Foundation Models framework

### Platform Support
- iOS 26.0 or later
- Flutter 3.0.0 or later

### Documentation
- Comprehensive README with installation and usage instructions
- Complete example application demonstrating all features
- API reference and error handling guidelines

### Technical Implementation
- Pigeon-generated platform channels for type-safe communication
- Swift implementation using Foundation Models framework
- Singleton pattern for easy access to functionality
- Proper error handling and device compatibility checks
