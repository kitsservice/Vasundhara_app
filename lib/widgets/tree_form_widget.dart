import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../services/cloudinary_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/ola_maps_service.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;

class TreeFormWidget extends StatefulWidget {
  const TreeFormWidget({
    super.key,
  });

  @override
  State<TreeFormWidget> createState() => _TreeFormWidgetState();
}

class _TreeFormWidgetState extends State<TreeFormWidget>
    with WidgetsBindingObserver {
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _treeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double? _pickedLat;
  double? _pickedLon;
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isAutoFetching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _autoFetchLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_locationController.text.isEmpty && !_isAutoFetching) {
        _autoFetchLocation();
      }
    }
  }

  Future<void> _autoFetchLocation() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final isMarathi = context.locale.languageCode == 'mr';
      setState(() {
        _isAutoFetching = true;
        _locationController.text =
            isMarathi ? 'स्थान शोधत आहे...' : 'Locating...';
      });

      try {
        final loc.Location location = loc.Location();
        bool serviceEnabled = await location.serviceEnabled();
        if (!serviceEnabled) {
          serviceEnabled = await location.requestService();
          if (!serviceEnabled) {
            if (mounted) {
              setState(() {
                _locationController.text = '';
              });
              _showStrictLocationWarning();
            }
            return;
          }
          // Brief pause to let GPS hardware initialize after turning on
          await Future.delayed(const Duration(milliseconds: 600));
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) {
            if (mounted) {
              setState(() {
                _locationController.text = '';
              });
              _showStrictLocationWarning();
            }
            return;
          }
        }
        if (permission == LocationPermission.deniedForever) {
          if (mounted) {
            setState(() {
              _locationController.text = '';
            });
            _showStrictLocationWarning();
          }
          return;
        }

        final Position position = await Geolocator.getCurrentPosition(
          locationSettings:
              const LocationSettings(accuracy: LocationAccuracy.medium),
        );

        _pickedLat = position.latitude;
        _pickedLon = position.longitude;

        final response = await http.get(
          Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${position.latitude}&lon=${position.longitude}&email=vasundhara.app@example.com',
          ),
          headers: {'User-Agent': 'com.vasundhara.treeapp'},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final address = data['display_name'] as String? ?? 'Current Location';
          if (mounted) {
            setState(() {
              _locationController.text = address;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _locationController.text = '';
            });
          }
        }
      } catch (e) {
        debugPrint('Auto fetch location error: $e');
        if (mounted) {
          setState(() {
            _locationController.text = '';
          });
        }
      } finally {
        if (mounted) {
          setState(() => _isAutoFetching = false);
        }
      }
    });
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= _quantity) {
      final isMarathi = context.locale.languageCode == 'mr';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isMarathi 
              ? 'तुम्ही जास्तीत जास्त $_quantity फोटो जोडू शकता.' 
              : 'You can only add up to $_quantity photos.',),
        ),
      );
      return;
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _showStrictLocationWarning() {
    if (!mounted) return;
    final isMarathi = context.locale.languageCode == 'mr';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              isMarathi ? 'GPS आवश्यक' : 'GPS Required',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          isMarathi
              ? 'झाड लावण्यासाठी तुमचे अचूक स्थान आवश्यक आहे. कृपया पुढे जाण्यासाठी तुमचे GPS चालू करा आणि परवानगी द्या.'
              : 'Accurate location is required to plant a tree. Please enable your GPS and grant location permissions to proceed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: Text(
              isMarathi ? 'मागे जा' : 'Go Back',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Check if service is disabled, open location settings if so
              final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
              if (!serviceEnabled) {
                await Geolocator.openLocationSettings();
              } else {
                // If service is enabled but permissions are denied, open app settings
                final LocationPermission permission = await Geolocator.checkPermission();
                if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                  await Geolocator.openAppSettings();
                }
              }
              
              // Wait a moment for user to potentially return from settings
              await Future.delayed(const Duration(milliseconds: 500));
              _autoFetchLocation(); // Retry fetching
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isMarathi ? 'GPS चालू करा' : 'Enable GPS',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    final isMarathi = context.locale.languageCode == 'mr';
    if (_treeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarathi
                ? 'कृपया झाडाची प्रजाती किंवा नाव प्रविष्ट करा.'
                : 'Please enter the tree species or name.',
          ),
        ),
      );
      return;
    }
    if (_locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarathi
                ? 'कृपया लागवडीचे ठिकाण प्रविष्ट करा.'
                : 'Please enter the planting location.',
          ),
        ),
      );
      return;
    }
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarathi
                ? 'कृपया झाडाचा किमान एक फोटो जोडा.'
                : 'Please add at least one photo of the tree.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    double? lat = _pickedLat;
    double? lng = _pickedLon;

    if (lat == null || lng == null) {
      try {
        final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            permission = await Geolocator.requestPermission();
          }
          if (permission == LocationPermission.whileInUse ||
              permission == LocationPermission.always) {
            final Position position = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.medium),
            );
            lat = position.latitude;
            lng = position.longitude;
          }
        }
      } catch (e) {
        debugPrint('Location error: $e');
      }
    }

    final List<String> uploadedUrls = [];
    if (_selectedImages.isNotEmpty) {
      for (var file in _selectedImages) {
        final String? url = await CloudinaryService.uploadImage(file);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }
    }

    if (!mounted) return;

    await context.read<UserProvider>().plantTree(
      PlantedTree(
        speciesName: _treeNameController.text.trim(),
        datePlanted: _selectedDate,
        location: _locationController.text.trim(),
        quantity: _quantity,
        imageUrl: uploadedUrls.isNotEmpty ? uploadedUrls.first : null,
        imageUrls: uploadedUrls.isNotEmpty ? uploadedUrls : null,
        latitude: lat,
        longitude: lng,
      ),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: SizedBox(
          height: 120,
          child: Lottie.network(
            'https://assets3.lottiefiles.com/packages/lf20_touohxv0.json',
            repeat: false,
            errorBuilder: (context, error, stackTrace) => const Icon(
              CupertinoIcons.check_mark_circled_solid,
              color: AppColors.success,
              size: 80,
            ),
          ),
        ),
        content: Text(
          isMarathi
              ? 'झाड यशस्वीरित्या लावले! आपल्या ६-महिन्यांच्या वाढीच्या अद्यतनासाठी एक स्मरणपत्र सेट केले गेले आहे.'
              : 'Tree planted successfully! A reminder has been set for your 6-month growth update.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // close form
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(isMarathi ? 'उत्तम!' : 'Great!'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _treeNameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMarathi = context.locale.languageCode == 'mr';
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTreeNameSection(isMarathi),
                  const SizedBox(height: 28),
                  _buildQuantitySection(isMarathi),
                  const SizedBox(height: 28),
                  _buildDateSection(isMarathi),
                  const SizedBox(height: 28),
                  _buildLocationSection(isMarathi),
                  const SizedBox(height: 28),
                  _buildPhotoUploadSection(isMarathi),
                  const SizedBox(height: 32),
                  _buildTrackingNotice(isMarathi),
                ],
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: _buildSubmitButton(isMarathi),
          ),
        ),
      ],
    );
  }

  Widget _buildTreeNameSection(bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'झाडाची प्रजाती / नाव' : 'Tree Species / Name',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _treeNameController,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: isMarathi
                ? 'उदा. वड, कडुलिंब, आंबा...'
                : 'e.g. Banyan, Neem, Mango...',
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.leaf_arrow_circlepath,
              color: AppColors.primary,
              size: 22,
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantitySection(bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi
              ? 'आज तुम्ही किती झाडे लावली?'
              : 'How many trees did you plant today?',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.minus_circle_fill),
                color: _quantity > 1 ? AppColors.primary : Colors.grey.shade400,
                iconSize: 28,
                onPressed: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
              Text(
                '$_quantity',
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.plus_circle_fill),
                color: AppColors.primary,
                iconSize: 28,
                onPressed: () {
                  setState(() => _quantity++);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection(bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'लागवडीची तारीख' : 'Date of Planting',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.calendar,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Text(
                  DateFormat('MMMM dd, yyyy').format(_selectedDate),
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'ठिकाण' : 'Location',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _locationController,
          readOnly: true,
          onTap: () async {
            try {
              // Ask for permission and get current location natively
              final position = await Geolocator.getCurrentPosition();
              final String? address = await OlaMapsService.reverseGeocode(
                position.latitude,
                position.longitude,
              );

              if (address != null) {
                setState(() {
                  _locationController.text = address;
                  _pickedLat = position.latitude;
                  _pickedLon = position.longitude;
                });
              }
            } catch (e) {
              debugPrint('Error fetching location: $e');
            }
          },
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText:
                isMarathi ? 'नकाशावरून ठिकाण निवडा' : 'Pick location from map',
            hintStyle: GoogleFonts.inter(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.location_solid,
              color: AppColors.primary,
              size: 22,
            ),
            suffixIcon: _isAutoFetching
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadSection(bool isMarathi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isMarathi ? 'झाडाचे फोटो जोडा ($_quantity पर्यंत)' : 'Add Photos of the Trees (Up to $_quantity)',
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ..._selectedImages.asMap().entries.map((entry) {
              final int idx = entry.key;
              final File file = entry.value;
              return Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImages.removeAt(idx)),
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              );
            }),
            ...List.generate(_quantity - _selectedImages.length, (index) {
              return GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.camera_fill, color: AppColors.primary, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        isMarathi ? 'फोटो जोडा' : 'Add Photo',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingNotice(bool isMarathi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFDCFCE7),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.time,
              color: Color(0xFF166534),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isMarathi
                  ? 'या रोपाच्या प्रगतीचा मागोवा घेण्यासाठी "६-महिन्यांचा वाढीचा फोटो" स्लॉट ${DateFormat('MMM dd, yyyy').format(_selectedDate.add(const Duration(days: 180)))} रोजी उघडेल.'
                  : 'A slot for a "6-Month Growth Photo" will open on ${DateFormat('MMM dd, yyyy').format(_selectedDate.add(const Duration(days: 180)))} to track this plant\'s progress.',
              style: GoogleFonts.inter(
                color: const Color(0xFF166534),
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isMarathi) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isMarathi ? 'नोंद करा' : 'Record Planting',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
