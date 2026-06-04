import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'auth_state.dart';

/*class ReportIssueScreen extends StatefulWidget {
  final Map<String, dynamic> station;

  const ReportIssueScreen({super.key, required this.station});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  // ── STATE ──
  String? _selectedIssue;
  bool _isLoading = false; // ← moved here where it belongs

  // ── TEXT CONTROLLERS ──
  final TextEditingController _petrolPriceController = TextEditingController();
  final TextEditingController _lpg6kgController = TextEditingController();
  final TextEditingController _lpg14kgController = TextEditingController();
  final TextEditingController _lpg19kgController = TextEditingController();
  final TextEditingController _evPriceController = TextEditingController();
  final TextEditingController _evSpeedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // ── PHOTO UPLOAD ──
  final List<XFile> _uploadedPhotos = [];
  final ImagePicker _picker = ImagePicker();

  // ── ISSUE LISTS per fuel type ──
  List<String> get _issueTypes {
    final type = widget.station['type'] ?? '';
    if (type == 'Petrol/Diesel') {
      return [
        'Unusual price',
        'Poor fuel quality',
        'Fuel shortage',
        'Other',
      ];
    } else if (type == 'LPG') {
      return [
        'Unusual prices',
        'Autogas not available',
        'Long queue',
        'Other',
      ];
    } else if (type == 'EV') {
      return [
        'Charger is not working',
        'Price has changed',
        'Connector type is wrong',
        'Charging speed is slower',
        'Other',
      ];
    }
    return ['Other'];
  }

  // ─────────────────────────────────────────
  // VALIDATION
  // ─────────────────────────────────────────

  bool get _isFormValid {
    if (_selectedIssue == null) return false;

    if (_selectedIssue == 'Unusual price') {
      final price = double.tryParse(_petrolPriceController.text.trim());
      if (price == null || price <= 0) return false;
    }

    if (_selectedIssue == 'Unusual prices') {
      final has6kg = _lpg6kgController.text.trim().isNotEmpty;
      final has14kg = _lpg14kgController.text.trim().isNotEmpty;
      final has19kg = _lpg19kgController.text.trim().isNotEmpty;
      if (!has6kg && !has14kg && !has19kg) return false;
    }

    if (_selectedIssue == 'Price has changed') {
      final price = double.tryParse(_evPriceController.text.trim());
      if (price == null || price <= 0) return false;
    }

    if (_selectedIssue == 'Charging speed is slower') {
      if (_evSpeedController.text.trim().isEmpty) return false;
    }

    if (_selectedIssue == 'Other') {
      if (_notesController.text.trim().length < 10) return false;
    }

    return true;
  }

  // ─────────────────────────────────────────
  // HELPER METHODS
  // ─────────────────────────────────────────

  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Colors.amber.shade700;
      case 'LPG':
        return Colors.blue.shade600;
      case 'EV':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Icons.local_gas_station;
      case 'LPG':
        return Icons.gas_meter;
      case 'EV':
        return Icons.electric_bolt;
      default:
        return Icons.help_outline;
    }
  }

  // ── PHOTO PICKER ──
  Future<void> _pickPhoto() async {
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
                      color: _brandGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt, color: _brandGreen),
                  ),
                  title: const Text('Take a photo',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child:
                        Icon(Icons.photo_library, color: Colors.blue.shade600),
                  ),
                  title: const Text('Choose from gallery',
                      style: TextStyle(fontWeight: FontWeight.w500)),
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
    setState(() => _uploadedPhotos.add(photo));
  }

  // ── SECTION LABEL ──
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

  // ── INPUT FIELD ──
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    String? suffix,
    String? prefix,
    TextInputType keyboard =
        const TextInputType.numberWithOptions(decimal: true),
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandGreen, width: 2),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  // ─────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final type = station['type'] ?? 'Unknown';

    return Scaffold(
      // ── APP BAR ──
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Issue',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STATION HEADER CARD ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _fuelColor(type).withValues(alpha: 0.15),
                    ),
                    child: Icon(_fuelIcon(type),
                        color: _fuelColor(type), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station['name'] ?? 'Station',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _fuelColor(type).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _fuelColor(type), width: 1),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _fuelColor(type),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              station['price'] ?? 'N/A',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── ISSUE TYPE SECTION ──
            _sectionLabel('What are you reporting?'),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                children: _issueTypes.map((issue) {
                  final isLast = issue == _issueTypes.last;
                  return Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(issue,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500)),
                        value: issue,
                        groupValue: _selectedIssue,
                        activeColor: _brandGreen,
                        onChanged: (val) => setState(() {
                          _selectedIssue = val;
                          _petrolPriceController.clear();
                          _lpg6kgController.clear();
                          _lpg14kgController.clear();
                          _lpg19kgController.clear();
                          _evPriceController.clear();
                          _evSpeedController.clear();
                          _notesController.clear();
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

            if (_selectedIssue == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please select an issue type',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            const SizedBox(height: 28),

            // ── PETROL — Unusual price ──
            if (_selectedIssue == 'Unusual price') ...[
              _sectionLabel('What is the actual price?'),
              const SizedBox(height: 10),
              _inputField(
                controller: _petrolPriceController,
                hint: 'e.g. 14.80',
                suffix: 'GH₵ / L',
              ),
              const SizedBox(height: 28),
            ],

            // ── LPG — Unusual prices ──
            if (_selectedIssue == 'Unusual prices') ...[
              _sectionLabel('Enter the actual price per cylinder size'),
              const SizedBox(height: 6),
              const Text(
                'Fill in only the sizes available at this station',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const SizedBox(
                    width: 60,
                    child: Text('6 kg',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  Expanded(
                    child: _inputField(
                      controller: _lpg6kgController,
                      hint: 'e.g. 50.00',
                      suffix: 'GH₵',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 60,
                    child: Text('14.5 kg',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  Expanded(
                    child: _inputField(
                      controller: _lpg14kgController,
                      hint: 'e.g. 120.00',
                      suffix: 'GH₵',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(
                    width: 60,
                    child: Text('19 kg',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                  Expanded(
                    child: _inputField(
                      controller: _lpg19kgController,
                      hint: 'e.g. 160.00',
                      suffix: 'GH₵',
                    ),
                  ),
                ],
              ),
              if (_lpg6kgController.text.isEmpty &&
                  _lpg14kgController.text.isEmpty &&
                  _lpg19kgController.text.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Please fill in at least one cylinder size',
                    style: TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              const SizedBox(height: 28),
            ],

            // ── EV — Price has changed ──
            if (_selectedIssue == 'Price has changed') ...[
              _sectionLabel('What is the actual price?'),
              const SizedBox(height: 10),
              _inputField(
                controller: _evPriceController,
                hint: 'e.g. 5.50',
                suffix: 'GH₵ / kWh',
              ),
              const SizedBox(height: 28),
            ],

            // ── EV — Charging speed is slower ──
            if (_selectedIssue == 'Charging speed is slower') ...[
              _sectionLabel('What speed are you actually getting?'),
              const SizedBox(height: 10),
              _inputField(
                controller: _evSpeedController,
                hint: 'e.g. 11',
                suffix: 'kW',
              ),
              const SizedBox(height: 28),
            ],

            // ── PHOTOS ──
            _sectionLabel(
              _uploadedPhotos.isEmpty
                  ? 'Add Photos (Optional)'
                  : 'Photos  •  ${_uploadedPhotos.length}/3',
            ),
            const SizedBox(height: 10),

            SizedBox(
              height: 90,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._uploadedPhotos.asMap().entries.map((entry) {
                    final index = entry.key;
                    final photo = entry.value;
                    return Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2))
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(photo.path),
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(
                                  () => _uploadedPhotos.removeAt(index)),
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (_uploadedPhotos.length < 3)
                    GestureDetector(
                      onTap: _pickPhoto,
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
                            Text('Add',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── NOTES ──
            _sectionLabel(
              _selectedIssue == 'Other'
                  ? 'Describe the issue (required)'
                  : 'Additional Notes (Optional)',
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Add any extra details here...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brandGreen, width: 2),
                ),
                errorText: _selectedIssue == 'Other' &&
                        _notesController.text.isNotEmpty &&
                        _notesController.text.trim().length < 10
                    ? 'Please provide more details (min 10 characters)'
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 40),

            // ── SUBMIT BUTTON ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFormValid
                    ? () async {
                        setState(() => _isLoading = true);

                        try {
                          final Map<String, dynamic> extraData = {};

                          if (_selectedIssue == 'Unusual price') {
                            extraData['petrolPrice'] =
                                _petrolPriceController.text.trim();
                          }
                          if (_selectedIssue == 'Unusual prices') {
                            if (_lpg6kgController.text.isNotEmpty) {
                              extraData['6kg'] = _lpg6kgController.text.trim();
                            }
                            if (_lpg14kgController.text.isNotEmpty) {
                              extraData['14.5kg'] =
                                  _lpg14kgController.text.trim();
                            }
                            if (_lpg19kgController.text.isNotEmpty) {
                              extraData['19kg'] =
                                  _lpg19kgController.text.trim();
                            }
                          }
                          if (_selectedIssue == 'Price has changed') {
                            extraData['evPrice'] =
                                _evPriceController.text.trim();
                          }
                          if (_selectedIssue == 'Charging speed is slower') {
                            extraData['speed'] = _evSpeedController.text.trim();
                          }

                          final token = AuthState.instance.token ?? '';

                          await ApiService.submitReport(
                            token: token,
                            stationId: widget.station['id'],
                            issueType: _selectedIssue!,
                            extraData: extraData,
                            notes: _notesController.text.trim(),
                          );

                          if (!mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Report submitted — thank you!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );

                          Navigator.pop(context);
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                e.toString().replaceAll('Exception: ', ''),
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                // ← closing ) was missing here before
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            // ← SizedBox is now OUTSIDE the button
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _petrolPriceController.dispose();
    _lpg6kgController.dispose();
    _lpg14kgController.dispose();
    _lpg19kgController.dispose();
    _evPriceController.dispose();
    _evSpeedController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}*/

