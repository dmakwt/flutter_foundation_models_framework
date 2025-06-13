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
