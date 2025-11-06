import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
}
