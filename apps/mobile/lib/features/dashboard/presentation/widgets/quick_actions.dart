import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class QuickActions extends StatelessWidget {
  final Function(int) onTabSelected;

  const QuickActions({super.key, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildActionCard(
              context,
              title: 'Register Business',
              icon: LucideIcons.building2,
              color: Colors.emerald,
              onTap: () => context.push('/businesses/new'), // Assume router handles this
            ),
            _buildActionCard(
              context,
              title: 'Apply Scheme',
              icon: LucideIcons.heartHandshake,
              color: Colors.blue,
              onTap: () => onTabSelected(3), // Navigate to Schemes tab
            ),
            _buildActionCard(
              context,
              title: 'Start Learning',
              icon: LucideIcons.graduationCap,
              color: Colors.purple,
              onTap: () => onTabSelected(2), // Navigate to Learning tab
            ),
            _buildActionCard(
              context,
              title: 'Talk to AI',
              icon: LucideIcons.sparkles,
              color: Theme.of(context).colorScheme.primary,
              onTap: () {
                // Should trigger voice overlay, perhaps using a global key or provider,
                // For now, we can just show a snackbar or call a callback.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tap the FAB to Talk to AI')),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
