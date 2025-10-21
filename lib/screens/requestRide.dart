import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import 'home.dart' as home_screen;
import 'tracking.dart';

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

class DeliveryRequestFormScreen extends StatefulWidget {
  const DeliveryRequestFormScreen({super.key});

  @override
  State<DeliveryRequestFormScreen> createState() =>
      _DeliveryRequestFormScreenState();
}

class _DeliveryRequestFormScreenState extends State<DeliveryRequestFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form data
  String? _pickupLocation;
  String? _destination;
  String? _selectedVehicle;
  String? _packageCategory;
  String? _packageDescription;
  String? _specialInstructions;
  DateTime? _scheduledTime;
  bool _isLoading = false;

  // Mock current location
  final String _mockCurrentLocation =
      "Market Circle, Takoradi, Western Region, Ghana";

  @override
  void initState() {
    super.initState();
    _pickupLocation = _mockCurrentLocation;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _pickupLocation != null &&
        _pickupLocation!.isNotEmpty &&
        _destination != null &&
        _destination!.isNotEmpty &&
        _selectedVehicle != null &&
        _packageCategory != null;
  }

  void _useCurrentLocation() {
    setState(() {
      _pickupLocation = _mockCurrentLocation;
    });

    Fluttertoast.showToast(
      msg: "Current location detected",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.successGreen,
      textColor: AppTheme.backgroundWhite,
    );
  }

  Future<void> _submitDeliveryRequest() async {
    if (!_isFormValid) {
      Fluttertoast.showToast(
        msg: "Please fill in all required fields",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.backgroundWhite,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show success message
      Fluttertoast.showToast(
        msg: "Delivery request submitted successfully!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.successGreen,
        textColor: AppTheme.backgroundWhite,
      );

      // Navigate back or to tracking screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Failed to submit request. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.backgroundWhite,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Request Delivery',
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
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(height: 2.h),

                        // Vehicle Selection
                        _VehicleSelectionWidget(
                          onVehicleSelected: (vehicle) {
                            setState(() {
                              _selectedVehicle = vehicle;
                            });
                          },
                          selectedVehicle: _selectedVehicle,
                        ),

                        // Pickup Location
                        _PickupLocationWidget(
                          currentLocation: _pickupLocation,
                          onLocationChanged: (location) {
                            setState(() {
                              _pickupLocation = location;
                            });
                          },
                          onUseCurrentLocation: _useCurrentLocation,
                        ),

                        // Destination
                        _DestinationWidget(
                          onDestinationChanged: (destination) {
                            setState(() {
                              _destination = destination;
                            });
                          },
                          selectedDestination: _destination,
                        ),

                        // Package Details
                        _PackageDetailsWidget(
                          onCategoryChanged: (category) {
                            setState(() {
                              _packageCategory = category;
                            });
                          },
                          onDescriptionChanged: (description) {
                            setState(() {
                              _packageDescription = description;
                            });
                          },
                          selectedCategory: _packageCategory,
                          description: _packageDescription,
                        ),

                        // Special Instructions
                        _SpecialInstructionsWidget(
                          onInstructionsChanged: (instructions) {
                            setState(() {
                              _specialInstructions = instructions;
                            });
                          },
                          instructions: _specialInstructions,
                        ),

                        // Delivery Time
                        _DeliveryTimeWidget(
                          onTimeChanged: (time) {
                            setState(() {
                              _scheduledTime = time;
                            });
                          },
                          selectedTime: _scheduledTime,
                        ),

                        // Pricing Breakdown
                        _PricingBreakdownWidget(
                          selectedVehicle: _selectedVehicle,
                          selectedCategory: _packageCategory,
                          scheduledTime: _scheduledTime,
                          distance: 5.2, // Mock distance
                        ),

                        SizedBox(height: 15.h), // Space for the bottom nav
                      ],
                    ),
                  ),
                ),

                // Bottom Action Section
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundWhite,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.shadowSubtle,
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isFormValid) ...[
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningAmber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.warningAmber.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: AppTheme.warningAmber,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    'Please complete all required fields to continue',
                                    style: TextStyle(
                                      color: AppTheme.warningAmber,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                        SizedBox(
                          width: double.infinity,
                          height: 7.h,
                          child: ElevatedButton(
                            onPressed:
                                _isFormValid && !_isLoading
                                    ? _submitDeliveryRequest
                                    : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isFormValid
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textDisabled,
                              foregroundColor: AppTheme.backgroundWhite,
                              elevation: _isFormValid ? 4 : 0,
                              shadowColor: AppTheme.primaryBlue.withOpacity(
                                0.3,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppTheme.backgroundWhite,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Text(
                                          'Submitting Request...',
                                          style: TextStyle(
                                            color: AppTheme.backgroundWhite,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.send_rounded,
                                          color: AppTheme.backgroundWhite,
                                          size: 20,
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'Request Delivery',
                                          style: TextStyle(
                                            color: AppTheme.backgroundWhite,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14.sp,
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
              ],
            ),
          ),
          _buildBottomNav(),
        ],
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
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            _BottomNavItem(
              icon: Icons.add_circle_outline,
              label: 'Request',
              active: true,
              onTap: null, // Already on this screen
            ),
            _BottomNavItem(
              icon: Icons.location_on_outlined,
              label: 'Tracking',
              active: false,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeliveryTrackingScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- Enhanced Helper Widgets ---

class _VehicleSelectionWidget extends StatefulWidget {
  final Function(String) onVehicleSelected;
  final String? selectedVehicle;

  const _VehicleSelectionWidget({
    required this.onVehicleSelected,
    this.selectedVehicle,
  });

  @override
  State<_VehicleSelectionWidget> createState() =>
      _VehicleSelectionWidgetState();
}

class _VehicleSelectionWidgetState extends State<_VehicleSelectionWidget> {
  String? _selectedVehicle;

  final List<Map<String, dynamic>> _vehicles = [
    {
      'id': 'motorbike',
      'name': 'Motorbike',
      'description': 'Fast delivery for small items',
      'capacity': 'Up to 5kg',
      'estimatedTime': '15-30 min',
      'basePrice': 'GH₵ 15.00',
      'icon': Icons.motorcycle_rounded,
      'color': AppTheme.successGreen,
    },
    {
      'id': 'tricycle',
      'name': 'Cargo Tricycle',
      'description': 'Perfect for medium packages',
      'capacity': 'Up to 25kg',
      'estimatedTime': '20-45 min',
      'basePrice': 'GH₵ 25.00',
      'icon': Icons.pedal_bike_rounded,
      'color': AppTheme.warningAmber,
    },
    {
      'id': 'van',
      'name': 'Van',
      'description': 'Ideal for large deliveries',
      'capacity': 'Up to 100kg',
      'estimatedTime': '30-60 min',
      'basePrice': 'GH₵ 45.00',
      'icon': Icons.local_shipping_rounded,
      'color': AppTheme.primaryBlue,
    },
    {
      'id': 'truck',
      'name': 'Truck',
      'description': 'Heavy duty for bulk items',
      'capacity': 'Up to 500kg',
      'estimatedTime': '45-90 min',
      'basePrice': 'GH₵ 80.00',
      'icon': Icons.fire_truck_rounded,
      'color': AppTheme.errorRed,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.selectedVehicle;
  }

  void _selectVehicle(String vehicleId) {
    setState(() {
      _selectedVehicle = vehicleId;
    });
    widget.onVehicleSelected(vehicleId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Select Vehicle Type',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _vehicles.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.h),
            itemBuilder: (context, index) {
              final vehicle = _vehicles[index];
              final isSelected = _selectedVehicle == vehicle['id'];

              return GestureDetector(
                onTap: () => _selectVehicle(vehicle['id'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? (vehicle['color'] as Color).withOpacity(0.1)
                            : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isSelected
                              ? vehicle['color'] as Color
                              : AppTheme.textDisabled.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: (vehicle['color'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          vehicle['icon'] as IconData,
                          color: vehicle['color'] as Color,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    vehicle['name'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? vehicle['color'] as Color
                                              : AppTheme.textPrimary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ),
                                Text(
                                  vehicle['basePrice'] as String,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: vehicle['color'] as Color,
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              vehicle['description'] as String,
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.scale_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  vehicle['capacity'] as String,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11.sp,
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.schedule_rounded,
                                  color: AppTheme.textSecondary,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  vehicle['estimatedTime'] as String,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11.sp,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: vehicle['color'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            color: AppTheme.backgroundWhite,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
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

class _PickupLocationWidget extends StatefulWidget {
  final String? currentLocation;
  final Function(String) onLocationChanged;
  final VoidCallback onUseCurrentLocation;

  const _PickupLocationWidget({
    this.currentLocation,
    required this.onLocationChanged,
    required this.onUseCurrentLocation,
  });

  @override
  State<_PickupLocationWidget> createState() => _PickupLocationWidgetState();
}

class _PickupLocationWidgetState extends State<_PickupLocationWidget> {
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _locationController.text = widget.currentLocation!;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Pickup Location',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _locationController,
            onChanged: widget.onLocationChanged,
            decoration: InputDecoration(
              hintText: 'Enter pickup address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              suffixIcon:
                  widget.currentLocation != null
                      ? null
                      : IconButton(
                        onPressed: widget.onUseCurrentLocation,
                        icon: Icon(
                          Icons.gps_fixed_rounded,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                        tooltip: 'Use current location',
                      ),
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          if (widget.currentLocation != null) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successGreen,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Current location detected',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DestinationWidget extends StatefulWidget {
  final Function(String) onDestinationChanged;
  final String? selectedDestination;

  const _DestinationWidget({
    required this.onDestinationChanged,
    this.selectedDestination,
  });

  @override
  State<_DestinationWidget> createState() => _DestinationWidgetState();
}

class _DestinationWidgetState extends State<_DestinationWidget> {
  final TextEditingController _destinationController = TextEditingController();
  bool _showSuggestions = false;

  final List<Map<String, dynamic>> _takoradiLandmarks = [
    {
      'name': 'Takoradi Mall',
      'address': 'Liberation Road, Takoradi',
      'icon': Icons.shopping_cart_rounded,
    },
    {
      'name': 'Shoprite Takoradi',
      'address': 'Takoradi Mall, Liberation Road',
      'icon': Icons.store_rounded,
    },
    {
      'name': 'Effia Nkwanta Hospital',
      'address': 'Hospital Road, Effia',
      'icon': Icons.local_hospital_rounded,
    },
    {
      'name': 'Market Circle',
      'address': 'Central Market Area, Takoradi',
      'icon': Icons.shopping_basket_rounded,
    },
    {
      'name': 'Takoradi Technical University',
      'address': 'University Road, Takoradi',
      'icon': Icons.school_rounded,
    },
  ];

  List<Map<String, dynamic>> _filteredLandmarks = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedDestination != null) {
      _destinationController.text = widget.selectedDestination!;
    }
    _filteredLandmarks = _takoradiLandmarks;
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _filterLandmarks(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLandmarks = _takoradiLandmarks;
        _showSuggestions = false;
      } else {
        _filteredLandmarks =
            _takoradiLandmarks
                .where(
                  (landmark) =>
                      (landmark['name'] as String).toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      (landmark['address'] as String).toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
        _showSuggestions = true;
      }
    });
  }

  void _selectLandmark(Map<String, dynamic> landmark) {
    setState(() {
      _destinationController.text =
          '${landmark['name']} - ${landmark['address']}';
      _showSuggestions = false;
    });
    widget.onDestinationChanged(_destinationController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.place_rounded,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Destination',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          TextFormField(
            controller: _destinationController,
            onChanged: (value) {
              _filterLandmarks(value);
              widget.onDestinationChanged(value);
            },
            onTap: () {
              if (_destinationController.text.isEmpty) {
                setState(() {
                  _showSuggestions = true;
                });
              }
            },
            decoration: InputDecoration(
              hintText: 'Enter destination address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              suffixIcon:
                  _destinationController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          setState(() {
                            _destinationController.clear();
                            _showSuggestions = false;
                          });
                          widget.onDestinationChanged('');
                        },
                        icon: Icon(
                          Icons.clear_rounded,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                      )
                      : null,
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.successGreen, width: 2),
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
          if (_showSuggestions && _filteredLandmarks.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              constraints: BoxConstraints(maxHeight: 25.h),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textDisabled.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowSubtle,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _filteredLandmarks.length,
                separatorBuilder:
                    (context, index) => Divider(
                      height: 1,
                      color: AppTheme.textDisabled.withOpacity(0.1),
                    ),
                itemBuilder: (context, index) {
                  final landmark = _filteredLandmarks[index];
                  return ListTile(
                    onTap: () => _selectLandmark(landmark),
                    leading: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        landmark['icon'] as IconData,
                        color: AppTheme.successGreen,
                        size: 18,
                      ),
                    ),
                    title: Text(
                      landmark['name'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    subtitle: Text(
                      landmark['address'] as String,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PackageDetailsWidget extends StatefulWidget {
  final Function(String) onCategoryChanged;
  final Function(String) onDescriptionChanged;
  final String? selectedCategory;
  final String? description;

  const _PackageDetailsWidget({
    required this.onCategoryChanged,
    required this.onDescriptionChanged,
    this.selectedCategory,
    this.description,
  });

  @override
  State<_PackageDetailsWidget> createState() => _PackageDetailsWidgetState();
}

class _PackageDetailsWidgetState extends State<_PackageDetailsWidget> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;

  final List<Map<String, dynamic>> _packageCategories = [
    {
      'id': 'food',
      'name': 'Food',
      'icon': Icons.restaurant_rounded,
      'color': AppTheme.warningAmber,
    },
    {
      'id': 'documents',
      'name': 'Documents',
      'icon': Icons.description_rounded,
      'color': AppTheme.primaryBlue,
    },
    {
      'id': 'electronics',
      'name': 'Electronics',
      'icon': Icons.devices_rounded,
      'color': AppTheme.successGreen,
    },
    {
      'id': 'clothing',
      'name': 'Clothing',
      'icon': Icons.checkroom_rounded,
      'color': AppTheme.errorRed,
    },
    {
      'id': 'other',
      'name': 'Other',
      'icon': Icons.category_rounded,
      'color': AppTheme.textSecondary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory;
    if (widget.description != null) {
      _descriptionController.text = widget.description!;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategory = categoryId;
    });
    widget.onCategoryChanged(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_rounded,
                  color: AppTheme.warningAmber,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Package Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Package Category',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children:
                _packageCategories.map((category) {
                  final isSelected = _selectedCategory == category['id'];
                  return GestureDetector(
                    onTap: () => _selectCategory(category['id'] as String),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? (category['color'] as Color).withOpacity(0.15)
                                : AppTheme.backgroundWhite,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? category['color'] as Color
                                  : AppTheme.textDisabled.withOpacity(0.3),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            category['icon'] as IconData,
                            color:
                                isSelected
                                    ? category['color'] as Color
                                    : AppTheme.textSecondary,
                            size: 18,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            category['name'] as String,
                            style: TextStyle(
                              color:
                                  isSelected
                                      ? category['color'] as Color
                                      : AppTheme.textSecondary,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
          SizedBox(height: 2.h),
          Text(
            'Package Description (Optional)',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _descriptionController,
            onChanged: widget.onDescriptionChanged,
            maxLines: 3,
            maxLength: 200,
            decoration: InputDecoration(
              hintText:
                  'Describe your package (size, weight, special handling)',
              filled: true,
              fillColor: AppTheme.backgroundWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.textDisabled.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.warningAmber, width: 2),
              ),
              counterStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11.sp,
              ),
            ),
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}

class _SpecialInstructionsWidget extends StatefulWidget {
  final Function(String) onInstructionsChanged;
  final String? instructions;

  const _SpecialInstructionsWidget({
    required this.onInstructionsChanged,
    this.instructions,
  });

  @override
  State<_SpecialInstructionsWidget> createState() =>
      _SpecialInstructionsWidgetState();
}

class _SpecialInstructionsWidgetState
    extends State<_SpecialInstructionsWidget> {
  final TextEditingController _instructionsController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.instructions != null) {
      _instructionsController.text = widget.instructions!;
    }

    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: AppTheme.errorRed,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Special Instructions',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              Text(
                '(Optional)',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: TextFormField(
              controller: _instructionsController,
              focusNode: _focusNode,
              onChanged: widget.onInstructionsChanged,
              maxLines: _isExpanded ? 5 : 3,
              maxLength: 300,
              decoration: InputDecoration(
                hintText:
                    'Any special delivery instructions?\ne.g., "Call when you arrive", "Leave at gate", "Handle with care"',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(left: 3.w, right: 2.w, top: 3.w),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.backgroundWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.textDisabled.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.textDisabled.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.errorRed, width: 2),
                ),
                counterStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11.sp,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 3.w,
                ),
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          if (_instructionsController.text.isNotEmpty) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: AppTheme.primaryBlue,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Your instructions will be shared with the delivery driver',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeliveryTimeWidget extends StatefulWidget {
  final Function(DateTime?) onTimeChanged;
  final DateTime? selectedTime;

  const _DeliveryTimeWidget({required this.onTimeChanged, this.selectedTime});

  @override
  State<_DeliveryTimeWidget> createState() => _DeliveryTimeWidgetState();
}

class _DeliveryTimeWidgetState extends State<_DeliveryTimeWidget> {
  DateTime? _selectedDateTime;
  String _selectedTimeSlot = 'now';

  final List<Map<String, dynamic>> _timeSlots = [
    {
      'id': 'now',
      'title': 'Now',
      'subtitle': 'ASAP delivery',
      'icon': Icons.flash_on_rounded,
      'color': AppTheme.successGreen,
    },
    {
      'id': 'scheduled',
      'title': 'Schedule',
      'subtitle': 'Pick a specific time',
      'icon': Icons.schedule_rounded,
      'color': AppTheme.primaryBlue,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.selectedTime;
    if (_selectedDateTime != null) {
      _selectedTimeSlot = 'scheduled';
    }
  }

  Future<void> _selectDateTime() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
              onPrimary: AppTheme.backgroundWhite,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? now),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppTheme.primaryBlue,
                onPrimary: AppTheme.backgroundWhite,
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null && mounted) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        setState(() {
          _selectedDateTime = selectedDateTime;
        });
        widget.onTimeChanged(selectedDateTime);
      }
    }
  }

  void _selectTimeSlot(String slotId) {
    setState(() {
      _selectedTimeSlot = slotId;
      if (slotId == 'now') {
        _selectedDateTime = null;
        widget.onTimeChanged(null);
      } else if (slotId == 'scheduled' && _selectedDateTime == null) {
        _selectDateTime();
      }
    });
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dateStr;
    if (selectedDate == today) {
      dateStr = 'Today';
    } else if (selectedDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    final timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$dateStr at $timeStr';
  }

  bool _isBusinessHours(DateTime dateTime) {
    final hour = dateTime.hour;
    return hour >= 8 && hour <= 20; // 8 AM to 8 PM
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Delivery Time',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children:
                _timeSlots.map((slot) {
                  final isSelected = _selectedTimeSlot == slot['id'];
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    child: GestureDetector(
                      onTap: () => _selectTimeSlot(slot['id'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (slot['color'] as Color).withOpacity(0.1)
                                  : AppTheme.backgroundWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? slot['color'] as Color
                                    : AppTheme.textDisabled.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: (slot['color'] as Color).withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                slot['icon'] as IconData,
                                color: slot['color'] as Color,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    slot['title'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isSelected
                                              ? slot['color'] as Color
                                              : AppTheme.textPrimary,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    slot['subtitle'] as String,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: slot['color'] as Color,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          if (_selectedTimeSlot == 'scheduled') ...[
            SizedBox(height: 1.h),
            GestureDetector(
              onTap: _selectDateTime,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        _selectedDateTime != null
                            ? _formatDateTime(_selectedDateTime!)
                            : 'Select date and time',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppTheme.primaryBlue,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedDateTime != null &&
                !_isBusinessHours(_selectedDateTime!)) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningAmber.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: AppTheme.warningAmber,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Selected time is outside business hours (8 AM - 8 PM). Additional charges may apply.',
                        style: TextStyle(
                          color: AppTheme.warningAmber,
                          fontWeight: FontWeight.w500,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _PricingBreakdownWidget extends StatelessWidget {
  final String? selectedVehicle;
  final String? selectedCategory;
  final DateTime? scheduledTime;
  final double distance;

  const _PricingBreakdownWidget({
    this.selectedVehicle,
    this.selectedCategory,
    this.scheduledTime,
    this.distance = 5.0,
  });

  Map<String, double> get _vehicleBasePrices => {
    'motorbike': 15.0,
    'tricycle': 25.0,
    'van': 45.0,
    'truck': 80.0,
  };

  Map<String, double> get _categoryMultipliers => {
    'food': 1.0,
    'documents': 0.8,
    'electronics': 1.3,
    'clothing': 1.1,
    'other': 1.0,
  };

  double get _basePrice {
    if (selectedVehicle == null) return 0.0;
    return _vehicleBasePrices[selectedVehicle] ?? 0.0;
  }

  double get _distanceCharge {
    if (distance <= 2.0) return 0.0;
    return (distance - 2.0) * 3.0; // GHS 3 per km after first 2km
  }

  double get _categoryCharge {
    if (selectedCategory == null) return 0.0;
    final multiplier = _categoryMultipliers[selectedCategory] ?? 1.0;
    return _basePrice * (multiplier - 1.0);
  }

  double get _schedulingCharge {
    if (scheduledTime == null) return 0.0;
    final now = DateTime.now();
    final isOutsideBusinessHours =
        scheduledTime!.hour < 8 || scheduledTime!.hour > 20;
    return isOutsideBusinessHours ? 10.0 : 0.0;
  }

  double get _serviceFee {
    final subtotal =
        _basePrice + _distanceCharge + _categoryCharge + _schedulingCharge;
    return subtotal * 0.1; // 10% service fee
  }

  double get _totalPrice {
    return _basePrice +
        _distanceCharge +
        _categoryCharge +
        _schedulingCharge +
        _serviceFee;
  }

  String _formatPrice(double price) {
    return 'GH₵ ${price.toStringAsFixed(2)}';
  }

  String _getVehicleName(String? vehicle) {
    switch (vehicle) {
      case 'motorbike':
        return 'Motorbike';
      case 'tricycle':
        return 'Cargo Tricycle';
      case 'van':
        return 'Van';
      case 'truck':
        return 'Truck';
      default:
        return 'Select Vehicle';
    }
  }

  String _getCategoryName(String? category) {
    switch (category) {
      case 'food':
        return 'Food';
      case 'documents':
        return 'Documents';
      case 'electronics':
        return 'Electronics';
      case 'clothing':
        return 'Clothing';
      case 'other':
        return 'Other';
      default:
        return 'Standard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textDisabled.withOpacity(0.3)),
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
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                'Estimated Price',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          if (selectedVehicle != null) ...[
            _buildPriceRow(
              'Base Price (${_getVehicleName(selectedVehicle)})',
              _formatPrice(_basePrice),
              AppTheme.primaryBlue,
            ),
            if (_distanceCharge > 0) ...[
              SizedBox(height: 1.h),
              _buildPriceRow(
                'Distance Charge (${distance.toStringAsFixed(1)} km)',
                _formatPrice(_distanceCharge),
                AppTheme.warningAmber,
              ),
            ],
            if (_categoryCharge != 0) ...[
              SizedBox(height: 1.h),
              _buildPriceRow(
                'Category Fee (${_getCategoryName(selectedCategory)})',
                _formatPrice(_categoryCharge),
                AppTheme.successGreen,
              ),
            ],
            if (_schedulingCharge > 0) ...[
              SizedBox(height: 1.h),
              _buildPriceRow(
                'After Hours Fee',
                _formatPrice(_schedulingCharge),
                AppTheme.errorRed,
              ),
            ],
            SizedBox(height: 1.h),
            _buildPriceRow(
              'Service Fee (10%)',
              _formatPrice(_serviceFee),
              AppTheme.textSecondary,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.textDisabled.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      fontSize: 16.sp,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.successGreen.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _formatPrice(_totalPrice),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.successGreen,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textDisabled.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Select a vehicle type to see pricing details',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: AppTheme.primaryBlue,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Transparent pricing with no hidden fees. Payment on delivery.',
                    style: TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14.sp),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
