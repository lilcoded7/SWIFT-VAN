import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

const Color kLuxuryBlue = Color(0xFF001B48);
const Color kAccentGreen = Color(0xFF00BFA6);
const Color kGold = Color(0xFFFFD700);

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

  final List<Map<String, dynamic>> _riders = [];
  late final StreamSubscription<List<Map<String, dynamic>>> _riderStreamSub;
  final Random _rnd = Random();

  final LatLngBounds _takoradiBounds = LatLngBounds(
    const LatLng(4.86, -1.79),
    const LatLng(4.94, -1.72),
  );

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
      'color': kLuxuryBlue,
    },
    'tricycle': {
      'name': 'Tricycle',
      'icon': Icons.moped,
      'priceRange': 'GHC 20-35',
      'minPrice': 20,
      'maxPrice': 35,
      'color': Color(0xFF8B4513),
    },
    'van': {
      'name': 'Van',
      'icon': Icons.local_shipping_rounded,
      'priceRange': 'GHC 40-60',
      'minPrice': 40,
      'maxPrice': 60,
      'color': kAccentGreen,
    },
    'truck': {
      'name': 'Truck',
      'icon': Icons.local_shipping,
      'priceRange': 'GHC 80-120',
      'minPrice': 80,
      'maxPrice': 120,
      'color': Colors.orange,
    },
  };

  @override
  void initState() {
    super.initState();
    _draggableController = DraggableScrollableController();
    _generateInitialRidersAround(_currentLocation);
    _startSimulatedRiderStream();
    _determinePositionAndMove();
  }

  @override
  void dispose() {
    _riderStreamSub.cancel();
    _draggableController.dispose();
    _descCtrl.dispose();
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
      'Adwoa Poku'
    ];
    
    for (var i = 0; i < 10; i++) {
      final type = types[_rnd.nextInt(types.length)];
      final vehicleData = _vehiclePricing[type]!;
      
      final distance = _rnd.nextDouble() * 0.03;
      final angle = _rnd.nextDouble() * 2 * pi;
      
      final dlat = distance * cos(angle);
      final dlng = distance * sin(angle);
      
      final p = LatLng(
        (center.latitude + dlat).clamp(_takoradiBounds.south, _takoradiBounds.north),
        (center.longitude + dlng).clamp(_takoradiBounds.west, _takoradiBounds.east),
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
        'price': vehicleData['minPrice'] + _rnd.nextInt(vehicleData['maxPrice'] - vehicleData['minPrice']),
        'color': vehicleData['color'],
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
          
          final distance = _calculateDistance(_currentLocation, LatLng(newLat, newLng));
          final eta = (distance * 3).ceil();
          
          return {
            ...r, 
            'pos': LatLng(newLat, newLng), 
            'eta': '${eta.clamp(3, 25)} min'
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
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoadingLocation = false);
        return;
      }
      
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }
      
      final pos = await Geolocator.getCurrentPosition();
      final clampedLat = pos.latitude.clamp(_takoradiBounds.south, _takoradiBounds.north);
      final clampedLon = pos.longitude.clamp(_takoradiBounds.west, _takoradiBounds.east);
      
      setState(() {
        _currentLocation = LatLng(clampedLat, clampedLon);
        _isLoadingLocation = false;
      });
      
      _generateInitialRidersAround(_currentLocation);
      _mapController.move(_currentLocation, 15.0);
    } catch (_) {
      setState(() => _isLoadingLocation = false);
    }
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
    final String type = r['type'] as String;
    final vehicleData = _vehiclePricing[type]!;
    final Color bg = r['color'] as Color;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.4),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Center(
            child: Icon(
              vehicleData['icon'] as IconData,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
              )
            ],
          ),
          child: Text(
            r['eta'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kLuxuryBlue,
            ),
          ),
        ),
      ],
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
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
        onTap: (tapPos, latlng) {
          _closeTooltip();
          FocusScope.of(context).unfocus();
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.swiftvan.app',
        ),
        MarkerLayer(
          markers: _visibleRiders
              .map((r) => Marker(
                    point: r['pos'] as LatLng,
                    width: 88,
                    height: 120,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: (details) => _onRiderTap(
                        r,
                        TapPosition(details.globalPosition, details.localPosition),
                      ),
                      child: _vehicleMarker(r),
                    ),
                  ))
              .toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: _currentLocation,
              width: 52,
              height: 52,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: kLuxuryBlue, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: kLuxuryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person_pin_circle,
                    color: kLuxuryBlue,
                    size: 28,
                  ),
                ),
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
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Icon(Icons.menu, color: kLuxuryBlue),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                )
              ],
              gradient: LinearGradient(
                colors: [kLuxuryBlue, Color(0xFF2A63B8)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.delivery_dining, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'SwiftVan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 0.5,
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
      duration: const Duration(milliseconds: 300),
      left: _isMenuOpen ? 0 : -MediaQuery.of(context).size.width * 0.75,
      top: 0,
      bottom: 0,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: kLuxuryBlue,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                    decoration: BoxDecoration(
                      color: kLuxuryBlue.withOpacity(0.8),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Icon(Icons.person, color: Colors.white, size: 30),
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
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, color: kGold, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      children: [
                        _sidebarItem(Icons.delivery_dining, 'My Deliveries'),
                        _sidebarItem(Icons.payment, 'Payment Methods'),
                        _sidebarItem(Icons.local_offer, 'Promotions'),
                        _sidebarItem(Icons.settings, 'Settings'),
                        const SizedBox(height: 20),
                        Divider(color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        _sidebarItem(Icons.help, 'Help & Support'),
                        _sidebarItem(Icons.info, 'About'),
                        _sidebarItem(Icons.logout, 'Logout', isLogout: true),
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

  Widget _sidebarItem(IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.red[300] : Colors.white),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red[300] : Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        setState(() {
          _isMenuOpen = false;
        });
      },
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
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildRiderTooltip() {
    if (_selectedRider == null || _tooltipPos == null) return const SizedBox.shrink();
    
    final left = (_tooltipPos!.dx - 110).clamp(8.0, MediaQuery.of(context).size.width - 220.0);
    final top = (_tooltipPos!.dy - 140).clamp(MediaQuery.of(context).viewPadding.top + 10, MediaQuery.of(context).size.height - 160);
    
    return Positioned(
      left: left,
      top: top,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: (_selectedRider!['color'] as Color).withOpacity(0.1),
                    child: Icon(
                      _vehiclePricing[_selectedRider!['type']]!['icon'] as IconData,
                      color: _selectedRider!['color'] as Color,
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
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _selectedRider!['eta'],
                              style: TextStyle(
                                fontSize: 14,
                                color: kLuxuryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.star, color: kGold, size: 14),
                            Text(
                              ' ${(_selectedRider!['rating'] as double).toStringAsFixed(1)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: _closeTooltip,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kLuxuryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Estimated Price:',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'GHC ${_selectedRider!['price']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: kLuxuryBlue,
                        fontSize: 16,
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
    
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicleType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 130,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: active ? (vehicleData['color'] as Color).withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? vehicleData['color'] as Color : Colors.grey.shade300,
            width: active ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: active 
                  ? (vehicleData['color'] as Color).withOpacity(0.15)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: active ? vehicleData['color'] as Color : Colors.grey[100],
                  child: Icon(
                    vehicleData['icon'] as IconData,
                    color: active ? Colors.white : Colors.grey[700],
                    size: 28,
                  ),
                ),
                if (availableCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
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
            const SizedBox(height: 12),
            Text(
              vehicleData['name'] as String,
              style: TextStyle(
                color: active ? vehicleData['color'] as Color : Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              vehicleData['priceRange'] as String,
              style: TextStyle(
                color: active ? vehicleData['color'] as Color : Colors.grey[600],
                fontSize: 12,
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
      initialChildSize: 0.35,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.2, 0.35, 0.8],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Request Delivery',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: kLuxuryBlue,
                  ),
                ),
                const SizedBox(height: 16),
                _LocationInputRow(
                  label: 'Pickup location',
                  icon: Icons.my_location,
                  value: 'Current location',
                  onCurrentPressed: () => _mapController.move(_currentLocation, 16.0),
                ),
                const SizedBox(height: 12),
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
                          backgroundColor: kLuxuryBlue,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Choose Vehicle Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 4),
                      ..._vehiclePricing.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _vehicleChoiceCard(entry.key, entry.value),
                        );
                      }),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Available Vehicles: ${visible.length}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visible.length,
                    itemBuilder: (context, i) {
                      final r = visible[i];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
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
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: (r['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: r['color'] as Color,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _vehiclePricing[r['type']]!['icon'] as IconData,
                                      color: r['color'] as Color,
                                      size: 30,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'GHC ${r['price']}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: r['color'] as Color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: 80,
                              child: Column(
                                children: [
                                  Text(
                                    r['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    r['eta'],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
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
                const SizedBox(height: 20),
                const Text(
                  'Package Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _packageChip('Food', Icons.restaurant),
                    _packageChip('Documents', Icons.description),
                    _packageChip('Box', Icons.inventory_2),
                    _packageChip('Clothing', Icons.checkroom),
                    _packageChip('Other', Icons.more_horiz),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Describe the package (weight, fragility, special instructions...)',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kLuxuryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () {
                          final vehicle = _selectedVehicleType ?? 'any vehicle';
                          final vehicleName = _selectedVehicleType != null 
                              ? _vehiclePricing[_selectedVehicleType]!['name'] 
                              : 'any vehicle';
                          final desc = _descCtrl.text.trim();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Request sent — searching for nearby $vehicleName. ${desc.isEmpty ? '' : 'Note: $desc'}',
                              ),
                              backgroundColor: kAccentGreen,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                          
                          Future.delayed(const Duration(milliseconds: 500), () {
                            _draggableController.animateTo(
                              0.2,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          });
                        },
                        child: const Text(
                          'Request Rider',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? kAccentGreen : Colors.white,
          border: Border.all(
            color: active ? kAccentGreen : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: active 
                  ? kAccentGreen.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: active ? Colors.white : kLuxuryBlue,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _BottomNavItem(icon: Icons.home, label: 'Home', active: true),
            _BottomNavItem(icon: Icons.add_circle_outline, label: 'Request', active: false),
            _BottomNavItem(icon: Icons.location_on_outlined, label: 'Tracking', active: false),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationLoader() {
    return Positioned(
      top: MediaQuery.of(context).viewPadding.top + 84,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(kLuxuryBlue),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Getting your location in Takoradi...',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: kLuxuryBlue,
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
          if (_selectedRider != null && _tooltipPos != null) _buildRiderTooltip(),
          _buildBottomSheet(context),
          _buildBottomNav(),
          _buildOverlay(),
          _buildSidebar(),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: kLuxuryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value ?? label,
                style: TextStyle(
                  color: value == null ? Colors.grey[600] : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (onCurrentPressed != null)
              GestureDetector(
                onTap: onCurrentPressed,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kLuxuryBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Current',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
  
  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? kLuxuryBlue.withOpacity(0.1) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: active ? kLuxuryBlue : Colors.grey[600],
            size: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: active ? kLuxuryBlue : Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}