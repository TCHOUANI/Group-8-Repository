 import 'package:flutter/material.dart';
 import 'package:flutter_application_1/l10n/app_localizations.dart'; // NEW: Import AppLocalizations
import 'onboarding_screen_one.dart';
import 'dart:math' as math; // Import dart:math for proper cos/sin

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the localized strings
    final l10n = AppLocalizations.of(context)!; // Get the localization instance

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header with RoadEX logo image
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
              child: SizedBox( // Changed to SizedBox from Container with fixed height
                height: 40, // Adjusted height for better visibility
                child: Image.asset(
                  'assets/images/roadex_logo.png', // Your RoadEX logo
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Main illustration container
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFF2C3E50),
                ),
                child: Stack(
                  children: [
                    // Sky gradient background
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            const Color(0xFF87CEEB),
                            const Color(0xFFE0F6FF),
                          ],
                        ),
                      ),
                    ),

                    // Road and landscape
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFF90EE90),
                              const Color(0xFF228B22),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Road
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        size: const Size(double.infinity, 180),
                        painter: RoadPainter(),
                      ),
                    ),

                    // Location markers
                    Positioned(
                      top: 120,
                      left: 40,
                      child: LocationMarker(color: Colors.orange),
                    ),
                    Positioned(
                      top: 100,
                      left: MediaQuery.of(context).size.width * 0.5 - 40,
                      child: LocationMarker(color: Colors.orange),
                    ),
                    Positioned(
                      top: 120,
                      right: 40,
                      child: LocationMarker(color: Colors.orange),
                    ),

                    // Dashboard
                    Positioned(
                      bottom: 15,
                      left: 15,
                      right: 15,
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          children: [
                            // Left gauge
                            Expanded(
                              child: CustomPaint(painter: GaugePainter()),
                            ),
                            // Center steering wheel area
                            Expanded(
                              flex: 2,
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2C3E50),
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            // Right gauge
                            Expanded(
                              child: CustomPaint(painter: GaugePainter()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with text and button
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text( // REMOVED const
                          l10n.welcomeTo, // Use localized string
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          height: 32, // Matches the text height
                          child: Image.asset(
                            'assets/images/roadex_logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text( // REMOVED const
                      l10n.yourSmartRoadCompanion, // Use localized string
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Get Started Button
                    SizedBox( // Changed to SizedBox from Container with fixed width/height
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnboardingScreenOne(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A2463),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text( // REMOVED const
                          l10n.getStarted, // Use localized string
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

// Custom painter for the road
class RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF696969)
          ..style = PaintingStyle.fill;

    // Road path (perspective view)
    final path = Path();
    path.moveTo(size.width * 0.3, size.height);
    path.lineTo(size.width * 0.7, size.height);
    path.lineTo(size.width * 0.55, size.height * 0.3);
    path.lineTo(size.width * 0.45, size.height * 0.3);
    path.close();

    canvas.drawPath(path, paint);

    // Road markings (dashed lines)
    final linePaint =
        Paint()
          ..color = Colors.yellow
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Center dashed line
    for (int i = 0; i < 5; i++) {
      final startY = size.height - (i * 25);
      final endY = startY - 15;
      final centerX = size.width * 0.5;

      canvas.drawLine(
        Offset(centerX, startY),
        Offset(centerX, endY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Custom painter for dashboard gauges
class GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw gauge circle
    canvas.drawCircle(center, radius, paint);

    // Draw some gauge marks
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180); // Use math.pi
      final startX = center.dx + (radius - 5) * math.cos(angle); // Use math.cos
      final startY = center.dy + (radius - 5) * math.sin(angle); // Use math.sin
      final endX = center.dx + radius * math.cos(angle); // Use math.cos
      final endY = center.dy + radius * math.sin(angle); // Use math.sin

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Location marker widget
class LocationMarker extends StatelessWidget {
  final Color color;

  const LocationMarker({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox( // Changed to SizedBox from Container
      width: 24,
      height: 30,
      child: Stack(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.location_on, color: Colors.white, size: 16),
          ),
          Positioned(
            bottom: 0,
            left: 11,
            child: Container(width: 2, height: 6, color: color),
          ),
        ],
      ),
    );
  }
}

// Removed your custom cos/sin functions because dart:math provides them.
// Make sure you have 'import 'dart:math' as math;' at the top.