import 'package:flutter_test/flutter_test.dart';

import 'package:foundation_models_framework/foundation_models_framework.dart';

void main() {
  group('Foundation Models Framework', () {
    test('should create singleton instance', () {
      final instance1 = FoundationModelsFramework.instance;
      final instance2 = FoundationModelsFramework.instance;
      expect(instance1, same(instance2));
    });

    test('should have proper data class constructors', () {
      // Test SummarizationRequest
      final request = SummarizationRequest(
        text: 'Test text',
        maxLength: 100,
        style: 'brief',
      );
      expect(request.text, 'Test text');
      expect(request.maxLength, 100);
      expect(request.style, 'brief');

      // Test AvailabilityResponse
      final availability = AvailabilityResponse(
        isAvailable: true,
        osVersion: '18.1',
        errorMessage: null,
      );
      expect(availability.isAvailable, true);
      expect(availability.osVersion, '18.1');
      expect(availability.errorMessage, null);
    });
  });
}
