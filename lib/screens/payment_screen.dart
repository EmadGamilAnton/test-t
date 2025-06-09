import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/tamara_service.dart';
import '../utils/debug_helper.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final Function(PaymentResult, String?) onPaymentResult;

  const PaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.onPaymentResult,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress if needed
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });

            // Check for callback on page start as well
            DebugHelper.log('Page started loading: $url');
            if (TamaraService.isPaymentCallback(url)) {
              DebugHelper.logPaymentCallback(url);
              final result = TamaraService.getPaymentResult(url);
              final orderId = TamaraService.getOrderId(url);
              DebugHelper.logPaymentResult(result.toString(), orderId);
              widget.onPaymentResult(result, orderId);
              Navigator.of(context).pop();
            }
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Also check for callback on page finished
            DebugHelper.log('Page finished loading: $url');
            if (TamaraService.isPaymentCallback(url)) {
              DebugHelper.log('Payment callback detected on page finish - processing...');

              final result = TamaraService.getPaymentResult(url);
              final orderId = TamaraService.getOrderId(url);

              DebugHelper.log('Payment result from page finish: $result');
              DebugHelper.log('Order ID from page finish: $orderId');

              // Call the callback
              widget.onPaymentResult(result, orderId);
              Navigator.of(context).pop();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            DebugHelper.log('Navigation URL: ${request.url}');

            // Check if this is a payment callback
            if (TamaraService.isPaymentCallback(request.url)) {
              DebugHelper.log('Payment callback detected - processing...');

              final result = TamaraService.getPaymentResult(request.url);
              final orderId = TamaraService.getOrderId(request.url);

              DebugHelper.log('Payment result: $result');
              DebugHelper.log('Order ID: $orderId');

              // Call the callback immediately
              DebugHelper.log('Calling onPaymentResult...');
              widget.onPaymentResult(result, orderId);

              // Close the payment screen
              DebugHelper.log('Closing payment screen...');
              Navigator.of(context).pop();

              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في تحميل الصفحة: ${error.description}'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دفع تمارا'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentResult(PaymentResult.cancelled, null);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
