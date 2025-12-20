import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import '../../../../core/network/file_upload_repository.dart';
import '../../../auth/data/repositories/user_repository.dart';
import '../../../auth/logic/cubit/user_cubit.dart';
import '../../../auth/logic/cubit/user_state.dart';
import '../../../widgets/custom_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditRecruiterProfileScreen extends StatelessWidget {
  const EditRecruiterProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(UserRepository())..fetchMe(),
      child: const _EditRecruiterProfileView(),
    );
  }
}

class _EditRecruiterProfileView extends StatefulWidget {
  const _EditRecruiterProfileView();

  @override
  State<_EditRecruiterProfileView> createState() =>
      _EditRecruiterProfileViewState();
}

class _EditRecruiterProfileViewState extends State<_EditRecruiterProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _websiteController = TextEditingController();

  File? _companyLogo;
  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;

  @override
  void dispose() {
    _companyNameController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _pickCompanyLogo() async {
    try {
      print('📸 Opening image picker for company logo');
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _companyLogo = File(image.path);
        });
        print('✅ Company logo selected: ${image.path}');
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
    print('🔵 Update recruiter profile button clicked');
    if (!_formKey.currentState!.validate()) {
      print('❌ Form validation failed');
      return;
    }

    print('✅ Form validation passed');

    // Upload company logo if selected
    String? companyLogoUrl;
    if (_companyLogo != null) {
      try {
        print('📤 Uploading company logo...');
        final uploadRepo = FileUploadRepository();
        companyLogoUrl = await uploadRepo.uploadFile(_companyLogo!);
        print('✅ Company logo uploaded: $companyLogoUrl');
      } catch (e) {
        print('❌ Failed to upload company logo: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload company logo: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }
    }

    print('🔵 Calling updateRecruiterProfile...');
    await context.read<UserCubit>().updateRecruiterProfile(
          companyName: _companyNameController.text.trim(),
          website: _websiteController.text.trim().isEmpty
              ? null
              : _websiteController.text.trim(),
          companyLogoUrl: companyLogoUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Company Profile'),
      ),
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded) {
            print('✅ Recruiter profile updated successfully');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profile updated successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is UserError) {
            print('❌ Recruiter profile update failed: ${state.message}');
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
            final profile = state.user.recruiterProfile;
            if (profile != null) {
              _companyNameController.text = profile.companyName;
              _websiteController.text = profile.website ?? '';
              _isInitialized = true;
              print('✅ Form initialized with recruiter data');
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
                  // Company Logo Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            image: _companyLogo != null
                                ? DecorationImage(
                                    image: FileImage(_companyLogo!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _companyLogo == null
                              ? const Icon(
                                  Icons.business,
                                  size: 60,
                                  color: AppTheme.accentBlue,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickCompanyLogo,
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

                  // Company Name Field
                  TextFormField(
                    controller: _companyNameController,
                    decoration: InputDecoration(
                      labelText: 'Company Name',
                      prefixIcon: const Icon(Icons.business_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your company name';
                      }
                      return null;
                    },
                    enabled: !isUpdating,
                  ),
                  const SizedBox(height: 16),

                  // Website Field
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      labelText: 'Website (Optional)',
                      prefixIcon: const Icon(Icons.language_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'https://www.example.com',
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        // Basic URL validation
                        if (!value.startsWith('http://') &&
                            !value.startsWith('https://')) {
                          return 'Please enter a valid URL (starting with http:// or https://)';
                        }
                      }
                      return null;
                    },
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
