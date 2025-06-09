import 'package:flutter/material.dart';
import '../services/flight_service.dart';
import '../models/flight_order_response.dart';

class GetReservationScreen extends StatefulWidget {
  final String reservationGuid;
  final String? orderId;

  const GetReservationScreen({
    super.key,
    required this.reservationGuid,
    this.orderId,
  });

  @override
  State<GetReservationScreen> createState() => _GetReservationScreenState();
}

class _GetReservationScreenState extends State<GetReservationScreen> {
  bool _isLoading = true;
  FlightOrderResponse? _flightOrder;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservationDetails();
  }

  Future<void> _loadReservationDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await FlightService.getReservation(
        reservationGuid: widget.reservationGuid,
      );

      setState(() {
        _isLoading = false;
        if (response.success) {
          _flightOrder = response;
        } else {
          _errorMessage = response.errorMessage;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'خطأ في تحميل بيانات الحجز: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الحجز'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservationDetails,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('جاري تحميل بيانات الحجز...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadReservationDetails,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    if (_flightOrder != null) {
      return _buildReservationDetails();
    }

    return const Center(
      child: Text('لا توجد بيانات للعرض'),
    );
  }

  Widget _buildReservationDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[300]!),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  'تم الدفع بنجاح! ✅',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (widget.orderId != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'رقم الطلب: ${widget.orderId}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reservation details
          const Text(
            'تفاصيل الحجز',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildDetailCard('رقم الحجز', widget.reservationGuid),
          
          if (_flightOrder!.status != null)
            _buildDetailCard('حالة الحجز', _flightOrder!.status!),
          
          if (_flightOrder!.passengerName != null)
            _buildDetailCard('اسم المسافر', _flightOrder!.passengerName!),
          
          if (_flightOrder!.flightNumber != null)
            _buildDetailCard('رقم الرحلة', _flightOrder!.flightNumber!),
          
          if (_flightOrder!.departureAirport != null)
            _buildDetailCard('مطار المغادرة', _flightOrder!.departureAirport!),
          
          if (_flightOrder!.arrivalAirport != null)
            _buildDetailCard('مطار الوصول', _flightOrder!.arrivalAirport!),
          
          if (_flightOrder!.departureDate != null)
            _buildDetailCard('تاريخ المغادرة', _flightOrder!.departureDate!),
          
          if (_flightOrder!.arrivalDate != null)
            _buildDetailCard('تاريخ الوصول', _flightOrder!.arrivalDate!),
          
          if (_flightOrder!.totalAmount != null && _flightOrder!.currency != null)
            _buildDetailCard(
              'المبلغ الإجمالي', 
              '${_flightOrder!.totalAmount} ${_flightOrder!.currency}',
            ),

          // Raw response for debugging (if available)
          if (_flightOrder!.data?['rawResponse'] != null) ...[
            const SizedBox(height: 24),
            const Text(
              'استجابة الخادم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                _flightOrder!.data!['rawResponse'].toString(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],

          const SizedBox(height: 32),

          // Back to home button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'العودة للصفحة الرئيسية',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
