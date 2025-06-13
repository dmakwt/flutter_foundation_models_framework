import 'package:flutter_test/flutter_test.dart';

import 'package:foundation_models_framework/foundation_models_framework.dart';

void main() {
  group('Foundation Models Framework', () {
    test('should create singleton instance', () {
      final instance1 = FoundationModelsFramework.instance;
      final instance2 = FoundationModelsFramework.instance;
      expect(instance1, same(instance2));
    });

    test('should create mock instance for testing', () {
      final mockFramework = FoundationModelsFramework.mock();
      expect(mockFramework, isNotNull);
    });

    test('should have proper data class constructors', () {
      // Test ChatRequest
      final request = ChatRequest(prompt: 'Test prompt');
      expect(request.prompt, 'Test prompt');

      // Test ChatResponse
      final response = ChatResponse(
        content: 'Test response',
        errorMessage: null,
      );
      expect(response.content, 'Test response');
      expect(response.errorMessage, null);

      // Test AvailabilityResponse
      final availability = AvailabilityResponse(
        isAvailable: true,
        osVersion: '26.0',
        errorMessage: null,
      );
      expect(availability.isAvailable, true);
      expect(availability.osVersion, '26.0');
      expect(availability.errorMessage, null);
    });

    group('LanguageModelSession', () {
      test('should create session instance', () {
        final session = LanguageModelSession();
        expect(session, isNotNull);
      });

      test('should create mock session for testing', () {
        final mockSession = LanguageModelSession.mock();
        expect(mockSession, isNotNull);
      });

      test('mock session should return mock response', () async {
        final mockSession = LanguageModelSession.mock();
        final response = await mockSession.respond(prompt: 'Test prompt');

        expect(response.content, 'Mock response to: Test prompt');
        expect(response.errorMessage, null);
      });
    });

    group('FoundationModelsFramework', () {
      test('should create session from framework', () {
        final framework = FoundationModelsFramework.instance;
        final session = framework.createSession();
        expect(session, isNotNull);
      });

      test('mock framework should return mock availability', () async {
        final mockFramework = FoundationModelsFramework.mock();
        final availability = await mockFramework.checkAvailability();

        expect(availability.isAvailable, false);
        expect(availability.errorMessage, contains('Mock implementation'));
      });

      test('mock framework should create mock session', () {
        final mockFramework = FoundationModelsFramework.mock();
        final session = mockFramework.createSession();
        expect(session, isNotNull);
      });

      test('convenience sendPrompt method should work', () async {
        final mockFramework = FoundationModelsFramework.mock();
        final response = await mockFramework.sendPrompt('Test prompt');

        expect(response.content, 'Mock response to: Test prompt');
        expect(response.errorMessage, null);
      });
    });
  });
}
