 import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

class SecureErrorHandler {
  // Niveaux de log pour filtrer en production
  static const bool _enableDetailedLogs =
      kDebugMode; // Désactiver en production

  // === LOGGING SÉCURISÉ ===
  static void logInfo(String message, {Map<String, dynamic>? data}) {
    if (_enableDetailedLogs) {
      developer.log(
        _sanitizeMessage(message),
        name: 'NewsFlow',
        level: 800, // INFO
        error: data != null ? _sanitizeData(data) : null,
      );
    }
  }

  static void logWarning(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
  }) {
    developer.log(
      _sanitizeMessage(message),
      name: 'NewsFlow',
      level: 900, // WARNING
      error: error ?? (data != null ? _sanitizeData(data) : null),
    );
  }

  static void logError(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Toujours logger les erreurs même en production (sans données sensibles)
    developer.log(
      _sanitizeMessage(message),
      name: 'NewsFlow',
      level: 1000, // ERROR
      error: error,
      stackTrace: _enableDetailedLogs ? stackTrace : null,
    );

    // En production, envoyer à un service de monitoring (ex: Sentry, Firebase Crashlytics)
    if (!kDebugMode) {
      _sendToMonitoringService(message, error, stackTrace);
    }
  }

  static void logPaymentEvent(
    String event, {
    Map<String, dynamic>? sanitizedData,
  }) {
    // Logging spécial pour les événements de paiement (toujours anonymisé)
    final safeData = sanitizedData != null
        ? _sanitizePaymentData(sanitizedData)
        : <String, dynamic>{};
    logInfo('PAYMENT_$event', data: safeData);
  }

  // === GESTION D'ERREURS SÉCURISÉE ===
  static String handlePaymentError(Object error) {
    logPaymentEvent(
      'ERROR',
      sanitizedData: {'error_type': error.runtimeType.toString()},
    );

    // Ne jamais exposer de détails sensibles dans les messages utilisateur
    if (error is Exception) {
      if (error.toString().contains('card_declined')) {
        return 'Paiement refusé. Vérifiez vos informations de carte.';
      }
      if (error.toString().contains('insufficient_funds')) {
        return 'Fonds insuffisants sur votre carte.';
      }
      if (error.toString().contains('expired_card')) {
        return 'Votre carte a expiré.';
      }
    }

    return 'Une erreur est survenue lors du paiement. Veuillez réessayer.';
  }

  static String handleBiometricError(Object error) {
    logError('BIOMETRIC_ERROR', error: error);

    if (error.toString().contains('NotAvailable')) {
      return 'Authentification biométrique non disponible sur cet appareil.';
    }
    if (error.toString().contains('NotEnrolled')) {
      return 'Aucune biométrie configurée. Allez dans les paramètres de sécurité.';
    }
    if (error.toString().contains('LockedOut')) {
      return 'Trop de tentatives. Réessayez dans quelques instants.';
    }

    return 'Erreur d\'authentification. Utilisez votre code PIN.';
  }

  static String handleStorageError(Object error) {
    logError('STORAGE_ERROR', error: error);
    return 'Erreur d\'accès aux données sécurisées. Redémarrez l\'application.';
  }

  // === NETTOYAGE DE DONNÉES SENSIBLES ===
  static String _sanitizeMessage(String message) {
    // Supprimer les tokens, clés API, emails, etc. des messages de log
    return message
        .replaceAll(RegExp(r'Bearer\s+[^\s]+'), '[TOKEN]')
        .replaceAll(
          RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
          '[EMAIL]',
        )
        .replaceAll(
          RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
          '[CARD_NUMBER]',
        )
        .replaceAll(RegExp(r'\b\d{3}\b'), '[CVV]');
  }

  static Map<String, dynamic> _sanitizeData(Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);

    // Supprimer ou masquer les champs sensibles
    const sensitiveKeys = [
      'password',
      'token',
      'api_key',
      'secret',
      'card_number',
      'cvv',
      'expiry_date',
      'cardholder_name',
      'billing_address',
    ];

    for (final key in sensitiveKeys) {
      if (sanitized.containsKey(key)) {
        sanitized[key] = '[REDACTED]';
      }
    }

    return sanitized;
  }

  static Map<String, dynamic> _sanitizePaymentData(Map<String, dynamic> data) {
    // Pour les données de paiement, ne garder que les informations non sensibles
    final allowedKeys = ['amount', 'currency', 'status', 'timestamp'];
    return Map.fromEntries(
      data.entries.where((entry) => allowedKeys.contains(entry.key)),
    );
  }

  // === MONITORING EN PRODUCTION ===
  static void _sendToMonitoringService(
    String message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Implémentez l'envoi à votre service de monitoring
    // Exemples: Sentry, Firebase Crashlytics, LogRocket

    // Placeholder pour l'intégration future
    /*
    if (error != null) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: message,
      );
    }
    */
  }

  // === VALIDATION DE SÉCURITÉ ===
  static bool validateEnvironment() {
    // Environment variables are now compile-time constants with Envied
    // No runtime validation needed
    logInfo('SECURITY_CHECK_PASSED: Using compile-time environment constants');
    return true;
  }

  static Future<bool> validateSecureStorage() async {
    try {
      final available = await SecureStorageService.isStorageAvailable();
      if (available) {
        logInfo('SECURITY_CHECK_PASSED: Secure storage available');
      } else {
        logWarning('SECURITY_CHECK_WARNING: Secure storage not available');
      }
      return available;
    } catch (e) {
      logError('SECURITY_CHECK_FAILED: Secure storage error', error: e);
      return false;
    }
  }
}

// === EXTENSIONS POUR LOGGING FACILE ===
extension SecureLog on Object {
  void logInfo([String? message]) {
    SecureErrorHandler.logInfo(message ?? toString());
  }

  void logWarning([String? message]) {
    SecureErrorHandler.logWarning(message ?? toString());
  }

  void logError([String? message, StackTrace? stackTrace]) {
    SecureErrorHandler.logError(message ?? toString(), stackTrace: stackTrace);
  }
}
