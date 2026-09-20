import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/eligibility_provider.dart';
import '../../domain/entities/eligibility_profile.dart';
import '../../domain/entities/question_definition.dart';

class SchemeQuestionnaireScreen extends ConsumerStatefulWidget {
  const SchemeQuestionnaireScreen({super.key});

  @override
  ConsumerState<SchemeQuestionnaireScreen> createState() =>
      _SchemeQuestionnaireScreenState();
}

class _SchemeQuestionnaireScreenState
    extends ConsumerState<SchemeQuestionnaireScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Static Schema Definition supporting serializable conditional visibility logic
  static const List<QuestionDefinition> _questions = [
    // Step 1: Base Profile
    QuestionDefinition(
      id: 'activity',
      field: 'activityType',
      label: 'What best describes your primary activity?',
      type: 'SINGLE_SELECT',
      options: ['FARMER', 'ENTREPRENEUR', 'ARTISAN', 'STUDENT', 'OTHER'],
      required: true,
    ),
    QuestionDefinition(
      id: 'age',
      field: 'age',
      label: 'What is your age?',
      type: 'NUMBER',
      required: true,
    ),
    // Step 2: Location
    QuestionDefinition(
      id: 'state',
      field: 'state',
      label: 'Which state do you operate in?',
      type: 'SINGLE_SELECT',
      options: ['Maharashtra', 'Karnataka', 'Gujarat', 'Other'],
      required: true,
    ),
    QuestionDefinition(
      id: 'district',
      field: 'district',
      label: 'Enter your district name',
      type: 'TEXT',
      required: true,
    ),
    // Step 3: Farmer Specific Questions (Condition: activityType == FARMER)
    QuestionDefinition(
      id: 'owns_land',
      field: 'ownsLand',
      label: 'Do you own agricultural land?',
      type: 'BOOLEAN',
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'FARMER',
      ),
    ),
    QuestionDefinition(
      id: 'land_size',
      field: 'landSize',
      label: 'What is your land size (in acres)?',
      type: 'NUMBER',
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'FARMER',
      ),
    ),
    // Step 4: Entrepreneur Specific Questions (Condition: activityType == ENTREPRENEUR)
    QuestionDefinition(
      id: 'biz_type',
      field: 'businessType',
      label: 'What is your business type?',
      type: 'SINGLE_SELECT',
      options: ['Manufacturing', 'Services', 'Retail', 'Agri-business'],
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'ENTREPRENEUR',
      ),
    ),
    QuestionDefinition(
      id: 'biz_stage',
      field: 'businessStage',
      label: 'What stage is your business in?',
      type: 'SINGLE_SELECT',
      options: ['Idea Stage', 'Early Stage', 'Growth Stage', 'Mature'],
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'ENTREPRENEUR',
      ),
    ),
    // Step 5: Artisan Specific Questions (Condition: activityType == ARTISAN)
    QuestionDefinition(
      id: 'craft_type',
      field: 'craftType',
      label: 'What craft type do you specialize in?',
      type: 'TEXT',
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'ARTISAN',
      ),
    ),
    // Step 6: Financials
    QuestionDefinition(
      id: 'income',
      field: 'annualIncome',
      label: 'Enter your approximate annual income:',
      type: 'RANGE',
      options: ['Below 1 Lakh', '1-5 Lakhs', '5-10 Lakhs', 'Above 10 Lakhs'],
    ),
    QuestionDefinition(
      id: 'turnover',
      field: 'annualTurnover',
      label: 'Enter your business annual turnover (if applicable):',
      type: 'RANGE',
      options: ['Below 5 Lakhs', '5-10 Lakhs', '10-25 Lakhs', 'Above 25 Lakhs'],
      visibilityCondition: QuestionVisibilityCondition(
        field: 'activityType',
        operator: 'EQ',
        value: 'ENTREPRENEUR',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(eligibilityDraftProvider);
    final completeness = ref.watch(profileCompletenessProvider);

    // Group questions into logic pages/steps
    final visibleQuestions =
        _questions.where((q) => q.isVisible(draft)).toList();

    // Safety check: clear hidden properties immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final question in _questions) {
        if (!question.isVisible(draft) && draft[question.field] != null) {
          ref
              .read(eligibilityDraftProvider.notifier)
              .updateAnswer(question.field, null);
        }
      }
    });

    final steps = _buildStepGroups(visibleQuestions, draft);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eligibility Questionnaire'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: completeness,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Profile completeness: ${(completeness * 100).toInt()}%',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: _currentStep < steps.length
                  ? ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 12.0,),
                      children: steps[_currentStep],
                    )
                  : _buildSuccessView(),
            ),
            _buildNavigationRow(steps.length),
          ],
        ),
      ),
    );
  }

  List<List<Widget>> _buildStepGroups(
      List<QuestionDefinition> visibleQuestions, Map<String, dynamic> draft,) {
    final List<List<Widget>> stepWidgets = [];

    // Group 1: General Core Info
    final step1 = visibleQuestions
        .where((q) => q.id == 'activity' || q.id == 'age')
        .toList();
    if (step1.isNotEmpty) {
      stepWidgets.add(step1.map((q) => _buildQuestionField(q, draft)).toList());
    }

    // Group 2: Location
    final step2 = visibleQuestions
        .where((q) => q.id == 'state' || q.id == 'district')
        .toList();
    if (step2.isNotEmpty) {
      stepWidgets.add(step2.map((q) => _buildQuestionField(q, draft)).toList());
    }

    // Group 3: Dynamic Category Specifics
    final step3 = visibleQuestions
        .where((q) =>
            q.id == 'owns_land' ||
            q.id == 'land_size' ||
            q.id == 'biz_type' ||
            q.id == 'biz_stage' ||
            q.id == 'craft_type',)
        .toList();
    if (step3.isNotEmpty) {
      stepWidgets.add(step3.map((q) => _buildQuestionField(q, draft)).toList());
    }

    // Group 4: Financials
    final step4 = visibleQuestions
        .where((q) => q.id == 'income' || q.id == 'turnover')
        .toList();
    if (step4.isNotEmpty) {
      stepWidgets.add(step4.map((q) => _buildQuestionField(q, draft)).toList());
    }

    return stepWidgets;
  }

  Widget _buildQuestionField(
      QuestionDefinition question, Map<String, dynamic> draft,) {
    final value = draft[question.field];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,),
          ),
          const SizedBox(height: 12),
          if (question.type == 'SINGLE_SELECT' || question.type == 'RANGE')
            DropdownButtonFormField<String>(
              initialValue: value?.toString(),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: question.options!
                  .map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList(),
              onChanged: (val) {
                ref
                    .read(eligibilityDraftProvider.notifier)
                    .updateAnswer(question.field, val);
              },
              validator: question.required
                  ? (v) => v == null ? 'Required field' : null
                  : null,
            )
          else if (question.type == 'BOOLEAN')
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Yes', style: TextStyle(fontSize: 16)),
                    selected: value == true,
                    onSelected: (selected) {
                      ref
                          .read(eligibilityDraftProvider.notifier)
                          .updateAnswer(question.field, true);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('No', style: TextStyle(fontSize: 16)),
                    selected: value == false,
                    onSelected: (selected) {
                      ref
                          .read(eligibilityDraftProvider.notifier)
                          .updateAnswer(question.field, false);
                    },
                  ),
                ),
              ],
            )
          else if (question.type == 'NUMBER')
            TextFormField(
              initialValue: value?.toString(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                final numVal = num.tryParse(val);
                ref
                    .read(eligibilityDraftProvider.notifier)
                    .updateAnswer(question.field, numVal);
              },
              validator: question.required
                  ? (v) => (v == null || v.isEmpty) ? 'Required field' : null
                  : null,
            )
          else
            TextFormField(
              initialValue: value?.toString(),
              decoration: InputDecoration(
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) {
                ref
                    .read(eligibilityDraftProvider.notifier)
                    .updateAnswer(question.field, val);
              },
              validator: question.required
                  ? (v) => (v == null || v.isEmpty) ? 'Required field' : null
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 72),
            SizedBox(height: 24),
            Text(
              'Profile Validated!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'Click submit to send your details to the recommendation engine.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationRow(int totalSteps) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),),
              ),
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),),
            ),
            onPressed: () async {
              if (_currentStep < totalSteps) {
                if (_formKey.currentState!.validate()) {
                  setState(() => _currentStep++);
                }
              } else {
                // Submit Form
                final draft = ref.read(eligibilityDraftProvider);
                final profile = EligibilityProfile(
                  activityType: draft['activityType']?.toString(),
                  age: draft['age'] != null
                      ? int.tryParse(draft['age'].toString())
                      : null,
                  state: draft['state']?.toString(),
                  district: draft['district']?.toString(),
                  ownsLand: draft['ownsLand'] as bool?,
                  landSize: draft['landSize'] != null
                      ? double.tryParse(draft['landSize'].toString())
                      : null,
                  businessType: draft['businessType']?.toString(),
                  businessStage: draft['businessStage']?.toString(),
                  craftType: draft['craftType']?.toString(),
                  annualIncome: draft['annualIncome'] != null
                      ? 300000.0
                      : null, // Mocked range mapping
                  profileVersion: 1,
                  profileUpdatedAt: DateTime.now(),
                );

                await ref
                    .read(eligibilityProfileProvider.notifier)
                    .submitProfile(profile);
                ref.read(eligibilityDraftProvider.notifier).clearAnswers();
                if (!mounted) return;
                context.pop();
              }
            },
            child:
                Text(_currentStep < totalSteps ? 'Continue' : 'Submit Profile'),
          ),
        ],
      ),
    );
  }
}
