import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome_screen.dart'; // Import your welcome screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully!');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeRoad Cameroon',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const FirebaseTestScreen(), // Temporary test screen
    );
  }
}

// Temporary test screen to verify Firebase
class FirebaseTestScreen extends StatelessWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  void _testFirebase() {
    try {
      print('Firebase App Name: ${Firebase.app().name}');
      print('Firebase initialized successfully!');
    } catch (e) {
      print('Firebase test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRoad Cameroon - Firebase Test'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'SafeRoad Cameroon',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Firebase Connection Test'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _testFirebase,
              child: const Text('Test Firebase Connection'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ),
                );
              },
              child: const Text('Go to Welcome Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
