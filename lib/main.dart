import 'package:flutter/material.dart';
import 'screens/payment_screen.dart';
import 'screens/get_reservation_screen.dart';
import 'services/tamara_service.dart';
import 'models/tamara_payment_response.dart';
import 'utils/debug_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'تطبيق دفع تمارا'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _reservationController = TextEditingController();
  final TextEditingController _deviceTokenController = TextEditingController();
  bool _isLoading = false;
  String _lastPaymentResult = '';
  String? _lastOrderId;

  @override
  void initState() {
    super.initState();
    // Set default values for testing
    _reservationController.text = 'bf44a8641bf8400ea7683a411a995c13';
    _deviceTokenController.text = 'test-device-token-456';
  }

  @override
  void dispose() {
    _reservationController.dispose();
    _deviceTokenController.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    if (_reservationController.text.isEmpty || _deviceTokenController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await TamaraService.createPaymentSession(
        reservationGuid: _reservationController.text,
        deviceToken: _deviceTokenController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (response.success && response.paymentUrl != null) {
        // Navigate to payment screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              paymentUrl: response.paymentUrl!,
              onPaymentResult: _handlePaymentResult,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إنشاء جلسة الدفع: ${response.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentResult(PaymentResult result, String? orderId) {
    DebugHelper.log('=== _handlePaymentResult CALLED ===');
    DebugHelper.log('Result: $result');
    DebugHelper.log('Order ID: $orderId');
    DebugHelper.log('Reservation GUID: ${_reservationController.text}');

    String message;
    Color color;

    switch (result) {
      case PaymentResult.success:
        DebugHelper.log('Processing SUCCESS result...');
        message = 'تم الدفع بنجاح! ✅';
        if (orderId != null) {
          message += '\nرقم الطلب: $orderId';
        }
        color = Colors.green;

        DebugHelper.log('About to navigate to GetReservationScreen...');
        DebugHelper.log('Context mounted: ${mounted}');

        // Check if widget is still mounted
        if (!mounted) {
          DebugHelper.log('Widget not mounted, cannot navigate');
          return;
        }

        // Use a post-frame callback to ensure we're in the right state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DebugHelper.log('Post-frame callback executing...');

          if (!mounted) {
            DebugHelper.log('Widget not mounted in post-frame callback');
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                DebugHelper.log('Building GetReservationScreen...');
                return GetReservationScreen(
                  reservationGuid: _reservationController.text,
                  orderId: orderId,
                );
              },
            ),
          ).then((_) {
            DebugHelper.log('Navigation completed successfully');
          }).catchError((error) {
            DebugHelper.log('Navigation failed with error: $error');
          });
        });

        DebugHelper.log('Post-frame callback scheduled');
        break;
      case PaymentResult.failure:
        message = 'فشل في عملية الدفع ❌';
        color = Colors.red;
        break;
      case PaymentResult.cancelled:
        message = 'تم إلغاء عملية الدفع';
        color = Colors.orange;
        break;
      case PaymentResult.unknown:
        message = 'نتيجة غير معروفة';
        color = Colors.grey;
        break;
    }

    setState(() {
      _lastPaymentResult = message;
      _lastOrderId = orderId;
    });

    // Only show snackbar for non-success results
    if (result != PaymentResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'بيانات الدفع',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _reservationController,
              decoration: const InputDecoration(
                labelText: 'رقم الحجز (Reservation GUID)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _deviceTokenController,
              decoration: const InputDecoration(
                labelText: 'رمز الجهاز (Device Token)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(height: 32),



            ElevatedButton(
              onPressed: _isLoading ? null : _startPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text('جاري التحميل...'),
                      ],
                    )
                  : const Text(
                      'ادفع بتمارا',
                      style: TextStyle(fontSize: 18),
                    ),
            ),

            const SizedBox(height: 24),

            if (_lastPaymentResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نتيجة آخر عملية دفع:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(_lastPaymentResult),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
