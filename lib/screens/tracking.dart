import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';

import 'home.dart';
import 'requestRide.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF4361EE);
  static const Color secondaryPurple = Color(0xFF7209B7);
  static const Color accentTeal = Color(0xFF4CC9F0);
  static const Color successGreen = Color(0xFF06D6A0);
  static const Color warningAmber = Color(0xFFFFD166);
  static const Color errorRed = Color(0xFFEF476F);
  static const Color backgroundWhite = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color shadowSubtle = Color(0x0D000000);
  static const Color overlayDark = Color(0x66000000);

  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryBlue, secondaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [accentTeal, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _refreshAnimationController;
  bool _isRefreshing = false;
  final MapController _mapController = MapController();
  late LatLng _currentDriverLocation;
  Timer? _driverMoveTimer;

  // Mock delivery data
  final Map<String, dynamic> _deliveryDetails = {
    'orderId': 'SV-2025-001234',
    'status': 'En Route',
    'pickupAddress': 'Takoradi Mall, Liberation Road, Takoradi',
    'destinationAddress': 'Grace Garden Hotel, Beach Road, Takoradi',
    'estimatedArrival': '15 mins',
    'distanceRemaining': '3.2 km',
    'totalDistance': '8.5 km',
    'orderValue': 'GHS 45.50',
  };

  final Map<String, dynamic> _driverInfo = {
    'name': 'Kwame Asante',
    'avatar':
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
    'rating': 4.8,
    'totalRides': 1247,
    'vehicleType': 'Motorbike',
    'licensePlate': 'GR 2345-23',
    'phone': '+233 24 123 4567',
  };

  final List<Map<String, dynamic>> _statusTimeline = [
    {
      'title': 'Order Confirmed',
      'description': 'Your delivery request has been confirmed',
      'timestamp': '10:15 AM',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': 'Driver Assigned',
      'description': 'Kwame Asante is your delivery driver',
      'timestamp': '10:18 AM',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': 'Pickup in Progress',
      'description': 'Driver is collecting your package',
      'timestamp': '10:25 AM',
      'isCompleted': true,
      'isActive': false,
    },
    {
      'title': 'En Route',
      'description': 'Package is on the way to destination',
      'timestamp': '10:32 AM',
      'isCompleted': false,
      'isActive': true,
    },
    {
      'title': 'Delivered',
      'description': 'Package delivered successfully',
      'timestamp': null,
      'isCompleted': false,
      'isActive': false,
    },
  ];

  // Mock coordinates for Takoradi, Ghana
  final LatLng _pickupLocation = const LatLng(4.8967, -1.7581); // Takoradi Mall
  final LatLng _destinationLocation = const LatLng(
    4.9045,
    -1.7432,
  ); // Grace Garden Hotel

  final List<LatLng> _routePoints = [
    const LatLng(4.8967, -1.7581), // Takoradi Mall
    const LatLng(4.8985, -1.7565),
    const LatLng(4.9001, -1.7543),
    const LatLng(4.9012, -1.7502), // Current driver position
    const LatLng(4.9025, -1.7478),
    const LatLng(4.9038, -1.7455),
    const LatLng(4.9045, -1.7432), // Grace Garden Hotel
  ];

  @override
  void initState() {
    super.initState();
    _currentDriverLocation = _routePoints[3]; // Initial driver position
    _startDriverSimulation();
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _refreshAnimationController.dispose();
    _driverMoveTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startDriverSimulation() {
    int currentPointIndex = 3;
    _driverMoveTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        currentPointIndex++;
        if (currentPointIndex >= _routePoints.length) {
          currentPointIndex = _routePoints.length - 1;
          timer.cancel(); // Stop when destination is reached
        }
        _currentDriverLocation = _routePoints[currentPointIndex];

        // Animate map to follow the driver
        _mapController.move(_currentDriverLocation, _mapController.camera.zoom);
      });
    });
  }

  Future<void> _refreshTrackingData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    _refreshAnimationController.forward();
    HapticFeedback.lightImpact();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _refreshAnimationController.reset();
    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tracking data updated'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _callDriver() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling ${_driverInfo['name']}...'),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _messageDriver() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${_driverInfo['name']}...'),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _shareTrackingLink() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tracking link copied to clipboard'),
        backgroundColor: AppTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _reportIssue() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Issue'),
            content: const Text('What issue would you like to report?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Issue reported successfully'),
                      backgroundColor: AppTheme.warningAmber,
                    ),
                  );
                },
                child: const Text('Report'),
              ),
            ],
          ),
    );
  }

  void _emergencyContact() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.emergency_rounded,
                  color: AppTheme.errorRed,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                const Text('Emergency Contact'),
              ],
            ),
            content: const Text(
              'Are you sure you want to contact emergency services?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contacting emergency services...'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                ),
                child: const Text('Contact'),
              ),
            ],
          ),
    );
  }

  void _centerOnDriver() {
    HapticFeedback.selectionClick();
    _mapController.move(_currentDriverLocation, 16.0);
  }

  void _showDeliveryDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _DeliveryDetailsBottomSheetWidget(
            deliveryDetails: _deliveryDetails,
            onShareTracking: _shareTrackingLink,
            onReportIssue: _reportIssue,
            onEmergencyContact: _emergencyContact,
          ),
    );
  }

  void _showStatusTimeline() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 2.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: _DeliveryStatusTimelineWidget(
                    statusTimeline: _statusTimeline,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Track Delivery',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        actions: [
          AnimatedBuilder(
            animation: _refreshAnimationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshAnimationController.value * 2 * 3.14159,
                child: IconButton(
                  onPressed: _isRefreshing ? null : _refreshTrackingData,
                  icon: Icon(
                    Icons.refresh_rounded,
                    color:
                        _isRefreshing
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                    size: 20,
                  ),
                  tooltip: 'Refresh tracking',
                ),
              );
            },
          ),
          IconButton(
            onPressed: _showDeliveryDetails,
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
            tooltip: 'More options',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshTrackingData,
        color: AppTheme.primaryBlue,
        child: Stack(
          children: [
            // Map
            _DeliveryMapWidget(
              mapController: _mapController,
              pickupLocation: _pickupLocation,
              destinationLocation: _destinationLocation,
              currentDriverLocation: _currentDriverLocation,
              routePoints: _routePoints,
              onCenterOnDriver: _centerOnDriver,
            ),

            // Driver info card
            Positioned(
              top: 2.h,
              left: 0,
              right: 0,
              child: _DriverInfoCardWidget(
                driverInfo: _driverInfo,
                onCallDriver: _callDriver,
                onMessageDriver: _messageDriver,
              ),
            ),

            // Status timeline button
            Positioned(
              left: 4.w,
              bottom: 20.h,
              child: FloatingActionButton.extended(
                onPressed: _showStatusTimeline,
                backgroundColor: colorScheme.surface,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 4,
                icon: Icon(
                  Icons.timeline_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                label: Text(
                  'Status',
                  style: TextStyle(
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),

            // Bottom Navigation Bar
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 25,
      right: 25,
      bottom: 25,
      child: Container(
        height: 75,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.home,
              label: 'Home',
              active: false,
              onTap: () {
                // Pop until we get to the root screen (HomeScreen)
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Request',
              active: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryRequestFormScreen(),
                  ),
                );
              },
            ),
            _BottomNavItem(
              icon: Icons.location_on_outlined,
              label: 'Tracking',
              active: true,
              onTap: null, // Already on this screen
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverInfoCardWidget extends StatelessWidget {
  final Map<String, dynamic> driverInfo;
  final VoidCallback onCallDriver;
  final VoidCallback onMessageDriver;

  const _DriverInfoCardWidget({
    required this.driverInfo,
    required this.onCallDriver,
    required this.onMessageDriver,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSubtle,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 15.w,
                height: 15.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryBlue, width: 2),
                ),
                child: ClipOval(
                  child: Image.network(
                    driverInfo['avatar'] as String,
                    width: 15.w,
                    height: 15.w,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        child: Icon(
                          Icons.person_rounded,
                          color: AppTheme.primaryBlue,
                          size: 8.w,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverInfo['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: AppTheme.warningAmber,
                          size: 14,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${driverInfo['rating']} (${driverInfo['totalRides']} rides)',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${driverInfo['vehicleType']} • ${driverInfo['licensePlate']}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCallDriver,
                  icon: Icon(
                    Icons.phone_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                  label: Text('Call', style: TextStyle(fontSize: 14.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successGreen,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMessageDriver,
                  icon: Icon(
                    Icons.message_rounded,
                    color: AppTheme.primaryBlue,
                    size: 16,
                  ),
                  label: Text('Message', style: TextStyle(fontSize: 14.sp)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    side: const BorderSide(color: AppTheme.primaryBlue),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryStatusTimelineWidget extends StatelessWidget {
  final List<Map<String, dynamic>> statusTimeline;

  const _DeliveryStatusTimelineWidget({required this.statusTimeline});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Status',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 3.h),
          ...statusTimeline.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isLast = index == statusTimeline.length - 1;
            final isCompleted = status['isCompleted'] as bool;
            final isActive = status['isActive'] as bool;

            return _buildTimelineItem(
              context,
              status,
              isLast,
              isCompleted,
              isActive,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> status,
    bool isLast,
    bool isCompleted,
    bool isActive,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    if (isCompleted) {
      statusColor = AppTheme.successGreen;
    } else if (isActive) {
      statusColor = AppTheme.primaryBlue;
    } else {
      statusColor = colorScheme.outline;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 2),
              ),
              child:
                  isCompleted
                      ? Icon(Icons.check_rounded, color: Colors.white, size: 12)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 8.h,
                color:
                    isCompleted
                        ? AppTheme.successGreen
                        : colorScheme.outline.withOpacity(0.3),
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                status['title'] as String,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color:
                      isActive
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),
              if (status['description'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  status['description'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
              ],
              if (status['timestamp'] != null) ...[
                SizedBox(height: 0.5.h),
                Text(
                  status['timestamp'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryMapWidget extends StatefulWidget {
  final MapController mapController;
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final LatLng currentDriverLocation;
  final List<LatLng> routePoints;
  final VoidCallback onCenterOnDriver;

  const _DeliveryMapWidget({
    required this.mapController,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.currentDriverLocation,
    required this.routePoints,
    required this.onCenterOnDriver,
  });

  @override
  State<_DeliveryMapWidget> createState() => _DeliveryMapWidgetState();
}

class _DeliveryMapWidgetState extends State<_DeliveryMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _driverAnimationController;
  late Animation<double> _driverPulseAnimation;

  @override
  void initState() {
    super.initState();
    _driverAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _driverPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _driverAnimationController,
        curve: Curves.easeInOut,
      ),
    );
    _driverAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _driverAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: widget.currentDriverLocation,
            initialZoom: 15.0,
            minZoom: 12.0,
            maxZoom: 18.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.swiftvan.app',
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: widget.routePoints,
                  strokeWidth: 5.0,
                  gradientColors: [AppTheme.accentTeal, AppTheme.primaryBlue],
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                _buildLocationMarker(
                  widget.pickupLocation,
                  Icons.store_rounded,
                  AppTheme.successGreen,
                ),
                _buildLocationMarker(
                  widget.destinationLocation,
                  Icons.flag_rounded,
                  AppTheme.errorRed,
                ),
                Marker(
                  point: widget.currentDriverLocation,
                  width: 80,
                  height: 80,
                  child: ScaleTransition(
                    scale: _driverPulseAnimation,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                      ),
                      child: Center(
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(
                              BorderSide(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        // Center on driver button
        Positioned(
          right: 4.w,
          bottom: 20.h,
          child: FloatingActionButton(
            onPressed: widget.onCenterOnDriver,
            backgroundColor: colorScheme.surface,
            foregroundColor: AppTheme.primaryBlue,
            elevation: 4,
            child: Icon(
              Icons.my_location_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Marker _buildLocationMarker(LatLng point, IconData icon, Color color) {
    return Marker(
      point: point,
      width: 45,
      height: 45,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _DeliveryDetailsBottomSheetWidget extends StatelessWidget {
  final Map<String, dynamic> deliveryDetails;
  final VoidCallback onShareTracking;
  final VoidCallback onReportIssue;
  final VoidCallback onEmergencyContact;

  const _DeliveryDetailsBottomSheetWidget({
    required this.deliveryDetails,
    required this.onShareTracking,
    required this.onReportIssue,
    required this.onEmergencyContact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowSubtle,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Delivery Details',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                              fontSize: 18.sp,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                deliveryDetails['status'] as String,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              deliveryDetails['status'] as String,
                              style: TextStyle(
                                color: _getStatusColor(
                                  deliveryDetails['status'] as String,
                                ),
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),

                      // Delivery info
                      _buildInfoSection(
                        context,
                        'Order ID',
                        deliveryDetails['orderId'] as String,
                      ),
                      _buildInfoSection(
                        context,
                        'Pickup Location',
                        deliveryDetails['pickupAddress'] as String,
                      ),
                      _buildInfoSection(
                        context,
                        'Destination',
                        deliveryDetails['destinationAddress'] as String,
                      ),
                      _buildInfoSection(
                        context,
                        'Estimated Arrival',
                        deliveryDetails['estimatedArrival'] as String,
                      ),
                      _buildInfoSection(
                        context,
                        'Distance Remaining',
                        deliveryDetails['distanceRemaining'] as String,
                      ),

                      SizedBox(height: 3.h),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onShareTracking,
                              icon: Icon(
                                Icons.share_rounded,
                                color: AppTheme.primaryBlue,
                                size: 16,
                              ),
                              label: Text(
                                'Share',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBlue,
                                side: const BorderSide(
                                  color: AppTheme.primaryBlue,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onReportIssue,
                              icon: Icon(
                                Icons.report_problem_rounded,
                                color: AppTheme.warningAmber,
                                size: 16,
                              ),
                              label: Text(
                                'Report',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.warningAmber,
                                side: const BorderSide(
                                  color: AppTheme.warningAmber,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2.h),

                      // Emergency contact button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onEmergencyContact,
                          icon: Icon(
                            Icons.emergency_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: Text(
                            'Emergency Contact',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorRed,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppTheme.primaryBlue;
      case 'driver assigned':
        return AppTheme.warningAmber;
      case 'pickup in progress':
        return AppTheme.successGreen;
      case 'en route':
        return AppTheme.primaryBlue;
      case 'delivered':
        return AppTheme.successGreen;
      default:
        return AppTheme.primaryBlue;
    }
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: active ? AppTheme.primaryGradient : null,
              color: active ? null : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : AppTheme.textSecondary,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: active ? AppTheme.primaryBlue : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
