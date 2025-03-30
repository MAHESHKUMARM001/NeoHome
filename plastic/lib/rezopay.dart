import "package:flutter/cupertino.dart";
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Rezopay extends StatefulWidget {
  const Rezopay({super.key});

  @override
  State<Rezopay> createState() => _RezopayState();
}

class _RezopayState extends State<Rezopay> {
  late Razorpay razorpay;
  TextEditingController amountController = TextEditingController(); // Amount input field

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();

    // Event Listeners
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
  }

  @override
  void dispose() {
    razorpay.clear(); // Clear event listeners
    amountController.dispose();
    super.dispose();
  }

  void openCheckout() {
    double amount = (double.tryParse(amountController.text) ?? 10) * 100; // Convert ₹ to paise

    var options = {
      'key': 'rzp_test_usAb7HAxi4eKxf',
      'amount': amount, // Dynamic Amount
      'name': 'Acme Corp.',
      'description': 'Payment for Order',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': '9360295163', 'email': 'test@razorpay.com'},
      'external': {'wallets': ['paytm']}
    };

    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}\nMetadata: ${response.error.toString()}");
  }

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    showAlertDialog(context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        ElevatedButton(
          child: const Text("OK"),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Enter Amount (₹)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter amount in INR",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: openCheckout,
              child: const Text("Pay with Razorpay"),
            ),
          ],
        ),
      ),
    );
  }
}
