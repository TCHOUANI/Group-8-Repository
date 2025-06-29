import 'package:flutter/material.dart';
import 'live_road_alert_page.dart';
import 'learn_page.dart';
import 'report_page.dart';
import 'settings_page.dart';
import 'profile_page.dart'; // Add this import for the profile page

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Zoom functionality variables
  double _zoomLevel = 1.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 3.0;
  final double _zoomStep = 0.3;

  // Animation controller for smooth zoom transitions
  late AnimationController _zoomAnimationController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    _zoomAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: _zoomLevel, end: _zoomLevel).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _zoomAnimationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    if (_zoomLevel < _maxZoom) {
      setState(() {
        double newZoom = (_zoomLevel + _zoomStep).clamp(_minZoom, _maxZoom);
        _animateZoom(newZoom);
      });
    }
  }

  void _zoomOut() {
    if (_zoomLevel > _minZoom) {
      setState(() {
        double newZoom = (_zoomLevel - _zoomStep).clamp(_minZoom, _maxZoom);
        _animateZoom(newZoom);
      });
    }
  }

  void _animateZoom(double targetZoom) {
    _zoomAnimation = Tween<double>(begin: _zoomLevel, end: targetZoom).animate(
      CurvedAnimation(
        parent: _zoomAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _zoomAnimationController.forward(from: 0).then((_) {
      _zoomLevel = targetZoom;
    });
  }

  void _onBottomNavTapped(int index) {
    // Handle different navigation items
    switch (index) {
      case 0:
        // Home - already here, update selected index
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1:
        // Alerts
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveRoadAlertsPage()),
        ).then((_) {
          // Reset selected index when returning
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2:
        // Report
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        ).then((_) {
          // Reset selected index when returning
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3:
        // Learn
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearnPage()),
        ).then((_) {
          // Reset selected index when returning
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 4:
        // Settings - Navigate to Settings Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        ).then((_) {
          // Reset selected index when returning
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
    }
  }

  void _onProfileTapped() {
    // Navigate to Profile Page - Updated to handle returning from EditProfile
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background with Zoom functionality
          AnimatedBuilder(
            animation: _zoomAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _zoomAnimation.value,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF87CEEB), // Sky blue
                        Color(0xFFB0E0E6), // Powder blue
                        Color(0xFF98FB98), // Pale green
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Road network lines (drawn first so they appear behind pins)
                      CustomPaint(
                        size: Size(double.infinity, double.infinity),
                        painter: RoadNetworkPainter(),
                      ),

                      // Cameroon map elements
                      // Northern Region
                      Positioned(
                        top: 120,
                        left: 100,
                        child: _buildMapPin(
                          'Garoua',
                          Icons.location_city,
                          Colors.orange,
                        ),
                      ),
                      Positioned(
                        top: 100,
                        right: 80,
                        child: _buildMapPin(
                          'Maroua',
                          Icons.location_city,
                          Colors.red,
                        ),
                      ),

                      // Central Region
                      Positioned(
                        top: 280,
                        left: 140,
                        child: _buildMapPin(
                          'Yaoundé',
                          Icons.account_balance, // Capital city
                          Color(0xFF1A237E),
                        ),
                      ),
                      Positioned(
                        top: 250,
                        left: 80,
                        child: _buildMapPin(
                          'Bafoussam',
                          Icons.location_city,
                          Colors.purple,
                        ),
                      ),

                      // Littoral Region
                      Positioned(
                        top: 320,
                        left: 60,
                        child: _buildMapPin(
                          'Douala',
                          Icons.business, // Economic capital
                          Colors.blue,
                        ),
                      ),

                      // South West Region
                      Positioned(
                        bottom: 280,
                        left: 40,
                        child: _buildMapPin(
                          'Buea',
                          Icons.terrain, // Mountain city
                          Colors.green,
                        ),
                      ),
                      Positioned(
                        bottom: 250,
                        left: 20,
                        child: _buildMapPin(
                          'Limbe',
                          Icons.beach_access, // Coastal city
                          Colors.teal,
                        ),
                      ),

                      // Eastern Region
                      Positioned(
                        top: 300,
                        right: 60,
                        child: _buildMapPin(
                          'Bertoua',
                          Icons.location_city,
                          Colors.brown,
                        ),
                      ),

                      // South Region
                      Positioned(
                        bottom: 180,
                        left: 120,
                        child: _buildMapPin(
                          'Ebolowa',
                          Icons.location_city,
                          Colors.indigo,
                        ),
                      ),

                      // Major highways/roads indicators
                      Positioned(
                        top: 200,
                        left: 90,
                        child: _buildRoadMarker('N1 Highway'),
                      ),
                      Positioned(
                        top: 350,
                        left: 100,
                        child: _buildRoadMarker('N3 Highway'),
                      ),
                      Positioned(
                        bottom: 220,
                        right: 120,
                        child: _buildRoadMarker('N2 Highway'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Top Bar with Logo and Profile
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // App Logo/Name
                  Row(
                    children: [
                      Icon(
                        Icons.navigation,
                        color: Color(0xFF1A237E),
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'SafeRoad',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    ],
                  ),
                  // Profile Avatar
                  GestureDetector(
                    onTap: _onProfileTapped,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.shade300,
                            Colors.orange.shade400,
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search locations, roads...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Zoom Controls
          Positioned(
            right: 20,
            top: MediaQuery.of(context).padding.top + 160,
            child: Column(
              children: [
                _buildZoomButton(Icons.add, _zoomIn),
                const SizedBox(height: 8),
                _buildZoomButton(Icons.remove, _zoomOut),
              ],
            ),
          ),

          // Quick Action Buttons section has been removed
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A237E),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Learn'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMapPin(String city, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected: $city'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              city,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadMarker(String roadName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        roadName,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF1A237E)),
        onPressed: onPressed,
        iconSize: 20,
      ),
    );
  }
}

// Custom painter for drawing road networks
class RoadNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    // Draw main highways connecting major cities
    // N1 Highway (Yaoundé to Douala)
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.4),
      Offset(size.width * 0.15, size.height * 0.45),
      paint,
    );

    // N2 Highway (Yaoundé to Bertoua)
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.42),
      paint,
    );

    // N3 Highway (Yaoundé to Ebolowa)
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.4),
      Offset(size.width * 0.3, size.height * 0.72),
      paint,
    );

    // Douala to Buea/Limbe road
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.1, size.height * 0.6),
      paint,
    );

    // Northern roads
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.8, size.height * 0.12),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
