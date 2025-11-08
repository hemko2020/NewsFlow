import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Configuration pour sécurité maximale : Keystore sur Android, Keychain sur iOS
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false, // Force Keystore usage
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Clés pour données sensibles
  static const String _firebaseIdTokenKey = 'firebase_id_token';
  static const String _firebaseRefreshTokenKey = 'firebase_refresh_token';
  static const String _userEmailKey = 'user_email';
  static const String _userSubscriptionKey = 'user_subscription_data';
  static const String _paymentTokenKey = 'payment_token'; // Token sécurisé, pas données bancaires
  static const String _biometricEnabledKey = 'biometric_enabled';

  // === TOKENS FIREBASE ===
  static Future<void> storeFirebaseIdToken(String token) async {
    await _storage.write(key: _firebaseIdTokenKey, value: token);
  }

  static Future<String?> getFirebaseIdToken() async {
    return await _storage.read(key: _firebaseIdTokenKey);
  }

  static Future<void> deleteFirebaseIdToken() async {
    await _storage.delete(key: _firebaseIdTokenKey);
  }

  static Future<void> storeFirebaseRefreshToken(String token) async {
    await _storage.write(key: _firebaseRefreshTokenKey, value: token);
  }

  static Future<String?> getFirebaseRefreshToken() async {
    return await _storage.read(key: _firebaseRefreshTokenKey);
  }

  static Future<void> deleteFirebaseRefreshToken() async {
    await _storage.delete(key: _firebaseRefreshTokenKey);
  }

  // === DONNÉES PERSONNELLES ===
  static Future<void> storeUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  static Future<void> deleteUserEmail() async {
    await _storage.delete(key: _userEmailKey);
  }

  // === DONNÉES D'ABONNEMENT (pas de données bancaires !) ===
  static Future<void> storeSubscriptionData(String subscriptionJson) async {
    await _storage.write(key: _userSubscriptionKey, value: subscriptionJson);
  }

  static Future<String?> getSubscriptionData() async {
    return await _storage.read(key: _userSubscriptionKey);
  }

  static Future<void> deleteSubscriptionData() async {
    await _storage.delete(key: _userSubscriptionKey);
  }

  // === TOKEN DE PAIEMENT SÉCURISÉ (de Stripe/PayPal, pas données bancaires) ===
  static Future<void> storePaymentToken(String token) async {
    await _storage.write(key: _paymentTokenKey, value: token);
  }

  static Future<String?> getPaymentToken() async {
    return await _storage.read(key: _paymentTokenKey);
  }

  static Future<void> deletePaymentToken() async {
    await _storage.delete(key: _paymentTokenKey);
  }

  // === BIOMÉTRIE ===
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  // === SÉCURITÉ ===
  static Future<void> clearAllSensitiveData() async {
    await _storage.deleteAll();
  }

  // Vérifier si le stockage sécurisé est disponible
  static Future<bool> isStorageAvailable() async {
    try {
      await _storage.read(key: 'test_key');
      return true;
    } catch (e) {
      return false;
    }
  }
}
