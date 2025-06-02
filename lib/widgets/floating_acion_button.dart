import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roadex/pages/home_page.dart';

class Floating extends StatelessWidget {
  const Floating({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.offAll(HomePage());
      },
      backgroundColor: const Color(0xffffffff),
      child: Icon(
        Icons.forward,
        color: const Color(0xFF0a2463),
      ),
    );
  }
}
