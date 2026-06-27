import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../providers/user_provider.dart';
import '../services/cloudinary_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/location_picker_screen.dart';
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
  bool get isMarathi => context.watch<SettingsProvider>().isMarathi;
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _treeNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double? _pickedLat;
  double? _pickedLon;
  File? _selectedImage;
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
      final isMarathi = context.read<SettingsProvider>().isMarathi;
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showStrictLocationWarning() {
    if (!mounted) return;
    final isMarathi = context.read<SettingsProvider>().isMarathi;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.red),
            const SizedBox(width: 8),
            Text(isMarathi ? 'GPS आवश्यक' : 'GPS Required', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
            child: Text(isMarathi ? 'मागे जा' : 'Go Back', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _autoFetchLocation(); // Retry fetching
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isMarathi ? 'GPS चालू करा' : 'Enable GPS', style: const TextStyle(color: Colors.white)),
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
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isMarathi
                ? 'कृपया झाडाचा फोटो जोडा.'
                : 'Please add a photo of the tree.',
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

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await CloudinaryService.uploadImage(_selectedImage!);
    }

    if (!mounted) return;

    await Provider.of<UserProvider>(context, listen: false).plantTree(
      PlantedTree(
        speciesName: _treeNameController.text.trim(),
        datePlanted: _selectedDate,
        location: _locationController.text.trim(),
        quantity: _quantity,
        imageUrl: imageUrl,
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
        title: const Icon(
          CupertinoIcons.check_mark_circled_solid,
          color: AppColors.success,
          size: 60,
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
    return SingleChildScrollView(
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
            // Tree Name Section
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
              style:
                  GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
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
            const SizedBox(height: 28),

            // Quantity Section
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
                    color: _quantity > 1
                        ? AppColors.primary
                        : Colors.grey.shade400,
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
            const SizedBox(height: 28),

            // Date Section
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
            const SizedBox(height: 28),

            // Location Section
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LocationPickerScreen(),
                  ),
                );
                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    _locationController.text = result['address'] as String;
                    _pickedLat = result['lat'] as double;
                    _pickedLon = result['lon'] as double;
                  });
                }
              },
              style:
                  GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: isMarathi
                    ? 'नकाशावरून ठिकाण निवडा'
                    : 'Pick location from map',
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
            const SizedBox(height: 28),

            // Photo Upload Section
            Text(
              isMarathi ? 'झाडाचा फोटो जोडा' : 'Add a Photo of the Tree',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _selectedImage == null
                      ? const Color(0xFFF3F4F6)
                      : Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              CupertinoIcons.camera_fill,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isMarathi
                                ? 'फोटो काढण्यासाठी टॅप करा'
                                : 'Tap to take a live photo',
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedImage = null),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // 6-Month Tracking Notice
            Container(
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
            ),

            const SizedBox(height: 40),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
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
            ),
          ],
        ),
      ),
    );
  }
}
