import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plastic/Home.dart';
import 'package:plastic/Navbar.dart';
import 'package:plastic/Navbar1.dart';
import 'package:plastic/PhoneNumber.dart';
import 'package:plastic/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Logo
              SizedBox(
                height: 100, // Proper image height
                width: 200, // Proper image width
                child: Image.asset("images/plasticlogo.png"),
              ),

              const SizedBox(height: 20),

              // Sign in text
              Text(
                "Sign in",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 20),

              // Google Sign-in Button
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade300, blurRadius: 5),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 24, // Proper image height
                        width: 24, // Proper image width
                        child: Image.asset("images/google.png"),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Sign in with Google",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4285F4), fontFamily: 'Poppins',),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Insert your Login Details",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),

              const SizedBox(height: 10),

              // Email Field

              Padding(

                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _emailController,
                  // obscureText: obscureText,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.grey),
                    hintText: "Enter Your Email",
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
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock, color: Colors.grey),
                    hintText: "Enter Your Password",
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

              // _buildTextField("Enter Your Email", Icons.email),
              // Password Field
              // _buildTextField("Enter Your Password", Icons.lock, obscureText: true),

              const SizedBox(height: 20),

              // Login Button
              GestureDetector(
                onTap: () async{
                  // Handle login
                  if (_emailController.text.isEmpty ||
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

                    if (existingUser.docs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("User not found. Please sign up.")),
                      );
                      return;
                    }

                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);

                    print("home");

                    navigateBasedOnUser(context);

                    // Navigator.pushReplacement(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => Navbar()), // Navigate to HomePage
                    // );
                  }
                  catch (e) {
                    print(
                        'Error during login: $e'); // Print the full error message
                    if (e is FirebaseAuthException &&
                        e.code == 'wrong-password') {
                      String errorMessage = 'Password is wrong. Please try again.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Color(0xFF6bb848),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "Login Now",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Poppins',),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Register Now
              Column(
                  children: [
                    Text(
                      "If you are a New user",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black, fontFamily: 'Poppins',),
                    ),
                    InkWell(
                      // When the user taps the button, show a snackbar.
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignupPage()),
                        );

                      },
                      child:  Text(
                         "Register Now",
                         textAlign: TextAlign.center,
                         style: TextStyle(fontSize: 15, color: Color(0xFF6bb848),fontFamily: 'Poppins',fontWeight: FontWeight.bold),
                      ),
                    ),
                    // TextButton(
                    //
                    //   onPressed: () async{
                    //     await GoogleSignIn().signOut();
                    //     await FirebaseAuth.instance.signOut();
                    //   },
                    //   child: Text('logout'),
                    // )




                  ],
                ),


              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
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
        else {
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
