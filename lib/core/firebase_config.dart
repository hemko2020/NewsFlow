import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseConfig {
  static FirebaseOptions get options {
    String getEnv(String key, {String fallback = ''}) {
      try {
        final value = dotenv.get(key, fallback: fallback);
        return value.isNotEmpty ? value : fallback;
      } catch (e) {
        return fallback;
      }
    }

    return FirebaseOptions(
      apiKey: getEnv('FIREBASE_API_KEY', fallback: 'demo_api_key'),
      appId: getEnv('FIREBASE_APP_ID', fallback: '1:demo:android:demo'),
      messagingSenderId: getEnv('FIREBASE_MESSAGING_SENDER_ID', fallback: '123456789'),
      projectId: getEnv('FIREBASE_PROJECT_ID', fallback: 'demo-project'),
      storageBucket: getEnv('FIREBASE_STORAGE_BUCKET', fallback: 'demo-project.appspot.com'),
    );
  }

  static bool isValid() {
    try {
      final opts = options;
      return opts.apiKey != 'demo_api_key' &&
             opts.appId != '1:demo:android:demo' &&
             opts.projectId != 'demo-project';
    } catch (e) {
      return false;
    }
  }
}
