import 'package:flutter/material.dart';

enum Category {
  politics('Politique', Icons.account_balance, Colors.blue),
  finance('Finance', Icons.attach_money, Colors.green),
  health('Santé', Icons.local_hospital, Colors.red),
  technology('Technologie', Icons.computer, Colors.purple),
  ai('IA', Icons.smart_toy, Colors.orange),
  gaming('Jeux vidéo', Icons.games, Colors.indigo),
  crypto('Crypto-monnaie', Icons.currency_bitcoin, Colors.yellow),
  sports('Sport', Icons.sports_soccer, Colors.teal),
  entertainment('Divertissement', Icons.movie, Colors.pink),
  sciences('Sciences', Icons.science, Colors.cyan);

  const Category(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}
