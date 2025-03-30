// import 'package:flutter/material.dart';
// import 'package:cashfree_pg/cashfree_pg.dart';
// import 'package:cashfree_pg/cf_environment.dart';
//
// class CashfreePayment extends StatefulWidget {
//   const CashfreePayment({super.key});
//
//   @override
//   State<CashfreePayment> createState() => _CashfreePaymentState();
// }
//
// class _CashfreePaymentState extends State<CashfreePayment> {
//   TextEditingController amountController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     CFPaymentGatewayService().setEventListener(_cashfreePaymentResponseHandler);
//   }
//
//   void _cashfreePaymentResponseHandler(CFErrorResponse response) {
//     String message = response.message ?? "Unknown error";
//
//     if (response.status == CFPaymentStatus.SUCCESS) {
//       showAlertDialog(context, "Payment Successful", "Transaction ID: ${response.referenceId}");
//     } else if (response.status == CFPaymentStatus.FAILED) {
//       showAlertDialog(context, "Payment Failed", "Error: $message");
//     } else {
//       showAlertDialog(context, "Payment Cancelled", "Transaction was cancelled.");
//     }
//   }
//
//   void startPayment() async {
//     double amount = double.tryParse(amountController.text) ?? 10;
//
//     // Generate this from your backend
//     String paymentSessionId = "YOUR_PAYMENT_SESSION_ID";
//
//     CFSession session = CFSessionBuilder()
//         .setEnvironment(CFEnvironment.SANDBOX) // Change to PRODUCTION when live
//         .setOrderId("order_${DateTime.now().millisecondsSinceEpoch}")
//         .setPaymentSessionId(paymentSessionId)
//         .setOrderAmount(amount)
//         .setOrderCurrency("INR")
//         .build();
//
//     try {
//       await CFPaymentGatewayService().doPayment(session);
//     } catch (e) {
//       debugPrint("Payment Error: $e");
//     }
//   }
//
//   void showAlertDialog(BuildContext context, String title, String message) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text(title),
//           content: Text(message),
//           actions: [
//             ElevatedButton(
//               child: const Text("OK"),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Cashfree Payment")),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'Enter Amount (₹)',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextField(
//               controller: amountController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 hintText: "Enter amount in INR",
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.currency_rupee),
//               ),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: startPayment,
//               child: const Text("Pay with Cashfree"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
