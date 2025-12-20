import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/app_theme.dart';
import '../../../../core/network/file_upload_repository.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/logic/cubit/user_cubit.dart';
import '../../../auth/logic/cubit/user_state.dart';
import '../../../widgets/custom_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditJobSeekerProfileScreen extends StatelessWidget {
  const EditJobSeekerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(UserRepository())..fetchMe(),
      child: const _EditJobSeekerProfileView(),
    );
  }
}

class _EditJobSeekerProfileView extends StatefulWidget {
  const _EditJobSeekerProfileView();

  @override
  State<_EditJobSeekerProfileView> createState() =>
      _EditJobSeekerProfileViewState();
}

class _EditJobSeekerProfileViewState
    extends State<_EditJobSeekerProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _profileImage;
  File? _cvFile;
  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      print('📸 Opening image picker for profile picture');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        print('✅ Profile image selected: ${image.path}');
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    print('🔵 Update profile button clicked');
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    print('✅ Form validation passed');

    // Upload profile picture if selected
    String? profilePictureUrl;
    if (_profileImage != null) {
      try {
        print('📤 Uploading profile picture...');
        final uploadRepo = FileUploadRepository();
        profilePictureUrl = await uploadRepo.uploadFile(_profileImage!);
        print('✅ Profile picture uploaded: $profilePictureUrl');
      } catch (e) {
        print('❌ Failed to upload profile picture: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload profile picture: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
    }

    print('🔵 Calling updateJobSeekerProfile...');
    await context.read<UserCubit>().updateJobSeekerProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          profilePictureUrl: profilePictureUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            print('✅ Profile updated successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profile updated successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is UserError) {
            print('❌ Profile update failed: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
        },
        builder: (context, state) {
          // Initialize form fields when user data is loaded
          if (state is UserLoaded && !_isInitialized) {
            final profile = state.user.jobSeekerProfile;
            if (profile != null) {
              _firstNameController.text = profile.firstName;
              _lastNameController.text = profile.lastName;
              _phoneController.text = profile.phoneNumber ?? '';
              _isInitialized = true;
              print('✅ Form initialized with user data');
            }
          }

          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isUpdating = state is UserUpdating;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppTheme.accentBlue.withOpacity(0.2),
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.accentBlue,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.accentBlue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // First Name Field
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),

                  // Last Name Field
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),

                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 32),

                  // Update Button
                  CustomButton(
                    text: isUpdating ? 'Updating...' : 'Update Profile',
                    isLoading: isUpdating,
                    onPressed: _updateProfile,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