/*class ReportIssueScreen extends StatefulWidget {
  final Map<String, dynamic> station;

  const ReportIssueScreen({super.key, required this.station});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  // ── STATE ──
  String? _selectedIssue;
  //bool _isLoading = false;
  bool _isSubmitting = false;

  // ── PHOTO ──
  XFile? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  // ── TEXT CONTROLLERS ──
  final TextEditingController _notesController = TextEditingController();

  // ── LPG CYLINDER SIZES ──
  String? _selectedCylinderSize;

  // ── ISSUE LISTS per fuel type ──
  List<String> get _issueTypes {
    final type = widget.station['type'] ?? '';
    if (type == 'Petrol/Diesel') {
      return [
        'Unusual price',
        'Poor fuel quality',
        'Fuel shortage',
        'Other',
      ];
    } else if (type == 'LPG') {
      return [
        'Price higher than market rate',
        'Autogas not available',
        'Suspected gas leakage',
        'Underfilling of cylinders',
        'Long queue',
        'Slow refill service',
        'Cylinder size not available',
        'Other',
      ];
    } else if (type == 'EV') {
      return [
        'Charger not working',
        'Charging slower than rated speed',
        'Wrong connector type listed',
        'Price higher than listed',
        'Charger damaged/vandalized',
        'Charging stopped unexpectedly',
        'No backup generator',
        'Other',
      ];
    }
    return ['Other'];
  }

  // ── CHECK IF PHOTO IS REQUIRED ──
  bool get isPhotoRequired {
    if (_selectedIssue == null) return false;

    // Issues that ALWAYS require photo evidence
    final photoRequiredIssues = [
      'Unusual price',
      'Price higher than market rate',
      'Price higher than listed',
      'Underfilling of cylinders',
      'Suspected gas leakage',
      'Charger damaged/vandalized',
      'Charger not working',
      'Poor fuel quality',
    ];

    return photoRequiredIssues.contains(_selectedIssue);
  }

  // VALIDATION 
  bool get _isFormValid {
    if (_selectedIssue == null) return false;

    // Photo is required for most issues
    if (isPhotoRequired && _selectedPhoto == null) return false;

    // LPG cylinder size required for underfilling
    if (_selectedIssue == 'Underfilling of cylinders' &&
        _selectedCylinderSize == null) {
      return false;
    }

    return true;
  }

  // PHOTO PICKER 
  Future<void> _pickPhoto() async {
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
                  'Add Photo Evidence',
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
                  subtitle: Text(
                    isPhotoRequired ? 'Required for this issue' : 'Optional',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  subtitle: Text(
                    isPhotoRequired ? 'Required for this issue' : 'Optional',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

    if (photo != null && mounted) {
      setState(() => _selectedPhoto = photo);
    }
  }

  //  REMOVE PHOTO 
  void _removePhoto() {
    setState(() => _selectedPhoto = null);
  }

  //  UPLOAD PHOTO 
  Future<String?> _uploadPhoto() async {
    if (_selectedPhoto == null) return null;

    try {
      final token = AuthState.instance.token ?? '';
      final photoUrls = await ApiService.uploadPhotos(
        token: token,
        photos: [_selectedPhoto!],
      );
      return photoUrls.isNotEmpty ? photoUrls.first : null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }

  //  SUBMIT REPORT 
  /*Future<void> _submitReport() async {
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload photo first
      String? photoUrl = await _uploadPhoto();
      
      // Build extraData
      final Map<String, dynamic> extraData = {};
      
      if (_selectedIssue == 'Underfilling of cylinders' && _selectedCylinderSize != null) {
        extraData['cylinder_size'] = _selectedCylinderSize;
      }
      
      if (_selectedIssue == 'Unusual price') {
        extraData['issue'] = 'price_concern';
      }
      
      if (_selectedIssue == 'Price higher than market rate') {
        extraData['issue'] = 'lpg_price_concern';
      }
      
      if (_selectedIssue == 'Price higher than listed') {
        extraData['issue'] = 'ev_price_concern';
      }
      
      // Add photo URL to extraData
      if (photoUrl != null) {
        extraData['photo_url'] = photoUrl;
      }

      final token = AuthState.instance.token ?? '';
      await ApiService.submitReport(
        token: token,
        stationId: widget.station['id'],
        issueType: _selectedIssue!,
        extraData: extraData,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted — thank you for helping others!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
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

  Future<void> _submitReport() async {
    if (!_isFormValid) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload photo first
      String? photoUrl = await _uploadPhoto();

      // Build extraData
      final Map<String, dynamic> extraData = {};

      if (_selectedIssue == 'Underfilling of cylinders' &&
          _selectedCylinderSize != null) {
        extraData['cylinder_size'] = _selectedCylinderSize;
      }

      // ADD PHOTO URL TO EXTRA DATA
      if (photoUrl != null && photoUrl.isNotEmpty) {
        extraData['photo_url'] = photoUrl;
        print('Photo URL saved to extraData: $photoUrl');
      }

      final token = AuthState.instance.token ?? '';
      await ApiService.submitReport(
        token: token,
        stationId: widget.station['id'],
        issueType: _selectedIssue!,
        extraData: extraData,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted — thank you for helping others!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
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

  // CYLINDER SIZE SELECTOR 
  Widget _cylinderSizeSelector() {
    final sizes = ['3 kg', '6 kg', '12.5 kg', '14.5 kg', '15 kg', '50/52 kg'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Cylinder Size',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: sizes.map((size) {
            return ChoiceChip(
              label: Text(size),
              selected: _selectedCylinderSize == size,
              selectedColor: _brandGreen,
              labelStyle: TextStyle(
                color: _selectedCylinderSize == size
                    ? Colors.white
                    : Colors.black87,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCylinderSize = selected ? size : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    //final type = station['type'] ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Issue',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── STATION HEADER ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  //const Icon(Icons.local_gas_station,
                     // size: 32, color: _brandGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station['name'] ?? 'Station',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${station['type']} • ${station['price'] ?? 'N/A'}',
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ISSUE TYPE 
            const Text(
              'What issue did you experience?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ..._issueTypes.map((issue) {
              return RadioListTile<String>(
                title: Text(issue),
                value: issue,
                groupValue: _selectedIssue,
                activeColor: _brandGreen,
                onChanged: (val) => setState(() {
                  _selectedIssue = val;
                  _selectedCylinderSize = null;
                }),
                contentPadding: EdgeInsets.zero,
              );
            }),

            if (_selectedIssue == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Please select an issue type',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),

            //  CYLINDER SIZE (LPG only) 
            if (_selectedIssue == 'Underfilling of cylinders') ...[
              _cylinderSizeSelector(),
            ],

            const SizedBox(height: 24),

            //  PHOTO EVIDENCE 
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isPhotoRequired && _selectedPhoto == null
                      ? Colors.red.shade300
                      : Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.camera_alt,
                        color:
                            isPhotoRequired ? Colors.red.shade700 : _brandGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Photo Evidence',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isPhotoRequired
                              ? Colors.red.shade700
                              : Colors.black87,
                        ),
                      ),
                      if (isPhotoRequired) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Required',
                            style: TextStyle(fontSize: 10, color: Colors.red),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPhotoRequired
                        ? 'Please provide a photo to verify this issue (receipt, price board, damage, etc.)'
                        : 'Adding a photo helps us verify the issue faster (recommended)',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  if (_selectedPhoto != null) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_selectedPhoto!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: _removePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon:
                            Icon(Icons.add_photo_alternate, color: _brandGreen),
                        label: Text(
                          isPhotoRequired
                              ? 'Add Photo (Required)'
                              : 'Add Photo (Optional)',
                          style: TextStyle(color: _brandGreen),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pickPhoto,
                      ),
                    ),
                  ],
                  if (isPhotoRequired && _selectedPhoto == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Photo evidence is required for this issue type',
                        style:
                            TextStyle(fontSize: 12, color: Colors.red.shade600),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            //  NOTES 
            const Text(
              'Additional Details (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any extra information that might help...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brandGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            //  SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isFormValid ? _submitReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Submit Report',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}*/



