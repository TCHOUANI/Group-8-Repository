import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:roadex/pages/home_page.dart';
import 'package:roadex/pages/landing_page.dart';
import 'package:roadex/pages/learn_page.dart';
import 'package:roadex/pages/reports_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'roadEX',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LandingPage(),
    );
  }
}
