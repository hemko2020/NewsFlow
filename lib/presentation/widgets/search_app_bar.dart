import 'package:flutter/material.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final VoidCallback onSearch;
  final VoidCallback onClear;

  const SearchAppBar({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: TextField(
        controller: searchController,
        decoration: const InputDecoration(
          hintText: 'Rechercher des articles...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70),
        ),
        style: const TextStyle(color: Colors.white),
        onSubmitted: (_) => onSearch(),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: onSearch),
        IconButton(icon: const Icon(Icons.clear), onPressed: onClear),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