class ReportIssueScreen extends StatefulWidget {
  final Map<String, dynamic> station;

  const ReportIssueScreen({super.key, required this.station});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  String? _selectedIssue;
  final TextEditingController _notesController = TextEditingController();
  XFile? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isUploadingPhoto = false;

  // Issue types based on fuel type
  List<String> get _issueTypes {
    final type = widget.station['type'] ?? '';
    if (type == 'Petrol/Diesel') {
      return [
        'unusual_price',
        'poor_quality',
        'fuel_shortage',
        'other',
      ];
    } else if (type == 'LPG') {
      return [
        'price_higher',
        'leakage',
        'underfilling',
        'long_queue',
        'slow_service',
        'other',
      ];
    } else if (type == 'EV') {
      return [
        'charger_not_working',
        'slow_charging',
        'wrong_connector',
        'price_higher',
        'damaged_charger',
        'stopped_unexpectedly',
        'no_backup',
        'other',
      ];
    }
    return ['other'];
  }

  String _getDisplayName(String issueType) {
    switch (issueType) {
      case 'unusual_price': return 'Unusual Price';
      case 'poor_quality': return 'Poor Fuel Quality';
      case 'fuel_shortage': return 'Fuel Shortage';
      case 'charger_not_working': return 'Charger Not Working';
      case 'slow_charging': return 'Charging Slower Than Rated';
      case 'wrong_connector': return 'Wrong Connector Type';
      case 'price_higher': return 'Price Higher Than Listed';
      case 'damaged_charger': return 'Charger Damaged/Vandalized';
      case 'stopped_unexpectedly': return 'Charging Stopped Unexpectedly';
      case 'no_backup': return 'No Backup Generator';
      case 'leakage': return 'Suspected Gas Leakage';
      case 'underfilling': return 'Underfilling of Cylinders';
      case 'long_queue': return 'Long Queue';
      case 'slow_service': return 'Slow Refill Service';
      case 'cylinder_not_available': return 'Cylinder Size Not Available';
      default: return 'Other';
    }
  }

