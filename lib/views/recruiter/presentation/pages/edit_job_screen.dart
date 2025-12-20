import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/category.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job.dart';
import 'package:flutter_alinfo9/views/jobs/data/models/job_request.dart';
import 'package:flutter_alinfo9/views/jobs/data/repositories/job_repository.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/create_job_cubit.dart';
import 'package:flutter_alinfo9/views/recruiter/logic/create_job_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class EditJobScreen extends StatefulWidget {
  final int? jobId;
  const EditJobScreen({Key? key, this.jobId}) : super(key: key);

  @override
  State<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _salaryController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();
  bool _requiresQuiz = false;
  File? _jobImage;
  int? _selectedCategoryId;
  List<Category> _categories = [];
  Job? _currentJob;
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _loadJobData();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final categoriesResponse = await JobRepository().getCategories();
      setState(() {
        _categories = categoriesResponse.content;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load categories: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _loadJobData() async {
    if (widget.jobId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job ID is missing'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final job = await JobRepository().getJobById(widget.jobId!);
      setState(() {
        _currentJob = job;
        _titleController.text = job.title;
        _descriptionController.text = job.description;
        _requirementsController.text = job.requirements ?? '';
        _salaryController.text = job.salary?.toString() ?? '';
        _durationController.text = job.duration ?? '';
        _locationController.text = job.location ?? '';
        _requiresQuiz = job.requiresQuiz;
        _selectedCategoryId = job.category.id;
        if (job.skills != null) {
          _selectedSkills.addAll(job.skills!);
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load job: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _jobImage = File(pickedFile.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category.'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final jobRequest = JobRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        requirements: _requirementsController.text.isEmpty
            ? null
            : _requirementsController.text,
        salary: double.tryParse(_salaryController.text),
        duration: _durationController.text.isEmpty
            ? null
            : _durationController.text,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        categoryId: _selectedCategoryId!,
        requiresQuiz: _requiresQuiz,
        skills: _selectedSkills,
        imageUrl: _currentJob?.imageUrl, // Keep existing image URL
      );

      context.read<CreateJobCubit>().updateJob(
        widget.jobId!,
        jobRequest,
        imageFile: _jobImage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Job')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Job')),
      body: BlocConsumer<CreateJobCubit, CreateJobState>(
        listener: (context, state) {
          if (state is CreateJobSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Job updated successfully!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context, true); // Return true to indicate success
          } else if (state is CreateJobFailure) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Error'),
                content: Text(state.error),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CreateJobLoading;
          return Stack(
            children: [
              SingleChildScrollView(
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
              CustomTextField(
                label: 'Requirements (Optional)',
                hint: 'e.g., 2+ years experience',
                controller: _requirementsController,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Salary (DT)',
                      hint: '50',
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      label: 'Duration',
                      hint: '2 days',
                      controller: _durationController,
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
              Text(
                'Job Image',
                style: TextStyle(
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
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                  child: _jobImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_jobImage!, fit: BoxFit.cover),
                        )
                      : _currentJob?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _currentJob!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              ),
                            )
                          : _buildImagePlaceholder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Required Skills',
                style: TextStyle(
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
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Require Quiz',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Applicants must pass a quiz to apply',
                            style: TextStyle(
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
                text: 'Update Job',
                onPressed: _submitForm,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          size: 40,
        ),
        const SizedBox(height: 8),
        Text(
          _currentJob?.imageUrl != null
              ? 'Tap to change image'
              : 'Upload a picture of the job',
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      hint: const Text('Select Category'),
      onChanged: (int? newValue) {
        setState(() {
          _selectedCategoryId = newValue;
        });
      },
      items: _categories.map<DropdownMenuItem<int>>((Category category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      validator: (value) => value == null ? 'Please select a category' : null,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
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
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.accentBlue : Theme.of(context).dividerColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? AppTheme.accentBlue : null,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
