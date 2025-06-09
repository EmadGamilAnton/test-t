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
    // Check for Tamara callback URL pattern
    return url.contains('takeed.sa/tamara/') && url.contains('paymentStatus=');
  }

  /// Extracts payment result from callback URL
  static PaymentResult getPaymentResult(String url) {
    // Parse the URL to get paymentStatus parameter
    final uri = Uri.parse(url);
    final paymentStatus = uri.queryParameters['paymentStatus'];

    switch (paymentStatus) {
      case 'approved':
        return PaymentResult.success;
      case 'declined':
      case 'failed':
        return PaymentResult.failure;
      case 'cancelled':
      case 'canceled':
        return PaymentResult.cancelled;
      default:
        return PaymentResult.unknown;
    }
  }

  /// Extracts order ID from callback URL
  static String? getOrderId(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters['orderId'];
  }
}

enum PaymentResult {
  success,
  failure,
  cancelled,
  unknown,
}
