import 'package:flutter_test/flutter_test.dart';
import 'package:webview_test/services/tamara_service.dart';
import 'package:webview_test/models/tamara_payment_request.dart';

void main() {
  group('TamaraService Tests', () {
    test('TamaraPaymentRequest should create valid JSON', () {
      final request = TamaraPaymentRequest(
        paymentMethod: 'tamara',
        reservationGuid: 'bf44a8641bf8400ea7683a411a995c13',
        deviceToken: 'test-token-456',
      );

      final json = request.toJson();

      expect(json['paymentMethod'], equals('tamara'));
      expect(json['reservationGuid'], equals('bf44a8641bf8400ea7683a411a995c13'));
      expect(json['deviceToken'], equals('test-token-456'));
    });

    test('TamaraPaymentRequest should create from JSON', () {
      final json = {
        'paymentMethod': 'tamara',
        'reservationGuid': 'bf44a8641bf8400ea7683a411a995c13',
        'deviceToken': 'test-token-456',
      };

      final request = TamaraPaymentRequest.fromJson(json);

      expect(request.paymentMethod, equals('tamara'));
      expect(request.reservationGuid, equals('bf44a8641bf8400ea7683a411a995c13'));
      expect(request.deviceToken, equals('test-token-456'));
    });

    test('isPaymentCallback should detect callback URLs', () {
      expect(TamaraService.isPaymentCallback('https://takeed.sa/tamara/?paymentStatus=approved'), isTrue);
      expect(TamaraService.isPaymentCallback('https://takeed.sa/tamara/?paymentStatus=declined'), isTrue);
      expect(TamaraService.isPaymentCallback('https://takeed.sa/tamara/?paymentStatus=cancelled'), isTrue);
      expect(TamaraService.isPaymentCallback('https://example.com/other-page'), isFalse);
    });

    test('getPaymentResult should return correct results', () {
      expect(TamaraService.getPaymentResult('https://takeed.sa/tamara/?paymentStatus=approved'),
             equals(PaymentResult.success));
      expect(TamaraService.getPaymentResult('https://takeed.sa/tamara/?paymentStatus=declined'),
             equals(PaymentResult.failure));
      expect(TamaraService.getPaymentResult('https://takeed.sa/tamara/?paymentStatus=cancelled'),
             equals(PaymentResult.cancelled));
      expect(TamaraService.getPaymentResult('https://takeed.sa/tamara/?paymentStatus=unknown'),
             equals(PaymentResult.unknown));
    });

    test('getOrderId should extract order ID from callback URL', () {
      const testUrl = 'https://takeed.sa/tamara/?paymentStatus=approved&orderId=bc0eab28-b964-4df6-8ed5-15f766dbbf13';
      expect(TamaraService.getOrderId(testUrl), equals('bc0eab28-b964-4df6-8ed5-15f766dbbf13'));
    });
  });
}
