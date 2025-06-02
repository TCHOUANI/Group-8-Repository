import 'package:flutter/material.dart';
import 'package:roadex/widgets/bottom_nav_bar.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

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
                "Reports",
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), color: Colors.amber),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "assets/map.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: const Color.fromRGBO(10, 36, 99, 0.3)),
                          color: Colors.white),
                      child: ListTile(
                        leading: Icon(Icons.circle),
                        title: Text(
                          "Pothole",
                          style: TextStyle(fontSize: 11),
                        ),
                        titleAlignment: ListTileTitleAlignment.center,
                        iconColor: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: const Color.fromRGBO(10, 36, 99, 0.3)),
                          color: Colors.white),
                      child: ListTile(
                        leading: Icon(Icons.warning),
                        title: Text(
                          "Accident",
                          style: TextStyle(fontSize: 11),
                        ),
                        titleAlignment: ListTileTitleAlignment.center,
                        iconColor: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Container(
                      height: 32,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              width: 1,
                              color: const Color.fromRGBO(10, 36, 99, 0.3)),
                          color: Colors.white),
                      child: ListTile(
                        leading: Icon(Icons.traffic),
                        title: Text(
                          "Traffic",
                          style: TextStyle(fontSize: 11),
                        ),
                        titleAlignment: ListTileTitleAlignment.center,
                        iconColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Describe the issue...",
                  labelStyle: TextStyle(
                    color: const Color.fromRGBO(10, 36, 99, 0.4),
                  ),
                  suffixIcon: Icon(
                    Icons.description_outlined,
                    color: const Color(0xFF0a2463),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(
                          width: 1,
                          color: const Color.fromRGBO(10, 36, 99, 0.3))),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromRGBO(255, 84, 0, 0.3),
                      ),
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {},
              child: Container(
                alignment: Alignment.center,
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                    color: const Color(0xFF0a2463),
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  "Submit Report",
                  style: TextStyle(
                    fontFamily: "arial",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          ],
        ),
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
