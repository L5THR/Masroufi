// lib/views/recruiter/presentation/pages/job_wizard_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_theme.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../quiz/logic/quiz_state.dart';
import '../../../quiz/data/models/quiz_question.dart';
import '../../logic/job_wizard_cubit.dart';
import '../../logic/job_wizard_state.dart';

class JobWizardScreen extends StatefulWidget {
  const JobWizardScreen({super.key});

  @override
  State<JobWizardScreen> createState() => _JobWizardScreenState();
}

class _JobWizardScreenState extends State<JobWizardScreen> {
  // Job Details Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _durationController = TextEditingController();
  final _locationController = TextEditingController();

  // Quiz Controllers
  final _quizTitleController = TextEditingController();

  // Available skills
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

  @override
  void initState() {
    super.initState();
    context.read<JobWizardCubit>().initialize();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _durationController.dispose();
    _locationController.dispose();
    _quizTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null && mounted) {
      context.read<JobWizardCubit>().setImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<JobWizardCubit, JobWizardState>(
      listener: (context, state) {
        // Show error snackbar
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppTheme.errorRed,
            ),
          );
          context.read<JobWizardCubit>().clearError();
        }

        // Show success and navigate back
        if (state.successMessage != null && state.createdJobId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppTheme.successGreen,
            ),
          );
          Navigator.of(context).pop(true); // Return true to indicate success
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(state)),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _showExitConfirmation(context),
            ),
          ),
          body: state.isLoading
              ? _buildLoadingState(state)
              : _buildContent(context, state, isDark),
        );
      },
    );
  }

  String _getAppBarTitle(JobWizardState state) {
    if (state.currentStep == 0) {
      return 'Create Job';
    } else if (state.currentStep == 1 && state.requiresQuiz) {
      return 'Create Quiz';
    }
    return 'Create Job';
  }

  Widget _buildLoadingState(JobWizardState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            state.requiresQuiz
                ? 'Creating job and quiz...'
                : 'Creating job...',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, JobWizardState state, bool isDark) {
    return Column(
      children: [
        // Step Indicator
        _buildStepIndicator(state, isDark),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: state.currentStep == 0
                ? _buildJobDetailsStep(context, state, isDark)
                : _buildQuizStep(context, state, isDark),
          ),
        ),

        // Navigation Buttons
        _buildNavigationButtons(context, state, isDark),
      ],
    );
  }

  Widget _buildStepIndicator(JobWizardState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
        ),
      ),
      child: Row(
        children: [
          // Step 1
          _buildStepChip(
            index: 0,
            label: 'Job Details',
            isActive: state.currentStep == 0,
            isCompleted: state.currentStep > 0,
            isDark: isDark,
          ),

          // Connector
          if (state.requiresQuiz) ...[
            Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: state.currentStep > 0
                    ? AppTheme.accentBlue
                    : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
              ),
            ),

            // Step 2
            _buildStepChip(
              index: 1,
              label: 'Quiz',
              isActive: state.currentStep == 1,
              isCompleted: false,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepChip({
    required int index,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required bool isDark,
  }) {
    final Color backgroundColor;
    final Color textColor;

    if (isActive) {
      backgroundColor = AppTheme.accentBlue;
      textColor = Colors.white;
    } else if (isCompleted) {
      backgroundColor = AppTheme.accentGreen;
      textColor = Colors.white;
    } else {
      backgroundColor =
          isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey;
      textColor = isDark ? AppTheme.textGrey : AppTheme.textDarkGrey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isCompleted)
            const Icon(Icons.check, size: 16, color: Colors.white)
          else
            Text(
              '${index + 1}',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STEP 1: JOB DETAILS ====================

  Widget _buildJobDetailsStep(
      BuildContext context, JobWizardState state, bool isDark) {
    final cubit = context.read<JobWizardCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        CustomTextField(
          label: 'Job Title *',
          hint: 'e.g., Web Developer',
          controller: _titleController,
          onChanged: cubit.updateTitle,
        ),
        const SizedBox(height: 20),

        // Description
        CustomTextField(
          label: 'Description *',
          hint: 'Describe the job requirements and responsibilities',
          controller: _descriptionController,
          maxLines: 4,
          onChanged: cubit.updateDescription,
        ),
        const SizedBox(height: 20),

        // Category
        _buildCategoryDropdown(state, cubit, isDark),
        const SizedBox(height: 20),

        // Salary & Duration
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Salary (DT)',
                hint: '50',
                controller: _salaryController,
                keyboardType: TextInputType.number,
                onChanged: cubit.updateSalary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Duration',
                hint: '2 days',
                controller: _durationController,
                onChanged: cubit.updateDuration,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Location
        CustomTextField(
          label: 'Location',
          hint: 'Tunis, Tunisia',
          controller: _locationController,
          onChanged: cubit.updateLocation,
        ),
        const SizedBox(height: 20),

        // Image Picker
        _buildImagePicker(state, isDark),
        const SizedBox(height: 20),

        // Skills
        _buildSkillsSection(state, cubit, isDark),
        const SizedBox(height: 20),

        // Requires Quiz Toggle
        _buildQuizToggle(state, cubit, isDark),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryDropdown(
      JobWizardState state, JobWizardCubit cubit, bool isDark) {
    if (state.categoriesLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownButtonFormField<int>(
      value: state.categoryId,
      hint: const Text('Select Category *'),
      decoration: InputDecoration(
        labelText: 'Category *',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: state.categories.map((category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: cubit.updateCategory,
    );
  }

  Widget _buildImagePicker(JobWizardState state, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
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
              color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
                width: 2,
              ),
            ),
            child: state.imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(state.imageFile!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 40,
                        color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to upload a picture',
                        style: TextStyle(
                          color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(
      JobWizardState state, JobWizardCubit cubit, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
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
            final isSelected = state.selectedSkills.contains(skill);
            return GestureDetector(
              onTap: () => cubit.toggleSkill(skill),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentBlue.withAlpha(51)
                      : (isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentBlue
                        : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
                  ),
                ),
                child: Text(
                  skill,
                  style: TextStyle(
                    color: isSelected ? AppTheme.accentBlue : null,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuizToggle(
      JobWizardState state, JobWizardCubit cubit, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: state.requiresQuiz
            ? Border.all(color: AppTheme.accentBlue, width: 2)
            : null,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Applicants must pass a quiz to apply',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: state.requiresQuiz,
            onChanged: cubit.toggleRequiresQuiz,
            activeColor: AppTheme.accentBlue,
          ),
        ],
      ),
    );
  }

  // ==================== STEP 2: QUIZ ====================

  Widget _buildQuizStep(
      BuildContext context, JobWizardState state, bool isDark) {
    final cubit = context.read<JobWizardCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Summary
        _buildJobSummary(state, isDark),
        const SizedBox(height: 20),

        // Quiz Title
        CustomTextField(
          label: 'Quiz Title *',
          hint: 'e.g., Flutter Developer Assessment',
          controller: _quizTitleController,
          onChanged: cubit.updateQuizTitle,
        ),
        const SizedBox(height: 20),

        // Questions
        if (state.questions.isEmpty)
          _buildEmptyQuestionsState(isDark)
        else
          ...state.questions.asMap().entries.map((entry) {
            return _QuestionCard(
              questionIndex: entry.key,
              question: entry.value,
              cubit: cubit,
            );
          }),

        // Add Question Button
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: cubit.addQuestion,
          icon: const Icon(Icons.add),
          label: const Text('Add Question'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildJobSummary(JobWizardState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withAlpha(77)),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: AppTheme.accentBlue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Creating quiz for:',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
                  ),
                ),
                Text(
                  state.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            onPressed: () => context.read<JobWizardCubit>().previousStep(),
            tooltip: 'Edit job details',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyQuestionsState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 64,
            color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'No questions yet',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add at least one question to create the quiz',
            style: TextStyle(
              color: isDark ? AppTheme.textGrey : AppTheme.textDarkGrey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== NAVIGATION ====================

  Widget _buildNavigationButtons(
      BuildContext context, JobWizardState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back Button
            if (state.currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: context.read<JobWizardCubit>().previousStep,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back'),
                ),
              ),

            if (state.currentStep > 0) const SizedBox(width: 16),

            // Next/Submit Button
            Expanded(
              flex: state.currentStep > 0 ? 1 : 1,
              child: _buildPrimaryButton(context, state),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, JobWizardState state) {
    final cubit = context.read<JobWizardCubit>();

    // Determine button text and action
    String buttonText;
    VoidCallback? onPressed;

    if (state.currentStep == 0) {
      if (state.requiresQuiz) {
        buttonText = 'Next: Create Quiz';
        onPressed = state.isJobDetailsValid ? cubit.nextStep : null;
      } else {
        buttonText = 'Post Job';
        onPressed = state.isJobDetailsValid ? cubit.submit : null;
      }
    } else {
      buttonText = 'Create Job & Quiz';
      onPressed = state.canSubmit ? cubit.submit : null;
    }

    return CustomButton(
      text: buttonText,
      onPressed: onPressed,
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'Are you sure you want to exit? All unsaved changes will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== QUESTION CARD ====================

class _QuestionCard extends StatefulWidget {
  final int questionIndex;
  final QuestionDraft question;
  final JobWizardCubit cubit;

  const _QuestionCard({
    required this.questionIndex,
    required this.question,
    required this.cubit,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question.text);
  }

  @override
  void didUpdateWidget(_QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.text != widget.question.text) {
      _questionController.text = widget.question.text;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isDark ? AppTheme.secondaryBlack : AppTheme.secondaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Q${widget.questionIndex + 1}',
                    style: const TextStyle(
                      color: AppTheme.accentBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                  onPressed: () => widget.cubit.removeQuestion(widget.questionIndex),
                  tooltip: 'Delete question',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Question Text
            TextField(
              controller: _questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'Enter your question here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
              onChanged: (value) =>
                  widget.cubit.updateQuestionText(widget.questionIndex, value),
            ),
            const SizedBox(height: 16),

            // Question Type
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Type:',
                  style: TextStyle(
                    color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ChoiceChip(
                  label: const Text('Single Choice'),
                  selected: widget.question.type == QuestionType.SINGLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      widget.cubit.updateQuestionType(
                          widget.questionIndex, QuestionType.SINGLE_CHOICE);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Multiple Choice'),
                  selected: widget.question.type == QuestionType.MULTIPLE_CHOICE,
                  onSelected: (selected) {
                    if (selected) {
                      widget.cubit.updateQuestionType(
                          widget.questionIndex, QuestionType.MULTIPLE_CHOICE);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Options
            Text(
              'Options:',
              style: TextStyle(
                color: isDark ? AppTheme.textWhite : AppTheme.textBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...widget.question.options.asMap().entries.map((entry) {
              return _OptionField(
                questionIndex: widget.questionIndex,
                optionIndex: entry.key,
                option: entry.value,
                canDelete: widget.question.options.length > 2,
                cubit: widget.cubit,
              );
            }),

            // Add Option Button
            if (widget.question.options.length < 6)
              TextButton.icon(
                onPressed: () => widget.cubit.addOption(widget.questionIndex),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add Option'),
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== OPTION FIELD ====================

class _OptionField extends StatefulWidget {
  final int questionIndex;
  final int optionIndex;
  final OptionDraft option;
  final bool canDelete;
  final JobWizardCubit cubit;

  const _OptionField({
    required this.questionIndex,
    required this.optionIndex,
    required this.option,
    required this.canDelete,
    required this.cubit,
  });

  @override
  State<_OptionField> createState() => _OptionFieldState();
}

class _OptionFieldState extends State<_OptionField> {
  late TextEditingController _optionController;

  @override
  void initState() {
    super.initState();
    _optionController = TextEditingController(text: widget.option.text);
  }

  @override
  void didUpdateWidget(_OptionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.option.text != widget.option.text) {
      _optionController.text = widget.option.text;
    }
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.option.correct
            ? AppTheme.accentGreen.withAlpha(26)
            : (isDark ? AppTheme.primaryBlack : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.option.correct
              ? AppTheme.accentGreen
              : (isDark ? AppTheme.tertiaryGrey : AppTheme.lightGrey),
          width: widget.option.correct ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: widget.option.correct,
            onChanged: (value) {
              widget.cubit
                  .toggleOptionCorrect(widget.questionIndex, widget.optionIndex);
            },
            activeColor: AppTheme.accentGreen,
          ),
          Expanded(
            child: TextField(
              controller: _optionController,
              decoration: InputDecoration(
                hintText: 'Option ${widget.optionIndex + 1}',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                widget.cubit.updateOptionText(
                    widget.questionIndex, widget.optionIndex, value);
              },
            ),
          ),
          if (widget.canDelete)
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => widget.cubit
                  .removeOption(widget.questionIndex, widget.optionIndex),
              tooltip: 'Remove option',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
