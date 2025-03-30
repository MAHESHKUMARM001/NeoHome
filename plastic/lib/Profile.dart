import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastic/login.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Razorpay razorpay;
  TextEditingController amountController = TextEditingController(); // Amount input field

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    // super.initState();
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
    int enteredAmount = (double.tryParse(amountController.text) ?? 0).toInt(); // Get integer value


    if (availableCoins - enteredAmount < 0) {
      showAlertDialog(context, "Insufficient Coins", "You do not have enough coins to proceed with this payment.");
      return;
    }

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

  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async{
    int enteredAmount = (double.tryParse(amountController.text) ?? 0).toInt(); // Get integer value

    // Deduct coins from Firestore
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'coins': availableCoins - enteredAmount,
      });

      setState(() {
        availableCoins -= enteredAmount;
        redeemedCoins += enteredAmount;
      });
    }
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? name;
  String? email;
  String? phone;
  int earnedCoins = 0; // New variable for coins
  int availableCoins =0;
  int redeemedCoins = 0;

  @override
  // void initState() {
  //   super.initState();
  //   _fetchUserData();
  // }

  void _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          name = userDoc['name'];
          email = userDoc['email'];
          phone = userDoc['phone'];
          availableCoins= userDoc['coins'];
        });
      }

      // Fetch earned coins from plastics collection
      _fetchEarnedCoins(user.uid);
    }
  }

  void _fetchEarnedCoins(String userId) async {
    QuerySnapshot plasticsDocs = await _firestore.collection('plastics')
        .where('userId', isEqualTo: userId)
        .get();

    int totalCoins = 0;
    for (var doc in plasticsDocs.docs) {
      totalCoins += (doc['coins'] as num?)?.toInt() ?? 0;
    }

    setState(() {
      earnedCoins = totalCoins;
      redeemedCoins = earnedCoins-availableCoins;
    });
  }

  void _logout() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    int enteredAmount = (double.tryParse(amountController.text) ?? 0).toInt();

    return Scaffold(
      // appBar: AppBar(title: Text("Profile")),
        backgroundColor: Color(0XFFD0FFBA).withOpacity(0.3),
      body: SingleChildScrollView(
       child: Padding(
         padding: EdgeInsets.all(20),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text("Name: ${name ?? 'Loading...'}", style: TextStyle(fontSize: 18)),
             SizedBox(height: 10),
             Text("Email: ${email ?? 'Loading...'}", style: TextStyle(fontSize: 18)),
             SizedBox(height: 10),
             Text("Phone: ${phone ?? 'Not Available'}", style: TextStyle(fontSize: 18)),
             SizedBox(height: 10),
             Text("Earned Coins: $earnedCoins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), // Display earned coins
             SizedBox(height: 30),
             Text("available Coins: $availableCoins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), // Display earned coins
             SizedBox(height: 30),
             Text("redeemed Coins: $redeemedCoins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)), // Display earned coins
             SizedBox(height: 30),
             Padding(
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
                     onPressed: (availableCoins - enteredAmount < 0) ? null : openCheckout,
                     child: const Text("Redeem"),
                   ),
                 ],
               ),
             ),
             Center(
               child: ElevatedButton(
                 onPressed: _logout,
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                 child: Text("Logout", style: TextStyle(color: Colors.white)),
               ),
             ),
           ],
         ),
       ),
      )
    );
  }
}
