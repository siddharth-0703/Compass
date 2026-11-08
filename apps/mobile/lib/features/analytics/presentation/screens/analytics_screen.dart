import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/localization/locale_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String _selectedRangeKey = '6m';

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    final rangeOptions = [
      {'key': '30d', 'label': strings.range30Days},
      {'key': '3m', 'label': strings.range3Months},
      {'key': '6m', 'label': strings.range6Months},
      {'key': '1y', 'label': strings.range1Year},
    ];

    final currentRangeLabel = rangeOptions.firstWhere(
      (r) => r['key'] == _selectedRangeKey,
      orElse: () => rangeOptions[2],
    )['label']!;

    final kpis = [
      {
        'title': strings.marketplaceVolume,
        'value': '₹42.8 Lakh',
        'trend': strings.yoyGrowth,
        'icon': LucideIcons.dollarSign,
        'color': Colors.green,
      },
      {
        'title': strings.activeEntrepreneurs,
        'value': '1,842',
        'trend': strings.newEntrepreneurs,
        'icon': LucideIcons.users,
        'color': Colors.blue,
      },
      {
        'title': strings.schemeSuccessRate,
        'value': '84.2%',
        'trend': strings.sanctionedCount,
        'icon': LucideIcons.award,
        'color': Colors.purple,
      },
      {
        'title': strings.mandiPricePremium,
        'value': '+14.2%',
        'trend': strings.aboveMsp,
        'icon': LucideIcons.trendingUp,
        'color': Colors.amber,
      },
    ];

    final sectorBreakdown = [
      {'name': strings.agriProcessing, 'pct': 38, 'color': const Color(0xFF10b981)},
      {'name': strings.dairyLivestock, 'pct': 26, 'color': const Color(0xFF3b82f6)},
      {'name': strings.handicrafts, 'pct': 18, 'color': const Color(0xFF8b5cf6)},
      {'name': strings.foodSpices, 'pct': 12, 'color': const Color(0xFFf59e0b)},
      {'name': strings.renewableTech, 'pct': 6, 'color': const Color(0xFF06b6d4)},
    ];

    final stateStats = [
      {'state': 'Maharashtra', 'units': 684, 'disbursed': '₹48.2 L', 'growth': '+22%'},
      {'state': 'Madhya Pradesh', 'units': 412, 'disbursed': '₹29.6 L', 'growth': '+18%'},
      {'state': 'Gujarat', 'units': 326, 'disbursed': '₹24.1 L', 'growth': '+14%'},
      {'state': 'Karnataka', 'units': 248, 'disbursed': '₹18.5 L', 'growth': '+11%'},
      {'state': 'Uttar Pradesh', 'units': 172, 'disbursed': '₹12.8 L', 'growth': '+9%'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.platformAnalytics,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedRangeKey,
            onSelected: (val) => setState(() => _selectedRangeKey = val),
            itemBuilder: (context) => rangeOptions
                .map((r) => PopupMenuItem(value: r['key'], child: Text(r['label']!)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    currentRangeLabel,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary
            Text(
              strings.ecosystemMetrics,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              strings.ecosystemSubtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // KPI Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.35,
              ),
              itemCount: kpis.length,
              itemBuilder: (context, index) {
                final kpi = kpis[index];
                final color = kpi['color'] as Color;
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                kpi['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            Icon(kpi['icon'] as IconData, size: 16, color: color),
                          ],
                        ),
                        Text(
                          kpi['value'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kpi['trend'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Sector Breakdown Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.enterprisesBySector,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ...sectorBreakdown.map((sector) {
                      final pct = sector['pct'] as int;
                      final color = sector['color'] as Color;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      sector['name'] as String,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                backgroundColor: color.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Top Performing States Table Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.topPerformingStates,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.topStatesSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...stateStats.map((st) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  st['state'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '${st['units']} ${strings.activeUnits}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  st['disbursed'] as String,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  st['growth'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
