/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'auth_state.dart';

class EditStationScreen extends StatefulWidget {
  final Map<String, dynamic> station;

  const EditStationScreen({super.key, required this.station});

  @override
  State<EditStationScreen> createState() => _EditStationScreenState();
}

class _EditStationScreenState extends State<EditStationScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _lpgPricePerKgController = TextEditingController();
  bool _deliveryAvailable = false;
  bool _hasBackupGenerator = false;

  // FUEL TYPE 
  late String _fuelType;

  // LPG OPTIONS 
  Set<String> _selectedLpgTypes = {};

  // EV CONNECTOR 
  String? _selectedConnector;

  // OCTANE (Petrol) 
  String _selectedOctane = '';

  // POWER OUTPUT (EV)
  String? _selectedPowerOutput;

  // PHOTOS
  List<String> _existingPhotoUrls = [];
  final List<XFile> _newPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStationData();
  }

  void _loadStationData() {
    final station = widget.station;

    _fuelType = station['type'] ?? 'Unknown';

    _nameController.text = station['name'] ?? '';
    _phoneController.text = station['phone'] ?? '';
    _whatsappController.text = station['whatsapp'] ?? '';
    _latController.text = (station['lat'] ?? 0.0).toString();
    _lngController.text = (station['lng'] ?? 0.0).toString();
    _lpgPricePerKgController.text = (station['lpg_price_per_kg'] ?? 0.0).toString();

    // Load fuel-type specific data
    if (_fuelType == 'Petrol/Diesel') {
      _selectedOctane = station['octane'] ?? 'SUPER(RON 91)';
    } else if (_fuelType == 'LPG') {
      final lpgTypes = station['lpg_type'];
      if (lpgTypes != null && lpgTypes is List) {
        _selectedLpgTypes = Set<String>.from(lpgTypes);
      }
      _deliveryAvailable = station['delivery_available'] == true;
    } else if (_fuelType == 'EV') {
      _selectedConnector = station['connector'];
      _selectedPowerOutput = station['power_output'];
      _hasBackupGenerator = station['has_backup_generator'] == true;
    }

    // Load existing photos
    final photos = station['photos'];
    if (photos != null && photos is List) {
      _existingPhotoUrls = List<String>.from(photos);
    }
  }

  // PHOTO PICKER 
  Future<void> _pickPhotos() async {
    if (_existingPhotoUrls.length + _newPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 photos allowed')),
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
                const Text('Add Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  title: const Text('Take a photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.photo_library, color: Colors.blue.shade600),
                  ),
                  title: const Text('Choose from gallery'),
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
    setState(() => _newPhotos.add(photo));
  }

  void _removeExistingPhoto(int index) {
    setState(() => _existingPhotoUrls.removeAt(index));
  }

  void _removeNewPhoto(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  /*Future<List<String>> _uploadNewPhotos() async {
    if (_newPhotos.isEmpty) return [];
    setState(() => _isUploading = true);
    try {
      final token = AuthState.instance.token ?? '';
      final photoUrls = await ApiService.uploadPhotos(
        token: token,
        photos: _newPhotos,
      );
      return photoUrls;
    } catch (e) {
      print('Upload error: $e');
      return [];
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }*/


Future<List<String>> _uploadNewPhotos() async {
  if (_newPhotos.isEmpty) return [];

  setState(() => _isUploading = true);

  try {
    // Use direct Cloudinary upload (no backend token needed)
    final photoUrls = await ApiService.uploadMultiplePhotosToCloudinary(
      photos: _newPhotos,
    );
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


  // SAVE CHANGES 
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newPhotoUrls = await _uploadNewPhotos();
      final allPhotoUrls = [..._existingPhotoUrls, ...newPhotoUrls];

      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'type': _fuelType,
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'photos': allPhotoUrls,
      };

      // Add fuel type specific fields 
      if (_fuelType == 'Petrol/Diesel') {
        updatedData['octane'] = _selectedOctane;
      } else if (_fuelType == 'LPG') {
        updatedData['lpg_type'] = _selectedLpgTypes.toList();
        updatedData['delivery_available'] = _deliveryAvailable;
      } else if (_fuelType == 'EV') {
        if (_selectedConnector != null) {
          updatedData['connector'] = _selectedConnector!;
        }
        if (_selectedPowerOutput != null) {
          updatedData['power_output'] = _selectedPowerOutput!;
        }
        updatedData['has_backup_generator'] = _hasBackupGenerator;
      }

      print('=== EDIT STATION DEBUG ===');
      print('Station ID: ${widget.station['id']}');
      print('Fuel type: $_fuelType');
      print('Update data: $updatedData');

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStation(
        token: token,
        stationId: widget.station['id'],
        updatedData: updatedData,
      );

      print('Update successful!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station updated successfully!')),
      );

      Navigator.pop(context, updatedData);
    } catch (e) {
      print('Update error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotos = _existingPhotoUrls.length + _newPhotos.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STATION NAME
              _sectionLabel('Station Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'Station name',
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter station name' : null,
              ),

              const SizedBox(height: 20),

              // FUEL TYPE (readonly)
              _sectionLabel('Fuel Type'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(_fuelType, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              ),

              const SizedBox(height: 20),

              // PETROL OCTANE 
              if (_fuelType == 'Petrol/Diesel') ...[
                _sectionLabel('Octane Rating'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['SUPER(RON 91)', 'PREMIUM(RON 95)', 'V-POWER', 'Excellium'].map((o) {
                    return ChoiceChip(
                      label: Text(o),
                      selected: _selectedOctane == o,
                      selectedColor: _brandGreen,
                      labelStyle: TextStyle(color: _selectedOctane == o ? Colors.white : Colors.black87),
                      onSelected: (_) => setState(() => _selectedOctane = o),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],

              // LPG TYPE 
              if (_fuelType == 'LPG') ...[
                _sectionLabel('LPG Type Offered'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['Autogas', 'Cylinder Refill'].map((t) {
                    final isSelected = _selectedLpgTypes.contains(t);
                    return FilterChip(
                      avatar: Icon(
                        t == 'Autogas' ? Icons.directions_car : Icons.propane_tank,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.blue.shade600,
                      ),
                      label: Text(t),
                      selected: isSelected,
                      selectedColor: Colors.blue.shade600,
                      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) _selectedLpgTypes.add(t);
                          else _selectedLpgTypes.remove(t);
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
                      onChanged: (val) => setState(() => _deliveryAvailable = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text('Home Delivery Available', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // EV CONNECTOR, POWER OUTPUT, BACKUP GENERATOR
              if (_fuelType == 'EV') ...[
                _sectionLabel('Connector Type'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['CCS', 'Type 2', 'CHAdeMO', 'Tesla', 'Type 1', 'GB/T'].map((c) {
                    return ChoiceChip(
                      label: Text(c),
                      selected: _selectedConnector == c,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(color: _selectedConnector == c ? Colors.white : Colors.black87),
                      onSelected: (_) => setState(() => _selectedConnector = c),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                _sectionLabel('Power Output'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['7.4 kW', '11 kW', '22 kW', '50 kW', '100 kW', '150 kW', '350 kW'].map((power) {
                    return ChoiceChip(
                      label: Text(power),
                      selected: _selectedPowerOutput == power,
                      selectedColor: Colors.green.shade600,
                      labelStyle: TextStyle(color: _selectedPowerOutput == power ? Colors.white : Colors.black87),
                      onSelected: (_) => setState(() => _selectedPowerOutput = power),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // BACKUP GENERATOR TOGGLE (EV only)
                Row(
                  children: [
                    Checkbox(
                      value: _hasBackupGenerator,
                      onChanged: (val) => setState(() => _hasBackupGenerator = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text('Has Backup Generator', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // PHOTO SECTION 
              _sectionLabel(totalPhotos == 0 ? 'Add Photos (Optional, max 4)' : 'Photos • $totalPhotos/4'),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingPhotoUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photoUrl = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90, height: 90, margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 14,
                            child: GestureDetector(
                              onTap: () => _removeExistingPhoto(index),
                              child: Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    ..._newPhotos.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photo = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90, height: 90, margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(image: FileImage(File(photo.path)), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 14,
                            child: GestureDetector(
                              onTap: () => _removeNewPhoto(index),
                              child: Container(
                                width: 22, height: 22,
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (totalPhotos < 4)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, color: Colors.grey[500], size: 28),
                              const SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter phone number' : null,
              ),

              const SizedBox(height: 20),

              // WHATSAPP 
              _sectionLabel('WhatsApp Number (Optional)'),
              const SizedBox(height: 8),
              _textField(controller: _whatsappController, hint: 'e.g. +233244000000', keyboard: TextInputType.phone),

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
                      keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _textField(
                      controller: _lngController,
                      hint: 'Longitude e.g. -0.1870',
                      keyboard: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // SAVE BUTTON 
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isUploading) ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving || _isUploading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey, letterSpacing: 1.2),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
    _lpgPricePerKgController.dispose();
    super.dispose();
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'auth_state.dart';
import 'package:flutter/services.dart';

class EditStationScreen extends StatefulWidget {
  final Map<String, dynamic> station;

  const EditStationScreen({super.key, required this.station});

  @override
  State<EditStationScreen> createState() => _EditStationScreenState();
}

class _EditStationScreenState extends State<EditStationScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  final _formKey = GlobalKey<FormState>();

  // TEXT CONTROLLERS
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _lpgPriceController = TextEditingController();

  // FUEL TYPE
  late String _fuelType;

  // PETROL/DIESEL PREMIUM VARIABLES
  bool _sellsPetrol = false;
  List<Map<String, dynamic>> _petrolOctanes = [];

  bool _sellsDiesel = false;
  List<Map<String, dynamic>> _dieselTypes = [];

  // LPG VARIABLES (Simplified)
  Set<String> _selectedLpgTypes = {};
  bool _deliveryAvailable = false;

  // EV PREMIUM VARIABLES
  List<Map<String, dynamic>> _chargingPoints = [];
  bool _hasBackupGenerator = false;

  // PHOTOS
  List<String> _existingPhotoUrls = [];
  final List<XFile> _newPhotos = [];
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadStationData();
  }

  /*void _loadStationData() {
    final station = widget.station;
    _fuelType = station['type'] ?? 'Unknown';

    _nameController.text = station['name'] ?? '';
    _phoneController.text = station['phone'] ?? '';
    _whatsappController.text = station['whatsapp'] ?? '';
    _latController.text = (station['lat'] ?? 0.0).toString();
    _lngController.text = (station['lng'] ?? 0.0).toString();

    // Load PREMIUM PETROL data

    if (station['petrol_data'] != null) {
      _sellsPetrol = station['petrol_data'].get('available', false);
      final octanes = station['petrol_data'].get('octane_ratings');
      if (octanes != null && octanes is List) {
        _petrolOctanes = List<Map<String, dynamic>>.from(octanes.map((o) => ({
              'name': o['name'] ?? '',
              'price': o['price']?.toString() ?? '',
              'inStock': o['in_stock'] ?? true,
            })));
      }
    }

// Load PREMIUM DIESEL data (from diesel_data field - SEPARATE!)
    if (station['diesel_data'] != null) {
      _sellsDiesel = station['diesel_data'].get('available', false);
      final diesels = station['diesel_data'].get('diesel_types');
      if (diesels != null && diesels is List) {
        _dieselTypes = List<Map<String, dynamic>>.from(diesels.map((d) => ({
              'name': d['name'] ?? '',
              'price': d['price']?.toString() ?? '',
              'inStock': d['in_stock'] ?? true,
            })));
      }
    }

    // Load LPG data
    if (_fuelType == 'LPG') {
      final lpgTypes = station['lpg_type'];
      if (lpgTypes != null && lpgTypes is List) {
        _selectedLpgTypes = Set<String>.from(lpgTypes);
      }
      _deliveryAvailable = station['delivery_available'] == true;
      _lpgPriceController.text = _extractPriceNumber(station['price'] ?? '');
    }

    // Load PREMIUM EV data
    if (_fuelType == 'EV') {
      final chargingPoints = station['charging_points'];
      if (chargingPoints != null && chargingPoints is List) {
        _chargingPoints =
            List<Map<String, dynamic>>.from(chargingPoints.map((c) => ({
                  'connector': c['connector'] ?? 'CCS',
                  'power': c['power_kw']?.toString() ?? '150',
                  'price': c['price_per_kwh']?.toString() ?? '',
                  'available': c['available'] ?? true,
                })));
      } else if (station['connector'] != null) {
        // Backward compatibility for old EV stations
        _chargingPoints = [
          {
            'connector': station['connector'],
            'power': station['power_output']?.replaceAll(' kW', '') ?? '150',
            'price': _extractPriceNumber(station['price'] ?? ''),
            'available': true,
          },
        ];
      }
      _hasBackupGenerator = station['has_backup_generator'] == true;
    }

    // Load existing photos
    final photos = station['photos'];
    if (photos != null && photos is List) {
      _existingPhotoUrls = List<String>.from(photos);
    }
  }*/

  void _loadStationData() {
    final station = widget.station;
    _fuelType = station['type'] ?? 'Unknown';

    _nameController.text = station['name'] ?? '';
    _phoneController.text = station['phone'] ?? '';
    _whatsappController.text = station['whatsapp'] ?? '';
    _latController.text = (station['lat'] ?? 0.0).toString();
    _lngController.text = (station['lng'] ?? 0.0).toString();

    // Load PREMIUM PETROL data (from 'petrol' field - API format)
    if (station['petrol'] != null) {
      _sellsPetrol = true;
      final octanes = station['petrol']['octane_ratings'];
      if (octanes != null && octanes is List) {
        _petrolOctanes = List<Map<String, dynamic>>.from(octanes.map((o) => ({
              'name': o['name'] ?? '',
              'price': o['price']?.toString() ?? '',
              'inStock': o['in_stock'] ?? true,
            })));
      }
    } else if (station['petrol_data'] != null) {
      // Fallback for old data format
      _sellsPetrol = station['petrol_data'].get('available', false);
      final octanes = station['petrol_data'].get('octane_ratings');
      if (octanes != null && octanes is List) {
        _petrolOctanes = List<Map<String, dynamic>>.from(octanes.map((o) => ({
              'name': o['name'] ?? '',
              'price': o['price']?.toString() ?? '',
              'inStock': o['in_stock'] ?? true,
            })));
      }
    }

    // Load PREMIUM DIESEL data (from 'diesel' field - API format)
    if (station['diesel'] != null) {
      _sellsDiesel = true;
      final diesels = station['diesel']['diesel_types'];
      if (diesels != null && diesels is List) {
        _dieselTypes = List<Map<String, dynamic>>.from(diesels.map((d) => ({
              'name': d['name'] ?? '',
              'price': d['price']?.toString() ?? '',
              'inStock': d['in_stock'] ?? true,
            })));
      }
    } else if (station['diesel_data'] != null) {
      // Fallback for old data format
      _sellsDiesel = station['diesel_data'].get('available', false);
      final diesels = station['diesel_data'].get('diesel_types');
      if (diesels != null && diesels is List) {
        _dieselTypes = List<Map<String, dynamic>>.from(diesels.map((d) => ({
              'name': d['name'] ?? '',
              'price': d['price']?.toString() ?? '',
              'inStock': d['in_stock'] ?? true,
            })));
      }
    }

    // Load LPG data
    if (_fuelType == 'LPG') {
      final lpgTypes = station['lpg_type'];
      if (lpgTypes != null && lpgTypes is List) {
        _selectedLpgTypes = Set<String>.from(lpgTypes);
      }
      _deliveryAvailable = station['delivery_available'] == true;

      // Extract price number from string like "GH₵ 12.70/kg"
      final priceStr = station['price'] ?? '';
      final match = RegExp(r'[\d.]+').firstMatch(priceStr);
      _lpgPriceController.text = match?.group(0) ?? '';
    }

    // Load PREMIUM EV data (from 'charging_points' field - API format)
    if (_fuelType == 'EV') {
      final chargingPoints = station['charging_points'];
      if (chargingPoints != null && chargingPoints is List) {
        _chargingPoints =
            List<Map<String, dynamic>>.from(chargingPoints.map((c) => ({
                  'connector': c['connector'] ?? 'CCS',
                  'power': c['power_kw']?.toString() ?? '150',
                  'price': c['price_per_kwh']?.toString() ?? '',
                  'available': c['available'] ?? true,
                })));
      } else if (station['ev_data'] != null) {
        // Fallback for old data format
        final evData = station['ev_data'];
        if (evData is List) {
          _chargingPoints = List<Map<String, dynamic>>.from(evData.map((c) => ({
                'connector': c['connector'] ?? 'CCS',
                'power': c['power_kw']?.toString() ?? '150',
                'price': c['price_per_kwh']?.toString() ?? '',
                'available': c['available'] ?? true,
              })));
        }
      }
      _hasBackupGenerator = station['has_backup_generator'] == true;
    }

    // Load existing photos
    final photos = station['photos'];
    if (photos != null && photos is List) {
      _existingPhotoUrls = List<String>.from(photos);
    }
  }

  // Helper to extract number from price string
  String _extractPriceNumber(String priceString) {
    final match = RegExp(r'[\d.]+').firstMatch(priceString);
    return match?.group(0) ?? '';
  }

  // PETROL HELPER FUNCTIONS
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

  // DIESEL HELPER FUNCTIONS
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

  // EV HELPER FUNCTIONS
  void _addChargingPoint() {
    setState(() {
      _chargingPoints.add(
          {'connector': 'CCS', 'power': '150', 'price': '', 'available': true});
    });
  }

  void _removeChargingPoint(int index) {
    setState(() {
      _chargingPoints.removeAt(index);
    });
  }

  // PHOTO PICKER
  Future<void> _pickPhotos() async {
    if (_existingPhotoUrls.length + _newPhotos.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 4 photos allowed')),
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
                const Text('Add Photo',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                  title: const Text('Take a photo'),
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
                  title: const Text('Choose from gallery'),
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
    setState(() => _newPhotos.add(photo));
  }

  void _removeExistingPhoto(int index) {
    setState(() => _existingPhotoUrls.removeAt(index));
  }

  void _removeNewPhoto(int index) {
    setState(() => _newPhotos.removeAt(index));
  }

  Future<List<String>> _uploadNewPhotos() async {
    if (_newPhotos.isEmpty) return [];
    setState(() => _isUploading = true);
    try {
      final photoUrls = await ApiService.uploadMultiplePhotosToCloudinary(
        photos: _newPhotos,
      );
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

  // SAVE CHANGES
  /* Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newPhotoUrls = await _uploadNewPhotos();
      final allPhotoUrls = [..._existingPhotoUrls, ...newPhotoUrls];

      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'type': _fuelType,
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'photos': allPhotoUrls,
      };

      // Add fuel type specific fields
      if (_fuelType == 'Petrol/Diesel') {
        // PETROL data - goes to petrol_data field
        if (_sellsPetrol && _petrolOctanes.isNotEmpty) {
          updatedData['petrol_data'] = {
            'available': true,
            'octane_ratings': _petrolOctanes
                .map((o) => ({
                      'name': o['name'],
                      'price': double.tryParse(o['price']) ?? 0,
                      'in_stock': o['inStock'],
                    }))
                .toList(),
          };
        }

        // DIESEL data - goes to diesel_data field (SEPARATE!)
        if (_sellsDiesel && _dieselTypes.isNotEmpty) {
          updatedData['diesel_data'] = {
            'available': true,
            'diesel_types': _dieselTypes
                .map((d) => ({
                      'name': d['name'],
                      'price': double.tryParse(d['price']) ?? 0,
                      'in_stock': d['inStock'],
                    }))
                .toList(),
          };
        }
      }

      // Add LPG data
      if (_fuelType == 'LPG') {
        updatedData['lpg_type'] = _selectedLpgTypes.toList();
        updatedData['price'] = 'GH₵ ${_lpgPriceController.text.trim()}/kg';
        updatedData['delivery_available'] = _deliveryAvailable;
      }

      // Add PREMIUM EV data
      if (_fuelType == 'EV') {
        updatedData['charging_points'] = _chargingPoints
            .map((c) => {
                  'connector': c['connector'],
                  'power_kw': int.tryParse(c['power']) ?? 0,
                  'price_per_kwh': double.tryParse(c['price']) ?? 0,
                  'available': c['available'],
                })
            .toList();
        updatedData['has_backup_generator'] = _hasBackupGenerator;
      }

      print('=== EDIT STATION DEBUG ===');
      print('Station ID: ${widget.station['id']}');
      print('Fuel type: $_fuelType');
      print('Update data: $updatedData');

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStation(
        token: token,
        stationId: widget.station['id'],
        updatedData: updatedData,
      );

      print('Update successful!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station updated successfully!')),
      );

      Navigator.pop(context, updatedData);
    } catch (e) {
      print('Update error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }*/

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final newPhotoUrls = await _uploadNewPhotos();
      final allPhotoUrls = [..._existingPhotoUrls, ...newPhotoUrls];

      final Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'type': _fuelType,
        'phone': _phoneController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'lat': double.tryParse(_latController.text.trim()) ?? 0.0,
        'lng': double.tryParse(_lngController.text.trim()) ?? 0.0,
        'photos': allPhotoUrls,
      };

      // Add fuel type specific fields using API format
      if (_fuelType == 'Petrol/Diesel') {
        // PETROL data - send as 'petrol' (API expects this)
        if (_sellsPetrol && _petrolOctanes.isNotEmpty) {
          updatedData['petrol'] = {
            'available': true,
            'octane_ratings': _petrolOctanes
                .map((o) => ({
                      'name': o['name'],
                      'price': double.tryParse(o['price']) ?? 0,
                      'in_stock': o['inStock'],
                    }))
                .toList(),
          };
        }

        // DIESEL data - send as 'diesel' (API expects this)
        if (_sellsDiesel && _dieselTypes.isNotEmpty) {
          updatedData['diesel'] = {
            'available': true,
            'diesel_types': _dieselTypes
                .map((d) => ({
                      'name': d['name'],
                      'price': double.tryParse(d['price']) ?? 0,
                      'in_stock': d['inStock'],
                    }))
                .toList(),
          };
        }
      } else if (_fuelType == 'LPG') {
        updatedData['lpg_type'] = _selectedLpgTypes.toList();
        updatedData['price'] = 'GH₵ ${_lpgPriceController.text.trim()}/kg';
        updatedData['delivery_available'] = _deliveryAvailable;
      } else if (_fuelType == 'EV') {
        // EV data - send as 'charging_points' (API expects this)
        updatedData['charging_points'] = _chargingPoints
            .map((c) => ({
                  'connector': c['connector'],
                  'power_kw': int.tryParse(c['power']) ?? 0,
                  'price_per_kwh': double.tryParse(c['price']) ?? 0,
                  'available': c['available'],
                }))
            .toList();
        updatedData['has_backup_generator'] = _hasBackupGenerator;
      }

      print("=== SAVING EDIT DATA ===");
      print(updatedData);

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStation(
        token: token,
        stationId: widget.station['id'],
        updatedData: updatedData,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station updated successfully!')),
      );
      Navigator.pop(context, updatedData);
    } catch (e) {
      print('Update error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPhotos = _existingPhotoUrls.length + _newPhotos.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Edit Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // STATION NAME
              _sectionLabel('Station Name'),
              const SizedBox(height: 8),
              _textField(
                controller: _nameController,
                hint: 'Station name',
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Please enter station name'
                    : null,
              ),

              const SizedBox(height: 20),

              // FUEL TYPE (readonly)
              _sectionLabel('Fuel Type'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(_fuelType,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500)),
              ),

              const SizedBox(height: 20),

              // ========== PETROL/DIESEL PREMIUM SECTION ==========
              if (_fuelType == 'Petrol/Diesel') ...[
                // PETROL SECTION
                Row(
                  children: [
                    Checkbox(
                      value: _sellsPetrol,
                      onChanged: (val) =>
                          setState(() => _sellsPetrol = val ?? true),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Sells Petrol',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                                        _petrolOctanes[index]['inStock'] =
                                            val ?? true;
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
                      onChanged: (val) =>
                          setState(() => _sellsDiesel = val ?? false),
                      activeColor: _brandGreen,
                    ),
                    const Text(
                      'Sells Diesel',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                    hintText:
                                        'e.g. Regular Diesel, Premium Diesel, Biodiesel',
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
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
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
                                        _dieselTypes[index]['inStock'] =
                                            val ?? true;
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

                const SizedBox(height: 20),
              ],

              // ========== LPG SECTION (Simplified) ==========
              if (_fuelType == 'LPG') ...[
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
                          color: isSelected ? Colors.white : Colors.black87),
                      onSelected: (selected) {
                        setState(() {
                          if (selected)
                            _selectedLpgTypes.add(t);
                          else
                            _selectedLpgTypes.remove(t);
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
                    const Text('Home Delivery Available',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
              ],

              // EV SECTION
              if (_fuelType == 'EV') ...[
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
                                  DropdownMenuItem(
                                      value: 'CCS', child: Text('CCS')),
                                  DropdownMenuItem(
                                      value: 'Type 2', child: Text('Type 2')),
                                  DropdownMenuItem(
                                      value: 'CHAdeMO', child: Text('CHAdeMO')),
                                  DropdownMenuItem(
                                      value: 'Tesla', child: Text('Tesla')),
                                  DropdownMenuItem(
                                      value: 'Type 1', child: Text('Type 1')),
                                  DropdownMenuItem(
                                      value: 'GB/T', child: Text('GB/T')),
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
                        /*Row(
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
                  //style: const TextStyle(fontSize: 10),
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    hintText: 'e.g. 5.50',
                    suffixText: 'GH₵/kWh',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                  ],
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
          ),*/

                        Row(
                          children: [
                            // Power Output - narrower
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                initialValue: point['power']?.toString() ?? '',
                                decoration: const InputDecoration(
                                  labelText: 'Power',
                                  hintText: 'kW',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  setState(() {
                                    _chargingPoints[index]['power'] = val ?? '';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Price - wider
                            Expanded(
                              flex: 1,
                              child: TextFormField(
                                initialValue: point['price']?.toString() ?? '',
                                style: const TextStyle(fontSize: 12),
                                decoration: const InputDecoration(
                                  labelText: 'Price',
                                  hintText: '0.00',
                                  suffixText: 'GH₵/kWh',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 10),
                                  labelStyle: TextStyle(fontSize: 10),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d*\.?\d{0,2}$')),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _chargingPoints[index]['price'] = val ?? '';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Availability
                            SizedBox(
                              width: 75,
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: point['available'] ?? true,
                                    onChanged: (val) {
                                      setState(() {
                                        _chargingPoints[index]['available'] =
                                            val ?? true;
                                      });
                                    },
                                    activeColor: _brandGreen,
                                  ),
                                  const Flexible(
                                    child: Text('Avail',
                                        style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
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

              // PHOTO SECTION
              _sectionLabel(totalPhotos == 0
                  ? 'Add Photos (Optional, max 4)'
                  : 'Photos • $totalPhotos/4'),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._existingPhotoUrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final photoUrl = entry.value;
                      return Stack(
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                  image: NetworkImage(photoUrl),
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _removeExistingPhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    ..._newPhotos.asMap().entries.map((entry) {
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
                                  fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 14,
                            child: GestureDetector(
                              onTap: () => _removeNewPhoto(index),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    if (totalPhotos < 4)
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined,
                                  color: Colors.grey[500], size: 28),
                              const SizedBox(height: 4),
                              Text('Add Photo',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
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
                  keyboard: TextInputType.phone),

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
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
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
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_isSaving || _isUploading) ? null : _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving || _isUploading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white))
                      : const Text('Save Changes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
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
          letterSpacing: 1.2),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
