import 'package:flutter/material.dart';

enum Category {
  general('Général', Icons.article, Colors.blue),  // Catégorie par défaut
  finance('Finance', Icons.attach_money, Colors.green),
  health('Santé', Icons.local_hospital, Colors.red),
  sciences('Sciences', Icons.science, Colors.cyan),
  technology('Technologie', Icons.computer, Colors.purple),
  sports('Sport', Icons.sports_soccer, Colors.teal),
  entertainment('Divertissement', Icons.movie, Colors.pink);

  // Note: Enum reordering is safe because the code uses enum values directly
  // rather than indices. No persistence layer or API communication relies on
  // ordinal positions of these enum values.

  const Category(this.displayName, this.icon, this.color);

  final String displayName;
  final IconData icon;
  final Color color;
}
