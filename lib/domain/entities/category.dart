import 'package:flutter/material.dart';

enum Category {
  finance('Finance', Icons.attach_money, Colors.green),
  health('Santé', Icons.local_hospital, Colors.red),
  technology('Technologie', Icons.computer, Colors.purple),
  sports('Sport', Icons.sports_soccer, Colors.teal),
  entertainment('Divertissement', Icons.movie, Colors.pink),
  sciences('Sciences', Icons.science, Colors.cyan);

  const Category(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}
