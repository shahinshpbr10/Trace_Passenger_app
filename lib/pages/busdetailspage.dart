import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BusDetailsPage extends StatefulWidget {
  final Map<String, dynamic> bus;
  const BusDetailsPage({super.key, required this.bus});

  @override
  State<BusDetailsPage> createState() => _BusDetailsPageState();
}

class _BusDetailsPageState extends State<BusDetailsPage> {
  String? selectedRoute;
  int passengerCount = 1;
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userSnap = await FirebaseFirestore.instance.collection('passengers').doc(uid).get();
    final passengerData = userSnap.data();
    final bus = widget.bus;
    final routeName = selectedRoute!;
    final amount = bus['routes'][routeName] * passengerCount;
    final paymentId = response.paymentId;

    await FirebaseFirestore.instance.collection('passengers').doc(uid).collection('payments').add({
      'passengerId': uid,
      'passengerName': passengerData?['name'],
      'paymentId': paymentId,
      'amount': amount,
      'busId': bus['busId'],
      'busName': bus['name'],
      'route': routeName,
      'passengerCount': passengerCount,
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment successful and recorded!")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External wallet selected: ${response.walletName}")),
    );
  }

  void startPayment() {
    if (_razorpay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment not ready. Please try again.")),
      );
      return;
    }

    final route = selectedRoute!;
    final amount = widget.bus['routes'][route] * passengerCount;

    var options = {
      'key': 'rzp_live_zLLfH4BtsbMiht',
      'amount': amount * 100,
      'name': 'Trace Ride',
      'description': 'Bus ticket booking',
      'prefill': {
        'contact': '',
        'email': '',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bus = widget.bus;
    final routes = (bus['routes'] as Map<String, dynamic>);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: Text(bus['name'] ?? 'Bus Details'),
        backgroundColor: const Color(0xFF3D5AFE),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                bus['image'],
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text("Number Plate: ${bus['numberPlate']}", style: const TextStyle(fontSize: 16)),
            Text("Driver: ${bus['driver']}  |  Helper: ${bus['helper']}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text("Select Route", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...routes.entries.map((e) {
              return RadioListTile<String>(
                value: e.key,
                groupValue: selectedRoute,
                title: Text("${e.key} (₹${e.value})"),
                onChanged: (val) => setState(() => selectedRoute = val),
              );
            }).toList(),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Passengers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: passengerCount > 1 ? () => setState(() => passengerCount--) : null,
                    ),
                    Text("$passengerCount", style: const TextStyle(fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () => setState(() => passengerCount++),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Iconsax.wallet_check),
                label: Text("Pay ₹${selectedRoute != null ? (routes[selectedRoute] * passengerCount) : 0}"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: selectedRoute != null ? startPayment : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
