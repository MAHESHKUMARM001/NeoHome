import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class RedeemCoinsPage extends StatefulWidget {
  @override
  _RedeemCoinsPageState createState() => _RedeemCoinsPageState();
}

class _RedeemCoinsPageState extends State<RedeemCoinsPage> {
  int userCoins = 0;
  String userId = "";
  final TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  /// Get the currently logged-in user's ID
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      _fetchUserCoins();
    } else {
      print("No user is logged in.");
    }
  }

  /// Fetch user's coin balance from Firestore
  Future<void> _fetchUserCoins() async {
    if (userId.isEmpty) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("users").doc(userId).get();

      setState(() {
        userCoins = userDoc["coins"] ?? 0;
      });
    } catch (e) {
      print("Error fetching coins: $e");
    }
  }

  /// Redeem coins using Razorpay Payout Links
  // Future<void> redeemCoins() async {
  //   int redeemAmount = int.tryParse(amountController.text) ?? 0;
  //
  //   if (redeemAmount <= 0 || redeemAmount > userCoins) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Invalid amount!")),
  //     );
  //     return;
  //   }
  //
  //   String razorpayKey = "rzp_test_usAb7HAxi4eKxf"; // Razorpay Test Key
  //   String razorpaySecret = "vujm85U8B5YmjBvacsiiHuRD"; // Razorpay Secret
  //   String payoutUrl = "https://api.razorpay.com/v1/payout-links";
  //
  //   // Map<String, dynamic> payoutData = {
  //   //   "amount": redeemAmount * 100, // Convert to paise
  //   //   "currency": "INR",
  //   //   "purpose": "Redeem Coins",
  //   //   "account_type": "vpa",
  //   //   "fund_account": {
  //   //     "account_type": "vpa",
  //   //     "vpa": {
  //   //       "address": "9360295163@ptsbi" // User's UPI ID
  //   //     }
  //   //   },
  //   //   "reference_id": "TXN_${DateTime.now().millisecondsSinceEpoch}",
  //   //   "narration": "Redeem Coins",
  //   //   "send_sms": true,
  //   //   "send_email": false,
  //   //   "customer": {
  //   //     "name": "User Name", // Replace with actual user name
  //   //     "contact": "9876543210", // Replace with actual user contact
  //   //     "email": "user@example.com" // Replace with actual user email
  //   //   },
  //   //   // "expire_by": DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600, // Expires in 1 hour
  //   // };
  //   Map<String, dynamic> payoutData = {
  //     "account_number": "2323230022829596", // Razorpay linked account number
  //     "amount": redeemAmount * 100, // Convert to paise
  //     "currency": "INR",
  //     "purpose": "Redeem Coins",
  //     "fund_account": {
  //       "account_type": "vpa", // Or "bank_account" if using bank transfer
  //       "vpa": {
  //         "address": "9360295163@ptsbi" // Replace with actual UPI ID of the user
  //       }
  //     },
  //     "reference_id": "TXN_${DateTime.now().millisecondsSinceEpoch}",
  //     "narration": "Redeem Coins",
  //     "contact": "9876543210", // Replace wth actual user contact
  //     "description": "Withdrawal of earned coins", // Required field
  //     "customer": {
  //       "name": "mahesh", // Replace with actual user name
  //       "contact": "9360295162", // Replace with actual user contact
  //       "email": "maheshkumarm4367@gmail.com" // Replace with actual user email
  //     }
  //   };
  //
  //
  //   final response = await http.post(
  //     Uri.parse(payoutUrl),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}"
  //     },
  //     body: jsonEncode(payoutData),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     var responseData = jsonDecode(response.body);
  //     String payoutLink = responseData["short_url"] ?? "";
  //
  //     if (payoutLink.isNotEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Payout link generated! Open to redeem.")),
  //       );
  //
  //       // You can open the link in the browser
  //       print("Payout Link: $payoutLink");
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to generate payout link!")),
  //       );
  //     }
  //   } else {
  //     print("Error redeeming coins: ${response.body}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Redemption failed! Try again.")),
  //     );
  //   }
  // }

  // Future<vo> redeemCoins() async {
  //   int redeemAmount = int.tryParse(amountController.text) ?? 0;
  //
  //   if (redeemAmount <= 0 || redeemAmount > userCoins) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Invalid amount!")),
  //     );
  //     return;
  //   }
  //
  //   String razorpayKey = "rzp_test_usAb7HAxi4eKxf"; // Razorpay Test Key
  //   String razorpaySecret = "vujm85U8B5YmjBvacsiiHuRD"; // Razorpay Secret
  //   String payoutUrl = "https://api.razorpay.com/v1/payout-links";
  //
  //   Map<String, dynamic> payoutData = {
  //     "amount": redeemAmount * 100, // Convert to paise
  //     "currency": "INR",
  //     "purpose": "Redeem Coins",
  //     "customer": {
  //       "name": "mahesh", // Replace with actual user name
  //       "contact": "9360295162", // Replace with actual user contact
  //       "email": "maheshkumarm4367@gmail.com" // Replace with actual user email
  //     },
  //     "notify": {
  //       "sms": true, // Send SMS notification
  //       "email": false // Do not send email notification
  //     },
  //     "reference_id": "TXN_${DateTime.now().millisecondsSinceEpoch}",
  //     "description": "Withdrawal of earned coins", // Optional field
  //     // Remove the "expire_by" field
  //   };
  //
  //   final response = await http.post(
  //     Uri.parse(payoutUrl),
  //     headers: {
  //       "Content-Type": "application/json",
  //       "Authorization": "Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}"
  //     },
  //     body: jsonEncode(payoutData),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     var responseData = jsonDecode(response.body);
  //     String payoutLink = responseData["short_url"] ?? "";
  //
  //     if (payoutLink.isNotEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Payout link generated! Open to redeem.")),
  //       );
  //
  //       // You can open the link in the browser
  //       print("Payout Link: $payoutLink");
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Failed to generate payout link!")),
  //       );
  //     }
  //   } else {
  //     print("Error redeeming coins: ${response.body}");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Redemption failed! Try again.")),
  //     );
  //   }
  // }
  Future<void> redeemCoins() async {
    int redeemAmount = int.tryParse(amountController.text) ?? 0;

    if (redeemAmount <= 0 || redeemAmount > userCoins) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid amount!")),
      );
      return;
    }

    String razorpayKey = "rzp_test_usAb7HAxi4eKxf"; // Razorpay Test Key
    String razorpaySecret = "vujm85U8B5YmjBvacsiiHuRD"; // Razorpay Secret
    String payoutUrl = "https://api.razorpay.com/v1/payout-links";

    Map<String, dynamic> payoutData = {
      "account_number": "2323230022829596", // Replace with your Razorpay-linked bank account number
      "amount": redeemAmount * 100, // Convert to paise
      "currency": "INR",
      "purpose": "Redeem Coins",
      "fund_account": {
        "account_type": "vpa", // Use "vpa" for UPI or "bank_account" for bank transfers
        "vpa": {
          "address": "9360295163@ptsbi" // Replace with the recipient's UPI ID
        }
      },
      "reference_id": "TXN_${DateTime.now().millisecondsSinceEpoch}",
      "narration": "Redeem Coins",
      "contact": "9876543210", // Replace with the recipient's contact number
      "description": "Withdrawal of earned coins", // Optional field
      "customer": {
        "name": "mahesh", // Replace with the recipient's name
        "contact": "9360295162", // Replace with the recipient's contact number
        "email": "maheshkumarm4367@gmail.com" // Replace with the recipient's email
      }
    };

    final response = await http.post(
      Uri.parse(payoutUrl),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic ${base64Encode(utf8.encode('$razorpayKey:$razorpaySecret'))}"
      },
      body: jsonEncode(payoutData),
    );

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      String payoutLink = responseData["short_url"] ?? "";

      if (payoutLink.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payout link generated! Open to redeem.")),
        );

        // You can open the link in the browser
        print("Payout Link: $payoutLink");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to generate payout link!")),
        );
      }
    } else {
      print("Error redeeming coins: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redemption failed! Try again.")),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Redeem Coins")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Your Coins: $userCoins",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Enter amount to redeem",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: redeemCoins,
              child: Text("Redeem Now"),
            ),
          ],
        ),
      ),
    );
  }
}
