import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ContentModerationScreen extends StatefulWidget {
  const ContentModerationScreen({super.key});

  @override
  State<ContentModerationScreen> createState() =>
      _ContentModerationScreenState();
}

class _ContentModerationScreenState extends State<ContentModerationScreen> {
  String _activeTab = 'All';

  final List<Map<String, dynamic>> _items = [
    {
      'id': 'mod-1',
      'author': 'Kisan Trading Co.',
      'role': 'Merchant',
      'content':
          'Guaranteed 100% returns in 10 days on purchase of imported hybrid soybean seeds. WhatsApp us directly.',
      'source': 'Community Forum',
      'reason': 'Potential financial scam / misleading advertising',
      'confidence': 96,
      'status': 'Pending',
    },
    {
      'id': 'mod-2',
      'author': 'Devendra Verma',
      'role': 'Entrepreneur',
      'content':
          'Selling authentic handcrafted Kolhapur leather chappals with GI tag certification. DM for bulk orders.',
      'source': 'Marketplace Listing',
      'reason': 'Passed preliminary AI safety verification',
      'confidence': 99,
      'status': 'Approved',
    },
    {
      'id': 'mod-3',
      'author': 'Sunita Agro Fertilizers',
      'role': 'Supplier',
      'content':
          'Unregistered chemical pesticide available at 50% discount without invoice or clearance.',
      'source': 'Wholesale Board',
      'reason': 'Unregulated hazardous chemical sale',
      'confidence': 98,
      'status': 'Rejected',
    },
    {
      'id': 'mod-4',
      'author': 'Pooja Milk Federation',
      'role': 'Co-operative',
      'content':
          'Looking for dairy cold chain chilling unit partners in Satara district. Subsidized under PMKSY.',
      'source': 'Partnership Exchange',
      'reason': 'Legitimate collaboration request',
      'confidence': 97,
      'status': 'Approved',
    },
  ];

  void _setStatus(String id, String newStatus) {
    setState(() {
      final index = _items.indexWhere((i) => i['id'] == id);
      if (index >= 0) {
        _items[index]['status'] = newStatus;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Item marked as $newStatus'),
        backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _activeTab == 'All'
        ? _items
        : _items.where((i) => i['status'] == _activeTab).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Content Moderation',
            style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['All', 'Pending', 'Approved', 'Rejected'].map((tab) {
                final isSelected = _activeTab == tab;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(tab),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _activeTab = tab);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Overview KPI
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1,420 Scanned',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14,),),
                        Text('NLP Stream Active',
                            style:
                                TextStyle(fontSize: 11, color: Colors.blue),),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('98.7% Clean',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14,),),
                        Text('Trust Score',
                            style:
                                TextStyle(fontSize: 11, color: Colors.green),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No moderation items in this tab.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isApproved = item['status'] == 'Approved';
                      final isRejected = item['status'] == 'Rejected';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['author'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2,),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item['role'],
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3,),
                                    decoration: BoxDecoration(
                                      color: isApproved
                                          ? Colors.green.withValues(alpha: 0.15)
                                          : isRejected
                                              ? Colors.red
                                                  .withValues(alpha: 0.15)
                                              : Colors.amber
                                                  .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      item['status'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isApproved
                                            ? Colors.green
                                            : isRejected
                                                ? Colors.red
                                                : Colors.amber.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '“${item['content']}”',
                                  style: const TextStyle(
                                      fontSize: 13, height: 1.4,),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(LucideIcons.shieldAlert,
                                      size: 14, color: Colors.amber.shade800,),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item['reason'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.amber.shade900,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'AI: ${item['confidence']}%',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        fontWeight: FontWeight.bold,),
                                  ),
                                ],
                              ),
                              if (item['status'] == 'Pending') ...[
                                const Divider(height: 24),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _setStatus(item['id'], 'Rejected'),
                                      icon: const Icon(Icons.close,
                                          size: 16, color: Colors.red,),
                                      label: const Text('Reject',
                                          style: TextStyle(color: Colors.red),),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.red),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _setStatus(item['id'], 'Approved'),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Approve'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

