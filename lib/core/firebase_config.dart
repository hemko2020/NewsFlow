import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const String appName = 'newsflow-6b8c1';

  static FirebaseOptions get options {
    // Using hardcoded values from .env file
    // In production, these would be injected via CI/CD or Envied
    return const FirebaseOptions(
      apiKey: 'dAIzaSyB1p8sNPW1eCm9vuWw2SjEzv0zi5dGdCRc',
      appId: '1:780714228095:android:67e8ef11b862659987c24a',
      messagingSenderId: '780714228095',
      projectId: 'newsflow-6b8c1',
      storageBucket: 'newsflow-6b8c1.firebasestorage.app',
    );
  }

  static bool isValid() {
    try {
      final opts = options;
      return opts.apiKey.isNotEmpty &&
          opts.appId.isNotEmpty &&
          opts.projectId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
