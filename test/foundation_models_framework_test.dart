import 'package:flutter_test/flutter_test.dart';

import 'package:foundation_models_framework/foundation_models_framework.dart';

void main() {
  group('Foundation Models Framework (mock)', () {
    late FoundationModelsFramework mockFramework;

    setUp(() {
      mockFramework = FoundationModelsFramework.mock();
    });

    test('singleton instance remains stable', () {
      final instance1 = FoundationModelsFramework.instance;
      final instance2 = FoundationModelsFramework.instance;
      expect(instance1, same(instance2));
    });

    test('mock availability returns informative message', () async {
      final availability = await mockFramework.checkAvailability();
      expect(availability.isAvailable, isFalse);
      expect(availability.reasonCode, equals('mock'));
      expect(
        availability.errorMessage,
        contains('Foundation Models requires physical device'),
      );
    });

    test('mock session responds with canned transcript', () async {
      final session = mockFramework.createSession();
      final response = await session.respond(prompt: 'Hello');

      expect(response.content, equals('Mock response to: Hello'));
      expect(response.rawContent, equals('mock'));
      expect(response.transcriptEntries, isNotNull);
      expect(response.transcriptEntries, isNotEmpty);
      expect(response.transcriptEntries!.first?.role, equals('user'));
      expect(response.transcriptEntries!.first?.segments, isNotNull);
    });

    test('mock sendPrompt convenience method disposes session', () async {
      final response = await mockFramework.sendPrompt('Hi there');
      expect(response.content, equals('Mock response to: Hi there'));
    });

    test('mock stream emits single final chunk', () async {
      final session = mockFramework.createSession();
      final chunks = await session
          .streamResponse(prompt: 'Stream test')
          .toList();

      expect(chunks.length, equals(1));
      final chunk = chunks.single;
      expect(chunk.isFinal, isTrue);
      expect(chunk.errorMessage, isNull);
      expect(chunk.errorCode, isNull);
      expect(chunk.cumulative, equals('Mock response to: Stream test'));
    });
  });
}
