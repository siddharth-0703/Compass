import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/business_provider.dart';

class RegisterBusinessScreen extends ConsumerStatefulWidget {
  const RegisterBusinessScreen({super.key});

  @override
  ConsumerState<RegisterBusinessScreen> createState() =>
      _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState
    extends ConsumerState<RegisterBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _employeesController = TextEditingController(text: '4');

  String _category = 'Agriculture & Processing';
  String _stage = 'Early Stage';
  String _state = 'Maharashtra';
  String _district = 'Pune';
  bool _isLoading = false;

  final List<String> _categories = [
    'Agriculture & Processing',
    'Dairy & Livestock',
    'Handicrafts & Textiles',
    'Food Products & Spices',
    'Retail & Rural Commerce',
    'Renewable Energy & Solar',
  ];

  final List<String> _stages = [
    'Idea / Concept',
    'Seed',
    'Early Stage',
    'Growth',
    'Established',
  ];

  final List<String> _states = [
    'Maharashtra',
    'Madhya Pradesh',
    'Gujarat',
    'Karnataka',
    'Uttar Pradesh',
    'Punjab',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _employeesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repo = ref.read(businessRepositoryProvider);
    final success = await repo.registerBusiness({
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'category': _category,
      'stage': _stage,
      'employees': int.tryParse(_employeesController.text) ?? 2,
      'locationState': _state,
      'locationDistrict': _district,
      'yearStarted': DateTime.now().year,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ref.invalidate(myBusinessesProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business registered successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to register business. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Business',
            style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enterprise Profile',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Provide basic details to access subsidies, schemes, and market buyers.',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Business Name *',
                  hintText: 'e.g., Krishi Kalyan Agro Producers',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),),
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Enter business name' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: InputDecoration(
                  labelText: 'Industry Sector *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),),
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Business Description',
                  hintText:
                      'Describe your products, manufacturing methods, or crops...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _stage,
                      decoration: InputDecoration(
                        labelText: 'Stage',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),),
                      ),
                      items: _stages
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _stage = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _employeesController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Employees',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),),
                        prefixIcon: const Icon(Icons.people_outline),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _state,
                      decoration: InputDecoration(
                        labelText: 'State',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),),
                      ),
                      items: _states
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _state = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      initialValue: _district,
                      decoration: InputDecoration(
                        labelText: 'District',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),),
                      ),
                      onChanged: (val) => _district = val,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white,),
                        )
                      : const Text(
                          'Submit Business Registration',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

