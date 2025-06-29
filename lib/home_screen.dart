 import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'live_road_alert_page.dart';
import 'learn_page.dart';
import 'report_page.dart';
import 'settings_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Google Maps controller
  Completer<GoogleMapController> _controller = Completer();
  
  // Traffic and Map Settings
  bool _trafficEnabled = true;
  bool _buildingsEnabled = true;
  MapType _currentMapType = MapType.normal;
  
  // Weather API settings
  static const String _weatherApiKey = 'fcd11983af82b1ac4cb63fb4ea79cead'; // Replace with your API key
  static const String _weatherBaseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  Map<String, dynamic>? _currentWeather;
  bool _showWeatherInfo = false;
  
  // Initial camera position (centered on Cameroon)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(7.3697, 12.3547), // Center of Cameroon
    zoom: 6.0,
  );

  // Map markers for major cities in Cameroon
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  
  // Search suggestions - Extended list of Cameroon towns and cities
  List<String> _searchSuggestions = [];
  bool _showSuggestions = false;
  
  // Comprehensive list of Cameroon cities and towns with coordinates
  final Map<String, LatLng> _cameroonCities = {
    // Major Cities
    'yaounde': LatLng(3.8480, 11.5021),
    'douala': LatLng(4.0483, 9.7043),
    'garoua': LatLng(9.3011, 13.3857),
    'maroua': LatLng(10.5913, 14.3153),
    'bafoussam': LatLng(5.4781, 10.4167),
    'buea': LatLng(4.1546, 9.2945),
    'limbe': LatLng(4.0186, 9.2056),
    'bertoua': LatLng(4.5836, 13.6871),
    'ebolowa': LatLng(2.9175, 11.1546),
    'bamenda': LatLng(5.9597, 10.1494),
    'ngaoundere': LatLng(7.3167, 13.5833),
    'kumba': LatLng(4.6333, 9.4667),
    'edea': LatLng(3.8000, 10.1333),
    'loum': LatLng(4.7167, 9.7333),
    'dschang': LatLng(5.4500, 10.0500),
    
    // Additional towns and cities
    'kribi': LatLng(2.9333, 9.9167),
    'tiko': LatLng(4.0667, 9.3667),
    'mbalmayo': LatLng(3.5167, 11.5000),
    'sangmelima': LatLng(2.9333, 11.9833),
    'ambam': LatLng(2.3833, 11.2667),
    'batouri': LatLng(4.4333, 14.3667),
    'yokadouma': LatLng(3.5167, 15.0500),
    'moloundou': LatLng(2.0333, 15.1833),
    'kousséri': LatLng(12.0833, 15.0333),
    'mora': LatLng(11.0333, 14.1333),
    'waza': LatLng(11.3833, 14.6333),
    'mokolo': LatLng(10.7333, 13.8000),
    'kousseri': LatLng(12.0833, 15.0333),
    'roumsiki': LatLng(10.6000, 13.7667),
    'koza': LatLng(10.8500, 14.1000),
    'kaélé': LatLng(10.1000, 14.4500),
    'yagoua': LatLng(10.3333, 15.2333),
    'guidiguis': LatLng(9.0333, 15.0500),
    'touboro': LatLng(7.7833, 15.3667),
    'poli': LatLng(8.2667, 13.2667),
    'tchollire': LatLng(8.3833, 14.1667),
    'tibati': LatLng(6.4667, 12.6333),
    'banyo': LatLng(6.7500, 11.8167),
    'tignere': LatLng(7.3667, 12.6500),
    'meiganga': LatLng(6.5167, 14.2833),
    'batouri': LatLng(4.4333, 14.3667),
    'abong-mbang': LatLng(3.9833, 13.1833),
    'doume': LatLng(4.2167, 13.5333),
    'mindourou': LatLng(4.1167, 13.3833),
    'nanga-eboko': LatLng(4.6833, 12.3667),
    'ntui': LatLng(4.8167, 11.6333),
    'yoko': LatLng(5.5333, 12.3167),
    'tibati': LatLng(6.4667, 12.6333),
    'foumban': LatLng(5.7333, 10.9000),
    'foumbot': LatLng(5.5000, 10.6333),
    'koutaba': LatLng(5.7833, 10.7333),
    'bandjoun': LatLng(5.3667, 10.4167),
    'bafang': LatLng(5.1500, 10.1833),
    'mbouda': LatLng(5.6167, 10.2500),
    'wum': LatLng(6.3833, 10.0667),
    'nkambe': LatLng(6.5833, 10.6667),
    'ndop': LatLng(6.0167, 10.4500),
    'mbengwi': LatLng(6.1833, 9.8167),
    'muyuka': LatLng(4.3000, 9.3500),
    'mamfe': LatLng(5.7667, 9.3000),
    'kumbo': LatLng(6.2000, 10.6833),
    'fundong': LatLng(6.2333, 10.2833),
    'bali': LatLng(5.9000, 10.0167),
    'mbalmayo': LatLng(3.5167, 11.5000),
    'akonolinga': LatLng(3.7667, 12.2500),
    'ayos': LatLng(3.9000, 12.5333),
    'obala': LatLng(4.1667, 11.5333),
    'mfou': LatLng(3.7333, 11.6333),
    'sa\'a': LatLng(4.3667, 11.4500),
    'bafia': LatLng(4.7500, 11.2333),
    'bangangte': LatLng(5.1500, 10.5167),
    'melong': LatLng(5.1167, 9.9500),
    'nkongsamba': LatLng(4.9500, 9.9333),
    'manjo': LatLng(4.8000, 9.8333),
    'tombel': LatLng(4.6167, 9.6000),
    'konye': LatLng(4.5500, 9.2500),
    'ekondo-titi': LatLng(4.7167, 8.9167),
    'mundemba': LatLng(4.9667, 8.9667),
    'idenau': LatLng(4.1667, 8.9333),
    'debundscha': LatLng(4.0833, 9.0167),
  };

  @override
  void initState() {
    super.initState();
    _createMarkers();
    _createTrafficRoutes();
    _getCurrentLocationWeather();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch weather data for a given location
  Future<Map<String, dynamic>?> _fetchWeatherData(double lat, double lon) async {
    try {
      final url = '$_weatherBaseUrl?lat=$lat&lon=$lon&appid=$_weatherApiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Weather API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
    }
  }

  // Get weather for current/default location (Douala)
  Future<void> _getCurrentLocationWeather() async {
    final weatherData = await _fetchWeatherData(4.0483, 9.7043); // Douala coordinates
    if (weatherData != null) {
      setState(() {
        _currentWeather = weatherData;
      });
    }
  }

  // Get weather for searched location
  Future<void> _getLocationWeather(LatLng location, String cityName) async {
    final weatherData = await _fetchWeatherData(location.latitude, location.longitude);
    if (weatherData != null) {
      setState(() {
        _currentWeather = weatherData;
        _currentWeather!['searchedCity'] = cityName;
        _showWeatherInfo = true;
      });
      
      // Show weather info in a bottom sheet
      _showWeatherBottomSheet();
    }
  }

  // Show weather information in a bottom sheet
  void _showWeatherBottomSheet() {
    if (_currentWeather == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weather in ${_currentWeather!['searchedCity'] ?? _currentWeather!['name']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getWeatherIcon(_currentWeather!['weather'][0]['main']),
                  size: 48,
                  color: _getWeatherColor(_currentWeather!['weather'][0]['main']),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentWeather!['main']['temp'].round()}°C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentWeather!['weather'][0]['description'].toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  Icons.thermostat,
                  'Feels like',
                  '${_currentWeather!['main']['feels_like'].round()}°C',
                ),
                _buildWeatherDetail(
                  Icons.water_drop,
                  'Humidity',
                  '${_currentWeather!['main']['humidity']}%',
                ),
                _buildWeatherDetail(
                  Icons.air,
                  'Wind',
                  '${_currentWeather!['wind']['speed']} m/s',
                ),
              ],
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF1A237E)),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  IconData _getWeatherIcon(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.umbrella;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.blur_on;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _getWeatherColor(String weatherMain) {
    switch (weatherMain.toLowerCase()) {
      case 'clear':
        return Colors.orange;
      case 'clouds':
        return Colors.grey;
      case 'rain':
        return Colors.blue;
      case 'thunderstorm':
        return Colors.purple;
      case 'snow':
        return Colors.lightBlue;
      case 'mist':
      case 'fog':
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  // Google Maps controller initialization
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _createMarkers() {
    _markers = {
      // Northern Region
      Marker(
        markerId: const MarkerId('garoua'),
        position: const LatLng(9.3011, 13.3857),
        infoWindow: InfoWindow(
          title: 'Garoua',
          snippet: 'Northern Region${_trafficEnabled ? ' - Traffic: Moderate' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
      Marker(
        markerId: const MarkerId('maroua'),
        position: const LatLng(10.5913, 14.3153),
        infoWindow: InfoWindow(
          title: 'Maroua',
          snippet: 'Far North Region${_trafficEnabled ? ' - Traffic: Light' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      
      // Central Region
      Marker(
        markerId: const MarkerId('yaounde'),
        position: const LatLng(3.8480, 11.5021),
        infoWindow: InfoWindow(
          title: 'Yaoundé',
          snippet: 'Capital City${_trafficEnabled ? ' - Traffic: Heavy' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      Marker(
        markerId: const MarkerId('bafoussam'),
        position: const LatLng(5.4781, 10.4167),
        infoWindow: InfoWindow(
          title: 'Bafoussam',
          snippet: 'West Region${_trafficEnabled ? ' - Traffic: Moderate' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),

      // Littoral Region
      Marker(
        markerId: const MarkerId('douala'),
        position: const LatLng(4.0483, 9.7043),
        infoWindow: InfoWindow(
          title: 'Douala',
          snippet: 'Economic Capital${_trafficEnabled ? ' - Traffic: Heavy' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),

      // South West Region
      Marker(
        markerId: const MarkerId('buea'),
        position: const LatLng(4.1546, 9.2945),
        infoWindow: InfoWindow(
          title: 'Buea',
          snippet: 'South West Region${_trafficEnabled ? ' - Traffic: Light' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('limbe'),
        position: const LatLng(4.0186, 9.2056),
        infoWindow: InfoWindow(
          title: 'Limbe',
          snippet: 'Coastal City${_trafficEnabled ? ' - Traffic: Moderate' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),

      // Eastern Region
      Marker(
        markerId: const MarkerId('bertoua'),
        position: const LatLng(4.5836, 13.6871),
        infoWindow: InfoWindow(
          title: 'Bertoua',
          snippet: 'Eastern Region${_trafficEnabled ? ' - Traffic: Light' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      ),

      // South Region
      Marker(
        markerId: const MarkerId('ebolowa'),
        position: const LatLng(2.9175, 11.1546),
        infoWindow: InfoWindow(
          title: 'Ebolowa',
          snippet: 'South Region${_trafficEnabled ? ' - Traffic: Light' : ''}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose),
      ),
    };
  }

  void _createTrafficRoutes() {
    // Sample traffic routes between major cities
    _polylines = {
      // Yaoundé to Douala route (heavy traffic)
      Polyline(
        polylineId: const PolylineId('yaounde_douala'),
        points: [
          const LatLng(3.8480, 11.5021), // Yaoundé
          const LatLng(4.0483, 9.7043),  // Douala
        ],
        color: Colors.red,
        width: 5,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      ),
      
      // Douala to Buea route (moderate traffic)
      Polyline(
        polylineId: const PolylineId('douala_buea'),
        points: [
          const LatLng(4.0483, 9.7043), // Douala
          const LatLng(4.1546, 9.2945), // Buea
        ],
        color: Colors.orange,
        width: 4,
        patterns: [PatternItem.dash(15), PatternItem.gap(8)],
      ),
      
      // Garoua to Maroua route (light traffic)
      Polyline(
        polylineId: const PolylineId('garoua_maroua'),
        points: [
          const LatLng(9.3011, 13.3857),  // Garoua
          const LatLng(10.5913, 14.3153), // Maroua
        ],
        color: Colors.green,
        width: 3,
        patterns: [PatternItem.dash(10), PatternItem.gap(5)],
      ),
    };
  }

  // Toggle traffic layer
  void _toggleTraffic() {
    setState(() {
      _trafficEnabled = !_trafficEnabled;
      _createMarkers(); // Refresh markers with traffic info
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _trafficEnabled ? 'Traffic layer enabled' : 'Traffic layer disabled',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _trafficEnabled ? Colors.green : Colors.grey,
      ),
    );
  }

  // Toggle map type
  void _toggleMapType() {
    setState(() {
      switch (_currentMapType) {
        case MapType.normal:
          _currentMapType = MapType.satellite;
          break;
        case MapType.satellite:
          _currentMapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _currentMapType = MapType.terrain;
          break;
        case MapType.terrain:
          _currentMapType = MapType.normal;
          break;
        case MapType.none:
          _currentMapType = MapType.normal;
          break;
        default:
          _currentMapType = MapType.normal;
          break;
      }
    });
    
    String mapTypeName = _currentMapType.toString().split('.').last;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Map type: ${mapTypeName.toUpperCase()}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Toggle buildings
  void _toggleBuildings() {
    setState(() {
      _buildingsEnabled = !_buildingsEnabled;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _buildingsEnabled ? 'Buildings enabled' : 'Buildings disabled',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Enhanced search functionality
  void _performSearch(String query) {
    if (query.isEmpty) return;
    
    final searchKey = query.toLowerCase().trim();
    LatLng? targetLocation;
    String? cityName;
    
    // Search through all Cameroon cities
    for (String city in _cameroonCities.keys) {
      if (city.contains(searchKey) || city.startsWith(searchKey)) {
        targetLocation = _cameroonCities[city];
        cityName = city.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
        break;
      }
    }
    
    // Also check display names
    for (String city in _cameroonCities.keys) {
      String displayName = city.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
      if (displayName.toLowerCase().contains(searchKey)) {
        targetLocation = _cameroonCities[city];
        cityName = displayName;
        break;
      }
    }
    
    if (targetLocation != null && cityName != null) {
      _goToLocation(targetLocation);
      _getLocationWeather(targetLocation, cityName);
      setState(() {
        _showSuggestions = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: $query')),
      );
    }
  }

  // Generate search suggestions from comprehensive city list
  void _generateSearchSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _searchSuggestions = [];
      });
      return;
    }

    List<String> suggestions = _cameroonCities.keys
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .map((city) => city.split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '))
        .take(10) // Limit to 10 suggestions
        .toList();

    setState(() {
      _searchSuggestions = suggestions;
      _showSuggestions = suggestions.isNotEmpty;
    });
  }

  void _onBottomNavTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LiveRoadAlertsPage()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportPage()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LearnPage()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsPage()),
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
    }
  }

  void _onProfileTapped() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  Future<void> _goToLocation(LatLng location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: location, zoom: 12.0),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map with Traffic
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            polylines: _polylines,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            trafficEnabled: _trafficEnabled,
            buildingsEnabled: _buildingsEnabled,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            onTap: (LatLng position) {
              // Hide search suggestions when map is tapped
              setState(() {
                _showSuggestions = false;
              });
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
                  Row(
                    children: [
                      const Icon(
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
                      // Traffic status indicator
                      if (_trafficEnabled) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.traffic, size: 12, color: Colors.red.shade700),
                              const SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      // Weather indicator
                      if (_currentWeather != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showWeatherBottomSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getWeatherIcon(_currentWeather!['weather'][0]['main']),
                                  size: 12,
                                  color: _getWeatherColor(_currentWeather!['weather'][0]['main']),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_currentWeather!['main']['temp'].round()}°C',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
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

          // Enhanced Search Bar with Suggestions
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
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
                      hintText: 'Search any town in Cameroon...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_currentWeather != null)
                            IconButton(
                              icon: Icon(
                                Icons.wb_cloudy,
                                color: _getWeatherColor(_currentWeather!['weather'][0]['main']),
                              ),
                              onPressed: _showWeatherBottomSheet,
                              tooltip: 'View Weather',
                            ),
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                          ),
                        ],
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
                    onChanged: _generateSearchSuggestions,
                    onSubmitted: _performSearch,
                  ),
                ),
                // Search Suggestions
                if (_showSuggestions)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    constraints: BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.location_on, size: 20, color: Color(0xFF1A237E)),
                          title: Text(_searchSuggestions[index]),
                          dense: true,
                          onTap: () {
                            _searchController.text = _searchSuggestions[index];
                            _performSearch(_searchSuggestions[index]);
                            setState(() {
                              _showSuggestions = false;
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Enhanced Map Controls with Traffic Toggle
          Positioned(
            right: 20,
            top: MediaQuery.of(context).padding.top + 160,
            child: Column(
              children: [
                // Traffic Toggle Button
                _buildMapControlButton(
                  _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
                  _toggleTraffic,
                  backgroundColor: _trafficEnabled ? Colors.red.shade100 : Colors.white,
                  iconColor: _trafficEnabled ? Colors.red.shade700 : const Color(0xFF1A237E),
                ),
                const SizedBox(height: 8),
                
                // Weather Button
                if (_currentWeather != null)
                  _buildMapControlButton(
                    _getWeatherIcon(_currentWeather!['weather'][0]['main']),
                    _showWeatherBottomSheet,
                    backgroundColor: Colors.blue.shade100,
                    iconColor: Colors.blue.shade700,
                  ),
                if (_currentWeather != null) const SizedBox(height: 8),
                
                // Map Type Toggle
                _buildMapControlButton(
                  Icons.layers,
                  _toggleMapType,
                ),
                const SizedBox(height: 8),
                
                // Buildings Toggle
                _buildMapControlButton(
                  _buildingsEnabled ? Icons.business : Icons.business_outlined,
                  _toggleBuildings,
                  backgroundColor: _buildingsEnabled ? Colors.blue.shade100 : Colors.white,
                  iconColor: _buildingsEnabled ? Colors.blue.shade700 : const Color(0xFF1A237E),
                ),
                const SizedBox(height: 8),
                
                // Zoom In
                _buildMapControlButton(
                  Icons.add,
                  () async {
                    final GoogleMapController controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomIn());
                  },
                ),
                const SizedBox(height: 8),
                
                // Zoom Out
                _buildMapControlButton(
                  Icons.remove,
                  () async {
                    final GoogleMapController controller = await _controller.future;
                    controller.animateCamera(CameraUpdate.zoomOut());
                  },
                ),
                const SizedBox(height: 8),
                
                // My Location
                _buildMapControlButton(
                  Icons.my_location,
                  () async {
                    final GoogleMapController controller = await _controller.future;
                    // Center on Douala (default location)
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        const CameraPosition(
                          target: LatLng(4.0483, 9.7043), // Douala coordinates
                          zoom: 12.0,
                        ),
                      ),
                    );
                    // Refresh weather for current location
                    _getCurrentLocationWeather();
                  },
                ),
              ],
            ),
          ),

          // Traffic Legend (when traffic is enabled)
          if (_trafficEnabled)
            Positioned(
              left: 20,
              bottom: 120,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Traffic Legend',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTrafficLegendItem(Colors.green, 'Light Traffic'),
                    _buildTrafficLegendItem(Colors.orange, 'Moderate Traffic'),
                    _buildTrafficLegendItem(Colors.red, 'Heavy Traffic'),
                  ],
                ),
              ),
            ),
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

  Widget _buildMapControlButton(
    IconData icon, 
    VoidCallback onPressed, {
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
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
        icon: Icon(icon, color: iconColor ?? const Color(0xFF1A237E)),
        onPressed: onPressed,
        iconSize: 20,
      ),
    );
  }

  Widget _buildTrafficLegendItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 3,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}