import 'package:flutter/material.dart';
import 'onboarding_screen_two.dart';

class OnboardingScreenOne extends StatelessWidget {
  const OnboardingScreenOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header with logo and RoadEX
                Row(
                  children: [
                    // Menu/Navigation icon
                    Container(
                      height: 32, // Matches the text height
                      child: Image.asset(
                        'assets/images/roadex_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Phone illustration
                Container(
                  width: 180,
                  height: 280, // Reduced from 300 to 280
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Phone screen background
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4A4A),
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      // Road illustration
                      Positioned(
                        top: 30,
                        left: 8,
                        right: 8,
                        bottom: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A4A4A),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: CustomPaint(
                            painter: RoadIllustrationPainter(),
                          ),
                        ),
                      ),

                      // Location markers
                      Positioned(
                        top: 100,
                        left: 40,
                        child: LocationPin(),
                      ), // Adjusted position
                      Positioned(
                        top: 120,
                        right: 40,
                        child: LocationPin(),
                      ), // Adjusted position
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Title and description
                const Text(
                  'Your Smart Road\nCompanion',
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
                  'Stay informed with live alerts and road safety\nguidance wherever you go.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFF007BFF),
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
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30), // Reduced from 40 to 30
                // Next button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 100,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to next onboarding screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OnboardingScreenTwo(),
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
                        'Next',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Added some bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for the menu icon
class MenuIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw three lines for menu icon
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width, size.height * 0.2),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.8),
      Offset(size.width, size.height * 0.8),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for the road illustration
class RoadIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint =
        Paint()
          ..color = const Color(0xFF2A2A2A)
          ..style = PaintingStyle.fill;

    final linePaint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw road background
    final roadRect = Rect.fromLTWH(
      size.width * 0.4,
      0,
      size.width * 0.2,
      size.height,
    );

    canvas.drawRect(roadRect, roadPaint);

    // Draw dashed center line
    final dashHeight = 15.0;
    final dashSpace = 10.0;
    double currentY = 20.0;

    while (currentY < size.height - 20) {
      canvas.drawLine(
        Offset(size.width * 0.5, currentY),
        Offset(size.width * 0.5, currentY + dashHeight),
        linePaint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Location pin widget
class LocationPin extends StatelessWidget {
  const LocationPin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 24,
      child: Stack(
        children: [
          // Pin body
          Container(
            width: 16,
            height: 16,
            decoration: const BoxDecoration(
              color: Color(0xFFFF8C00),
              shape: BoxShape.circle,
            ),
          ),
          // Pin point
          Positioned(
            bottom: 0,
            left: 6,
            child: CustomPaint(
              size: const Size(8, 8),
              painter: PinPointPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the pin point
class PinPointPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFFFF8C00)
          ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
