import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_config.dart';
import 'core/app.dart';
import 'core/service_locator.dart';
import 'core/router.dart';

bool isFirebaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
  } catch (e) {
    // Could not load .env file
  }

  try {
    final apiKey = dotenv.get('NEWS_API_KEY');
    if (apiKey.isEmpty || apiKey == 'your_news_api_key_here') {
      // NEWS_API_KEY not set properly
    }
  } catch (e) {
    // Could not read NEWS_API_KEY
  }

  setupServiceLocator();

  try {
    // Check if Firebase config is valid before initializing
    final isValid = FirebaseConfig.isValid();

    if (isValid) {
      try {
        await Firebase.initializeApp(
          name: FirebaseConfig.appName,
          options: FirebaseConfig.options,
        );
        isFirebaseAvailable = true;
      } catch (e) {
        if (e is FirebaseException && e.code == 'duplicate-app') {
          isFirebaseAvailable = true; // App already exists, this is fine
        } else {
          isFirebaseAvailable = false;
        }
      }
    } else {
      isFirebaseAvailable = false;
    }
  } catch (e) {
    isFirebaseAvailable = false;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NewsFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
