import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = '6 Months';

  final List<Map<String, dynamic>> _kpis = [
    {
      'title': 'Marketplace Volume',
      'value': '₹42.8 Lakh',
      'trend': '+18.4% YoY',
      'icon': LucideIcons.dollarSign,
      'color': Colors.green,
    },
    {
      'title': 'Active Entrepreneurs',
      'value': '1,842',
      'trend': '+124 new',
      'icon': LucideIcons.users,
      'color': Colors.blue,
    },
    {
      'title': 'Scheme Success Rate',
      'value': '84.2%',
      'trend': '567 sanctioned',
      'icon': LucideIcons.award,
      'color': Colors.purple,
    },
    {
      'title': 'Mandi Price Premium',
      'value': '+14.2%',
      'trend': 'Above MSP',
      'icon': LucideIcons.trendingUp,
      'color': Colors.amber,
    },
  ];

  final List<Map<String, dynamic>> _sectorBreakdown = [
    {'name': 'Agri-Processing', 'pct': 38, 'color': const Color(0xFF10b981)},
    {'name': 'Dairy & Livestock', 'pct': 26, 'color': const Color(0xFF3b82f6)},
    {'name': 'Handicrafts & Handlooms', 'pct': 18, 'color': const Color(0xFF8b5cf6)},
    {'name': 'Food & Spices', 'pct': 12, 'color': const Color(0xFFf59e0b)},
    {'name': 'Rural Renewable Tech', 'pct': 6, 'color': const Color(0xFF06b6d4)},
  ];

  final List<Map<String, dynamic>> _stateStats = [
    {'state': 'Maharashtra', 'units': 684, 'disbursed': '₹48.2 L', 'growth': '+22%'},
    {'state': 'Madhya Pradesh', 'units': 412, 'disbursed': '₹29.6 L', 'growth': '+18%'},
    {'state': 'Gujarat', 'units': 326, 'disbursed': '₹24.1 L', 'growth': '+14%'},
    {'state': 'Karnataka', 'units': 248, 'disbursed': '₹18.5 L', 'growth': '+11%'},
    {'state': 'Uttar Pradesh', 'units': 172, 'disbursed': '₹12.8 L', 'growth': '+9%'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Analytics',
            style: TextStyle(fontWeight: FontWeight.bold),),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedRange,
            onSelected: (val) => setState(() => _selectedRange = val),
            itemBuilder: (context) => [
              '30 Days',
              '3 Months',
              '6 Months',
              '1 Year',
            ]
                .map((r) => PopupMenuItem(value: r, child: Text(r)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(_selectedRange,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),),
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
              'Ecosystem Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Real-time overview of rural entrepreneur adoption & subsidies.',
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
              itemCount: _kpis.length,
              itemBuilder: (context, index) {
                final kpi = _kpis[index];
                final color = kpi['color'] as MaterialColor;
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              kpi['title'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                            Icon(kpi['icon'], size: 16, color: color),
                          ],
                        ),
                        Text(
                          kpi['value'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2,),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            kpi['trend'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: color.shade800,
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
                  borderRadius: BorderRadius.circular(16),),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enterprises by Industry Sector',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ..._sectorBreakdown.map((sector) {
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
                                      sector['name'],
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$pct%',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct / 100,
                                minHeight: 6,
                                backgroundColor:
                                    color.withValues(alpha: 0.15),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
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
                  borderRadius: BorderRadius.circular(16),),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Performing States',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Regional subsidy flow & micro-business density',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._stateStats.map((st) {
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
                                Text(st['state'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,),),
                                Text('${st['units']} active units',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),),),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(st['disbursed'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,),),
                                Text(st['growth'],
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,),),
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

