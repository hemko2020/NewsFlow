import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/article_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedCountryProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final geolocationAsync = ref.watch(geolocationProvider);
    final deviceLanguage = ref.watch(deviceLanguageProvider);

    String getCountryName(String? code) {
      if (code == null) return 'Automatique';
      const countryNames = {
        'us': 'États-Unis',
        'fr': 'France',
        'gb': 'Royaume-Uni',
        'de': 'Allemagne',
        'ca': 'Canada',
        'au': 'Australie',
        'jp': 'Japon',
        'cn': 'Chine',
        'in': 'Inde',
        'br': 'Brésil',
      };
      return countryNames[code] ?? code.toUpperCase();
    }

    String getLanguageName(String? code) {
      if (code == null) return 'Automatique (${getLanguageName(deviceLanguage)})';
      const languageNames = {
        'ar': 'العربية',
        'en': 'English',
        'de': 'Deutsch',
        'es': 'Español',
        'fr': 'Français',
        'it': 'Italiano',
        'he': 'עברית',
        'nl': 'Nederlands',
        'no': 'Norsk',
        'pt': 'Português',
        'ru': 'Русский',
        'sv': 'Svenska',
        'ud': 'Undefined',
        'zh': '中文',
      };
      return languageNames[code] ?? code.toUpperCase();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          const SizedBox(height: 16),
          const Text(
            'Utilisateur NewsFlow',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'newsflow@example.com',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Settings
          const Text(
            'Paramètres',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Country selection
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Pays des actualités'),
            subtitle: Text(getCountryName(selectedCountry ?? geolocationAsync.maybeWhen(
              data: (data) => data,
              orElse: () => null,
            ))),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showCountryPicker(context, ref),
          ),

          // Language selection
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue des actualités'),
            subtitle: Text(getLanguageName(selectedLanguage)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          // Notification settings
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Recevoir des notifications d\'articles'),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: toggle notifications
              },
            ),
          ),

          // Dark mode
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Mode sombre'),
            subtitle: const Text('Activer le thème sombre'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: toggle dark mode
              },
            ),
          ),

          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Langue'),
            subtitle: const Text('Français'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: change language
            },
          ),

          // About
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('À propos'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'NewsFlow',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 NewsFlow',
              );
            },
          ),

          // Privacy policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Politique de confidentialité'),
            onTap: () {
              // TODO: show privacy policy
            },
          ),

          // Terms of service
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Conditions d\'utilisation'),
            onTap: () {
              // TODO: show terms
            },
          ),

          const Divider(),
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Se déconnecter',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () {
              // TODO: sign out
            },
          ),
        ],
      ),
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    const countries = {
      null: 'Automatique (géolocalisation)',
      'us': 'États-Unis',
      'fr': 'France',
      'gb': 'Royaume-Uni',
      'de': 'Allemagne',
      'ca': 'Canada',
      'au': 'Australie',
      'jp': 'Japon',
      'cn': 'Chine',
      'in': 'Inde',
      'br': 'Brésil',
      'es': 'Espagne',
      'it': 'Italie',
      'mx': 'Mexique',
      'ar': 'Argentine',
      'ru': 'Russie',
      'za': 'Afrique du Sud',
      'kr': 'Corée du Sud',
      'nl': 'Pays-Bas',
      'se': 'Suède',
      'no': 'Norvège',
      'dk': 'Danemark',
      'fi': 'Finlande',
      'pl': 'Pologne',
      'pt': 'Portugal',
      'tr': 'Turquie',
      'th': 'Thaïlande',
      'my': 'Malaisie',
      'sg': 'Singapour',
      'ch': 'Suisse',
      'at': 'Autriche',
      'be': 'Belgique',
      'cz': 'République Tchèque',
      'gr': 'Grèce',
      'hu': 'Hongrie',
      'ie': 'Irlande',
      'il': 'Israël',
      'nz': 'Nouvelle-Zélande',
      'ph': 'Philippines',
      'ro': 'Roumanie',
      'sk': 'Slovaquie',
      'si': 'Slovénie',
      'ua': 'Ukraine',
      've': 'Venezuela',
      'vn': 'Vietnam',
    };

    final currentCountry = ref.read(selectedCountryProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: countries.entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              selected: entry.key == currentCountry,
              onTap: () {
                ref.read(selectedCountryProvider.notifier).setCountry(entry.key);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    const languages = {
      null: 'Automatique',
      'ar': 'العربية',
      'en': 'English',
      'de': 'Deutsch',
      'es': 'Español',
      'fr': 'Français',
      'it': 'Italiano',
      'he': 'עברית',
      'nl': 'Nederlands',
      'no': 'Norsk',
      'pt': 'Português',
      'ru': 'Русский',
      'sv': 'Svenska',
      'zh': '中文',
    };

    final currentLanguage = ref.read(selectedLanguageProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: languages.entries.map((entry) {
            return ListTile(
              title: Text(entry.value),
              selected: entry.key == currentLanguage,
              onTap: () {
                ref.read(selectedLanguageProvider.notifier).setLanguage(entry.key);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}
