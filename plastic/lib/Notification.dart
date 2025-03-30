import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
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

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Notifications")),
        body: Center(child: Text("Please log in to view notifications")),
      );
    }

    return Scaffold(
      backgroundColor: Color(0XFFD0FFBA).withOpacity(0.2),
      // appBar: AppBar(title: Text("Notifications")),
      body: Column(
        children: [
          // 🔹 Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Filter: ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 0),
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

          // 🔹 Fetch and Display Data
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('plastics')
                  .where('userId', isEqualTo: userId) // Filter by user ID
                  .where('status', isEqualTo: selectedStatus) // Filter by status
                  .snapshots(),
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
                                  // SizedBox(height: 5),
                                  Text("Coins: ${data['coins']}"),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Date: ${DateFormat('yyyy-MM-dd').format((data['timestamp'] as Timestamp).toDate())}"),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        double lat = (data['latitude'] as num).toDouble();
                                        double lng = (data['longitude'] as num).toDouble();
                                        _openGoogleMaps(lat, lng);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xBB30C3EF)),
                                      child: Text("Location"),
                                    ),
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
            ),
          ),
        ],
      ),
    );
  }
}
