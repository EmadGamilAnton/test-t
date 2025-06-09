import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/flight_order_response.dart';

class FlightService {
  static const String baseUrl = 'https://takeed.runasp.net/api/v1/reservation';
  static const String getReservationEndpoint = '/get-by-id';

  /// Gets reservation details by reservation GUID
  /// Returns a FlightOrderResponse with reservation details or error
  static Future<FlightOrderResponse> getReservation({
    required String reservationGuid,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$getReservationEndpoint?ReservationGUID=$reservationGuid'),
        headers: {
          'accept': '*/*',
        },
      );

      if (response.statusCode == 200) {
        // Try to parse as JSON first
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          return FlightOrderResponse.fromJson(responseData);
        } catch (e) {
          // If not JSON, treat as plain text response
          return FlightOrderResponse.fromJson({
            'rawResponse': response.body,
            'reservationId': reservationGuid,
            'status': 'Retrieved',
          });
        }
      } else {
        return FlightOrderResponse.error(
          'Failed to get reservation. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      return FlightOrderResponse.error(
        'Error getting reservation: $e',
      );
    }
  }
}
