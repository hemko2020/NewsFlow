import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/article_provider.dart';

import '../../core/constants/strings.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCountry = ref.watch(selectedCountryProvider);
    final selectedLanguage = ref.watch(selectedLanguageProvider);
    final geolocationAsync = ref.watch(geolocationProvider);
    final deviceLanguage = ref.watch(deviceLanguageProvider);

    String getCountryName(String? code) {
      if (code == null) return AppStrings.automatic;
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
      if (code == null)
        return '${AppStrings.automatic} (${getLanguageName(deviceLanguage)})';
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          AppStrings.profileTitle,
          style: TextStyle(color: Colors.white, fontFamily: 'Serif'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile header
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF1C1C1E),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.defaultUserName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            AppStrings.defaultUserEmail,
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Settings
          const Text(
            AppStrings.settingsTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Country selection
          _buildSettingsTile(
            context,
            icon: Icons.location_on,
            title: AppStrings.countrySettings,
            subtitle: getCountryName(
              selectedCountry ??
                  geolocationAsync.maybeWhen(
                    data: (data) => data,
                    orElse: () => null,
                  ),
            ),
            onTap: () => _showCountryPicker(context, ref),
          ),

          // Language selection
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: AppStrings.languageSettings,
            subtitle: getLanguageName(selectedLanguage),
            onTap: () => _showLanguagePicker(context, ref),
          ),

          // Notification settings
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: AppStrings.notificationsSettings,
            subtitle: AppStrings.notificationsSubtitle,
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: toggle notifications
              },
              activeColor: Colors.red,
            ),
          ),

          // Dark mode
          _buildSettingsTile(
            context,
            icon: Icons.dark_mode,
            title: AppStrings.darkModeSettings,
            subtitle: AppStrings.darkModeSubtitle,
            trailing: Switch(
              value: true, // Always true for now as we enforced dark mode
              onChanged: (value) {
                // TODO: toggle dark mode
              },
              activeColor: Colors.red,
            ),
          ),

          // About
          const Divider(color: Colors.grey),
          _buildSettingsTile(
            context,
            icon: Icons.info,
            title: AppStrings.aboutSettings,
            subtitle: 'Version 1.0.0',
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
          _buildSettingsTile(
            context,
            icon: Icons.privacy_tip,
            title: AppStrings.privacyPolicy,
            onTap: () {
              // TODO: show privacy policy
            },
          ),

          // Terms of service
          _buildSettingsTile(
            context,
            icon: Icons.description,
            title: AppStrings.termsOfService,
            onTap: () {
              // TODO: show terms
            },
          ),

          const Divider(color: Colors.grey),
          // Sign out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              AppStrings.signOut,
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

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.white)
              : null),
      onTap: onTap,
    );
  }

  void _showCountryPicker(BuildContext context, WidgetRef ref) {
    const countries = {
      null: AppStrings.automaticGeolocation,
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
                ref
                    .read(selectedCountryProvider.notifier)
                    .setCountry(entry.key);
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
                ref
                    .read(selectedLanguageProvider.notifier)
                    .setLanguage(entry.key);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }
}
