import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:logging/logging.dart';

class HtmlFetchService {
  final http.Client _client;
  final Logger _logger = Logger('HtmlFetchService');

  HtmlFetchService(this._client);

  Future<String> fetchArticleContent(String url) async {
    try {
      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'en-US,en;q=0.5',
          'Accept-Encoding': 'gzip, deflate',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        throw Exception('Request timed out');
      });

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);

        // Remove unwanted elements
        _removeUnwantedElements(document);

        // Extract and clean the main content
        final cleanedHtml = _extractMainContent(document);

        return cleanedHtml;
      } else {
        throw Exception('Failed to load article: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching article content: $e');
    }
  }

  void _removeUnwantedElements(dom.Document document) {
    // Remove common unwanted elements
    final selectorsToRemove = [
      'script',
      'style',
      'nav',
      'header',
      'footer',
      '.advertisement',
      '.ads',
      '.ad',
      '.social-share',
      '.comments',
      '.newsletter',
      '.popup',
      '.modal',
      'iframe',
      '.video-player',
      // Common ad selectors
      '[class*="ad-"]',
      '[class*="ads-"]',
      '[id*="ad-"]',
      '[id*="ads-"]',
      // Social media widgets
      '.twitter-timeline',
      '.facebook-plugin',
      // Newsletter signup
      '.newsletter-signup',
      '.subscribe-form',
      // Related articles and suggestions
      '.related-articles',
      '.related-posts',
      '.related-content',
      '.suggested-articles',
      '.recommended-articles',
      '.more-articles',
      '.article-suggestions',
      '.related-links',
      '.also-read',
      '.you-might-like',
      '.similar-articles',
      '.article-related',
      '.related-stories',
      '.further-reading',
      // Common related article selectors
      '[class*="related"]',
      '[class*="suggested"]',
      '[class*="recommended"]',
      '[id*="related"]',
      '[id*="suggested"]',
      '[id*="recommended"]',
      // Sidebar content
      'aside',
      '.sidebar',
      '.side-content',
      // Author bio and other meta content
      '.author-bio',
      '.article-meta',
      '.article-info',
      '.byline',
    ];

    for (final selector in selectorsToRemove) {
      try {
        final elements = document.querySelectorAll(selector);
        for (final element in elements) {
          element.remove();
        }
      } catch (e) {
        // Log errors for selectors that don't exist or cause issues
        _logger.warning('Error removing selector: $selector - $e');
      }
    }
  }

  String _extractMainContent(dom.Document document) {
    // Try to find main content using common selectors
    final contentSelectors = [
      'article',
      '[class*="content"]',
      '[class*="article"]',
      '[class*="post"]',
      '[class*="entry"]',
      '.main-content',
      '#main-content',
      '.post-content',
      '#post-content',
      '.entry-content',
      '#entry-content',
      // Generic content containers
      'main',
      '.content',
      '#content',
    ];

    dom.Element? mainContent;

    for (final selector in contentSelectors) {
      try {
        mainContent = document.querySelector(selector);
        if (mainContent != null && mainContent.text.trim().length > 200) {
          break;
        }
      } catch (e) {
        _logger.warning('Error with content selector: $selector - $e');
        continue;
      }
    }

    // If no specific content found, use body but clean it
    mainContent ??= document.body ?? document.documentElement;

    if (mainContent != null) {
      // Add basic styling for better readability
      final styledHtml = '''
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
              line-height: 1.6;
              color: #333;
              margin: 0;
              padding: 16px;
              max-width: 100%;
              word-wrap: break-word;
              background-color: #ffffff;
            }

            /* Responsive images */
            img {
              max-width: 100% !important;
              height: auto !important;
              width: auto !important;
              display: block;
              margin: 16px auto;
              border-radius: 8px;
              box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            }

            /* Large images should take full width */
            img[width="100%"],
            img[style*="width: 100%"],
            img[style*="width:100%"] {
              width: 100% !important;
              max-width: 100% !important;
            }

            /* Images with captions */
            figure {
              margin: 20px 0;
              text-align: center;
            }

            figure img {
              margin: 0 auto 8px auto;
            }

            /* Typography */
            h1, h2, h3, h4, h5, h6 {
              color: #1a1a1a;
              margin-top: 24px;
              margin-bottom: 16px;
              line-height: 1.2;
              font-weight: 600;
            }

            h1 { font-size: 24px; }
            h2 { font-size: 20px; }
            h3 { font-size: 18px; }

            p {
              margin-bottom: 16px;
              text-align: justify;
            }

            /* Links */
            a {
              color: #007AFF;
              text-decoration: none;
            }

            a:hover {
              text-decoration: underline;
            }

            /* Blockquotes */
            blockquote {
              border-left: 4px solid #ddd;
              margin: 16px 0;
              padding-left: 16px;
              color: #666;
              font-style: italic;
              background-color: #f9f9f9;
              padding: 12px 16px;
              border-radius: 4px;
            }

            /* Lists */
            ul, ol {
              margin: 16px 0;
              padding-left: 24px;
            }

            li {
              margin-bottom: 8px;
            }

            /* Tables */
            table {
              border-collapse: collapse;
              width: 100%;
              margin: 16px 0;
              overflow-x: auto;
              display: block;
            }

            th, td {
              border: 1px solid #ddd;
              padding: 8px;
              text-align: left;
            }

            th {
              background-color: #f5f5f5;
              font-weight: 600;
            }

            /* Code blocks */
            pre, code {
              background-color: #f5f5f5;
              border-radius: 4px;
              font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
              font-size: 14px;
            }

            pre {
              padding: 16px;
              overflow-x: auto;
              margin: 16px 0;
            }

            code {
              padding: 2px 4px;
            }

            /* Hide any remaining unwanted elements */
            .hidden, [style*="display: none"], [style*="visibility: hidden"] {
              display: none !important;
            }

            /* Responsive design */
            @media (max-width: 480px) {
              body {
                padding: 12px;
                font-size: 16px;
              }

              h1 { font-size: 22px; }
              h2 { font-size: 18px; }
              h3 { font-size: 16px; }

              img {
                margin: 12px 0;
                border-radius: 6px;
              }
            }
          </style>
        </head>
        <body>
          ${mainContent.outerHtml}
        </body>
        </html>
      ''';

      return styledHtml;
    }

    // Fallback: return a simple message
    return '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            text-align: center;
            padding: 50px 20px;
            color: #666;
          }
        </style>
      </head>
      <body>
        <h2>Content not available</h2>
        <p>Unable to load the content of this article.</p>
      </body>
      </html>
    ''';
  }
}
