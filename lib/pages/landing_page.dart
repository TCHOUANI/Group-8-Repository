import 'package:flutter/material.dart';
import 'package:roadex/widgets/floating_acion_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromRGBO(255, 84, 0, 1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    height: 150,
                    width: 200,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 35),
                  child: Image.asset("assets/roadEx.png"),
                )
              ],
            ),
          ],
        ),
        floatingActionButton: Floating());
  }
}
