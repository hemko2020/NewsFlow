import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'article_detail_screen.dart';
import 'article_webview_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../providers/article_provider.dart';

// Provider to track if we're in webview mode
final isWebViewModeProvider = StateProvider<bool>((ref) => false);

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    ExploreScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedArticle = ref.watch(selectedArticleProvider);
        final isWebViewMode = ref.watch(isWebViewModeProvider);

        return Scaffold(
          body: Stack(
            children: [
              // Main content
              selectedArticle != null
                  ? (isWebViewMode
                        ? ArticleWebViewScreen(article: selectedArticle)
                        : ArticleDetailScreen(article: selectedArticle))
                  : _screens[_selectedIndex],
              // Overlay for bottom navigation (only show when article is selected)
              if (selectedArticle != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: CustomBottomNavBar(
                        selectedIndex: _selectedIndex,
                        onItemTapped: (index) {
                          // Clear selected article when navigating to other tabs
                          ref.read(selectedArticleProvider.notifier).state =
                              null;
                          ref.read(isWebViewModeProvider.notifier).state =
                              false;
                          _onItemTapped(index);
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: selectedArticle == null
              ? CustomBottomNavBar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: _onItemTapped,
                )
              : null,
        );
      },
    );
  }
}
