class TamaraPaymentRequest {
  final String paymentMethod;
  final String reservationGuid;
  final String deviceToken;

  TamaraPaymentRequest({
    required this.paymentMethod,
    required this.reservationGuid,
    required this.deviceToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentMethod': paymentMethod,
      'reservationGuid': reservationGuid,
      'deviceToken': deviceToken,
    };
  }

  factory TamaraPaymentRequest.fromJson(Map<String, dynamic> json) {
    return TamaraPaymentRequest(
      paymentMethod: json['paymentMethod'] ?? '',
      reservationGuid: json['reservationGuid'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
    );
  }
}
