import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../providers/market_provider.dart';
import '../../data/models/market_price_model.dart';
import 'package:intl/intl.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../core/localization/app_strings.dart';

class MarketPricesScreen extends ConsumerWidget {
  const MarketPricesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final pricesState = ref.watch(marketPricesProvider);
    final notifier = ref.read(marketPricesProvider.notifier);
    
    final statesAsync = ref.watch(marketStatesProvider);
    final commoditiesAsync = ref.watch(marketCommoditiesProvider(notifier.currentState));
    final marketsAsync = ref.watch(marketMarketsProvider(notifier.currentState));

    // Available lists with guaranteed zero-hang APMC fallbacks
    final availableStates = statesAsync.valueOrNull ?? const [
      'Maharashtra',
      'Madhya Pradesh',
      'Gujarat',
      'Karnataka',
      'Punjab',
      'Uttar Pradesh',
    ];
    final availableCommodities = commoditiesAsync.valueOrNull ?? const [
      'Wheat',
      'Onion',
      'Soybean',
      'Cotton',
      'Tomato',
      'Rice',
      'Pomegranate',
      'Banana',
    ];
    final availableMarkets = marketsAsync.valueOrNull ?? const [
      'All Markets',
      'Pune APMC',
      'Lasalgaon APMC',
      'Akola APMC',
      'Nagpur APMC',
      'Narayangaon APMC',
      'Kolhapur APMC',
      'Solapur APMC',
      'Jalgaon APMC',
    ];
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(strings.marketPrices, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.trendingUp, size: 32, color: Colors.green),
                      const SizedBox(width: 12),
                      Text(
                        strings.marketPrices,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.marketPricesSubtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Filter Card matching web's "Check APMC Mandi Rates"
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            strings.checkApmcRates,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            strings.filterRatesSubtitle,
                            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                          const SizedBox(height: 24),
                          
                          // Form Fields
                          Text(
                            strings.state,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            key: ValueKey('mandi_state_${notifier.currentState}'),
                            initialValue: availableStates.contains(notifier.currentState)
                                ? notifier.currentState
                                : (availableStates.isNotEmpty ? availableStates.first : null),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              hintText: strings.isHindi ? 'राज्य चुनें' : (strings.isMarathi ? 'राज्य निवडा' : 'Select State'),
                              suffixIcon: statesAsync.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            items: availableStates
                                .map((s) => DropdownMenuItem(
                                    value: s, child: Text(s),),)
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                notifier.fetchPrices(state: val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          Text(
                            strings.commodityCrop,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            key: ValueKey('mandi_commodity_${notifier.currentCommodity}'),
                            initialValue: (notifier.currentCommodity != null && availableCommodities.contains(notifier.currentCommodity))
                                ? notifier.currentCommodity
                                : null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              hintText: strings.isHindi ? 'फसल चुनें' : (strings.isMarathi ? 'पीक निवडा' : 'Select Crop'),
                              suffixIcon: commoditiesAsync.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(strings.allCommodities),
                              ),
                              ...availableCommodities
                                  .where((c) => c != 'All Commodities')
                                  .map((c) =>
                                      DropdownMenuItem(value: c, child: Text(c)),),
                            ],
                            onChanged: (val) {
                              notifier.fetchPrices(commodity: val);
                            },
                          ),
                          const SizedBox(height: 16),

                          Text(
                            strings.marketMandi,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            key: ValueKey('mandi_market_${notifier.currentMarket}'),
                            initialValue: (notifier.currentMarket != null && availableMarkets.contains(notifier.currentMarket))
                                ? notifier.currentMarket
                                : null,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              hintText: strings.isHindi ? 'मंडी चुनें' : (strings.isMarathi ? 'बाजार निवडा' : 'Select Market'),
                              suffixIcon: marketsAsync.isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: Padding(
                                        padding: EdgeInsets.all(14.0),
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: null,
                                child: Text(strings.allMarkets),
                              ),
                              ...availableMarkets
                                  .where((m) => m != 'All Markets')
                                  .map((m) =>
                                      DropdownMenuItem(value: m, child: Text(m)),),
                            ],
                            onChanged: (val) {
                              notifier.fetchPrices(market: val);
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          ElevatedButton.icon(
                            onPressed: () => notifier.fetchPrices(),
                            icon: const Icon(LucideIcons.refreshCw, size: 18),
                            label: Text(
                              strings.isHindi ? 'भाव देखें' : (strings.isMarathi ? 'भाव तपासा' : 'Check Prices'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  if (notifier.lastUpdated != null)
                    Builder(
                      builder: (context) {
                        final parsed = DateTime.tryParse(notifier.lastUpdated!);
                        final timeStr = parsed != null ? DateFormat.jm().format(parsed.toLocal()) : 'Today';
                        return Padding(
                          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${strings.isHindi ? "अंतिम अपडेट" : (strings.isMarathi ? "शेवटचे अपडेट" : "Last updated")}: $timeStr',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          
          // Prices List
          pricesState.when(
            data: (prices) {
              if (prices.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Center(
                      child: Text(
                        strings.noMarketData,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildPriceCard(context, prices[index], strings),
                    childCount: prices.length,
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator(color: Colors.green)),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.info, color: Colors.amber.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              strings.isHindi
                                  ? 'ऑफ़लाइन सहेजे गए एपीएमसी मंडी भाव दिखाए जा रहे हैं।'
                                  : (strings.isMarathi
                                      ? 'ऑफलाइन जतन केलेले एपीएमसी बाजार भाव दाखवले जात आहेत.'
                                      : 'Showing offline cached APMC Mandi rates.'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => notifier.fetchPrices(),
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: Text(
                          strings.isHindi ? 'भाव ताज़ा करें' : (strings.isMarathi ? 'भाव रिफ्रेश करा' : 'Refresh Rates'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, MarketPriceModel price, AppStrings strings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top green bar equivalent
          Container(
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
          ),
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.05),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.commodity,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${price.market}, ${price.state}',
                        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    price.arrivalDate,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade800),
                  ),
                ),
              ],
            ),
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPriceColumn(context, strings.minPrice, price.minPrice.toString(), false),
                    // Modal price box
                    Transform.translate(
                      offset: const Offset(0, -8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade100),
                        ),
                        child: Column(
                          children: [
                            Text(
                              strings.modalPrice,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${price.modalPrice}',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildPriceColumn(context, strings.maxPrice, price.maxPrice.toString(), false),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${strings.isHindi ? "किस्म" : (strings.isMarathi ? "प्रकार" : "Variety")}: ${price.variety}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        strings.isHindi ? 'इकाई: ₹/क्विंटल' : (strings.isMarathi ? 'एकक: ₹/क्विंटल' : 'Unit: ₹/quintal'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceColumn(BuildContext context, String label, String price, bool isModal) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹$price',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}
