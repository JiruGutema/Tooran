import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _copyToClipboard(
      BuildContext context, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  final String url = "https://jirugutema.vercel.com";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Get in touch with our team for support, feedback, or collaboration',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.textTheme.bodyLarge?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Contact Methods
            _buildSectionHeader(context, 'Contact Information'),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              title: 'Email Support',
              subtitle: 'jirudagutema@gmail.com',
              description: 'For general inquiries and support',
              onTap: () => _launchUrl(
                  'mailto:jirudagutema@gmail.com?subject=Tooran App Support'),
              onLongPress: () =>
                  _copyToClipboard(context, 'jirudagutema@gmail.com', 'Email'),
            ),

            const SizedBox(height: 12),

            _buildContactCard(
              context,
              title: 'Official Website',
              subtitle: 'tooran.vercel.app',
              description: 'Visit our website for updates and news',
              onTap: () => _launchUrl('https://tooran.vercel.app'),
              onLongPress: () => _copyToClipboard(
                  context, 'https://tooran.vercel.app', 'Website URL'),
            ),

            const SizedBox(height: 12),

            _buildContactCard(
              context,
              title: 'Source Code',
              subtitle: 'github.com/jirugutema/tooran',
              description: 'View source code and contribute',
              onTap: () => _launchUrl('https://github.com/jirugutema/tooran'),
              onLongPress: () => _copyToClipboard(context,
                  'https://github.com/jirugutema/tooran', 'GitHub URL'),
            ),

            const SizedBox(height: 40),

            // Developer Section
            _buildSectionHeader(context, 'About the Developer'),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: theme.dividerColor.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Removed CircleAvatar and Icon
                      const SizedBox(width: 0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jiru Gutema',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Software Developer',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Addis Ababa University',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Passionate about creating intuitive and powerful productivity tools. Always open to feedback and collaboration opportunities.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _launchUrl('https://jirugutema.vercel.app'),
                    child: Text(
                      'Portfolio',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Removed Icon container
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required VoidCallback onTap,
    required VoidCallback onLongPress,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Removed Icon container
                const SizedBox(width: 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                // Removed arrow icon
                const SizedBox(width: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSupportItem(
      BuildContext context, String emoji, String title, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Removed emoji
          const SizedBox(width: 0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
