import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/features/auth/presentation/state/auth_state.dart';
import 'package:vaidya/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

final _emailProvider = Provider<String?>((ref) {
  final s = ref.read(userSessionServiceProvider);
  try {
    return s.getCurrentUserEmail();
  } catch (_) {
    return null;
  }
});

final currentUserProfileProvider = Provider<String?>((ref) {
  final session = ref.read(userSessionServiceProvider);
  try {
    return session.getCurrentUserProfilePicture();
  } catch (_) {
    return null;
  }
});

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  bool _hasChanges = false;

  late String _initialName;
  late String _initialPhone;

  @override
  void initState() {
    super.initState();

    final session = ref.read(userSessionServiceProvider);

    _initialName = session.getCurrentUserFullName() ?? '';
    _initialPhone = '9841002428';

    _nameController = TextEditingController(text: _initialName);
    _phoneController = TextEditingController(text: _initialPhone);

    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed =
        _nameController.text.trim() != _initialName ||
        _phoneController.text.trim() != _initialPhone ||
        _selectedImage != null;

    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------- IMAGE PICKER ----------------

  Future<void> _pickFromCamera() async {
    if (!await Permission.camera.request().isGranted) return;

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _checkChanges();
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _checkChanges();
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Open Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Open Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- SAVE ----------------

  Future<void> _saveChanges() async {
    final session = ref.read(userSessionServiceProvider);
    final userId = session.getCurrentUserId();
    if (userId == null) return;

    final name = _nameController.text.trim();
    final numberStr = _phoneController.text.trim();
    final number = int.tryParse(numberStr);
    final email = session.getCurrentUserEmail();

    await ref.read(authViewModelProvider.notifier).updateProfile(
          userId: userId,
          name: name.isEmpty ? null : name,
          email: email,
          number: number,
          imagePath: _selectedImage?.path,
        );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(_emailProvider) ?? '';
    final profile = ref.watch(currentUserProfileProvider);
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
      }
      if (next.successMessage != null) {
        setState(() {
          _initialName = _nameController.text.trim();
          _initialPhone = _phoneController.text.trim();
          _selectedImage = null;
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
        ref.read(authViewModelProvider.notifier).clearSuccessMessage();
      }
    });

    final isUpdating = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personal Information'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // ---------------- PROFILE CARD ----------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showImagePicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (profile != null
                                    ? NetworkImage(profile) as ImageProvider
                                    : const AssetImage(
                                        'assets/images/avatar_placeholder.png',
                                      )),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text.trim().isEmpty
                              ? 'Your Name'
                              : _nameController.text.trim(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- EDITABLE FIELDS ----------------
            _EditableField(label: 'Full name', controller: _nameController),
            const SizedBox(height: 12),
            _EditableField(
              label: 'Phone',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),

            const Spacer(),

            // ---------------- SAVE BUTTON ----------------
            ElevatedButton(
              onPressed: (_hasChanges && !isUpdating) ? _saveChanges : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hasChanges
                    ? AppColors.primary
                    : AppColors.border,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: _hasChanges ? 2 : 0,
              ),
              child: isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save changes',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  const _EditableField({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),

        // Input field
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true, // reduces vertical height
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
