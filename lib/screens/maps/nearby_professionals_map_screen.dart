import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../models/professional_model.dart';
import 'professional_details_screen.dart';

class NearbyProfessionalsMapScreen extends StatefulWidget {
  final String? category;
  final String? initialProblem;

  const NearbyProfessionalsMapScreen({
    super.key,
    this.category,
    this.initialProblem,
  });

  @override
  State<NearbyProfessionalsMapScreen> createState() =>
      _NearbyProfessionalsMapScreenState();
}

class _NearbyProfessionalsMapScreenState
    extends State<NearbyProfessionalsMapScreen> {
  // Map Controller
  GoogleMapController? _mapController;
  LatLng _userLocation = const LatLng(28.6139, 77.2090);
  bool _isLoadingLocation = false;

  // Filter State
  late String _selectedCategory;
  String _selectedRadius = '5 km';
  int _selectedProIndex = 0;
  bool _isListView = false;
  MapType _currentMapType = MapType.normal;

  final PageController _pageController = PageController(viewportFraction: 0.88);

  final List<String> _categories = [
    'All',
    'AC Repair',
    'Plumbing',
    'Electrical',
    'Appliances',
  ];

  final List<String> _radiusOptions = ['2 km', '5 km', '10 km'];

  // Dark Map Style JSON for Google Maps
  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#181818"}]},
  {"featureType": "poi.park", "elementType": "geometry", "stylers": [{"color": "#121212"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "road.arterial", "elementType": "geometry", "stylers": [{"color": "#373737"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
  {"featureType": "road.highway.controlled_access", "elementType": "geometry", "stylers": [{"color": "#4e4e4e"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category ?? 'All';
    _fetchLiveLocation();
  }

  Future<void> _fetchLiveLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _isLoadingLocation = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(pos.latitude, pos.longitude);
          _isLoadingLocation = false;
        });
        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _userLocation, zoom: 14.5),
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  List<ProfessionalModel> get _filteredProfessionals {
    return ProfessionalModel.sampleProfessionals.where((pro) {
      if (_selectedCategory == 'All') return true;
      return pro.category.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          _selectedCategory.toLowerCase().contains(pro.category.toLowerCase());
    }).toList();
  }

  Set<Marker> _buildMarkers(List<ProfessionalModel> pros) {
    final markers = <Marker>{};

    // User Location Marker
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _userLocation,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    // Professional Markers
    for (int i = 0; i < pros.length; i++) {
      final pro = pros[i];
      final isSelected = i == _selectedProIndex;
      markers.add(
        Marker(
          markerId: MarkerId(pro.id),
          position: LatLng(pro.latitude, pro.longitude),
          infoWindow: InfoWindow(
            title: pro.name,
            snippet: '${pro.rating} ★ • ${pro.distance} away',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isSelected ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueRed,
          ),
          onTap: () {
            setState(() {
              _selectedProIndex = i;
            });
            _pageController.animateToPage(
              i,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
            );
          },
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    double radiusMeters = 5000;
    if (_selectedRadius == '2 km') radiusMeters = 2000;
    if (_selectedRadius == '10 km') radiusMeters = 10000;

    return {
      Circle(
        circleId: const CircleId('search_radius'),
        center: _userLocation,
        radius: radiusMeters,
        strokeWidth: 2,
        strokeColor: AppColors.primary.withValues(alpha: 0.6),
        fillColor: AppColors.primary.withValues(alpha: 0.08),
      ),
    };
  }

  void _onProChanged(int index, List<ProfessionalModel> pros) {
    if (index >= pros.length) return;
    setState(() {
      _selectedProIndex = index;
    });

    final pro = pros[index];
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(pro.latitude, pro.longitude),
          zoom: 15.0,
        ),
      ),
    );
  }

  Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dialing $phone...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pros = _filteredProfessionals;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // MAP OR LIST VIEW
            Positioned.fill(
              child: _isListView ? _buildListView(pros) : _buildMapView(pros),
            ),

            // TOP NAVIGATION & FILTERS
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 10),
                  _buildCategoryChips(),
                ],
              ),
            ),

            // FLOATING MAP CONTROLS
            if (!_isListView)
              Positioned(
                right: 16,
                top: 130,
                child: Column(
                  children: [
                    _floatingBtn(
                      icon: _isLoadingLocation ? Icons.hourglass_top_rounded : Icons.my_location_rounded,
                      tooltip: 'My Location',
                      onTap: _fetchLiveLocation,
                    ),
                    const SizedBox(height: 10),
                    _floatingBtn(
                      icon: _currentMapType == MapType.normal
                          ? Icons.layers_rounded
                          : Icons.map_rounded,
                      tooltip: 'Toggle Map Style',
                      onTap: () {
                        setState(() {
                          _currentMapType = _currentMapType == MapType.normal
                              ? MapType.hybrid
                              : MapType.normal;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _floatingBtn(
                      icon: Icons.tune_rounded,
                      tooltip: 'Radius Filter',
                      onTap: _showRadiusFilterDialog,
                    ),
                  ],
                ),
              ),

            // BOTTOM TECHNICIANS CAROUSEL
            if (!_isListView && pros.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: SizedBox(
                  height: 190,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pros.length,
                    onPageChanged: (index) => _onProChanged(index, pros),
                    itemBuilder: (context, index) {
                      final pro = pros[index];
                      final isSelected = index == _selectedProIndex;
                      return _buildCarouselCard(pro, isSelected);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nearby Professionals',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Google Maps • Live Verified Technicians',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              _isListView ? Icons.map_rounded : Icons.list_alt_rounded,
              color: AppColors.secondary,
            ),
            tooltip: _isListView ? 'Show Map' : 'Show List',
            onPressed: () {
              setState(() => _isListView = !_isListView);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (val) {
              if (val) {
                setState(() {
                  _selectedCategory = cat;
                  _selectedProIndex = 0;
                });
              }
            },
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.card.withValues(alpha: 0.9),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _floatingBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }

  void _showRadiusFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Search Distance Radius',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                ..._radiusOptions.map(
                  (r) => RadioListTile<String>(
                    activeColor: AppColors.primary,
                    title: Text('Within $r', style: const TextStyle(color: Colors.white)),
                    value: r,
                    groupValue: _selectedRadius,
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedRadius = val);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<ProfessionalModel> pros) {
    // If running on desktop / web or platforms without native Google Maps service,
    // GoogleMap provides a fallback canvas if map loading fails
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _userLocation,
        zoom: 14.5,
      ),
      mapType: _currentMapType,
      markers: _buildMarkers(pros),
      circles: _buildCircles(),
      myLocationEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      mapToolbarEnabled: false,
      style: _currentMapType == MapType.normal ? _darkMapStyle : null,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }

  Widget _buildListView(List<ProfessionalModel> pros) {
    if (pros.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded, size: 50, color: AppColors.textSecondary),
            const SizedBox(height: 14),
            Text(
              'No technicians found for "$_selectedCategory"',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 30),
      itemCount: pros.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final pro = pros[index];
        return _buildListCard(pro);
      },
    );
  }

  Widget _buildCarouselCard(ProfessionalModel pro, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.4),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getCategoryIcon(pro.category), color: AppColors.secondary, size: 22),
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
                            pro.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (pro.isVerified)
                          const Icon(Icons.verified_rounded, color: AppColors.primary, size: 16),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pro.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badges row
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC857), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    pro.rating.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' (${pro.reviewCount})',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${pro.trustScore}% Trust Score',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                pro.distance,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Action Buttons
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.call_rounded, color: AppColors.success, size: 20),
                onPressed: () => _makeCall(pro.phoneNumber),
                tooltip: 'Call Technician',
              ),
              const SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessionalDetailsScreen(professional: pro),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('View Details', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(ProfessionalModel pro) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_getCategoryIcon(pro.category), color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pro.specialty,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC857), size: 18),
              const SizedBox(width: 4),
              Text(
                '${pro.rating} (${pro.reviewCount})',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pro.trustScore}% AI Trust',
                  style: const TextStyle(color: AppColors.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '${pro.distance} away',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(pro.phoneNumber),
                  icon: const Icon(Icons.call_rounded, size: 16, color: AppColors.success),
                  label: const Text('Call', style: TextStyle(color: AppColors.success)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfessionalDetailsScreen(professional: pro),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'electrical':
        return Icons.electrical_services_rounded;
      case 'plumbing':
        return Icons.water_drop_rounded;
      case 'ac repair':
        return Icons.ac_unit_rounded;
      case 'appliances':
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }
}
