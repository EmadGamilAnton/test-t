class FlightOrderResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? errorMessage;

  FlightOrderResponse({
    required this.success,
    this.data,
    this.errorMessage,
  });

  factory FlightOrderResponse.fromJson(Map<String, dynamic> json) {
    return FlightOrderResponse(
      success: true,
      data: json,
    );
  }

  factory FlightOrderResponse.error(String message) {
    return FlightOrderResponse(
      success: false,
      errorMessage: message,
    );
  }

  // Helper getters to extract common fields
  String? get reservationId => data?['reservationId']?.toString();
  String? get status => data?['status']?.toString();
  String? get passengerName => data?['passengerName']?.toString();
  String? get flightNumber => data?['flightNumber']?.toString();
  String? get departureDate => data?['departureDate']?.toString();
  String? get arrivalDate => data?['arrivalDate']?.toString();
  String? get departureAirport => data?['departureAirport']?.toString();
  String? get arrivalAirport => data?['arrivalAirport']?.toString();
  double? get totalAmount => data?['totalAmount']?.toDouble();
  String? get currency => data?['currency']?.toString();
}
