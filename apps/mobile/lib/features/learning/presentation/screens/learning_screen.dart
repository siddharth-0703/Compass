import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/learning_provider.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Agriculture',
    'Digital Skills',
    'Financial Literacy',
    'Government Schemes',
    'Entrepreneurship',
    'Economy',
    'Women Entrepreneurs',
  ];

  String _getCategoryLabel(String cat, AppStrings strings) {
    switch (cat) {
      case 'All':
        return strings.all;
      case 'Agriculture':
        return strings.agriculture;
      case 'Digital Skills':
        return strings.digitalSkills;
      case 'Financial Literacy':
        return strings.financialLiteracy;
      case 'Government Schemes':
        return strings.schemes;
      case 'Entrepreneurship':
        return strings.entrepreneurship;
      case 'Economy':
        return strings.economy;
      case 'Women Entrepreneurs':
        return strings.womenEntrepreneurs;
      default:
        return cat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningNotifierProvider);
    final strings = ref.watch(appStringsProvider);

    if (learningState.isLoading && learningState.resources.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final filteredResources = learningState.resources.where((course) {
      final matchesSearch = course.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          course.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' ||
          course.categories.contains(_selectedCategory);
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.learningHub,
            style: const TextStyle(fontWeight: FontWeight.bold),),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: strings.searchOfflineCourses,
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text(_getCategoryLabel(category, strings)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedCategory = category);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredResources.isEmpty
                ? Center(child: Text(strings.noCoursesFound))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredResources.length,
                    itemBuilder: (context, index) {
                      final course = filteredResources[index];

                      // Sum duration across all lessons
                      final totalDurationMinutes = course.modules.fold<int>(
                            0,
                            (sum, m) =>
                                sum +
                                m.lessons.fold<int>(
                                    0, (s, l) => s + l.durationSeconds,),
                          ) ~/
                          60;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),),
                        child: InkWell(
                          onTap: () => context.push('/learning/${course.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (course.thumbnailUrl != null)
                                CachedNetworkImage(
                                  imageUrl: course.thumbnailUrl!,
                                  height: 160,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 160,
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: CircularProgressIndicator(),),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 160,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.video_library,
                                        size: 50, color: Colors.grey,),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          course.categories.firstOrNull ?? '',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.timer,
                                                size: 14, color: Colors.grey,),
                                            const SizedBox(width: 4),
                                            Text('$totalDurationMinutes m',
                                                style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,),),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      course.title,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      course.description,
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black54,),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
