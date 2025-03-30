import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:plastic/Home.dart';
import 'package:plastic/Navbar.dart';
import 'package:plastic/Navbar1.dart';
import 'package:plastic/PhoneNumber.dart';
import 'package:plastic/login.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void navigateBasedOnUser(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    if (user != null && user.email == "bneeraj7187@gmail.com") {
      // Admin email detected, navigate to Navbar1
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar1()),
      );
    } else {
      // Normal user, navigate to Navbar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()),
      );
    }
  }


  bool _acceptTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top background design
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFF6bb848),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Register as a New User",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                UserCredential? userCredential = await signInWithGoogle();
                if (userCredential != null) {
                  // Navigate to Home Page or Dashboard
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => HomePage()),
                  // );
                  // Navigator.pushReplacementNamed(context, '/home');
                }
              },
              child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.grey),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("images/google.png", height: 24), // Add a Google logo
                    const SizedBox(width: 10),
                    const Text(
                      "Continue with Google",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            const SizedBox(height: 5,),
            Text(
              "or",
              style: TextStyle(color: Colors.grey, fontFamily: 'Poppins',fontSize: 16),

            ),

            const SizedBox(height: 20),

            // Details Title
            const Padding(
              padding: EdgeInsets.only(left: 25, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Details",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: TextField(
                controller: _nameController,
                // obscureText: obscureText,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.grey),
                  hintText: "Full Name",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: TextField(
                controller: _emailController,
                // obscureText: obscureText,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email, color: Colors.grey),
                  hintText: "Email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.grey),
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              child: TextField(
                controller: _phoneController,
                // obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone, color: Colors.grey),
                  hintText: "Phone",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Proceed Button
            GestureDetector(
              onTap: () async {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _phoneController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("All fields are required!")),
                  );
                  return;
                }

                try {
                  // Check if the user already exists
                  var existingUser = await _firestore
                      .collection("users")
                      .where("email", isEqualTo: _emailController.text)
                      .get();

                  if (existingUser.docs.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("User already exists! Please log in.")),
                    );
                    return;
                  }

                  // Register new user
                  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
                    email: _emailController.text,
                    password: _passwordController.text,
                  );

                  // Store user details in Firestore
                  await _firestore.collection("users").doc(userCredential.user!.uid).set({
                    "createdAt": FieldValue.serverTimestamp(),
                    "name": _nameController.text,
                    "email": _emailController.text,
                    "phone": _phoneController.text,
                    "password": _passwordController.text,
                    "coins": 0,
                    "uid": userCredential.user!.uid,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Signup Successful!")),
                  );

                  // Navigator.pop(context); // Navigate back to login page

                  navigateBasedOnUser(context);

                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => Navbar()), // Navigate to HomePage
                  // );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              },

              child: Container(
                width: 250,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF6bb848),
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Proceed",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.fromLTRB(80, 0, 10, 10),
            child: Row(
              children: [
                Text("Alread have account",style: TextStyle(color: Colors.grey, fontFamily: "Poppins", fontSize: 16),),
                TextButton(

                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()), // Navigate to HomePage
                    );

                  },
                  child: Text('Login', style: TextStyle(color: Color(0xFF6bb848), fontWeight: FontWeight.bold,fontFamily: "Poppins", fontSize: 18),),
                )

              ],
            ),
            )
          ],
        ),
      ),
    );
  }

  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //
  //     // Trigger Google Sign-In
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     print("hbuvhgvygfkhvjvuhygvuigkhvbukhyvjgbv");
  //     if (googleUser == null) return null; // User canceled
  //
  //
  //
  //     // Obtain auth details
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //
  //     // Create a new credential
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     // Sign in to Firebase
  //     final UserCredential userCredential =
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     // Check if user exists in Firestore
  //     User? user = userCredential.user;
  //
  //     if (user != null) {
  //       DocumentSnapshot userDoc = await FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(user.uid)
  //           .get();
  //
  //       if (!userDoc.exists) {
  //         // Store user data in Firestore
  //         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
  //           "name": user.displayName,
  //           "email": user.email,
  //           "phone": user.phoneNumber,
  //           "uid": userCredential.user!.uid,
  //           // "photoURL": user.photoURL,
  //           // "createdAt": DateTime.now(),
  //         });
  //       }
  //     }
  //     return userCredential;
  //   } catch (e) {
  //     print("Google Sign-In Error: $e");
  //     return null;
  //   }
  // }

  // Future<UserCredential?> signInWithGoogle() async {
  //   try {
  //     // Trigger Google Sign-In
  //     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //     if (googleUser == null) return null; // User canceled
  //
  //     // Obtain auth details
  //     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  //
  //     // Create a new credential
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     // Sign in to Firebase
  //     final UserCredential userCredential =
  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //
  //     User? user = userCredential.user;
  //
  //     if (user != null) {
  //       // Check if an account with the same email already exists
  //       QuerySnapshot userDocs = await FirebaseFirestore.instance
  //           .collection('users')
  //           .where('email', isEqualTo: user.email)
  //           .get();
  //
  //       if (userDocs.docs.isEmpty) {
  //         // If email does not exist, create a new user
  //         await FirebaseFirestore.instance.collection('users').doc(user.email).set({
  //           "name": user.displayName,
  //           "email": user.email,
  //           "phone": user.phoneNumber,
  //           "uid": userCredential.user!.uid,
  //           "createdAt": FieldValue.serverTimestamp(),
  //         });
  //       }
  //     }
  //     return userCredential;
  //   } catch (e) {
  //     print("Google Sign-In Error: $e");
  //     return null;
  //   }
  // }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User canceled

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      User? user = userCredential.user;

      if (user != null) {
        // Check if an account with the same email already exists
        QuerySnapshot userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (userDocs.docs.isEmpty) {
          // Use the user's UID as the document ID
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            "name": user.displayName,
            "email": user.email,
            "phone": user.phoneNumber,
            "password": "",
            "coins": 0,
            "uid": user.uid, // Use the same UID as the document ID
            "createdAt": FieldValue.serverTimestamp(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Phonenumber()),
          );
        }
        else{
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => Navbar()),
          // );
          navigateBasedOnUser(context);
        }
      }
      // return userCredential;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }


}
