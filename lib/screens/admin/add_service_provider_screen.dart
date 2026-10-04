import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AddServiceProviderScreen extends StatefulWidget {
  const AddServiceProviderScreen({super.key});

  @override
  State<AddServiceProviderScreen> createState() =>
      _AddServiceProviderScreenState();
}

class _AddServiceProviderScreenState
    extends State<AddServiceProviderScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  final _pricingController = TextEditingController();
  final _servicesController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _skillsController = TextEditingController();
  final _brandsController = TextEditingController();
  final _equipmentTypesController = TextEditingController();
  final _problemTypesController = TextEditingController();
  final _serviceRadiusController = TextEditingController(text: '10');

  String _category = 'Electrical';
  bool _isVerified = true;
  bool _saving = false;
  bool _available = true;
  final List<Map<String, dynamic>> _pastJobs = [];

  final List<String> _categories = const [
    'Electrical',
    'Plumbing',
    'AC Repair',
    'Appliances',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _pricingController.dispose();
    _servicesController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();

    _skillsController.dispose();
    _brandsController.dispose();
    _equipmentTypesController.dispose();
    _problemTypesController.dispose();
    _serviceRadiusController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // NOTIFY USERS WITHIN 10 KM
  // ---------------------------------------------------------------------------

  Future<void> _notifyNearbyUsers({
    required double providerLatitude,
    required double providerLongitude,
    required String providerName,
    required String category,
  }) async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Get all registered users.
      final usersSnapshot =
          await firestore.collection('users').get();

      int notificationCount = 0;

      for (final userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();

        // Read user's saved location.
        final userLatitude = _toDouble(
          userData['latitude'],
        );

        final userLongitude = _toDouble(
          userData['longitude'],
        );

        // If the user doesn't have a valid location, skip them.
        if (userLatitude == null || userLongitude == null) {
          debugPrint(
            'Skipping user ${userDoc.id}: '
            'latitude/longitude missing or invalid.',
          );
          continue;
        }

        // Calculate distance between user and provider.
        final distanceKm = _calculateDistanceKm(
          userLatitude,
          userLongitude,
          providerLatitude,
          providerLongitude,
        );

        debugPrint(
          'USER LOCATION CHECK: '
          'uid=${userDoc.id}, '
          'userLat=$userLatitude, '
          'userLng=$userLongitude, '
          'providerLat=$providerLatitude, '
          'providerLng=$providerLongitude, '
          'distance=${distanceKm.toStringAsFixed(2)} km',
        );

        // Notify users within 10 km.
        if (distanceKm <= 10) {
          final notificationRef = firestore
              .collection('users')
              .doc(userDoc.id)
              .collection('notifications')
              .doc();

          await notificationRef.set({
            'title': '🔧 New Service Provider Added',
            'message':
                'A new $category service provider, '
                '$providerName, has been added near you. '
                'Check them out!',
            'type': 'professional',
            'isRead': false,
            'createdAt': FieldValue.serverTimestamp(),
          });

          notificationCount++;

          debugPrint(
            'NOTIFICATION CREATED for ${userDoc.id} '
            '(${distanceKm.toStringAsFixed(2)} km away)',
          );
        }
      }

      debugPrint(
        'New provider notification sent to '
        '$notificationCount nearby users.',
      );
    } catch (e) {
      debugPrint(
        'FAILED TO SEND PROVIDER NOTIFICATIONS: $e',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Provider added, but notification failed: $e',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CONVERT FIRESTORE VALUE TO DOUBLE
  // ---------------------------------------------------------------------------

  double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // DISTANCE CALCULATION
  // ---------------------------------------------------------------------------

  double _calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(
      sqrt(a),
      sqrt(1 - a),
    );

    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // ---------------------------------------------------------------------------
  // SAVE PROVIDER
  // ---------------------------------------------------------------------------

  Future<void> _addPastJob() async {
  final equipmentController = TextEditingController();
  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final problemController = TextEditingController();
  final skillsController = TextEditingController();
  final ratingController = TextEditingController();

  DateTime completedAt = DateTime.now();

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(
              'Add Past Job',
              style: TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: equipmentController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Equipment Type',
                      hint: 'e.g. washing machine',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: brandController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Brand',
                      hint: 'e.g. LG',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: modelController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Model',
                      hint: 'e.g. WM4000HBA',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: problemController,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Problem Type',
                      hint: 'e.g. drum not spinning',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: skillsController,
                    maxLines: 3,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Skills Used',
                      hint:
                          'e.g. Washing Machine Diagnostics, Motor Repair',
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: ratingController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                    ),
                    decoration: _inputDecoration(
                      'Customer Rating',
                      hint: '1 - 5',
                    ),
                  ),

                  const SizedBox(height: 12),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Completed Date',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      '${completedAt.day}/${completedAt.month}/${completedAt.year}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: completedAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setDialogState(() {
                          completedAt = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, false);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (equipmentController.text.trim().isEmpty ||
                      problemController.text.trim().isEmpty ||
                      skillsController.text.trim().isEmpty ||
                      ratingController.text.trim().isEmpty) {
                    return;
                  }

                  final rating =
                      int.tryParse(ratingController.text.trim());

                  if (rating == null || rating < 1 || rating > 5) {
                    return;
                  }

                  final skillsUsed = skillsController.text
                      .split(',')
                      .map((skill) => skill.trim())
                      .where((skill) => skill.isNotEmpty)
                      .toList();

                  _pastJobs.add({
                    'equipmentType':
                        equipmentController.text.trim(),
                    'brand': brandController.text.trim(),
                    'model': modelController.text.trim(),
                    'problemType':
                        problemController.text.trim(),
                    'skillsUsed': skillsUsed,
                    'customerRating': rating,
                    'completedAt':
                        Timestamp.fromDate(completedAt),
                  });

                  Navigator.pop(dialogContext, true);
                },
                child: const Text('Add Job'),
              ),
            ],
          );
        },
      );
    },
  );

  equipmentController.dispose();
  brandController.dispose();
  modelController.dispose();
  problemController.dispose();
  skillsController.dispose();
  ratingController.dispose();

  if (result == true && mounted) {
    setState(() {});
  }
}
  
  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final services = _servicesController.text
          .split(',')
          .map((service) => service.trim())
          .where((service) => service.isNotEmpty)
          .toList();
      final skills = _skillsController.text
          .split(',')
          .map((skill) => skill.trim())
          .where((skill) => skill.isNotEmpty)
          .toList();

      final brands = _brandsController.text
          .split(',')
          .map((brand) => brand.trim())
          .where((brand) => brand.isNotEmpty)
          .toList();

      final equipmentTypes = _equipmentTypesController.text
          .split(',')
          .map((type) => type.trim())
          .where((type) => type.isNotEmpty)
          .toList();

      final problemTypes = _problemTypesController.text
          .split(',')
          .map((problem) => problem.trim())
          .where((problem) => problem.isNotEmpty)
          .toList();

      final serviceRadiusKm =
          double.tryParse(
                _serviceRadiusController.text.trim(),
              ) ??
              10;

      final experience =
          int.tryParse(
                _experienceController.text.trim(),
              ) ??
              0;

      final pricing =
          double.tryParse(
                _pricingController.text.trim(),
              ) ??
              0;

      final latitude =
          double.tryParse(
            _latitudeController.text.trim(),
          );

      final longitude =
          double.tryParse(
            _longitudeController.text.trim(),
          );

      if (latitude == null || longitude == null) {
        throw Exception(
          'Please enter valid latitude and longitude.',
        );
      }

      final providerName =
          _nameController.text.trim();

      // -----------------------------------------------------------------------
      // 1. ADD PROVIDER TO FIRESTORE
      // -----------------------------------------------------------------------

      await FirebaseFirestore.instance
          .collection('professionals')
          .add({
        'name': providerName,
        'category': _category,
        'specialty':
            _specialtyController.text.trim(),
        'phoneNumber':
            _phoneController.text.trim(),
        'address':
            _addressController.text.trim(),
        'experienceYears': experience,
        'pricingStartingAt': pricing,
        'latitude': latitude,
        'longitude': longitude,
        'rating': 0.0,
        'reviewCount': 0,
        'trustScore': 0.0,
        'completedRepairs': 0,
        'aiReviewSummary': '',
        'isVerified': _isVerified,
        'services': services,
        'createdAt':
            FieldValue.serverTimestamp(),
        'skills': skills,
        'brands': brands,
        'equipmentTypes': equipmentTypes,
        'problemTypes': problemTypes,
        'pastJobs': _pastJobs,
        'serviceRadiusKm': serviceRadiusKm,
        'available': _available,
      });

      // -----------------------------------------------------------------------
      // 2. NOTIFY USERS WITHIN 10 KM
      // -----------------------------------------------------------------------

      await _notifyNearbyUsers(
        providerLatitude: latitude,
        providerLongitude: longitude,
        providerName: providerName,
        category: _category,
      );

      if (!mounted) {
        return;
      }

      // -----------------------------------------------------------------------
      // 3. SHOW SUCCESS MESSAGE
      // -----------------------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service provider added successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add provider: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // INPUT DECORATION
  // ---------------------------------------------------------------------------

  InputDecoration _inputDecoration(
    String label, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(
        color: AppColors.textSecondary,
      ),
      hintStyle: TextStyle(
        color: AppColors.textSecondary
            .withValues(alpha: 0.7),
      ),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.border
              .withValues(alpha: 0.35),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.border
              .withValues(alpha: 0.35),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // VALIDATORS
  // ---------------------------------------------------------------------------

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    return null;
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Enter a valid number';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Add Service Provider',
        ),
        backgroundColor:
            AppColors.background,
        foregroundColor:
            AppColors.textPrimary,
        elevation: 0,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider Details',
                  style: AppTextStyles.title,
                ),

                const SizedBox(height: 8),

                Text(
                  'Add a new service provider to the platform.',
                  style: AppTextStyles.bodySecondary,
                ),

                const SizedBox(height: 24),

                // NAME
                TextFormField(
                  controller: _nameController,
                  validator: _requiredValidator,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Provider Name',
                    hint: 'Enter provider name',
                  ),
                ),

                const SizedBox(height: 16),

                // CATEGORY
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  dropdownColor: AppColors.card,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Category',
                  ),
                  items: _categories.map(
                    (category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _category = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // SPECIALTY
                TextFormField(
                  controller:
                      _specialtyController,
                  validator: _requiredValidator,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Specialty',
                    hint:
                        'e.g. Residential wiring',
                  ),
                ),

                const SizedBox(height: 16),

                // PHONE
                TextFormField(
                  controller: _phoneController,
                  validator: _requiredValidator,
                  keyboardType:
                      TextInputType.phone,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Phone Number',
                    hint: 'Enter phone number',
                  ),
                ),

                const SizedBox(height: 16),

                // ADDRESS
                TextFormField(
                  controller: _addressController,
                  validator: _requiredValidator,
                  maxLines: 2,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Address',
                    hint: 'Enter provider address',
                  ),
                ),

                const SizedBox(height: 16),

                // EXPERIENCE
                TextFormField(
                  controller:
                      _experienceController,
                  validator: _numberValidator,
                  keyboardType:
                      TextInputType.number,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Experience (Years)',
                  ),
                ),

                const SizedBox(height: 16),

                // PRICING
                TextFormField(
                  controller: _pricingController,
                  validator: _numberValidator,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Starting Price',
                    hint: 'e.g. 500',
                  ),
                ),

                const SizedBox(height: 16),

                // SERVICES
                TextFormField(
                  controller:
                      _servicesController,
                  validator: _requiredValidator,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Services',
                    hint:
                        'Comma separated services',
                  ),
                ),

                const SizedBox(height: 16),

                

                Text(
                  'AI Matching Details',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'These details help the AI match customers with the right professional.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // SKILLS
                TextFormField(
                  controller: _skillsController,
                  maxLines: 3,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Technical Skills',
                    hint: 'Example: Wiring, MCB Repair, Electrical Diagnostics',
                  ),
                ),

                const SizedBox(height: 16),

                // BRANDS
                TextFormField(
                  controller: _brandsController,
                  maxLines: 2,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Brands',
                    hint: 'Example: LG, Samsung, IFB',
                  ),
                ),

                const SizedBox(height: 16),

                // EQUIPMENT TYPES
                TextFormField(
                  controller: _equipmentTypesController,
                  maxLines: 3,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Equipment / Device Types',
                    hint: 'Example: washing machine, front load washing machine',
                  ),
                ),

                const SizedBox(height: 16),

                // PROBLEM TYPES
                TextFormField(
                  controller: _problemTypesController,
                  maxLines: 4,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Problem Types',
                    hint: 'Example: drum not spinning, water not draining',
                  ),
                ),

                const SizedBox(height: 24),

              Text(
                'Past Job History',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height:15),

              Text(
                'Add previous repair jobs to help the AI identify providers with real experience.',
                style: AppTextStyles.bodySecondary.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              ..._pastJobs.asMap().entries.map((entry) {
                final index = entry.key;
                final job = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${job['equipmentType']} - ${job['problemType']}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: Colors.redAccent,
                            onPressed: () {
                              setState(() {
                                _pastJobs.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Text(
                        'Brand: ${job['brand'].toString().isEmpty ? 'N/A' : job['brand']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      Text(
                        'Model: ${job['model'].toString().isEmpty ? 'N/A' : job['model']}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      Text(
                        'Rating: ${job['customerRating']}/5',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              OutlinedButton.icon(
                onPressed: _addPastJob,
                icon: const Icon(Icons.add),
                label: const Text('Add Past Job'),
              ),
                 const SizedBox(height: 20),

                // SERVICE RADIUS
                TextFormField(
                  controller: _serviceRadiusController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Service Radius (km)',
                    hint: 'Example: 10',
                  ),
                ),

                const SizedBox(height: 16),

                // AVAILABLE SWITCH
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.35),
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Available for Jobs',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Allow this provider to receive new jobs',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    value: _available,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _available = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Location',
                  style: AppTextStyles.heading.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter the provider coordinates so they can appear on the map.',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // LATITUDE
                TextFormField(
                  controller:
                      _latitudeController,
                  validator: _numberValidator,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Latitude',
                    hint: 'e.g. 10.902694',
                  ),
                ),

                const SizedBox(height: 16),

                // LONGITUDE
                TextFormField(
                  controller:
                      _longitudeController,
                  validator: _numberValidator,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                  ),
                  decoration: _inputDecoration(
                    'Longitude',
                    hint: 'e.g. 76.896051',
                  ),
                ),

                const SizedBox(height: 20),

                // VERIFIED SWITCH
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border
                          .withValues(alpha: 0.35),
                    ),
                  ),
                  child: SwitchListTile(
                    contentPadding:
                        EdgeInsets.zero,
                    title: Text(
                      'Verified Provider',
                      style: TextStyle(
                        color:
                            AppColors.textPrimary,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      'Mark this provider as verified',
                      style: TextStyle(
                        color:
                            AppColors.textSecondary,
                      ),
                    ),
                    value: _isVerified,
                    activeThumbColor:
                        AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _isVerified = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        _saving ? null : _saveProvider,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors.primary,
                      foregroundColor: Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add Service Provider',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}