  Future<void> _pickPhoto() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
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
              const Text('Add Photo Evidence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      ),
    );

    if (source == null) return;
    final XFile? photo = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1024,
    );
    if (photo != null && mounted) {
      setState(() => _selectedPhoto = photo);
    }
  }

  /*Future<String?> _uploadPhoto() async {
    if (_selectedPhoto == null) return null;
    try {
      final token = AuthState.instance.token ?? '';
      final photoUrls = await ApiService.uploadPhotos(
        token: token,
        photos: [_selectedPhoto!],
      );
      return photoUrls.isNotEmpty ? photoUrls.first : null;
    } catch (e) {
      print('Upload error: $e');
      return null;
    }
  }*/

  Future<String?> _uploadPhoto() async {
  if (_selectedPhoto == null) return null;
  
  setState(() => _isUploadingPhoto = true);  // ← Now this works
  
  try {
    // Use direct Cloudinary upload (no backend token needed)
    final photoUrl = await ApiService.uploadPhotoToCloudinary(
      photo: _selectedPhoto!,
    );
    return photoUrl;
  } catch (e) {
    print('Upload error: $e');
    return null;
  } finally {
    if (mounted) setState(() => _isUploadingPhoto = false);  // ← Now this works
  }
}

  

  Future<void> _submitReport() async {
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue type')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? photoUrl = await _uploadPhoto();
      
      final Map<String, dynamic> extraData = {};
      if (photoUrl != null) {
        extraData['photo_url'] = photoUrl;
      }

      final token = AuthState.instance.token ?? '';
      await ApiService.submitReport(
        token: token,
        stationId: widget.station['id'],
        issueType: _selectedIssue!,
        extraData: extraData,
        notes: _notesController.text.trim(),
        photoUrl: photoUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted — thank you!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

/*static Future<void> submitReport({
  required String token,
  required String stationId,
  required String issueType,
  required Map<String, dynamic> extraData,
  required String notes,
  String? photoUrl,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/reports/'),
      headers: authHeaders(token),
      body: jsonEncode({
        'station': stationId,
        'issue_type': issueType,
        'extra_data': extraData,
        'notes': notes,
        'photo_url': photoUrl,
      }),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 201) {
      throw Exception('Failed to submit report');
    }
  } catch (e) {
    throw Exception('$e');
  }
}*/



  @override
  Widget build(BuildContext context) {
    final station = widget.station;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Report Issue',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Station header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_gas_station, size: 32, color: _brandGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(station['name'] ?? 'Station', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${station['type']} • ${station['price'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('What issue did you experience?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._issueTypes.map((issue) {
              return RadioListTile<String>(
                title: Text(_getDisplayName(issue)),
                value: issue,
                groupValue: _selectedIssue,
                activeColor: _brandGreen,
                onChanged: (val) => setState(() => _selectedIssue = val),
                contentPadding: EdgeInsets.zero,
              );
            }),

            const SizedBox(height: 24),

            // Photo evidence
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Photo Evidence (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Adding a photo helps us verify the issue faster', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (_selectedPhoto != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(File(_selectedPhoto!.path), height: 150, width: double.infinity, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8, right: 8,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPhoto = null),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.add_photo_alternate, color: _brandGreen),
                        label: Text('Add Photo', style: TextStyle(color: _brandGreen)),
                        onPressed: _pickPhoto,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text('Additional Details (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any extra information...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _brandGreen, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                    : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    
              ),
            ),
          ],
        ),
      ),
    );
  }
}
