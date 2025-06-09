class DebugHelper {
  static bool isDebugMode = true;
  
  static void log(String message) {
    if (isDebugMode) {
      print('[DEBUG] $message');
    }
  }
  
  static void logPaymentCallback(String url) {
    log('Payment callback URL: $url');
    
    // Parse and log all query parameters
    try {
      final uri = Uri.parse(url);
      log('Host: ${uri.host}');
      log('Path: ${uri.path}');
      log('Query parameters:');
      uri.queryParameters.forEach((key, value) {
        log('  $key: $value');
      });
    } catch (e) {
      log('Error parsing URL: $e');
    }
  }
  
  static void logPaymentResult(String result, String? orderId) {
    log('Payment result: $result');
    log('Order ID: ${orderId ?? 'null'}');
  }
}
