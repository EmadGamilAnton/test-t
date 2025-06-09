import 'package:flutter_test/flutter_test.dart';
import 'package:webview_test/services/flight_service.dart';
import 'package:webview_test/models/flight_order_response.dart';

void main() {
  group('ReservationService Tests', () {
    test('FlightOrderResponse should create from JSON', () {
      final json = {
        'reservationId': 'bf44a8641bf8400ea7683a411a995c13',
        'status': 'Confirmed',
        'passengerName': 'John Doe',
        'flightNumber': 'SV123',
        'departureAirport': 'RUH',
        'arrivalAirport': 'JED',
        'totalAmount': 500.0,
        'currency': 'SAR',
      };

      final response = FlightOrderResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.reservationId, equals('bf44a8641bf8400ea7683a411a995c13'));
      expect(response.status, equals('Confirmed'));
      expect(response.passengerName, equals('John Doe'));
      expect(response.flightNumber, equals('SV123'));
      expect(response.departureAirport, equals('RUH'));
      expect(response.arrivalAirport, equals('JED'));
      expect(response.totalAmount, equals(500.0));
      expect(response.currency, equals('SAR'));
    });

    test('FlightOrderResponse should create error response', () {
      final response = FlightOrderResponse.error('Test error message');

      expect(response.success, isFalse);
      expect(response.errorMessage, equals('Test error message'));
      expect(response.data, isNull);
    });

    test('FlightOrderResponse should handle null values gracefully', () {
      final json = <String, dynamic>{};
      final response = FlightOrderResponse.fromJson(json);

      expect(response.success, isTrue);
      expect(response.reservationId, isNull);
      expect(response.status, isNull);
      expect(response.passengerName, isNull);
      expect(response.flightNumber, isNull);
      expect(response.totalAmount, isNull);
    });
  });
}
