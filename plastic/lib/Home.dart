import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final List<String> imageList = [
    'images/banner1.png',
    'images/banner2.png',
    'images/banner3.png',
    'images/banner4.png',
    'images/banner5.png',
    'images/banner6.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFD0FFBA).withOpacity(0.3),
      body: Stack(
        children: [
          Column(
            children: [
              // First Background (Up to Slider)
              Container(
                height: 249, // Adjust this height to match the slider's position
                decoration: BoxDecoration(
                  image: DecorationImage(
                    opacity: 0.2,
                    image: AssetImage('images/background2.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // Second Background (Below Slider)
              Expanded(
                child: Container(
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      opacity: 0.2,
                      image: AssetImage('images/background1.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Home',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                ),
                SizedBox(height: 10),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 180,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: imageList.map((imagePath) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(imagePath, fit: BoxFit.cover, width: double.infinity),
                    );
                  }).toList(),
                ),


                SizedBox(height: 5),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(16.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          'How It Works',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fiber_manual_record, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Materials are collected, sorted, cleaned, processed, and transformed into reusable, eco-friendly new products efficiently.',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fiber_manual_record, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child:
                              Text(
                                'Recycling reduces waste, conserves resources, lowers pollution, saves energy, and promotes a healthier environment globally.',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),
                        Text(
                          'About Recycling',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                        ),
                        SizedBox(height: 5),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fiber_manual_record, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child:
                              Text(
                                'Recycling conserves natural resources, reduces landfill waste, saves energy, decreases pollution, and helps create a sustainable environment for future generations.',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fiber_manual_record, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child:
                              Text(
                                'Recycling minimizes greenhouse gas emissions, protects wildlife, conserves water, reduces production costs, and promotes eco-friendly practices in industries and households.',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.fiber_manual_record, size: 12, color: Colors.orange),
                            SizedBox(width: 8),
                            Expanded(
                              child:
                              Text(
                                'Separate plastics, paper, metals, and glass, rinse containers, avoid contaminated items, use recycling bins, and support sustainable waste management initiatives.',
                                style: TextStyle(fontSize: 14, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }
}
