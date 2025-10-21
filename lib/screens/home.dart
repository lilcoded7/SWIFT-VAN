import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import 'requestRide.dart';
import 'tracking.dart';
import '../auths/login.dart';
import '../auths/signup.dart';

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(4.9040, -1.7550);
  bool _isLoadingLocation = false;
  bool _isMenuOpen = false;
  String _locationAddress = "Getting your location...";

  final List<Map<String, dynamic>> _riders = [];
  late final StreamSubscription<List<Map<String, dynamic>>> _riderStreamSub;
  StreamSubscription<Position>? _positionStream;
  final Random _rnd = Random();

  final LatLngBounds _takoradiBounds = LatLngBounds(
    const LatLng(4.86, -1.79),
    const LatLng(4.94, -1.72),
  );

  late AnimationController _locationAnimationController;

  late final DraggableScrollableController _draggableController;
  Map<String, dynamic>? _selectedRider;
  Offset? _tooltipPos;

  String? _selectedVehicleType;
  String _selectedPackageType = 'Food';
  final TextEditingController _descCtrl = TextEditingController();

  final Map<String, Map<String, dynamic>> _vehiclePricing = {
    'motorbike': {
      'name': 'Motorbike',
      'icon': Icons.motorcycle,
      'priceRange': 'GHC 15-25',
      'minPrice': 15,
      'maxPrice': 25,
      'color': AppTheme.primaryBlue,
      'gradient': LinearGradient(
        colors: [AppTheme.primaryBlue, Color(0xFF4895EF)],
      ),
    },
    'tricycle': {
      'name': 'Tricycle',
      'icon': Icons.moped,
      'priceRange': 'GHC 20-35',
      'minPrice': 20,
      'maxPrice': 35,
      'color': AppTheme.secondaryPurple,
      'gradient': LinearGradient(
        colors: [AppTheme.secondaryPurple, Color(0xFFB5179E)],
      ),
    },
    'van': {
      'name': 'Van',
      'icon': Icons.local_shipping_rounded,
      'priceRange': 'GHC 40-60',
      'minPrice': 40,
      'maxPrice': 60,
      'color': AppTheme.successGreen,
      'gradient': LinearGradient(
        colors: [AppTheme.successGreen, Color(0xFF06D6A0)],
      ),
    },
    'truck': {
      'name': 'Truck',
      'icon': Icons.local_shipping,
      'priceRange': 'GHC 80-120',
      'minPrice': 80,
      'maxPrice': 120,
      'color': AppTheme.warningAmber,
      'gradient': LinearGradient(
        colors: [AppTheme.warningAmber, Color(0xFFFF9E00)],
      ),
    },
  };

  final List<Map<String, dynamic>> _landmarks = [
    {
      'lat': 4.9015,
      'lng': -1.7537,
      'name': 'Market Circle',
      'icon': Icons.shopping_basket_rounded,
    },
    {
      'lat': 4.9178,
      'lng': -1.7665,
      'name': 'STC Stadium',
      'icon': Icons.stadium_rounded,
    },
    {
      'lat': 4.8902,
      'lng': -1.7514,
      'name': 'Harbor City Mall',
      'icon': Icons.store_mall_directory_rounded,
    },
    {
      'lat': 4.9261,
      'lng': -1.7732,
      'name': 'Takoradi Technical University',
      'icon': Icons.school_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
    _locationAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _generateInitialRidersAround(_currentLocation);
    _startSimulatedRiderStream();
    _determinePositionAndMove();
  }

  @override
  void dispose() {
    _riderStreamSub.cancel();
    _positionStream?.cancel();
    _draggableController.dispose();
    _descCtrl.dispose();
    _locationAnimationController.dispose();
    super.dispose();
  }

  void _generateInitialRidersAround(LatLng center) {
    _riders.clear();
    final types = ['motorbike', 'tricycle', 'van', 'truck'];
    final riderNames = [
      'Kwame Mensah',
      'Ama Boateng',
      'Kofi Asare',
      'Esi Nyarko',
      'Yaw Owusu',
      'Akosua Ampofo',
      'Nana Yeboah',
      'Abena Serwaa',
      'Kwabena Darko',
      'Adwoa Poku',
    ];

    for (var i = 0; i < 10; i++) {
      final type = types[_rnd.nextInt(types.length)];
      final vehicleData = _vehiclePricing[type]!;

      final distance = _rnd.nextDouble() * 0.03;
      final angle = _rnd.nextDouble() * 2 * pi;

      final dlat = distance * cos(angle);
      final dlng = distance * sin(angle);

      final p = LatLng(
        (center.latitude + dlat).clamp(
          _takoradiBounds.south,
          _takoradiBounds.north,
        ),
        (center.longitude + dlng).clamp(
          _takoradiBounds.west,
          _takoradiBounds.east,
        ),
      );

      _riders.add({
        'id': 'r$i',
        'type': type,
        'pos': p,
        'name': riderNames[i],
        'vehicleName': '${vehicleData['name']} ${i + 1}',
        'eta': '${5 + _rnd.nextInt(15)} min',
        'available': true,
        'rating': 4.0 + _rnd.nextDouble() * 1.0,
        'price':
            vehicleData['minPrice'] +
            _rnd.nextInt(vehicleData['maxPrice'] - vehicleData['minPrice']),
        'color': vehicleData['color'],
        'gradient': vehicleData['gradient'],
      });
    }
  }

  void _startSimulatedRiderStream() {
    final stream = Stream<List<Map<String, dynamic>>>.periodic(
      const Duration(seconds: 3),
      (_) {
        return _riders.map((r) {
          final p = r['pos'] as LatLng;
          var newLat = p.latitude + (_rnd.nextDouble() - 0.5) * 0.0008;
          var newLng = p.longitude + (_rnd.nextDouble() - 0.5) * 0.0008;
          newLat = newLat.clamp(_takoradiBounds.south, _takoradiBounds.north);
          newLng = newLng.clamp(_takoradiBounds.west, _takoradiBounds.east);

          final distance = _calculateDistance(
            _currentLocation,
            LatLng(newLat, newLng),
          );
          final eta = (distance * 3).ceil();

          return {
            ...r,
            'pos': LatLng(newLat, newLng),
            'eta': '${eta.clamp(3, 25)} min',
          };
        }).toList();
      },
    );

    _riderStreamSub = stream.listen((updatedList) {
      setState(() {
        for (var u in updatedList) {
          final idx = _riders.indexWhere((r) => r['id'] == u['id']);
          if (idx != -1) _riders[idx] = u;
        }
      });
    });
  }

  double _calculateDistance(LatLng start, LatLng end) {
    const distance = Distance();
    return distance(start, end) / 1000;
  }

  Future<void> _determinePositionAndMove() async {
    setState(() {
      _positionStream?.cancel();
      _isLoadingLocation = true;
      _locationAddress = "Detecting your location...";
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
          _locationAddress = "Location services disabled";
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
            _locationAddress = "Location permission denied";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
          _locationAddress = "Location permission permanently denied";
        });
        return;
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 0,
        ),
      ).listen((Position pos) {
        final clampedLat = pos.latitude.clamp(
          _takoradiBounds.south,
          _takoradiBounds.north,
        );
        final clampedLon = pos.longitude.clamp(
          _takoradiBounds.west,
          _takoradiBounds.east,
        );

        final newLocation = LatLng(clampedLat, clampedLon);

        if (_isLoadingLocation) {
          // First time getting location
          _generateInitialRidersAround(newLocation);
          _mapController.move(newLocation, 16.0);
        } else {
          // Animate map to new location
          _mapController.move(newLocation, _mapController.camera.zoom);
        }

        setState(() {
          _currentLocation = newLocation;
          _isLoadingLocation = false;
          _locationAddress = _getAddressFromCoordinates(clampedLat, clampedLon);
        });
      });
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
        _locationAddress = "Unable to get location";
      });
    }
  }

  String _getAddressFromCoordinates(double lat, double lng) {
    for (var landmark in _landmarks) {
      final landmarkLat = landmark['lat'] as double;
      final landmarkLng = landmark['lng'] as double;
      final distance = _calculateDistance(
        LatLng(lat, lng),
        LatLng(landmarkLat, landmarkLng),
      );
      if (distance < 1.0) {
        return "Near ${landmark['name']}, Takoradi";
      }
    }

    return "Takoradi, Western Region, Ghana";
  }

  void _onRiderTap(Map<String, dynamic> rider, TapPosition tapPos) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final local = renderBox.globalToLocal(tapPos.global);
    setState(() {
      _selectedRider = rider;
      _tooltipPos = local;
    });
  }

  void _closeTooltip() {
    setState(() {
      _selectedRider = null;
      _tooltipPos = null;
    });
  }

  List<Map<String, dynamic>> get _visibleRiders {
    if (_selectedVehicleType == null) return _riders;
    return _riders.where((r) => r['type'] == _selectedVehicleType).toList();
  }

  Widget _vehicleMarker(Map<String, dynamic> r) {
    return _PulsingRiderMarker(
      key: ValueKey(r['id']),
      vehicleData: _vehiclePricing[r['type'] as String]!,
    );
  }

  Marker _buildLandmarkMarker(Map<String, dynamic> landmark) {
    return Marker(
      point: LatLng(landmark['lat'] as double, landmark['lng'] as double),
      width: 120,
      height: 40,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.85),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  landmark['icon'] as IconData,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 5),
                Text(
                  landmark['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentLocation,
        initialZoom: 15.0,
        minZoom: 12.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all,
        ),
        onTap: (tapPos, latlng) {
          _closeTooltip();
          FocusScope.of(context).unfocus();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.swiftvan.app',
        ),
        MarkerLayer(
          markers: _landmarks.map((l) => _buildLandmarkMarker(l)).toList(),
        ),
        MarkerLayer(
          markers:
              _visibleRiders
                  .map(
                    (r) => Marker(
                      point: r['pos'] as LatLng,
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTapDown:
                            (details) => _onRiderTap(
                              r,
                              TapPosition(
                                details.globalPosition,
                                details.localPosition,
                              ),
                            ),
                        child: _vehicleMarker(r),
                      ),
                    ),
                  )
                  .toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point:
                  _currentLocation, // This will be the target for the animation
              width: 60,
              height: 60,
              child: TweenAnimationBuilder<LatLng>(
                tween: LatLngTween(
                  begin: _currentLocation,
                  end: _currentLocation,
                ),
                duration: const Duration(milliseconds: 500),
                builder: (context, latLng, child) {
                  return _UserLocationMarker(key: ValueKey(_currentLocation));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isMenuOpen = true;
              });
              FocusScope.of(context).unfocus();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Icon(Icons.menu, color: Colors.white),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondaryPurple.withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'SwiftVan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      left: _isMenuOpen ? 0 : -MediaQuery.of(context).size.width * 0.8,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.secondaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      top: 70,
                      bottom: 25,
                      left: 25,
                      right: 25,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue.withOpacity(0.9),
                          AppTheme.secondaryPurple.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            gradient: AppTheme.secondaryGradient,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kwame Appiah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'kwame.appiah@email.com',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.yellow[700],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '4.8 • Premium User',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 25),
                      children: [
                        _sidebarItem(
                          Icons.delivery_dining,
                          'My Deliveries',
                          AppTheme.accentTeal,
                          onTap:
                              () => Navigator.pushNamed(context, '/tracking'),
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          color: Colors.white.withOpacity(0.3),
                          height: 1,
                        ),
                        const SizedBox(height: 15),
                        _sidebarItem(
                          Icons.login_rounded,
                          'Login',
                          AppTheme.successGreen,
                        ),
                        _sidebarItem(
                          Icons.person_add_alt_1_rounded,
                          'Sign Up',
                          AppTheme.warningAmber,
                        ),
                        const SizedBox(height: 25),
                        Divider(
                          color: Colors.white.withOpacity(0.3),
                          height: 1,
                        ),
                        const SizedBox(height: 15),
                        _sidebarItem(
                          Icons.logout,
                          'Logout',
                          AppTheme.errorRed,
                          isLogout: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(
    IconData icon,
    String title,
    Color color, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? AppTheme.errorRed : Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: isLogout ? AppTheme.errorRed : Colors.white.withOpacity(0.7),
          size: 16,
        ),
        onTap:
            onTap ??
            () async {
              // Close sidebar first
              if (mounted) {
                setState(() => _isMenuOpen = false);
              }
              // Wait for animation to finish before navigating
              await Future.delayed(const Duration(milliseconds: 400));

              if (mounted) {
                if (title == 'Login') {
                  Navigator.pushNamed(context, '/login');
                } else if (title == 'Sign Up') {
                  Navigator.pushNamed(context, '/signup');
                } else if (title == 'Logout') {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              }
            },
      ),
    );
  }

  Widget _buildOverlay() {
    return _isMenuOpen
        ? GestureDetector(
          onTap: () {
            setState(() {
              _isMenuOpen = false;
            });
          },
          child: Container(color: AppTheme.overlayDark),
        )
        : const SizedBox.shrink();
  }

  Widget _buildRiderTooltip() {
    if (_selectedRider == null || _tooltipPos == null)
      return const SizedBox.shrink();

    final left = (_tooltipPos!.dx - 110).clamp(
      8.0,
      MediaQuery.of(context).size.width - 220.0,
    );
    final top = (_tooltipPos!.dy - 140).clamp(
      MediaQuery.of(context).viewPadding.top + 10,
      MediaQuery.of(context).size.height - 160,
    );

    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 16,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 260,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _vehiclePricing[_selectedRider!['type']]!['icon']
                          as IconData,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedRider!['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _selectedRider!['eta'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              color: Colors.yellow[700],
                              size: 14,
                            ),
                            Text(
                              ' ${(_selectedRider!['rating'] as double).toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _closeTooltip,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Price:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'GHC ${_selectedRider!['price']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vehicleChoiceCard(String type, Map<String, dynamic> vehicleData) {
    final bool active = _selectedVehicleType == type;
    final int availableCount = _riders.where((r) => r['type'] == type).length;
    final Gradient gradient = vehicleData['gradient'] as Gradient;

    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          gradient:
              active
                  ? gradient
                  : LinearGradient(colors: [Colors.white, Colors.white]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.shade300,
            width: active ? 0 : 1,
          ),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: (vehicleData['color'] as Color).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                        active
                            ? Colors.white.withOpacity(0.2)
                            : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vehicleData['icon'] as IconData,
                    color: active ? Colors.white : Colors.grey[700],
                    size: 30,
                  ),
                ),
                if (availableCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        availableCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              vehicleData['name'] as String,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              vehicleData['priceRange'] as String,
              style: TextStyle(
                color:
                    active
                        ? Colors.white.withOpacity(0.9)
                        : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    final visible = _visibleRiders;

    return DraggableScrollableSheet(
      controller: _draggableController,
      initialChildSize: 0.38,
      minChildSize: 0.22,
      maxChildSize: 0.82,
      snap: true,
      snapSizes: const [0.22, 0.38, 0.82],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Request Delivery',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _locationAddress,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                _LocationInputRow(
                  label: 'Pickup location',
                  icon: Icons.my_location,
                  value: 'Current location',
                  onCurrentPressed:
                      () => _mapController.move(_currentLocation, 16.0),
                ),
                const SizedBox(height: 15),
                _LocationInputRow(
                  label: 'Destination',
                  icon: Icons.location_on,
                  value: null,
                  onTap: () async {
                    final res = await showDialog<String>(
                      context: context,
                      builder: (ctx) {
                        String txt = '';
                        return AlertDialog(
                          title: const Text('Enter destination'),
                          content: TextField(
                            onChanged: (v) => txt = v,
                            decoration: const InputDecoration(
                              hintText: 'Address or landmark in Takoradi',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(txt),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                    if (res != null && res.isNotEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Destination: $res'),
                          backgroundColor: AppTheme.successGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 25),
                const Text(
                  'Choose Vehicle Type',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      ..._vehiclePricing.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: _vehicleChoiceCard(entry.key, entry.value),
                        );
                      }),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Available Vehicles: ${visible.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final r = visible[i];
                      final Gradient gradient = r['gradient'] as Gradient;
                      return Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _mapController.move(r['pos'] as LatLng, 17.0);
                                setState(() {
                                  _selectedRider = r;
                                  _tooltipPos = null;
                                });
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: gradient,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (r['color'] as Color).withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _vehiclePricing[r['type']]!['icon']
                                          as IconData,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'GHC ${r['price']}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 90,
                              child: Column(
                                children: [
                                  Text(
                                    r['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    r['eta'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Package Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 15),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _packageChip('Food', Icons.restaurant),
                    _packageChip('Documents', Icons.description),
                    _packageChip('Box', Icons.inventory_2),
                    _packageChip('Clothing', Icons.checkroom),
                    _packageChip('Other', Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText:
                        'Describe the package (weight, fragility, special instructions...)',
                    filled: true,
                    fillColor: AppTheme.backgroundWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryBlue.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            final vehicle =
                                _selectedVehicleType ?? 'any vehicle';
                            final vehicleName =
                                _selectedVehicleType != null
                                    ? _vehiclePricing[_selectedVehicleType]!['name']
                                    : 'any vehicle';
                            final desc = _descCtrl.text.trim();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Request sent — searching for nearby $vehicleName. ${desc.isEmpty ? '' : 'Note: $desc'}',
                                ),
                                backgroundColor: AppTheme.successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 4),
                              ),
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () {
                                _draggableController.animateTo(
                                  0.22,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                );
                              },
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send, color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Request Delivery',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _packageChip(String label, IconData icon) {
    final bool active = _selectedPackageType == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedPackageType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: active ? AppTheme.primaryGradient : null,
          color: active ? null : Colors.white,
          border: Border.all(
            color: active ? Colors.transparent : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                    ),
                  ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : AppTheme.primaryBlue,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
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
              active: true,
              onTap: null,
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Request',
              active: false,
              onTap: () => Navigator.pushNamed(context, '/request'),
            ),
            _BottomNavItem(
              icon: Icons.location_on_outlined,
              label: 'Tracking',
              active: false,
              onTap: () => Navigator.pushNamed(context, '/tracking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationLoader() {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 90,
      left: 25,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              _locationAddress,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          if (_isLoadingLocation) _buildLocationLoader(),
          if (_selectedRider != null && _tooltipPos != null)
            _buildRiderTooltip(),
          _buildBottomSheet(context),
          _buildBottomNav(),
          _buildOverlay(),
          _buildSidebar(),
        ],
      ),
    );
  }
}

class _PulsingRiderMarker extends StatefulWidget {
  final Map<String, dynamic> vehicleData;
  const _PulsingRiderMarker({super.key, required this.vehicleData});

  @override
  State<_PulsingRiderMarker> createState() => _PulsingRiderMarkerState();
}

class _PulsingRiderMarkerState extends State<_PulsingRiderMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.vehicleData['color'] as Color;
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.2),
        ),
        child: Center(
          child: Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              widget.vehicleData['icon'] as IconData,
              color: Colors.white,
              size: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _UserLocationMarker extends StatefulWidget {
  const _UserLocationMarker({super.key});

  @override
  State<_UserLocationMarker> createState() => _UserLocationMarkerState();
}

class _UserLocationMarkerState extends State<_UserLocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
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
            ),
          ),
        ),
      ),
    );
  }
}

class LatLngTween extends Tween<LatLng> {
  LatLngTween({required LatLng begin, required LatLng end})
    : super(begin: begin, end: end);

  @override
  LatLng lerp(double t) {
    if (begin == null || end == null) {
      return begin ?? end ?? const LatLng(0, 0);
    }
    return LatLng(
      begin!.latitude + (end!.latitude - begin!.latitude) * t,
      begin!.longitude + (end!.longitude - begin!.longitude) * t,
    );
  }
}

class _LocationInputRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final VoidCallback? onCurrentPressed;
  final VoidCallback? onTap;

  const _LocationInputRow({
    required this.label,
    required this.icon,
    this.value,
    this.onCurrentPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color:
                      value == null
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (onCurrentPressed != null)
              GestureDetector(
                onTap: onCurrentPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
