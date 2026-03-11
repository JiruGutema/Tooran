import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/glass_container.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF050816),
                  Color(0xFF111827),
                  Color(0xFF020617),
                ]
              : const [
                  Color(0xFFE0F4FF),
                  Color(0xFFF5E9FF),
                  Color(0xFFE8F3FF),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('About Tooran'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // App Header Section
              Center(
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        'Tooran',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.secondary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Version 1.6.1',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Mission Statement
              GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(18),
                child: _buildSection(
                  context,
                  'Our Mission',
                  'Tooran helps you to manage you tasks. We believe productivity should be simple, beautiful, and accessible to everyone.',
                ),
              ),

              const SizedBox(height: 32),

              // Key Features
              GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(18),
                child: _buildSection(
                  context,
                  'Key Features',
                  null,
                ),
              ),
              const SizedBox(height: 16),

              ..._buildFeatureList(context),

              const SizedBox(height: 32),

              // Developer Info
              GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.all(18),
                child: _buildSection(
                  context,
                  'Developer',
                  'Created with passion by Jiru Gutema, a dedicated software developer from Addis Ababa University, committed to building tools that make life more organized and productive.',
                ),
              ),

              const SizedBox(height: 32),

              // Copyright
              Center(
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(20),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        '© 2025 Tooran',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All rights reserved',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String? description,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 12),
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.6,
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildFeatureList(BuildContext context) {
    final theme = Theme.of(context);

    final features = [
      {
        'title': 'Smart Categories',
        'desc': 'Organize tasks with intelligent categorization',
      },
      {
        'title': 'Progress Tracking',
        'desc': 'Visual indicators and completion analytics',
      },
      {
        'title': 'Drag & Drop',
        'desc': 'Intuitive reordering for better organization',
      },
      {
        'title': 'Adaptive Themes',
        'desc': 'Beautiful dark and light mode support',
      },
      {
        'title': 'Auto-Save',
        'desc': 'Never lose your data with automatic persistence',
      },
      {
        'title': 'Task Recovery',
        'desc': 'Restore accidentally deleted items',
      },
    ];

    return features
        .map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(18),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['desc'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildTechStack(BuildContext context) {
    final theme = Theme.of(context);

    final technologies = [
      {'name': 'Flutter', 'desc': 'Cross-platform UI framework'},
      {'name': 'Dart', 'desc': 'Modern programming language'},
      {'name': 'Material Design 3', 'desc': 'Latest design system'},
      {'name': 'SharedPreferences', 'desc': 'Local data persistence'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: technologies
          .map(
            (tech) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Text(
                tech['name'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
