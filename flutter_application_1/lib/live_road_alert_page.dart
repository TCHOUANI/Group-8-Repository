 import 'package:flutter/material.dart';
import 'alert_firebase_service.dart'; // Import your Firebase service

class LiveRoadAlertsPage extends StatefulWidget {
  const LiveRoadAlertsPage({Key? key}) : super(key: key);

  @override
  State<LiveRoadAlertsPage> createState() => _LiveRoadAlertsPageState();
}

class _LiveRoadAlertsPageState extends State<LiveRoadAlertsPage>
    with TickerProviderStateMixin {
  final AlertFirebaseService _alertService = AlertFirebaseService();
  
  List<RoadAlert> _alerts = [];
  List<RoadAlert> _filteredAlerts = [];
  List<String> _newAlertIds = []; // Track new alerts for notification
  AlertType? _selectedFilter;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _notificationController;
  late Animation<double> _notificationAnimation;

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _notificationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _notificationController,
      curve: Curves.elasticOut,
    ));
    
    _loadAlerts();
    _listenToAlerts();
  }

  @override
  void dispose() {
    _notificationController.dispose();
    super.dispose();
  }

  void _loadAlerts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final alerts = await _alertService.getActiveAlerts();
      setState(() {
        _alerts = alerts;
        _filteredAlerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load alerts: $e';
        _isLoading = false;
      });
    }
  }

  void _listenToAlerts() {
    _alertService.getActiveAlertsStream().listen(
      (alerts) {
        // Check for new alerts
        List<String> currentAlertIds = _alerts.map((alert) => alert.id).toList();
        List<RoadAlert> newAlerts = alerts.where((alert) => 
          !currentAlertIds.contains(alert.id) && _isRecentAlert(alert)
        ).toList();

        if (newAlerts.isNotEmpty && _alerts.isNotEmpty) {
          // New alerts detected
          _showNewAlertNotification(newAlerts);
          _newAlertIds.addAll(newAlerts.map((alert) => alert.id));
        }

        setState(() {
          _alerts = alerts;
          _applyCurrentFilter();
        });
      },
      onError: (error) {
        setState(() {
          _errorMessage = 'Real-time updates failed: $error';
        });
      },
    );
  }

  void _showNewAlertNotification(List<RoadAlert> newAlerts) {
    _notificationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _notificationController.reverse();
        }
      });
    });

    // Show snackbar for new alerts
    String message = newAlerts.length == 1 
        ? 'New ${_getAlertTitle(newAlerts.first.type).toLowerCase()} reported nearby!'
        : '${newAlerts.length} new alerts reported nearby!';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.new_releases, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                _scrollToNewAlerts();
              },
              child: const Text('VIEW', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _scrollToNewAlerts() {
    // Clear new alert tracking after user views them
    setState(() {
      _newAlertIds.clear();
    });
  }

  void _applyCurrentFilter() {
    if (_selectedFilter == null) {
      _filteredAlerts = _alerts;
    } else {
      _filteredAlerts = _alerts.where((alert) => alert.type == _selectedFilter).toList();
    }
    
    // Sort alerts by timestamp (newest first) and highlight new ones
    _filteredAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void _filterAlerts(AlertType? filterType) {
    setState(() {
      _selectedFilter = filterType;
      _applyCurrentFilter();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Filter Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            ...AlertType.values.map(
              (type) => ListTile(
                leading: Icon(
                  _getAlertIcon(type),
                  color: _getAlertColor(type),
                ),
                title: Text(_getAlertTitle(type)),
                trailing: _selectedFilter == type
                    ? const Icon(Icons.check, color: Color(0xFF1A237E))
                    : null,
                onTap: () {
                  _filterAlerts(type);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.clear_all, color: Colors.grey),
              title: const Text('Show All'),
              trailing: _selectedFilter == null
                  ? const Icon(Icons.check, color: Color(0xFF1A237E))
                  : null,
              onTap: () {
                _filterAlerts(null);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _viewOnMap() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Showing alerts on map'),
        backgroundColor: Color(0xFF1A237E),
      ),
    );
  }

  void _refreshAlerts() {
    _loadAlerts();
  }

  bool _isRecentAlert(RoadAlert alert) {
    final now = DateTime.now();
    final alertTime = alert.timestamp;
    final difference = now.difference(alertTime);
    return difference.inMinutes <= 10; // Consider alerts from last 10 minutes as recent
  }

  bool _isNewAlert(RoadAlert alert) {
    return _newAlertIds.contains(alert.id);
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF1A237E),
          ),
          SizedBox(height: 16),
          Text(
            'Loading live alerts...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == null 
                ? 'No active alerts in your area'
                : 'No ${_getAlertTitle(_selectedFilter!).toLowerCase()} alerts found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Road conditions look good!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(RoadAlert alert) {
    final isNew = _isNewAlert(alert);
    final isRecent = _isRecentAlert(alert);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isNew ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // New alert indicator
          if (isNew)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.fiber_new, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'NEW REPORT',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getAlertColor(alert.type),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getAlertIcon(alert.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  alert.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              if (isRecent)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'RECENT',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alert.location ?? 'Unknown Location',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSeverityColor(alert.severity).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.severity.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getSeverityColor(alert.severity),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  alert.description ?? 'No description available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimestamp(alert.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.people,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '1 report',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for alert display
  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return Icons.car_crash;
      case AlertType.traffic:
        return Icons.traffic;
      case AlertType.roadClosure:
        return Icons.warning;
      case AlertType.construction:
        return Icons.construction;
      case AlertType.weather:
        return Icons.cloud_queue;
      default:
        return Icons.info;
    }
  }

  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return Colors.red;
      case AlertType.traffic:
        return Colors.amber[800]!;
      case AlertType.roadClosure:
        return Colors.orange;
      case AlertType.construction:
        return Colors.brown;
      case AlertType.weather:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getAlertTitle(AlertType type) {
    switch (type) {
      case AlertType.accident:
        return 'Accident';
      case AlertType.traffic:
        return 'Traffic';
      case AlertType.roadClosure:
        return 'Road Hazard';
      case AlertType.construction:
        return 'Construction';
      case AlertType.weather:
        return 'Weather';
      default:
        return 'Alert';
    }
  }

  Color _getSeverityColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Live Road Alerts',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_alerts.isNotEmpty)
              Text(
                '${_filteredAlerts.length} active alerts',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: _selectedFilter != null ? const Color(0xFF1A237E) : Colors.black,
            ),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _refreshAlerts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A237E)),
            ),

          // Error message
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  TextButton(
                    onPressed: _refreshAlerts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),

          // New alerts notification banner
          AnimatedBuilder(
            animation: _notificationAnimation,
            builder: (context, child) {
              if (_notificationAnimation.value == 0) return const SizedBox.shrink();
              
              return Transform.scale(
                scale: _notificationAnimation.value,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  color: Colors.orange[50],
                  child: Row(
                    children: [
                      Icon(Icons.new_releases, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'New reports coming in! Stay alert on the roads.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Alert List
          Expanded(
            child: _isLoading && _alerts.isEmpty
                ? _buildLoadingState()
                : _filteredAlerts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async => _refreshAlerts(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAlerts.length,
                          itemBuilder: (context, index) {
                            return _buildAlertCard(_filteredAlerts[index]);
                          },
                        ),
                      ),
          ),

          // Bottom Action Button - Only View on Map
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _viewOnMap,
                icon: const Icon(Icons.map),
                label: const Text('View Alerts on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}