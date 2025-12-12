import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({Key? key}) : super(key: key);

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  bool _requiresQuiz = false;
  File? _jobImage;

  // Skills selection
  final List<String> _availableSkills = [
    'Flutter',
    'Dart',
    'UI/UX',
    'Firebase',
    'React',
    'Node.js',
    'Python',
    'Java',
  ];
  final List<String> _selectedSkills = [];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _jobImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post a Job')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Job Title',
                hint: 'e.g., Web Developer',
                controller: _titleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a job title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Description',
                hint: 'Describe the job requirements and responsibilities',
                controller: _descriptionController,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Salary (DT)',
                      hint: '50',
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter salary';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Duration',
                      hint: '2 days',
                      controller: _durationController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter duration';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Location',
                hint: 'Tunis, Tunisia',
                controller: _locationController,
              ),
              const SizedBox(height: 20),
              const Text(
                'Job Image',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.tertiaryGrey,
                      width: 2,
                    ),
                  ),
                  child: _jobImage != null
                      ? Image.file(_jobImage!, fit: BoxFit.cover)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: AppTheme.textGrey,
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Upload a picture of the job',
                              style: TextStyle(
                                color: AppTheme.textGrey,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Required Skills',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSkills.remove(skill);
                        } else {
                          _selectedSkills.add(skill);
                        }
                      });
                    },
                    child: _SkillChip(label: skill, selected: isSelected),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Require Quiz',
                            style: TextStyle(
                              color: AppTheme.textWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Applicants must pass a quiz to apply',
                            style: TextStyle(
                              color: AppTheme.textGrey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _requiresQuiz,
                      onChanged: (value) =>
                          setState(() => _requiresQuiz = value),
                      activeColor: AppTheme.accentBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Post Job',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Handle job creation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job posted successfully!'),
                        backgroundColor: AppTheme.accentGreen,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final bool selected;

  const _SkillChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.accentBlue.withOpacity(0.2)
            : AppTheme.tertiaryGrey,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.accentBlue : AppTheme.tertiaryGrey,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.accentBlue : AppTheme.textGrey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}