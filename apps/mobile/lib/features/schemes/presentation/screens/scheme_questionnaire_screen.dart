import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/scheme_recommendation_provider.dart';

class SchemeQuestionnaireScreen extends ConsumerStatefulWidget {
  const SchemeQuestionnaireScreen({super.key});

  @override
  ConsumerState<SchemeQuestionnaireScreen> createState() =>
      _SchemeQuestionnaireScreenState();
}

class _SchemeQuestionnaireScreenState
    extends ConsumerState<SchemeQuestionnaireScreen> {
  int _currentStep = 1;
  final int _totalSteps = 6;

  String? _activity = 'FARMER';
  String _state = 'Maharashtra';
  int _income = 80000;
  String? _age = '26-40';
  String? _gender = 'MALE';
  String? _category = 'SC';

  final List<String> _states = const [
    'Maharashtra',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(activeQuestionnaireProfileProvider);
    if (profile != null) {
      _activity = profile['activity']?.toString() ?? _activity;
      _state = profile['state']?.toString() ?? _state;
      if (profile['income'] is num) {
        _income = (profile['income'] as num).toInt();
      }
      _age = profile['age']?.toString() ?? _age;
      _gender = profile['gender']?.toString() ?? _gender;
      _category = profile['category']?.toString() ?? _category;
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Primary Activity';
      case 2:
        return 'State';
      case 3:
        return 'Annual Income';
      case 4:
        return 'Age Group';
      case 5:
        return 'Gender';
      case 6:
        return 'Social Category';
      default:
        return '';
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 1:
        return _activity != null;
      case 2:
        return _state.isNotEmpty;
      case 3:
        return _income >= 0;
      case 4:
        return _age != null;
      case 5:
        return _gender != null;
      case 6:
        return _category != null;
      default:
        return true;
    }
  }

  void _onNext() async {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      // Submit questionnaire
      final data = {
        'activity': _activity,
        'state': _state,
        'income': _income,
        'age': _age,
        'gender': _gender,
        'category': _category,
      };

      await ref
          .read(schemeRecommendationProvider.notifier)
          .updateFromQuestionnaire(data);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated for $_category \u00B7 $_activity in $_state!'),
            backgroundColor: Colors.green.shade800,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Find Your Schemes',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(38),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Step $_currentStep of $_totalSteps \u2014 ${_getStepTitle()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green.shade600,
                minHeight: 4,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: _buildCurrentStepContent(),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Activity();
      case 2:
        return _buildStep2State();
      case 3:
        return _buildStep3Income();
      case 4:
        return _buildStep4Age();
      case 5:
        return _buildStep5Gender();
      case 6:
        return _buildStep6SocialCategory();
      default:
        return const SizedBox();
    }
  }

  // STEP 1: Primary Activity
  Widget _buildStep1Activity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What best describes what you do?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          value: 'FARMER',
          selectedValue: _activity,
          icon: '\u{1F33E}',
          title: 'Farmer / Agriculture',
          subtitle: 'Crop farming, horticulture, animal husbandry, dairy',
          onTap: () => setState(() => _activity = 'FARMER'),
        ),
        _buildOptionCard(
          value: 'ENTREPRENEUR',
          selectedValue: _activity,
          icon: '\u{1F3EA}',
          title: 'Entrepreneur / Business Owner',
          subtitle: 'Running or starting a micro-business or processing unit',
          onTap: () => setState(() => _activity = 'ENTREPRENEUR'),
        ),
        _buildOptionCard(
          value: 'ARTISAN',
          selectedValue: _activity,
          icon: '\u{1F9F5}',
          title: 'Artisan / Craftsperson',
          subtitle: 'Handicrafts, handloom, pottery, carpentry',
          onTap: () => setState(() => _activity = 'ARTISAN'),
        ),
        _buildOptionCard(
          value: 'STUDENT',
          selectedValue: _activity,
          icon: '\u{1F4DA}',
          title: 'Student / Job Seeker',
          subtitle: 'Seeking skill training, subsidies or employment credit',
          onTap: () => setState(() => _activity = 'STUDENT'),
        ),
        _buildOptionCard(
          value: 'WOMEN_SHG',
          selectedValue: _activity,
          icon: '\u{1F469}',
          title: 'Women SHG Member',
          subtitle: 'Part of a Self Help Group / Joint Liability Group',
          onTap: () => setState(() => _activity = 'WOMEN_SHG'),
        ),
      ],
    );
  }

  // STEP 2: State
  Widget _buildStep2State() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your operational state for state-level subsidies.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _states.contains(_state) ? _state : _states.first,
              items: _states.map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Text(st, style: const TextStyle(fontSize: 15)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _state = val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // STEP 3: Annual Income
  Widget _buildStep3Income() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What is your approximate annual household income?',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixText: '\u20B9 ',
            labelText: 'Annual Income (in Rupees)',
            hintText: '200000',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          controller: TextEditingController(text: '$_income')
            ..selection = TextSelection.collapsed(offset: '$_income'.length),
          onChanged: (val) {
            final parsed = int.tryParse(val);
            if (parsed != null) setState(() => _income = parsed);
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Or quick select bracket:',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildIncomeChip('Below \u20B91L', 80000),
            _buildIncomeChip('\u20B91L \u2013 \u20B93L', 200000),
            _buildIncomeChip('\u20B93L \u2013 \u20B95L', 400000),
            _buildIncomeChip('Above \u20B95L', 600000),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomeChip(String label, int val) {
    final isSelected = _income == val;
    return InkWell(
      onTap: () => setState(() => _income = val),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.green.shade800 : Colors.black87,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // STEP 4: Age Group
  Widget _buildStep4Age() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your age group helps filter youth and senior-specific schemes.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          value: '18-25',
          selectedValue: _age,
          title: '18 \u2013 25 years',
          subtitle: 'Youth entrepreneur / recent graduate',
          onTap: () => setState(() => _age = '18-25'),
        ),
        _buildOptionCard(
          value: '26-40',
          selectedValue: _age,
          title: '26 \u2013 40 years',
          subtitle: 'Prime working age / micro-enterprise expansion',
          onTap: () => setState(() => _age = '26-40'),
        ),
        _buildOptionCard(
          value: '41-60',
          selectedValue: _age,
          title: '41 \u2013 60 years',
          subtitle: 'Experienced rural business operator',
          onTap: () => setState(() => _age = '41-60'),
        ),
        _buildOptionCard(
          value: '60+',
          selectedValue: _age,
          title: '60+ years',
          subtitle: 'Senior citizen pension and welfare schemes apply',
          onTap: () => setState(() => _age = '60+'),
        ),
      ],
    );
  }

  // STEP 5: Gender
  Widget _buildStep5Gender() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Several schemes have special benefits for women entrepreneurs.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildOptionCard(
          value: 'FEMALE',
          selectedValue: _gender,
          icon: '\u{1F469}',
          title: 'Female',
          subtitle: 'Women-specific schemes and interest rebates apply',
          onTap: () => setState(() => _gender = 'FEMALE'),
        ),
        _buildOptionCard(
          value: 'MALE',
          selectedValue: _gender,
          icon: '\u{1F468}',
          title: 'Male',
          subtitle: 'General and targeted entrepreneurship schemes',
          onTap: () => setState(() => _gender = 'MALE'),
        ),
        _buildOptionCard(
          value: 'OTHER',
          selectedValue: _gender,
          icon: '\u26A5',
          title: 'Other / Prefer not to say',
          subtitle: 'Inclusive central and state government benefits',
          onTap: () => setState(() => _gender = 'OTHER'),
        ),
      ],
    );
  }

  // STEP 6: Social Category (Exact Web Parity matching screenshot)
  Widget _buildStep6SocialCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Many central and state schemes have reserved benefits for specific social categories.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _buildCategoryCard(
          value: 'General',
          selectedValue: _category,
          colorDot: Colors.amber,
          title: 'General',
          onTap: () => setState(() => _category = 'General'),
        ),
        _buildCategoryCard(
          value: 'OBC',
          selectedValue: _category,
          colorDot: Colors.deepOrangeAccent,
          title: 'OBC (Other Backward Class)',
          onTap: () => setState(() => _category = 'OBC'),
        ),
        _buildCategoryCard(
          value: 'SC',
          selectedValue: _category,
          colorDot: Colors.blueAccent,
          title: 'SC (Scheduled Caste)',
          onTap: () => setState(() => _category = 'SC'),
        ),
        _buildCategoryCard(
          value: 'ST',
          selectedValue: _category,
          colorDot: Colors.green,
          title: 'ST (Scheduled Tribe)',
          onTap: () => setState(() => _category = 'ST'),
        ),
        _buildCategoryCard(
          value: 'Minority',
          selectedValue: _category,
          colorDot: Colors.purpleAccent,
          title: 'Minority',
          onTap: () => setState(() => _category = 'Minority'),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String value,
    required String? selectedValue,
    required Color colorDot,
    required String title,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? Colors.green.shade50.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colorDot,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                          isSelected ? Colors.green.shade900 : Colors.black87,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(LucideIcons.checkCircle,
                      color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String value,
    required String? selectedValue,
    String? icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isSelected = value == selectedValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isSelected
            ? Colors.green.shade50.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color:
                    isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                width: isSelected ? 2 : 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color:
                              isSelected ? Colors.green.shade900 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(LucideIcons.checkCircle,
                      color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 1)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => setState(() => _currentStep--),
              child: const Text('Back'),
            )
          else
            const SizedBox.shrink(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            onPressed: _canProceed() ? _onNext : null,
            child: Text(
              _currentStep < _totalSteps ? 'Continue' : 'Find My Schemes \u2192',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
