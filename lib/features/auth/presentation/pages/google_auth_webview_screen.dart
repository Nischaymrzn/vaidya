import 'package:flutter/material.dart';
import 'package:vaidya/core/api/api_endpoints.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GoogleAuthWebviewScreen extends StatefulWidget {
  const GoogleAuthWebviewScreen({super.key});

  @override
  State<GoogleAuthWebviewScreen> createState() =>
      _GoogleAuthWebviewScreenState();
}

class _GoogleAuthWebviewScreenState extends State<GoogleAuthWebviewScreen> {
  late final WebViewController _webViewController;
  late final Uri _apiBaseUri;
  bool _isLoading = true;
  String? _errorMessage;

  Uri _rewriteLocalhostCallback(Uri uri) {
    final isLocalhost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    final isGoogleCallback = uri.path.contains('/auth/google/callback');
    if (!isLocalhost || !isGoogleCallback) {
      return uri;
    }

    final targetPort = _apiBaseUri.hasPort ? _apiBaseUri.port : uri.port;
    return uri.replace(
      scheme: _apiBaseUri.scheme,
      host: _apiBaseUri.host,
      port: targetPort,
    );
  }

  void _loadGoogleLogin() {
    _webViewController.loadRequest(Uri.parse(ApiEndpoints.googleLoginUrl));
  }

  @override
  void initState() {
    super.initState();
    _apiBaseUri = Uri.parse(ApiEndpoints.baseUrl);
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage =
                    'Unable to load Google sign-in page. Please try again.';
              });
            }
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.navigate;

            final token = uri.queryParameters['token'];
            if (token != null && token.isNotEmpty) {
              Navigator.of(context).pop(token);
              return NavigationDecision.prevent;
            }

            final error = uri.queryParameters['error'];
            if (error != null && error.isNotEmpty) {
              Navigator.of(context).pop();
              return NavigationDecision.prevent;
            }

            final rewritten = _rewriteLocalhostCallback(uri);
            if (rewritten.toString() != uri.toString()) {
              _webViewController.loadRequest(rewritten);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(ApiEndpoints.googleLoginUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign In')),
      body: _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        _loadGoogleLogin();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
            ),
    );
  }
}
