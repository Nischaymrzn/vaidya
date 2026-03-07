import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ProfileCheckoutWebviewScreen extends StatefulWidget {
  final String checkoutUrl;

  const ProfileCheckoutWebviewScreen({super.key, required this.checkoutUrl});

  @override
  State<ProfileCheckoutWebviewScreen> createState() =>
      _ProfileCheckoutWebviewScreenState();
}

class _ProfileCheckoutWebviewScreenState
    extends State<ProfileCheckoutWebviewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            final rawUrl = request.url.trim();
            final uri = Uri.tryParse(rawUrl);
            final url = rawUrl.toLowerCase();
            final scheme = uri?.scheme.toLowerCase();
            final host = uri?.host.toLowerCase();
            final path = uri?.path.toLowerCase() ?? '';
            final paymentQuery = (uri?.queryParameters['payment'] ?? '')
                .toLowerCase();

            final isPaymentDeepLink = scheme == 'vaidya' && host == 'payment';
            final isSuccess =
                (isPaymentDeepLink && path.contains('success')) ||
                paymentQuery == 'success' ||
                url.contains('payment=success');
            final isCancelled =
                (isPaymentDeepLink && path.contains('cancelled')) ||
                paymentQuery == 'cancelled' ||
                url.contains('payment=cancelled');

            if (isSuccess) {
              Navigator.of(context).pop(true);
              return NavigationDecision.prevent;
            }
            if (isCancelled) {
              Navigator.of(context).pop(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stripe Checkout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}
