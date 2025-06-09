class TamaraPaymentResponse {
  final bool success;
  final String? paymentUrl;
  final String? sessionId;
  final String? errorMessage;
  final int? statusCode;
  final String? message;
  final Map<String, dynamic>? data;

  TamaraPaymentResponse({
    required this.success,
    this.paymentUrl,
    this.sessionId,
    this.errorMessage,
    this.statusCode,
    this.message,
    this.data,
  });

  factory TamaraPaymentResponse.fromJson(Map<String, dynamic> json) {
    return TamaraPaymentResponse(
      success: json['success'] ?? false,
      statusCode: json['statusCode'],
      message: json['message'],
      paymentUrl: json['data'] is String ? json['data'] : null,
      sessionId: null, // Not provided in this API format
      data: json,
    );
  }

  factory TamaraPaymentResponse.error(String message) {
    return TamaraPaymentResponse(
      success: false,
      errorMessage: message,
    );
  }
}
