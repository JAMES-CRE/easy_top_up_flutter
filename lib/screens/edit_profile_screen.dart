
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'api_service.dart';
import 'auth_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  
  XFile? _newProfilePhoto;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AuthState.instance.userName ?? '');
    _emailController = TextEditingController(text: AuthState.instance.userEmail ?? '');
    _currentPhotoUrl = AuthState.instance.userPhotoUrl;
  }

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
                  'Profile Photo',
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
                    child: Icon(Icons.photo_library, color: Colors.blue.shade600),
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
      imageQuality: 80,
      maxWidth: 512,
    );
    
    if (photo != null && mounted) {
      setState(() => _newProfilePhoto = photo);
    }
  }

  /*Future<String?> _uploadProfilePhoto() async {
    if (_newProfilePhoto == null) return null;
    
    setState(() => _isUploadingPhoto = true);
    
    try {
      final token = AuthState.instance.token ?? '';
      final photoUrl = await ApiService.uploadProfilePhoto(
        token: token,
        photo: _newProfilePhoto!,
      );
      return photoUrl;
    } catch (e) {
      print('Upload error: $e');
      return null;
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }*/

Future<String?> _uploadProfilePhoto() async {
  if (_newProfilePhoto == null) return null;
  
  setState(() => _isUploadingPhoto = true);
  
  try {
    final photoUrl = await ApiService.uploadProfilePhoto(
      photo: _newProfilePhoto!,
    );
    return photoUrl;
  } catch (e) {
    print('Upload error: $e');
    return null;
  } finally {
    if (mounted) setState(() => _isUploadingPhoto = false);
  }
}





  

  Future<void> _saveChanges() async {
  final nameChanged = _nameController.text.trim() != AuthState.instance.userName;
  final emailChanged = _emailController.text.trim() != AuthState.instance.userEmail;

  if (!nameChanged && !emailChanged && _newProfilePhoto == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No changes to save')),
    );
    return;
  }

 // setState(() => _isSaving = true);

  try {
    String? photoUrl;
    if (_newProfilePhoto != null) {
      photoUrl = await _uploadProfilePhoto();
    }

    final token = AuthState.instance.token ?? '';
    final updatedUser = await ApiService.updateProfile(
      token: token,
      name: nameChanged ? _nameController.text.trim() : null,
      email: emailChanged ? _emailController.text.trim() : null,
      photoUrl: photoUrl,
    );

    print('Updated user from API: $updatedUser');  // Debug print

    // Extract the full name from response
    String fullName = _nameController.text.trim();
    if (updatedUser['first_name'] != null && updatedUser['last_name'] != null) {
      fullName = '${updatedUser['first_name']} ${updatedUser['last_name']}'.trim();
    }

    // Update AuthState with new values
    AuthState.instance.updateProfile(
      name: fullName,
      email: updatedUser['email'] ?? _emailController.text.trim(),
      photoUrl: photoUrl,
    );

    print('AuthState updated - Name: ${AuthState.instance.userName}');  // Debug print

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );

    Navigator.pop(context, true);

  } catch (e) {
    print('Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
    );
  } finally {
    //if (mounted) setState(() => _isSaving = false);
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
          'Edit Profile',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveChanges,
            child: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            // ── PROFILE PHOTO ──
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: _brandGreen.withOpacity(0.15),
                    backgroundImage: _newProfilePhoto != null
                        ? FileImage(File(_newProfilePhoto!.path))
                        : (_currentPhotoUrl != null
                            ? NetworkImage(_currentPhotoUrl!)
                            : null) as ImageProvider?,
                    child: (_newProfilePhoto == null && _currentPhotoUrl == null)
                        ? Text(
                            (AuthState.instance.userName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _brandGreen,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickPhoto,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _brandGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isUploadingPhoto
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap the camera icon to change photo',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 32),

            // ── FULL NAME ──
            _sectionLabel('Full Name'),
            const SizedBox(height: 8),
            _textField(
              controller: _nameController,
              hint: 'Enter your full name',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            // ── EMAIL ──
            _sectionLabel('Email Address'),
            const SizedBox(height: 8),
            _textField(
              controller: _emailController,
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 40),

            // ── SAVE BUTTON ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _brandGreen, width: 2),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}