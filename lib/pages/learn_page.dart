import 'package:flutter/material.dart';
import 'package:roadex/widgets/bottom_nav_bar.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage> {
  final List<Map<String, dynamic>> learningMaterials = [
    {
      "name": "Stop",
      "image": "assets/stop.png",
    },
    {
      "name": "Yield",
      "image": "assets/yield.png",
    },
    {
      "name": "Speed limit",
      "image": "assets/speed.png",
    },
    {
      "name": "Do not enter",
      "image": "assets/dont.png",
    },
    {
      "name": "Curve Ahead",
      "image": "assets/curve.png",
    },
    {
      "name": "Pedestrian Crossing",
      "image": "assets/pedestrian.png",
    },
    {
      "name": "School Zone",
      "image": "assets/school.png",
    },
    {
      "name": "Construction Ahead",
      "image": "assets/construction.png",
    },
    {
      "name": "Interstate",
      "image": "assets/interstate.png",
    },
    {
      "name": "Route",
      "image": "assets/route.png",
    },
    {
      "name": "Destination",
      "image": "assets/destination.png",
    },
    {
      "name": "Service",
      "image": "assets/service.png",
    }
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF5400),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Image.asset(
                "assets/white.png",
                fit: BoxFit.contain,
                height: 220,
                alignment: Alignment.centerLeft,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 60),
              child: Text(
                "Road Signs",
                style: TextStyle(
                  fontFamily: "arial",
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 3,
              crossAxisSpacing: 5,
              mainAxisExtent: 215,
            ),
            itemCount: learningMaterials.length,
            itemBuilder: (context, position) {
              return GestureDetector(
                onTap: () {},
                child: Card(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "${learningMaterials.elementAt(position)['image']}",
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "${learningMaterials.elementAt(position)['name']}",
                          style: TextStyle(color: const Color(0xFF0a2463)),
                        )
                      ],
                    )),
              );
            }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 50,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
          child: Container(height: 60, child: BottomNavBar()),
        ),
      ),
    );
  }
}
