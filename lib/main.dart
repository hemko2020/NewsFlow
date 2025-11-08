import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/firebase_config.dart';
import 'core/app.dart';
import 'core/service_locator.dart';
import 'presentation/screens/main_navigation.dart';

// Flag global pour indiquer si Firebase est disponible
bool isFirebaseAvailable = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🚀 Starting NewsFlow...');

  // Chargement sécurisé du fichier .env avec gestion d'erreur
  try {
    await dotenv.load();
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Warning: Could not load .env file: $e');
    print('💡 Continuing without .env file');
  }

  // Vérifier si NEWS_API_KEY est chargé
  try {
    final apiKey = dotenv.get('NEWS_API_KEY');
    if (apiKey.isNotEmpty && apiKey != 'your_news_api_key_here') {
      print('✅ NEWS_API_KEY loaded successfully');
    } else {
      print('⚠️ NEWS_API_KEY not set or is default value');
    }
  } catch (e) {
    print('⚠️ Could not read NEWS_API_KEY: $e');
  }

  // Initialize service locator
  setupServiceLocator();
  print('🔧 Service locator initialized');

  // Initialize Firebase
  try {
    // Check if Firebase is already initialized (useful for hot reload)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: FirebaseConfig.options,
      );
      print('✅ Firebase initialized successfully');
    } else {
      print('ℹ️ Firebase already initialized, skipping initialization');
    }
    isFirebaseAvailable = true;
  } catch (e) {
    isFirebaseAvailable = false;
    print('⚠️ Firebase initialization failed: $e');
    print('💡 Continuing without Firebase features');
  }

  print('🎯 Launching app...');
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
