import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, 0, Icons.home_filled),
          _buildNavItem(context, 1, Icons.explore_outlined),
          _buildNavItem(context, 2, Icons.bookmark_border),
          _buildNavItem(context, 3, Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFFD32F2F) : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
