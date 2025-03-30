// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class CameraPage extends StatefulWidget {
//   @override
//   _CameraPageState createState() => _CameraPageState();
// }
//
// class _CameraPageState extends State<CameraPage> {
//   CameraController? _controller;
//   XFile? _capturedImage;
//   bool _isCameraReady = false;
//   int _selectedCameraIndex = 0;
//   List<CameraDescription>? _cameras;
//
//   final String cloudinaryUrl =
//       "https://api.cloudinary.com/v1_1/dbihdlrkh/image/upload";
//   final String uploadPreset = "mahesh001"; // If using unsigned upload
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera(_selectedCameraIndex);
//     _requestLocationPermission();
//   }
//
//   /// Request location permission
//   Future<void> _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) return;
//     }
//   }
//
//   /// Initialize camera
//   Future<void> _initializeCamera(int cameraIndex) async {
//     _cameras = await availableCameras();
//     if (_cameras == null || _cameras!.isEmpty) return;
//
//     _controller?.dispose();
//     _controller = CameraController(_cameras![cameraIndex], ResolutionPreset.high);
//
//     await _controller!.initialize();
//
//     if (!mounted) return;
//     setState(() {
//       _isCameraReady = true;
//       _selectedCameraIndex = cameraIndex;
//     });
//   }
//
//   /// Switch between front and back cameras
//   void _switchCamera() async {
//     if (_cameras == null || _cameras!.length < 2) return;
//     int newIndex = (_selectedCameraIndex == 0) ? 1 : 0;
//     await _initializeCamera(newIndex);
//   }
//
//   /// Capture a picture
//   Future<void> _takePicture() async {
//     if (!_controller!.value.isInitialized) return;
//
//     try {
//       final image = await _controller!.takePicture();
//       setState(() {
//         _capturedImage = image;
//       });
//       _showPreviewDialog(image);
//     } catch (e) {
//       print("Error taking picture: $e");
//     }
//   }
//
//   /// Upload image to Cloudinary and return the image URL
//   Future<String?> _uploadToCloudinary(String imagePath) async {
//     File imageFile = File(imagePath);
//     var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));
//
//     request.files.add(
//       await http.MultipartFile.fromPath("file", imageFile.path),
//     );
//
//     request.fields["upload_preset"] = uploadPreset; // If using unsigned upload
//
//     var response = await request.send();
//     if (response.statusCode == 200) {
//       var responseData = await response.stream.bytesToString();
//       var jsonResponse = json.decode(responseData);
//       return jsonResponse["secure_url"]; // Cloudinary image URL
//     } else {
//       print("Failed to upload image to Cloudinary");
//       return null;
//     }
//   }
//
//   /// Get current location
//   Future<Map<String, double>> _getCurrentLocation() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       throw Exception('Location services are disabled.');
//     }
//
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         throw Exception('Location permissions are denied.');
//       }
//     }
//
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     return {
//       "latitude": position.latitude,
//       "longitude": position.longitude,
//     };
//   }
//
//   /// Store image URL, location, and user ID in Firestore
//   Future<void> _storeDataInFirestore(String imageUrl, Map<String, double> location) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       throw Exception("User not logged in");
//     }
//
//     await FirebaseFirestore.instance.collection("plastics").add({
//       "userId": user.uid,
//       "imageUrl": imageUrl,
//       "latitude": location["latitude"],
//       "longitude": location["longitude"],
//       "coins": 0,
//       "status": "pending",
//       "timestamp": FieldValue.serverTimestamp(),
//     });
//   }
//
//   /// Show a pop-up with the captured image
//   void _showPreviewDialog(XFile image) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Image.file(File(image.path)),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 TextButton(
//                   onPressed: () async {
//                     try {
//                       // Upload image to Cloudinary
//                       String? imageUrl = await _uploadToCloudinary(image.path);
//                       if (imageUrl == null) throw Exception("Image upload failed");
//
//                       // Get current location
//                       Map<String, double> location = await _getCurrentLocation();
//
//                       // Store data in Firestore
//                       await _storeDataInFirestore(imageUrl, location);
//
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Image stored successfully!")),
//                       );
//                     } catch (e) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(content: Text("Error: ${e.toString()}")),
//                       );
//                     } finally {
//                       Navigator.of(context).pop();
//                     }
//                   },
//                   child: Text('OK'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     setState(() {
//                       _capturedImage = null;
//                     });
//                   },
//                   child: Text('Cancel'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isCameraReady) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned.fill(child: CameraPreview(_controller!)),
//           Positioned(
//             top: 40,
//             right: 20,
//             child: FloatingActionButton(
//               onPressed: _switchCamera,
//               child: Icon(Icons.switch_camera),
//               backgroundColor: Colors.white,
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: FloatingActionButton(
//                 onPressed: _takePicture,
//                 child: Icon(Icons.camera),
//                 backgroundColor: Colors.white,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  XFile? _capturedImage;
  bool _isCameraReady = false;
  bool _isLoading = false;
  int _selectedCameraIndex = 0;
  List<CameraDescription>? _cameras;

  final String cloudinaryUrl =
      "https://api.cloudinary.com/v1_1/dbihdlrkh/image/upload";
  final String uploadPreset = "mahesh001"; // If using unsigned upload

  @override
  void initState() {
    super.initState();
    _initializeCamera(_selectedCameraIndex);
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  Future<void> _initializeCamera(int cameraIndex) async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) return;

    _controller?.dispose();
    _controller = CameraController(_cameras![cameraIndex], ResolutionPreset.high);

    await _controller!.initialize();

    if (!mounted) return;
    setState(() {
      _isCameraReady = true;
      _selectedCameraIndex = cameraIndex;
    });
  }

  void _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;
    int newIndex = (_selectedCameraIndex == 0) ? 1 : 0;
    await _initializeCamera(newIndex);
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
      });
      _showPreviewDialog(image);
    } catch (e) {
      print("Error taking picture: $e");
    }
  }

  Future<String?> _uploadToCloudinary(String imagePath) async {
    File imageFile = File(imagePath);
    var request = http.MultipartRequest("POST", Uri.parse(cloudinaryUrl));

    request.files.add(
      await http.MultipartFile.fromPath("file", imageFile.path),
    );

    request.fields["upload_preset"] = uploadPreset;

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);
      return jsonResponse["secure_url"];
    } else {
      print("Failed to upload image to Cloudinary");
      return null;
    }
  }


  Future<Map<String, double>> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _getCurrentLocation();
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return {
      "latitude": position.latitude,
      "longitude": position.longitude,
    };
  }

  Future<void> _storeDataInFirestore(String imageUrl, Map<String, double> location) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    await FirebaseFirestore.instance.collection("plastics").add({
      "userId": user.uid,
      "imageUrl": imageUrl,
      "latitude": location["latitude"],
      "longitude": location["longitude"],
      "coins": 0,
      "status": "pending",
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  void _showPreviewDialog(XFile image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(image.path)),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () async {
                      setStateDialog(() => _isLoading = true);
                      try {
                        String? imageUrl = await _uploadToCloudinary(image.path);
                        if (imageUrl == null) throw Exception("Image upload failed");

                        Map<String, double> location = await _getCurrentLocation();
                        await _storeDataInFirestore(imageUrl, location);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Image stored successfully!")),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: ${e.toString()}")),
                        );
                      } finally {
                        setStateDialog(() => _isLoading = false);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _capturedImage = null;
                      });
                    },
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraReady) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned(
            top: 40,
            right: 20,
            child: FloatingActionButton(
              onPressed: _switchCamera,
              child: Icon(Icons.switch_camera),
              backgroundColor: Colors.white,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: FloatingActionButton(
                onPressed: _takePicture,
                child: Icon(Icons.camera),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
