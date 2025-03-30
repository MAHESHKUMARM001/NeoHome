import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NotificationPage1 extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage1> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  String selectedStatus = "pending"; // Default selected filter

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid; // Get logged-in user's ID
  }

  void _openGoogleMaps(double latitude, double longitude) async {
    final Uri url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw "Could not launch $url";
    }
  }

  void _showFullImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black,
            ),
            padding: EdgeInsets.all(10),
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  void _showCoinsDialog(String docId, int currentCoins) {
    TextEditingController coinsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Coins"),
          content: TextField(
            controller: coinsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter new coin value",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                int? newCoins = int.tryParse(coinsController.text);
                if (newCoins != null) {

                  await _firestore.collection('plastics').doc(docId).update({
                    "coins": newCoins,
                    "status": "valid", // Change status to valid
                  });

                  DocumentSnapshot userDoc1 = await _firestore.collection('plastics').doc(docId).get();
                  String id =userDoc1['userId'];
                  print("jhghdcvsvbcjhbcj");
                  print(id);

                  DocumentSnapshot userDoc2 = await _firestore.collection('users').doc(id).get();
                  int existingUserCoins = userDoc2['coins'];
                  print("ihihiuhijhijhuhbijhjhnibjhibnoiuygujmigyhn");
                  print(existingUserCoins);


                  await _firestore.collection('users').doc(id).update({
                    "coins": existingUserCoins + newCoins,
                  });

                  Navigator.pop(context);
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }


  Future<Map<String, String?>> _getUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return {
          "name": userDoc['name'] as String?,
          "phone": userDoc['phone'] as String?,
        };
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
    return {"name": null, "phone": null};
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        // appBar: AppBar(title: Text("Notifications")),
        body: Center(child: Text("Please log in to view notifications")),
      );
    }

    return Scaffold(
      backgroundColor: Color(0XFFD0FFBA).withOpacity(0.2),
      appBar: AppBar(title: Text("Notifications")),
      body: Column(
        children: [
          // 🔹 Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Filter: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                DropdownButton<String>(
                  value: selectedStatus,
                  items: ["pending", "valid", "invalid"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue!;
                    });
                  },
                ),
              ],
            ),
          ),

          // 🔹 Fetch and Display Data for All Users
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('plastics').where('status', isEqualTo: selectedStatus).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No notifications available"));
                }

                final documents = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final data = documents[index].data() as Map<String, dynamic>;
                    String userId = data['userId'];

                    return FutureBuilder<Map<String, String?>>(
                      future: _getUserDetails(userId),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return Padding(
                            padding: EdgeInsets.all(5),
                            child: Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child: Center(child: CircularProgressIndicator()),
                              ),
                            ),
                          );
                        }

                        final userDetails = userSnapshot.data ?? {"name": "Unknown", "phone": "N/A"};

                        return Padding(
                          padding: EdgeInsets.all(5),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (data['imageUrl'] != null)
                                    InkWell(
                                      onTap: () => _showFullImageDialog(data['imageUrl']),
                                      child: Image.network(
                                        data['imageUrl'],
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Status: ${data['status']}",
                                          style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text("Coins: ${data['coins']}"),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("User: ${userDetails['name'] ?? 'Unknown'}"),
                                      Text("Date: ${DateFormat('yyyy-MM-dd').format((data['timestamp'] as Timestamp).toDate())}"),
                                    ],
                                  ),
                                  SizedBox(height: 5),



                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          double lat = (data['latitude'] as num).toDouble();
                                          double lng = (data['longitude'] as num).toDouble();
                                          _openGoogleMaps(lat, lng);
                                        },
                                        child: Icon(Icons.location_on, color: Colors.blue, size: 40),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          final String phoneNumber = userDetails['phone'] ?? "N/A";
                                          final Uri phoneUri = Uri.parse("tel:$phoneNumber");
                                          if (!await launchUrl(phoneUri)) {
                                            throw "Could not launch $phoneUri";
                                          }
                                        },
                                        child: Icon(Icons.phone, color: Colors.green, size: 40),
                                      ),

                                      // 🔹 Show "Validated" if status is "valid"
                                      // 🔹 Show "Invalidated" if status is "invalid"
                                      // 🔹 Show buttons only if status is "pending"
                                      data['status'] == "valid"
                                          ? Text("Validated", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))
                                          : data['status'] == "invalid"
                                          ? Text("Invalidated", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red))
                                          : Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              _showCoinsDialog(documents[index].id, data['coins']);
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF00FF04)),
                                            child: Text("Valid"),
                                          ),
                                          SizedBox(width: 5),
                                          ElevatedButton(
                                            onPressed: () async {
                                              await _firestore.collection('plastics').doc(documents[index].id).update({
                                                "status": "invalid",
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFFF0000)),
                                            child: Text("Invalid"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),


                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
