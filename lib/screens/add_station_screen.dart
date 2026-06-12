/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_state.dart';
import 'api_service.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  // LPG SPECIFIC FIELDS
  //final TextEditingController _lpgPricePerKgController =
  // TextEditingController();
  bool _deliveryAvailable = false;
  bool _hasBackupGenerator = false;

  //  FUEL TYPE SELECTION
  String _selectedFuelType = 'Petrol/Diesel';

  //  LPG OPTIONS
  final Set<String> _selectedLpgTypes = {};

  //  EV CONNECTOR
  String? _selectedConnector;

  //  OCTANE
  String _selectedOctane = '95';

  //  POWER OUTPUT
  String? _selectedPowerOutput;

  //  PHOTO UPLOAD (NEW)
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  bool _isSubmitting = false;

  //  PHOTO PICKER (NEW)
  Future<void> _pickPhotos() async {
    if (_selectedPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 photos allowed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _brandGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: _brandGreen),
                  ),
                  title: const Text(
                    'Take a photo',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.photo_library, color: Colors.blue.shade600),
                  ),
                  title: const Text(
                    'Choose from gallery',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (photo == null) return;
    if (!mounted) return;

    setState(() {
      _selectedPhotos.add(photo);
    });
  }

  //  REMOVE PHOTO
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<List<String>> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) return [];

    setState(() => _isUploading = true);

    try {
      final token = AuthState.instance.token;
      print('Upload token exists: ${token != null}');

      if (token == null) {
        throw Exception('Not logged in');
      }

      /*final photoUrls = await ApiService.uploadPhotos(
        token: token,
        photos: _selectedPhotos,
      );
      print('Upload successful, URLs: $photoUrls');
      return photoUrls;
    } catch (e) {
      print('Upload error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload photos: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
      return [];
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }*/

  

Future<List<String>> _uploadPhotos() async {
  if (_selectedPhotos.isEmpty) return [];

  setState(() => _isUploading = true);

  try {
    // Use direct Cloudinary upload (no backend token needed)
    final photoUrls = await ApiService.uploadMultiplePhotosToCloudinary(
      photos: _selectedPhotos,
    );
    print('Upload successful, URLs: $photoUrls');
    return photoUrls;
  } catch (e) {
    print('Upload error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to upload photos: $e'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
    return [];
  } finally {
    if (mounted) setState(() => _isUploading = false);
  }
}


  //  SUBMIT
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate fuel type specific fields
    if (_selectedFuelType == 'LPG' && _selectedLpgTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one LPG type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedFuelType == 'EV' && _selectedConnector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a connector type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final photoUrls = await _uploadPhotos();

      // Build the unit based on fuel type
      final unit = _selectedFuelType == 'EV'
          ? '/kWh'
          : _selectedFuelType == 'LPG'
              ? '/kg'
              : '/L';

      // Build the station map
      /*final newStation = {
        //'id': 'pending_${DateTime.now().millisecondsSinceEpoch}',
        'name': _nameController.text.trim(),
        'type': _selectedFuelType,
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'status': _selectedFuelType == 'Petrol/Diesel'
            ? 'Open'
                'price'
            : 'GH₵ ${_priceController.text.trim()}$unit',
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'pending': true,
        'photos': photoUrls.isNotEmpty ? photoUrls : [], // ← NEW
        if (_selectedFuelType == 'Petrol/Diesel') 'octane': _selectedOctane,
        if (_selectedFuelType == 'LPG') 'lpg_type': _selectedLpgTypes.toList(),
        if (_selectedFuelType == 'EV') 'connector': _selectedConnector,
        if (_selectedFuelType == 'EV') 'power_output': _selectedPowerOutput,
        if (_selectedFuelType == 'EV') 'has_backup_generator': _hasBackupGenerator,  // ← ADD THIS

      };*/

      final Map<String, dynamic> newStation = {
        'name': _nameController.text.trim(),
        'type': _selectedFuelType,
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'status': 'Open',
        'price': 'GH₵ ${_priceController.text.trim()}$unit',
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'photos': photoUrls.isNotEmpty ? photoUrls : [],
      };

// Add fuel type specific fields
      if (_selectedFuelType == 'Petrol/Diesel') {
        newStation['octane'] = _selectedOctane;
      } else if (_selectedFuelType == 'LPG') {
        newStation['lpg_type'] = _selectedLpgTypes.toList();
        newStation['delivery_available'] = _deliveryAvailable;
      } else if (_selectedFuelType == 'EV') {
        // ✅ IMPORTANT: Add EV fields
        newStation['connector'] = _selectedConnector;
        newStation['power_output'] = _selectedPowerOutput;
        newStation['has_backup_generator'] = _hasBackupGenerator;

        // Debug prints
        print('EV Station being created with:');
        print('Connector: ${newStation['connector']}');
        print('Power Output: ${newStation['power_output']}');
        print('Backup Generator: ${newStation['has_backup_generator']}');
      }

      final token = AuthState.instance.token ?? '';
      await ApiService.addStation(
        token: token,
        station: newStation,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station submitted! Pending approval from admin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, newStation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── INFO BANNER ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your station will be reviewed before appearing on the map.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              //  STATION NAME
              _sectionLabel('Station Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'e.g. GOIL Spintex Road',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter station name'
                    : null,
              ),

              const SizedBox(height: 20),

              //  FUEL TYPE
              _sectionLabel('Fuel Type'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: ['Petrol/Diesel', 'LPG', 'EV'].map((type) {
                    final isLast = type == 'EV';
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(type,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          value: type,
                          groupValue: _selectedFuelType,
                          activeColor: _brandGreen,
                          onChanged: (val) => setState(() {
                            _selectedFuelType = val!;
                            _selectedLpgTypes.clear();
                            _selectedConnector = null;
                            _selectedOctane = '95';
                            _hasBackupGenerator = false;
                          }),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // PETROL OCTANE
              if (_selectedFuelType == 'Petrol/Diesel') ...[
                const SizedBox(height: 20),
                _sectionLabel('Octane Rating'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Super (RON 91)',
                    'Super (RON 95)',
                    'V-Power',
                    'Excellium'
                  ].map((o) {
                    return ChoiceChip(
                      label: Text(o),
                      selected: _selectedOctane == o,
                      selectedColor: _brandGreen,
                      labelStyle: TextStyle(
                        color: _selectedOctane == o
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selectedOctane = o),
                    );
                  }).toList(),
                ),
              ],

              // LPG TYPE
              // ── LPG TYPE ──
              if (_selectedFuelType == 'LPG') ...[
                const SizedBox(height: 20),
                _sectionLabel('LPG Type Offered'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Autogas', 'Cylinder Refill'].map((t) {
                    final isSelected = _selectedLpgTypes.contains(t);
                    return FilterChip(
                      avatar: Icon(
                        t == 'Autogas'
                            ? Icons.directions_car
                            : Icons.propane_tank,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.blue.shade600,
                      ),
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLpgTypes.add(t);
                          } else {
                            _selectedLpgTypes.remove(t);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                // ── DELIVERY TOGGLE (LPG only) ──
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _deliveryAvailable,
                      onChanged: (val) =>
                          setState(() => _deliveryAvailable = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Home Delivery Available',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // ── EV CONNECTOR & POWER OUTPUT ──
              /*if (_selectedFuelType == 'EV') ...[
                const SizedBox(height: 20),
                _sectionLabel('Connector Type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'CCS',
                    'Type 2',
                    'CHAdeMO',
                    'Tesla',
                    'Type 1',
                    'GB/T'
                  ].map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: _selectedConnector == c,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedConnector == c
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selectedConnector = c),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                _sectionLabel('Charger Power Output'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '7.4 kW',
                    '11 kW',
                    '22 kW',
                    '50 kW',
                    '100 kW',
                    '150 kW',
                    '350 kW',
                  ].map((power) {
                    return ChoiceChip(
                      avatar: Icon(
                        Icons.bolt,
                        size: 14,
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.green.shade600,
                      ),
                      label: Text(power),
                      selected: _selectedPowerOutput == power,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPowerOutput = power),
                    );
                  }).toList(),
                ),

                // ── BACKUP GENERATOR TOGGLE (EV only) ──
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasBackupGenerator,
                      onChanged: (val) =>
                          setState(() => _hasBackupGenerator = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Has Backup Generator',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],*/

              

               // ── EV CONNECTOR & POWER OUTPUT ──
              if (_selectedFuelType == 'EV') ...[
                const SizedBox(height: 20),
                _sectionLabel('Connector Type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'CCS',
                    'Type 2',
                    'CHAdeMO',
                    'Tesla',
                    'Type 1',
                    'GB/T'
                  ].map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: _selectedConnector == c,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedConnector == c
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selectedConnector = c),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                _sectionLabel('Charger Power Output'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '7.4 kW',
                    '11 kW',
                    '22 kW',
                    '50 kW',
                    '100 kW',
                    '150 kW',
                    '350 kW',
                  ].map((power) {
                    return ChoiceChip(
                      avatar: Icon(
                        Icons.bolt,
                        size: 14,
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.green.shade600,
                      ),
                      label: Text(power),
                      selected: _selectedPowerOutput == power,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPowerOutput = power),
                    );
                  }).toList(),
                ),

                // ── BACKUP GENERATOR TOGGLE (EV only) ──
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasBackupGenerator,
                      onChanged: (val) =>
                          setState(() => _hasBackupGenerator = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Has Backup Generator',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              // PHOTO UPLOAD SECTION (NEW)
              const SizedBox(height: 20),
              _sectionLabel(
                _selectedPhotos.isEmpty
                    ? 'Add Photos (Optional, max 4)'
                    : 'Photos  •  ${_selectedPhotos.length}/4',
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Selected photos
                    ..._selectedPhotos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photo = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(photo.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),

                    // Add button
                    if (_selectedPhotos.length < 4)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey[500],
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PRICE
              _sectionLabel('Current Price'),
              const SizedBox(height: 8),
              _textField(
                controller: _priceController,
                hint: 'e.g. 14.80',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                suffix: _selectedFuelType == 'EV'
                    ? 'GH₵/kWh'
                    : _selectedFuelType == 'LPG'
                        ? 'GH₵/kg'
                        : 'GH₵/L',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter current price'
                    : null,
              ),

              const SizedBox(height: 20),

              //  PHONE
              _sectionLabel('Phone Number'),
              const SizedBox(height: 8),
              _textField(
                controller: _phoneController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),

              const SizedBox(height: 20),

              //  WHATSAPP
              _sectionLabel('WhatsApp Number (Optional)'),
              const SizedBox(height: 8),
              _textField(
                controller: _whatsappController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              //  LOCATION
              _sectionLabel('Station Location (GPS Coordinates)'),
              const SizedBox(height: 4),
              const Text(
                'Open Google Maps, long press your station location and copy the coordinates',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _latController,
                      hint: 'Latitude e.g. 5.6037',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      controller: _lngController,
                      hint: 'Longitude e.g. -0.1870',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              //  SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isUploading) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting || _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Submit Station',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // HELPER: Section label
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  //  HELPER: Reusable text field
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandGreen, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  /*@override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }*/

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    // Add these new ones
    //_lpgPricePerKgController.dispose();
    super.dispose();
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_state.dart';
import 'api_service.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  // FUEL TYPE SELECTION
  String _selectedFuelType = 'Petrol/Diesel';

  // LPG OPTIONS
  final Set<String> _selectedLpgTypes = {};

  // EV CONNECTOR
  String? _selectedConnector;

  // OCTANE
  String _selectedOctane = '95';

  // POWER OUTPUT
  String? _selectedPowerOutput;

  // EV BACKUP GENERATOR
  bool _hasBackupGenerator = false;

  // LPG DELIVERY
  bool _deliveryAvailable = false;

  // PHOTO UPLOAD
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isSubmitting = false;

  // PHOTO PICKER
  Future<void> _pickPhotos() async {
    if (_selectedPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 photos allowed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _brandGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: _brandGreen),
                  ),
                  title: const Text(
                    'Take a photo',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.photo_library, color: Colors.blue.shade600),
                  ),
                  title: const Text(
                    'Choose from gallery',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (photo == null) return;
    if (!mounted) return;

    setState(() {
      _selectedPhotos.add(photo);
    });
  }

  // REMOVE PHOTO
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  // UPLOAD PHOTOS TO CLOUDINARY
  Future<List<String>> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) return [];

    setState(() => _isUploading = true);

    try {
      final photoUrls = await ApiService.uploadMultiplePhotosToCloudinary(
        photos: _selectedPhotos,
      );
      print('Upload successful, URLs: $photoUrls');
      return photoUrls;
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload photos: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return [];
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // SUBMIT
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate fuel type specific fields
    if (_selectedFuelType == 'LPG' && _selectedLpgTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one LPG type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedFuelType == 'EV' && _selectedConnector == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a connector type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final photoUrls = await _uploadPhotos();

      // Build the unit based on fuel type
      final unit = _selectedFuelType == 'EV'
          ? '/kWh'
          : _selectedFuelType == 'LPG'
              ? '/kg'
              : '/L';

      final Map<String, dynamic> newStation = {
        'name': _nameController.text.trim(),
        'type': _selectedFuelType,
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'status': 'Open',
        'price': 'GH₵ ${_priceController.text.trim()}$unit',
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'photos': photoUrls.isNotEmpty ? photoUrls : [],
      };

      // Add fuel type specific fields
      if (_selectedFuelType == 'Petrol/Diesel') {
        newStation['octane'] = _selectedOctane;
      } else if (_selectedFuelType == 'LPG') {
        newStation['lpg_type'] = _selectedLpgTypes.toList();
        newStation['delivery_available'] = _deliveryAvailable;
      } else if (_selectedFuelType == 'EV') {
        newStation['connector'] = _selectedConnector;
        newStation['power_output'] = _selectedPowerOutput;
        newStation['has_backup_generator'] = _hasBackupGenerator;

        print('EV Station being created with:');
        print('Connector: ${newStation['connector']}');
        print('Power Output: ${newStation['power_output']}');
        print('Backup Generator: ${newStation['has_backup_generator']}');
      }

      final token = AuthState.instance.token ?? '';
      await ApiService.addStation(
        token: token,
        station: newStation,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station submitted! Pending approval from admin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, newStation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFO BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your station will be reviewed before appearing on the map.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STATION NAME
              _sectionLabel('Station Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'e.g. GOIL Spintex Road',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter station name'
                    : null,
              ),

              const SizedBox(height: 20),

              // FUEL TYPE
              _sectionLabel('Fuel Type'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: ['Petrol/Diesel', 'LPG', 'EV'].map((type) {
                    final isLast = type == 'EV';
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(type,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          value: type,
                          groupValue: _selectedFuelType,
                          activeColor: _brandGreen,
                          onChanged: (val) => setState(() {
                            _selectedFuelType = val!;
                            _selectedLpgTypes.clear();
                            _selectedConnector = null;
                            _selectedOctane = '95';
                            _hasBackupGenerator = false;
                          }),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // PETROL OCTANE
              if (_selectedFuelType == 'Petrol/Diesel') ...[
                const SizedBox(height: 20),
                _sectionLabel('Octane Rating'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'Super (RON 91)',
                    'Super (RON 95)',
                    'V-Power',
                    'Excellium'
                  ].map((o) {
                    return ChoiceChip(
                      label: Text(o),
                      selected: _selectedOctane == o,
                      selectedColor: _brandGreen,
                      labelStyle: TextStyle(
                        color: _selectedOctane == o
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selectedOctane = o),
                    );
                  }).toList(),
                ),
              ],

              // LPG TYPE
              if (_selectedFuelType == 'LPG') ...[
                const SizedBox(height: 20),
                _sectionLabel('LPG Type Offered'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Autogas', 'Cylinder Refill'].map((t) {
                    final isSelected = _selectedLpgTypes.contains(t);
                    return FilterChip(
                      avatar: Icon(
                        t == 'Autogas'
                            ? Icons.directions_car
                            : Icons.propane_tank,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.blue.shade600,
                      ),
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLpgTypes.add(t);
                          } else {
                            _selectedLpgTypes.remove(t);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _deliveryAvailable,
                      onChanged: (val) =>
                          setState(() => _deliveryAvailable = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Home Delivery Available',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              // EV SECTION
              if (_selectedFuelType == 'EV') ...[
                const SizedBox(height: 20),
                _sectionLabel('Connector Type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    'CCS', 'Type 2', 'CHAdeMO', 'Tesla', 'Type 1', 'GB/T'
                  ].map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: _selectedConnector == c,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedConnector == c
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) => setState(() => _selectedConnector = c),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                _sectionLabel('Charger Power Output'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '7.4 kW', '11 kW', '22 kW', '50 kW',
                    '100 kW', '150 kW', '350 kW',
                  ].map((power) {
                    return ChoiceChip(
                      avatar: Icon(
                        Icons.bolt,
                        size: 14,
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.green.shade600,
                      ),
                      label: Text(power),
                      selected: _selectedPowerOutput == power,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(
                        color: _selectedPowerOutput == power
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedPowerOutput = power),
                    );
                  }).toList(),
                ),

                // BACKUP GENERATOR TOGGLE (EV only)
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasBackupGenerator,
                      onChanged: (val) =>
                          setState(() => _hasBackupGenerator = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Has Backup Generator',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              // PHOTO UPLOAD SECTION
              const SizedBox(height: 20),
              _sectionLabel(
                _selectedPhotos.isEmpty
                    ? 'Add Photos (Optional, max 4)'
                    : 'Photos  •  ${_selectedPhotos.length}/4',
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedPhotos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photo = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(photo.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedPhotos.length < 4)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey[500],
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PRICE
              _sectionLabel('Current Price'),
              const SizedBox(height: 8),
              _textField(
                controller: _priceController,
                hint: 'e.g. 14.80',
                keyboard: const TextInputType.numberWithOptions(decimal: true),
                suffix: _selectedFuelType == 'EV'
                    ? 'GH₵/kWh'
                    : _selectedFuelType == 'LPG'
                        ? 'GH₵/kg'
                        : 'GH₵/L',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter current price'
                    : null,
              ),

              const SizedBox(height: 20),

              // PHONE
              _sectionLabel('Phone Number'),
              const SizedBox(height: 8),
              _textField(
                controller: _phoneController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),

              const SizedBox(height: 20),

              // WHATSAPP
              _sectionLabel('WhatsApp Number (Optional)'),
              const SizedBox(height: 8),
              _textField(
                controller: _whatsappController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // LOCATION
              _sectionLabel('Station Location (GPS Coordinates)'),
              const SizedBox(height: 4),
              const Text(
                'Open Google Maps, long press your station location and copy the coordinates',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _latController,
                      hint: 'Latitude e.g. 5.6037',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      controller: _lngController,
                      hint: 'Longitude e.g. -0.1870',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isUploading) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting || _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Submit Station',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandGreen, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_state.dart';
import 'api_service.dart';

class AddStationScreen extends StatefulWidget {
  const AddStationScreen({super.key});

  @override
  State<AddStationScreen> createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _lpgPriceController = TextEditingController();

  // FUEL TYPE SELECTION
  String _selectedFuelType = 'Petrol/Diesel';

  // PETROL OPTIONS (Multiple octane ratings)
  bool _sellsPetrol = true;
  List<Map<String, dynamic>> _petrolOctanes = [
    {'name': 'RON 91', 'price': '', 'inStock': true},
    {'name': 'RON 95', 'price': '', 'inStock': true},
  ];

  // DIESEL OPTIONS (Separate from petrol)
  bool _sellsDiesel = false;
  List<Map<String, dynamic>> _dieselTypes = [
    {'name': 'Regular Diesel', 'price': '', 'inStock': true},
  ];

  // LPG OPTIONS (Simplified - no cylinder sizes)
  final Set<String> _selectedLpgTypes = {};
  bool _deliveryAvailable = false;

  // EV OPTIONS (Multiple charging points)
  List<Map<String, dynamic>> _chargingPoints = [
    {'connector': 'CCS', 'power': '150', 'price': '', 'available': true},
  ];
  bool _hasBackupGenerator = false;

  // PHOTO UPLOAD
  final List<XFile> _selectedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isSubmitting = false;

  // ========== HELPER FUNCTIONS ==========

  // PETROL - Add octane rating
  void _addPetrolOctane() {
    setState(() {
      _petrolOctanes.add({'name': '', 'price': '', 'inStock': true});
    });
  }

  void _removePetrolOctane(int index) {
    setState(() {
      _petrolOctanes.removeAt(index);
    });
  }

  // DIESEL - Add diesel type
  void _addDieselType() {
    setState(() {
      _dieselTypes.add({'name': '', 'price': '', 'inStock': true});
    });
  }

  void _removeDieselType(int index) {
    setState(() {
      _dieselTypes.removeAt(index);
    });
  }

  // EV - Add charging point
  void _addChargingPoint() {
    setState(() {
      _chargingPoints.add({'connector': 'CCS', 'power': '150', 'price': '', 'available': true});
    });
  }

  void _removeChargingPoint(int index) {
    setState(() {
      _chargingPoints.removeAt(index);
    });
  }

  // PHOTO PICKER
  Future<void> _pickPhotos() async {
    if (_selectedPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 4 photos allowed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Add Photo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _brandGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: _brandGreen),
                  ),
                  title: const Text(
                    'Take a photo',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.photo_library, color: Colors.blue.shade600),
                  ),
                  title: const Text(
                    'Choose from gallery',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (photo == null) return;
    if (!mounted) return;

    setState(() {
      _selectedPhotos.add(photo);
    });
  }

  // REMOVE PHOTO
  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  // UPLOAD PHOTOS TO CLOUDINARY
  Future<List<String>> _uploadPhotos() async {
    if (_selectedPhotos.isEmpty) return [];

    setState(() => _isUploading = true);

    try {
      final photoUrls = await ApiService.uploadMultiplePhotosToCloudinary(
        photos: _selectedPhotos,
      );
      print('Upload successful, URLs: $photoUrls');
      return photoUrls;
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload photos: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return [];
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // SUBMIT
  /*Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate fuel type specific fields
    if (_selectedFuelType == 'LPG' && _selectedLpgTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one LPG type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedFuelType == 'EV' && _chargingPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one charging point'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final photoUrls = await _uploadPhotos();

      /*final Map<String, dynamic> newStation = {
        'name': _nameController.text.trim(),
        'type': _selectedFuelType,
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'status': 'Open',
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'photos': photoUrls.isNotEmpty ? photoUrls : [],
      };

      // Add fuel type specific fields (Premium)
      if (_selectedFuelType == 'Petrol/Diesel') {
        // Petrol data
        if (_sellsPetrol && _petrolOctanes.isNotEmpty) {
          newStation['petrol'] = {
            'available': true,
            'octane_ratings': _petrolOctanes.map((o) => {
              'name': o['name'],
              'price': double.tryParse(o['price']) ?? 0,
              'in_stock': o['inStock'],
            }).toList(),
          };
        }
        
        // Diesel data
        if (_sellsDiesel && _dieselTypes.isNotEmpty) {
          newStation['diesel'] = {
            'available': true,
            'diesel_types': _dieselTypes.map((d) => {
              'name': d['name'],
              'price': double.tryParse(d['price']) ?? 0,
              'in_stock': d['inStock'],
            }).toList(),
          };
        }
        
        // Fallback simple price for backward compatibility
        if (_sellsPetrol && _petrolOctanes.isNotEmpty && _petrolOctanes[0]['price'].isNotEmpty) {
          newStation['price'] = 'GH₵ ${_petrolOctanes[0]['price']}/L';
        }
        
      } else if (_selectedFuelType == 'LPG') {
        newStation['lpg_type'] = _selectedLpgTypes.toList();
        newStation['price'] = 'GH₵ ${_lpgPriceController.text.trim()}/kg';
        newStation['delivery_available'] = _deliveryAvailable;
        
      } else if (_selectedFuelType == 'EV') {
        newStation['charging_points'] = _chargingPoints.map((c) => {
          'connector': c['connector'],
          'power_kw': int.tryParse(c['power']) ?? 0,
          'price_per_kwh': double.tryParse(c['price']) ?? 0,
          'available': c['available'],
        }).toList();
        newStation['has_backup_generator'] = _hasBackupGenerator;
        
        // Fallback price
        if (_chargingPoints.isNotEmpty && _chargingPoints[0]['price'].isNotEmpty) {
          newStation['price'] = 'GH₵ ${_chargingPoints[0]['price']}/kWh';
        }
      }*/
  final Map<String, dynamic> newStation = {
  'name': _nameController.text.trim(),
  'type': _selectedFuelType,
  'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
  'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
  'status': 'Open',
  'phone': _phoneController.text.trim(),
  'whatsapp': _whatsappController.text.trim(),
  'photos': photoUrls.isNotEmpty ? photoUrls : [],
};

// Add fuel type specific fields - CORRECT FORMAT
if (_selectedFuelType == 'Petrol/Diesel') {
  // Petrol data - send as 'petrol_data'
  if (_sellsPetrol && _petrolOctanes.isNotEmpty) {
    newStation['petrol_data'] = {  // ← FIXED: use 'petrol_data'
      'petrol': {  // ← FIXED: wrap in 'petrol' object
        'available': true,
        'octane_ratings': _petrolOctanes.map((o) => {
          'name': o['name'],
          'price': double.tryParse(o['price']) ?? 0,
          'in_stock': o['inStock'],
        }).toList(),
      }
    };
  }
  
  // Diesel data - send as part of petrol_data
  if (_sellsDiesel && _dieselTypes.isNotEmpty) {
    if (newStation['petrol_data'] == null) {
      newStation['petrol_data'] = {};
    }
    newStation['petrol_data']['diesel'] = {  // ← FIXED: add diesel inside petrol_data
      'available': true,
      'diesel_types': _dieselTypes.map((d) => ({
        'name': d['name'],
        'price': double.tryParse(d['price']) ?? 0,
        'in_stock': d['inStock'],
      })).toList(),
    };
  }
  
  // Fallback simple price
  if (_sellsPetrol && _petrolOctanes.isNotEmpty && _petrolOctanes[0]['price'].isNotEmpty) {
    newStation['price'] = 'GH₵ ${_petrolOctanes[0]['price']}/L';
  }
  
} else if (_selectedFuelType == 'LPG') {
  newStation['lpg_type'] = _selectedLpgTypes.toList();
  newStation['price'] = 'GH₵ ${_lpgPriceController.text.trim()}/kg';
  newStation['delivery_available'] = _deliveryAvailable;
  
} else if (_selectedFuelType == 'EV') {
  // EV data - send as 'ev_data'
  newStation['ev_data'] = _chargingPoints.map((c) => {  // ← FIXED: use 'ev_data'
    'connector': c['connector'],
    'power_kw': int.tryParse(c['power']) ?? 0,
    'price_per_kwh': double.tryParse(c['price']) ?? 0,
    'available': c['available'],
  }).toList();
  newStation['has_backup_generator'] = _hasBackupGenerator;
  
  // Fallback price
  if (_chargingPoints.isNotEmpty && _chargingPoints[0]['price'].isNotEmpty) {
    newStation['price'] = 'GH₵ ${_chargingPoints[0]['price']}/kWh';
  }
}


 

      final token = AuthState.instance.token ?? '';
      await ApiService.addStation(
        token: token,
        station: newStation,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station submitted! Pending approval from admin.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, newStation);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }*/

// SUBMIT
Future<void> _submit() async {
  if (!_formKey.currentState!.validate()) return;

  // Validate fuel type specific fields
  if (_selectedFuelType == 'LPG' && _selectedLpgTypes.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select at least one LPG type'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  if (_selectedFuelType == 'EV' && _chargingPoints.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please add at least one charging point'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  setState(() => _isSubmitting = true);

  try {
    final photoUrls = await _uploadPhotos();

    final Map<String, dynamic> newStation = {
      'name': _nameController.text.trim(),
      'type': _selectedFuelType,
      'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
      'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
      'status': 'Open',
      'phone': _phoneController.text.trim(),
      'whatsapp': _whatsappController.text.trim(),
      'photos': photoUrls.isNotEmpty ? photoUrls : [],
    };

    // Add fuel type specific fields
    if (_selectedFuelType == 'Petrol/Diesel') {
      // PETROL data - goes to petrol_data field
      if (_sellsPetrol && _petrolOctanes.isNotEmpty) {
        newStation['petrol_data'] = {
          'available': true,
          'octane_ratings': _petrolOctanes.map((o) => {
            'name': o['name'],
            'price': double.tryParse(o['price']) ?? 0,
            'in_stock': o['inStock'],
          }).toList(),
        };
      }
      
      // DIESEL data - goes to diesel_data field (SEPARATE!)
      if (_sellsDiesel && _dieselTypes.isNotEmpty) {
        newStation['diesel_data'] = {
          'available': true,
          'diesel_types': _dieselTypes.map((d) => {
            'name': d['name'],
            'price': double.tryParse(d['price']) ?? 0,
            'in_stock': d['inStock'],
          }).toList(),
        };
      }
      
      // Fallback simple price
      if (_sellsPetrol && _petrolOctanes.isNotEmpty && _petrolOctanes[0]['price'].isNotEmpty) {
        newStation['price'] = 'GH₵ ${_petrolOctanes[0]['price']}/L';
      }
      
    } else if (_selectedFuelType == 'LPG') {
      newStation['lpg_type'] = _selectedLpgTypes.toList();
      newStation['price'] = 'GH₵ ${_lpgPriceController.text.trim()}/kg';
      newStation['delivery_available'] = _deliveryAvailable;
      
    } else if (_selectedFuelType == 'EV') {
      // EV data - goes to ev_data field
      newStation['ev_data'] = _chargingPoints.map((c) => {
        'connector': c['connector'],
        'power_kw': int.tryParse(c['power']) ?? 0,
        'price_per_kwh': double.tryParse(c['price']) ?? 0,
        'available': c['available'],
      }).toList();
      newStation['has_backup_generator'] = _hasBackupGenerator;
      
      // Fallback price
      if (_chargingPoints.isNotEmpty && _chargingPoints[0]['price'].isNotEmpty) {
        newStation['price'] = 'GH₵ ${_chargingPoints[0]['price']}/kWh';
      }
    }

    print("=== SENDING DATA TO BACKEND ===");
    //print(jsonEncode(newStation));

    final token = AuthState.instance.token ?? '';
    await ApiService.addStation(
      token: token,
      station: newStation,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Station submitted! Pending approval from admin.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context, newStation);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString().replaceAll('Exception: ', '')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
      ),
    );
  } finally {
    if (mounted) setState(() => _isSubmitting = false);
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Add My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // INFO BANNER
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue.shade600, size: 20),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your station will be reviewed before appearing on the map.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // STATION NAME
              _sectionLabel('Station Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'e.g. GOIL Spintex Road',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter station name'
                    : null,
              ),

              const SizedBox(height: 20),

              // FUEL TYPE
              _sectionLabel('Fuel Type'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Column(
                  children: ['Petrol/Diesel', 'LPG', 'EV'].map((type) {
                    final isLast = type == 'EV';
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(type,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          value: type,
                          groupValue: _selectedFuelType,
                          activeColor: _brandGreen,
                          onChanged: (val) => setState(() {
                            _selectedFuelType = val!;
                            _selectedLpgTypes.clear();
                            _hasBackupGenerator = false;
                          }),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        if (!isLast)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // ========== PETROL/DIESEL PREMIUM SECTION ==========
              if (_selectedFuelType == 'Petrol/Diesel') ...[
                const SizedBox(height: 20),
                
                // PETROL SECTION
                Row(
                  children: [
                    Checkbox(
                      value: _sellsPetrol,
                      onChanged: (val) => setState(() => _sellsPetrol = val ?? true),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Sells Petrol',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                if (_sellsPetrol) ...[
                  const SizedBox(height: 8),
                  _sectionLabel('Octane Ratings (with prices)'),
                  const SizedBox(height: 8),
                  
                  ..._petrolOctanes.asMap().entries.map((entry) {
                    int index = entry.key;
                    var octane = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: octane['name'],
                                  decoration: const InputDecoration(
                                    labelText: 'Octane Name',
                                    hintText: 'e.g. RON 91, RON 95, V-Power',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _petrolOctanes[index]['name'] = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removePetrolOctane(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: octane['price'],
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    hintText: 'e.g. 14.80',
                                    suffixText: 'GH₵/L',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      _petrolOctanes[index]['price'] = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: octane['inStock'],
                                    onChanged: (val) {
                                      setState(() {
                                        _petrolOctanes[index]['inStock'] = val ?? true;
                                      });
                                    },
                                    activeColor: _brandGreen,
                                  ),
                                  const Text('In Stock'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  TextButton.icon(
                    onPressed: _addPetrolOctane,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Octane Rating'),
                    style: TextButton.styleFrom(
                      foregroundColor: _brandGreen,
                    ),
                  ),
                ],
                
                const Divider(height: 32),
                
                // DIESEL SECTION
                Row(
                  children: [
                    Checkbox(
                      value: _sellsDiesel,
                      onChanged: (val) => setState(() => _sellsDiesel = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Sells Diesel',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                
                if (_sellsDiesel) ...[
                  const SizedBox(height: 8),
                  _sectionLabel('Diesel Types (with prices)'),
                  const SizedBox(height: 8),
                  
                  ..._dieselTypes.asMap().entries.map((entry) {
                    int index = entry.key;
                    var diesel = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: diesel['name'],
                                  decoration: const InputDecoration(
                                    labelText: 'Diesel Type',
                                    hintText: 'e.g. Regular Diesel, Premium Diesel, Biodiesel',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _dieselTypes[index]['name'] = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeDieselType(index),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: diesel['price'],
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    hintText: 'e.g. 16.20',
                                    suffixText: 'GH₵/L',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      _dieselTypes[index]['price'] = val;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  Checkbox(
                                    value: diesel['inStock'],
                                    onChanged: (val) {
                                      setState(() {
                                        _dieselTypes[index]['inStock'] = val ?? true;
                                      });
                                    },
                                    activeColor: _brandGreen,
                                  ),
                                  const Text('In Stock'),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                  
                  TextButton.icon(
                    onPressed: _addDieselType,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Diesel Type'),
                    style: TextButton.styleFrom(
                      foregroundColor: _brandGreen,
                    ),
                  ),
                ],
              ],

              // ========== LPG SECTION (Simplified) ==========
              if (_selectedFuelType == 'LPG') ...[
                const SizedBox(height: 20),
                _sectionLabel('LPG Type Offered'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Autogas', 'Cylinder Refill'].map((t) {
                    final isSelected = _selectedLpgTypes.contains(t);
                    return FilterChip(
                      avatar: Icon(
                        t == 'Autogas'
                            ? Icons.directions_car
                            : Icons.propane_tank,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.blue.shade600,
                      ),
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedLpgTypes.add(t);
                          } else {
                            _selectedLpgTypes.remove(t);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _sectionLabel('Price'),
                const SizedBox(height: 8),
                _textField(
                  controller: _lpgPriceController,
                  hint: 'e.g. 12.70',
                  keyboard: TextInputType.number,
                  suffix: 'GH₵/kg',
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Please enter price per kg'
                      : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _deliveryAvailable,
                      onChanged: (val) =>
                          setState(() => _deliveryAvailable = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Home Delivery Available',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              // ========== EV PREMIUM SECTION ==========
              if (_selectedFuelType == 'EV') ...[
                const SizedBox(height: 20),
                _sectionLabel('Charging Points'),
                const SizedBox(height: 8),
                
                ..._chargingPoints.asMap().entries.map((entry) {
                  int index = entry.key;
                  var point = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: point['connector'],
                                decoration: const InputDecoration(
                                  labelText: 'Connector Type',
                                  border: OutlineInputBorder(),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'CCS', child: Text('CCS')),
                                  DropdownMenuItem(value: 'Type 2', child: Text('Type 2')),
                                  DropdownMenuItem(value: 'CHAdeMO', child: Text('CHAdeMO')),
                                  DropdownMenuItem(value: 'Tesla', child: Text('Tesla')),
                                  DropdownMenuItem(value: 'Type 1', child: Text('Type 1')),
                                  DropdownMenuItem(value: 'GB/T', child: Text('GB/T')),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _chargingPoints[index]['connector'] = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeChargingPoint(index),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: point['power'],
                                decoration: const InputDecoration(
                                  labelText: 'Power Output',
                                  hintText: 'e.g. 50, 150, 350',
                                  suffixText: 'kW',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    _chargingPoints[index]['power'] = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: point['price'],
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  hintText: 'e.g. 5.50',
                                  suffixText: 'GH₵/kWh',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    _chargingPoints[index]['price'] = val;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: point['available'],
                                  onChanged: (val) {
                                    setState(() {
                                      _chargingPoints[index]['available'] = val ?? true;
                                    });
                                  },
                                  activeColor: _brandGreen,
                                ),
                                const Text('Available'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                
                TextButton.icon(
                  onPressed: _addChargingPoint,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Charging Point'),
                  style: TextButton.styleFrom(
                    foregroundColor: _brandGreen,
                  ),
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _hasBackupGenerator,
                      onChanged: (val) =>
                          setState(() => _hasBackupGenerator = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Has Backup Generator',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],

              // PHOTO UPLOAD SECTION
              const SizedBox(height: 20),
              _sectionLabel(
                _selectedPhotos.isEmpty
                    ? 'Add Photos (Optional, max 4)'
                    : 'Photos  •  ${_selectedPhotos.length}/4',
              ),
              const SizedBox(height: 10),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._selectedPhotos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photo = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(File(photo.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _removePhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (_selectedPhotos.length < 4)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.grey[500],
                                size: 28,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // PHONE
              _sectionLabel('Phone Number'),
              const SizedBox(height: 8),
              _textField(
                controller: _phoneController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter phone number'
                    : null,
              ),

              const SizedBox(height: 20),

              // WHATSAPP
              _sectionLabel('WhatsApp Number (Optional)'),
              const SizedBox(height: 8),
              _textField(
                controller: _whatsappController,
                hint: 'e.g. +233244000000',
                keyboard: TextInputType.phone,
              ),

              const SizedBox(height: 20),

              // LOCATION
              _sectionLabel('Station Location (GPS Coordinates)'),
              const SizedBox(height: 4),
              const Text(
                'Open Google Maps, long press your station location and copy the coordinates',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _textField(
                      controller: _latController,
                      hint: 'Latitude e.g. 5.6037',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      controller: _lngController,
                      hint: 'Longitude e.g. -0.1870',
                      keyboard: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(v.trim()) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSubmitting || _isUploading) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting || _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Submit Station',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandGreen, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _lpgPriceController.dispose();
    super.dispose();
  }
}

