import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_config.dart';
import 'core/app.dart';
import 'core/service_locator.dart';
import 'presentation/screens/main_navigation.dart';

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
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: FirebaseConfig.options);
    }
    isFirebaseAvailable = true;
  } catch (e) {
    isFirebaseAvailable = false;
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NewsFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
