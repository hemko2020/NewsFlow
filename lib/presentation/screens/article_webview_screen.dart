import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/article.dart';
import '../../data/services/html_fetch_service.dart';
import '../../core/service_locator.dart';
import '../providers/article_provider.dart';
import '../screens/main_navigation.dart';

class ArticleWebViewScreen extends ConsumerStatefulWidget {
  final Article article;

  const ArticleWebViewScreen({super.key, required this.article});

  @override
  ConsumerState<ArticleWebViewScreen> createState() => _ArticleWebViewScreenState();
}

class _ArticleWebViewScreenState extends ConsumerState<ArticleWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadArticleContent();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Erreur de chargement: ${error.description}';
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Permettre la navigation seulement vers le contenu de l'article
            // Bloquer les liens externes pour une meilleure expérience utilisateur
            if (request.url.startsWith('data:') ||
                request.url == widget.article.url ||
                request.url.contains(widget.article.url.split('/')[2])) {
              return NavigationDecision.navigate;
            }

            // Pour les liens externes, demander confirmation à l'utilisateur
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Ouvrir le lien'),
                  content: const Text('Ce lien va ouvrir une page externe. Voulez-vous continuer ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Ouvrir dans le navigateur externe
                        launchUrl(Uri.parse(request.url.toString()),
                            mode: LaunchMode.externalApplication);
                      },
                      child: const Text('Ouvrir'),
                    ),
                  ],
                ),
              );
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    _isInitialized = true;
  }

  Future<void> _loadArticleContent() async {
    try {
      final htmlFetchService = getIt<HtmlFetchService>();
      final htmlContent = await htmlFetchService.fetchArticleContent(widget.article.url);

      if (mounted) {
        await _controller.loadHtmlString(htmlContent);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de charger l\'article: $e';
        });

        // Fallback: charger directement l'URL
        try {
          await _controller.loadRequest(Uri.parse(widget.article.url));
        } catch (fallbackError) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Erreur complète: Impossible de charger l\'article';
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(favoritesNotifierProvider).any((fav) => fav.id == widget.article.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.article.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Return to article details mode
            ref.read(isWebViewModeProvider.notifier).state = false;
          },
        ),
        actions: [
          // Favorite button
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: () {
              ref.read(favoritesNotifierProvider.notifier).toggleFavorite(widget.article);
            },
          ),
          // Share button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              await Share.share('${widget.article.title}\n\n${widget.article.url}');
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _loadArticleContent();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isInitialized)
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadArticleContent();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // Ouvrir dans le navigateur externe
                        final uri = Uri.parse(widget.article.url);
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          // Copier l'URL si impossible d'ouvrir
                          await Clipboard.setData(ClipboardData(text: widget.article.url));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('URL copiée dans le presse-papiers')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Ouvrir dans le navigateur'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
