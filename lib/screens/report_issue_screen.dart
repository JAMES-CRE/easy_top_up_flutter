import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'auth_state.dart';

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
  bool _isSubmitted = false;

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
      case 'unusual_price':
        return 'Unusual Price';
      case 'poor_quality':
        return 'Poor Fuel Quality';
      case 'fuel_shortage':
        return 'Fuel Shortage';
      case 'charger_not_working':
        return 'Charger Not Working';
      case 'slow_charging':
        return 'Charging Slower Than Rated';
      case 'wrong_connector':
        return 'Wrong Connector Type';
      case 'price_higher':
        return 'Price Higher Than Listed';
      case 'damaged_charger':
        return 'Charger Damaged/Vandalized';
      case 'stopped_unexpectedly':
        return 'Charging Stopped Unexpectedly';
      case 'no_backup':
        return 'No Backup Generator';
      case 'leakage':
        return 'Suspected Gas Leakage';
      case 'underfilling':
        return 'Underfilling of Cylinders';
      case 'long_queue':
        return 'Long Queue';
      case 'slow_service':
        return 'Slow Refill Service';
      case 'cylinder_not_available':
        return 'Cylinder Size Not Available';
      default:
        return 'Other';
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

  Future<String?> _uploadPhoto() async {
    if (_selectedPhoto == null) return null;

    setState(() => _isUploadingPhoto = true);

    try {
      final photoUrl = await ApiService.uploadPhotoToCloudinary(
        photo: _selectedPhoto!,
      );
      return photoUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
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

      setState(() {
        _isSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      setState(() => _isSubmitting = false);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedIssue = null;
      _notesController.clear();
      _selectedPhoto = null;
      _isSubmitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: _isSubmitted
          ? _buildSuccessScreen()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── STATION HEADER ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _brandGreen.withOpacity(0.12),
                          ),
                          child: Icon(
                            Icons.local_gas_station,
                            color: _brandGreen,
                            size: 24,
                          ),
                        ),
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
                                station['address'] ??
                                    '${station['type'] ?? 'Fuel'} Station',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // WHAT'S THE ISSUE 
                  Text(
                    'What\'s the issue?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _issueTypes.map((issue) {
                      final isSelected = _selectedIssue == issue;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIssue = issue;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? _brandGreen : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected ? _brandGreen : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            _getDisplayName(issue),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_selectedIssue == null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Please select an issue type',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // DESCRIPTION
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Describe what happened in detail',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: 'Tell us what happened...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _brandGreen, width: 2),
                      ),
                      counterStyle: TextStyle(color: Colors.grey[400]),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //  PHOTO EVIDENCE
                  Text(
                    'Photo Evidence',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optional — helps us verify the issue faster',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _selectedPhoto != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedPhoto!.path),
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => setState(() => _selectedPhoto = null),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : OutlinedButton.icon(
                            onPressed: _pickPhoto,
                            icon: Icon(
                              Icons.add_photo_alternate,
                              color: _brandGreen,
                              size: 20,
                            ),
                            label: Text(
                              'Add Photo',
                              style: TextStyle(color: _brandGreen),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 48),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                  if (_isUploadingPhoto)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Uploading photo...',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // SUBMIT BUTTON 
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: (_isSubmitting || _isUploadingPhoto)
                          ? null
                          : _submitReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting || _isUploadingPhoto
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Submit Report',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSuccessScreen() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade50,
            ),
            child: Icon(
              Icons.check,
              color: _brandGreen,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Report Submitted!',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thank you for your report. The station operator\nhas been notified.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {
                _resetForm();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: _brandGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back to Station',
                style: TextStyle(
                  color: _brandGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}