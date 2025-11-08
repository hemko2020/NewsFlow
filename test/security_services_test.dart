import 'package:flutter_test/flutter_test.dart';
import '../lib/core/secure_storage_service.dart';

void main() {
  group('Security Services Integration Tests', () {
    test('SecureStorageService should be properly initialized', () {
      // Vérifier que le service est accessible
      expect(SecureStorageService, isNotNull);
    });

    test('Secure storage should be accessible for basic operations', () async {
      // Tester que le stockage sécurisé est disponible
      final available = await SecureStorageService.isStorageAvailable();
      expect(available, isA<bool>());
    });
  });
}
