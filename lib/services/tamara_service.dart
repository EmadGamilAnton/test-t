import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/tamara_payment_request.dart';
import '../models/tamara_payment_response.dart';

class TamaraService {
  static const String baseUrl = 'https://takeed.runasp.net/api/v1/tamara';
  static const String createSessionEndpoint = '/create-session';

  /// Creates a payment session with Tamara
  /// Returns a TamaraPaymentResponse with payment URL or error
  static Future<TamaraPaymentResponse> createPaymentSession({
    required String reservationGuid,
    required String deviceToken,
  }) async {
    try {
      final request = TamaraPaymentRequest(
        paymentMethod: 'tamara',
        reservationGuid: reservationGuid,
        deviceToken: deviceToken,
      );

      final response = await http.post(
        Uri.parse('$baseUrl$createSessionEndpoint'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        // Check if the API response indicates success
        if (responseData['success'] == true && responseData['statusCode'] == 200) {
          return TamaraPaymentResponse(
            success: true,
            paymentUrl: responseData['data'], // The URL is directly in 'data' field
            sessionId: null, // No session ID in this response format
            data: responseData,
          );
        } else {
          return TamaraPaymentResponse.error(
            responseData['message'] ?? 'Unknown error from API',
          );
        }
      } else {
        return TamaraPaymentResponse.error(
          'Failed to create payment session. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return TamaraPaymentResponse.error(
        'Error creating payment session: $e',
      );
    }
  }

  /// Validates payment callback URL
  static bool isPaymentCallback(String url) {
    // Check for multiple possible callback URL patterns
    return (url.contains('takeed.sa/tamara/') && url.contains('paymentStatus=')) ||
           (url.contains('paymentStatus=')) ||
           (url.contains('payment-success')) ||
           (url.contains('payment-failure')) ||
           (url.contains('payment-cancel')) ||
           (url.contains('success=true')) ||
           (url.contains('success=false')) ||
           (url.contains('status=approved')) ||
           (url.contains('status=declined'));
  }

  /// Extracts payment result from callback URL
  static PaymentResult getPaymentResult(String url) {
    // Parse the URL to get various possible parameters
    final uri = Uri.parse(url);
    final paymentStatus = uri.queryParameters['paymentStatus'];
    final status = uri.queryParameters['status'];
    final success = uri.queryParameters['success'];

    // Check paymentStatus parameter first
    switch (paymentStatus) {
      case 'approved':
        return PaymentResult.success;
      case 'declined':
      case 'failed':
        return PaymentResult.failure;
      case 'cancelled':
      case 'canceled':
        return PaymentResult.cancelled;
    }

    // Check status parameter
    switch (status) {
      case 'approved':
      case 'success':
        return PaymentResult.success;
      case 'declined':
      case 'failed':
      case 'failure':
        return PaymentResult.failure;
      case 'cancelled':
      case 'canceled':
        return PaymentResult.cancelled;
    }

    // Check success parameter
    if (success == 'true') {
      return PaymentResult.success;
    } else if (success == 'false') {
      return PaymentResult.failure;
    }

    // Check URL patterns
    if (url.contains('payment-success') || url.contains('success')) {
      return PaymentResult.success;
    } else if (url.contains('payment-failure') || url.contains('failed')) {
      return PaymentResult.failure;
    } else if (url.contains('payment-cancel') || url.contains('cancel')) {
      return PaymentResult.cancelled;
    }

    return PaymentResult.unknown;
  }

  /// Extracts order ID from callback URL
  static String? getOrderId(String url) {
    final uri = Uri.parse(url);
    // Try different possible parameter names
    return uri.queryParameters['orderId'] ??
           uri.queryParameters['order_id'] ??
           uri.queryParameters['orderID'] ??
           uri.queryParameters['id'];
  }
}

enum PaymentResult {
  success,
  failure,
  cancelled,
  unknown,
}
