import 'package:flutter/material.dart';
import 'create_account_screen.dart'; // Import the create account screen

class OnboardingScreenFour extends StatelessWidget {
  const OnboardingScreenFour({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Header with car icon and RoadEX
              Row(
                children: [
                  // Car icon
                  Container(
                    width: 24,
                    height: 24,
                    child: const Icon(
                      Icons.directions_car,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    height: 32, // Matches the text height
                    child: Image.asset(
                      'assets/images/roadex_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Main illustration container
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5E6D3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Background mountains and trees
                      Positioned(
                        top: 30,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          child: CustomPaint(
                            painter: MountainBackgroundPainter(),
                            size: Size(double.infinity, 100),
                          ),
                        ),
                      ),

                      // Trees
                      Positioned(
                        top: 80,
                        left: 30,
                        child: CustomPaint(
                          painter: TreePainter(),
                          size: Size(40, 60),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        right: 40,
                        child: CustomPaint(
                          painter: TreePainter(),
                          size: Size(35, 50),
                        ),
                      ),
                      Positioned(
                        top: 90,
                        right: 80,
                        child: CustomPaint(
                          painter: TreePainter(),
                          size: Size(30, 45),
                        ),
                      ),

                      // Car dashboard and person
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 200,
                          child: Stack(
                            children: [
                              // Car dashboard
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C3E50),
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Dashboard elements
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF1A252F),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                    ],
                                  ),
                                ),
                              ),

                              // Person with phone
                              Positioned(
                                bottom: 45,
                                right: 40,
                                child: Container(
                                  width: 120,
                                  height: 140,
                                  child: CustomPaint(
                                    painter: PersonWithPhonePainter(),
                                    size: Size(120, 140),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Title and description
              const Text(
                'Report, Improve, Save\nLives',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Easily report potholes, blocked roads, or\ncrashes to make roads safer for everyone.',
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007BFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Bottom buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: () {
                      // Navigate directly to create account screen when skipped
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Get Started button - Updated to navigate to CreateAccountScreen
                  Container(
                    width: 120,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to CreateAccountScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A2463),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for mountain background
class MountainBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFB8C5B8)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.6);
    path.lineTo(size.width * 0.6, size.height * 0.2);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint); // Fixed: use 'paint' instead of 'path'
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for trees
class TreePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Tree trunk
    final trunkPaint =
        Paint()
          ..color = const Color(0xFF8B4513)
          ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.7,
        size.width * 0.2,
        size.height * 0.3,
      ),
      trunkPaint,
    );

    // Tree foliage
    final foliagePaint =
        Paint()
          ..color = const Color(0xFF228B22)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.2, size.height * 0.4);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.1, size.height * 0.7);
    path.lineTo(size.width * 0.9, size.height * 0.7);
    path.lineTo(size.width * 0.7, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.4);
    path.close();

    canvas.drawPath(path, foliagePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for person with phone
class PersonWithPhonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Person's body (simplified)
    final bodyPaint =
        Paint()
          ..color = const Color(0xFF7FB069)
          ..style = PaintingStyle.fill;

    // Body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.3,
          size.height * 0.4,
          size.width * 0.4,
          size.height * 0.5,
        ),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    // Head
    final headPaint =
        Paint()
          ..color = const Color(0xFFFFDBAE)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.25),
      size.width * 0.15,
      headPaint,
    );

    // Hair
    final hairPaint =
        Paint()
          ..color = const Color(0xFF2C3E50)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.16,
      hairPaint,
    );

    // Phone in hand
    final phonePaint =
        Paint()
          ..color = const Color(0xFF34495E)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.6,
          size.height * 0.5,
          size.width * 0.2,
          size.width * 0.35,
        ),
        const Radius.circular(8),
      ),
      phonePaint,
    );

    // Phone screen
    final screenPaint =
        Paint()
          ..color = const Color(0xFF4ECDC4)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.52,
          size.width * 0.16,
          size.width * 0.28,
        ),
        const Radius.circular(4),
      ),
      screenPaint,
    );

    // Arm holding phone
    final armPaint =
        Paint()
          ..color = const Color(0xFFFFDBAE)
          ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.55,
          size.height * 0.45,
          size.width * 0.15,
          size.width * 0.08,
        ),
        const Radius.circular(20),
      ),
      armPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
