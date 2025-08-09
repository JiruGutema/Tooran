import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for Samsung-specific notification issues
class SamsungNotificationHelper {
  
  /// Show Samsung-specific notification setup guide
  static Future<void> showSamsungSetupGuide(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone_android, color: Colors.blue),
            SizedBox(width: 8),
            Text('Samsung Device Setup'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Samsung devices require additional settings for notifications to work properly:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                
                _buildStep(
                  '1. Battery Optimization',
                  'Settings → Apps → Tooran → Battery → "Not optimized"',
                  'This prevents Samsung from killing the app in the background.',
                ),
                
                _buildStep(
                  '2. Notification Settings',
                  'Settings → Apps → Tooran → Notifications → Enable all',
                  'Make sure "Show notifications" and "Allow notification dot" are ON.',
                ),
                
                _buildStep(
                  '3. Auto-disable Prevention',
                  'Settings → Device care → Auto optimization → Turn OFF',
                  'Prevents Samsung from automatically disabling unused apps.',
                ),
                
                _buildStep(
                  '4. Sleep Mode Exception',
                  'Settings → Device care → Battery → More battery settings → Apps that won\'t be put to sleep → Add Tooran',
                  'Keeps the app active for notifications.',
                ),
                
                _buildStep(
                  '5. Exact Alarms (Android 12+)',
                  'Settings → Apps → Special app access → Alarms & reminders → Tooran → Allow',
                  'Required for precise notification timing.',
                ),
                
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text('Important:', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'After changing these settings, restart your phone for the changes to take full effect.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _copyInstructions(context),
            child: const Text('Copy Instructions'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildStep(String title, String path, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              path,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  static void _copyInstructions(BuildContext context) {
    const instructions = '''
Samsung Notification Setup Instructions:

1. Battery Optimization:
   Settings → Apps → Tooran → Battery → "Not optimized"

2. Notification Settings:
   Settings → Apps → Tooran → Notifications → Enable all

3. Auto-disable Prevention:
   Settings → Device care → Auto optimization → Turn OFF

4. Sleep Mode Exception:
   Settings → Device care → Battery → More battery settings → Apps that won't be put to sleep → Add Tooran

5. Exact Alarms (Android 12+):
   Settings → Apps → Special app access → Alarms & reminders → Tooran → Allow

Important: Restart your phone after making these changes.
''';

    Clipboard.setData(const ClipboardData(text: instructions));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Instructions copied to clipboard!')),
    );
  }

  /// Show quick Samsung troubleshooting tips
  static Future<void> showQuickTips(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Samsung Fixes'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Try these quick fixes:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('• Restart your phone'),
            Text('• Check if app is in "Deep sleeping apps" list'),
            Text('• Disable "Adaptive battery"'),
            Text('• Turn off "Put unused apps to sleep"'),
            Text('• Check notification channels in app settings'),
            SizedBox(height: 12),
            Text(
              'If notifications still don\'t work, use the full setup guide.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showSamsungSetupGuide(context);
            },
            child: const Text('Full Setup Guide'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Create a floating action button for Samsung help
  static Widget createSamsungHelpFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showSamsungSetupGuide(context),
      backgroundColor: Colors.blue,
      heroTag: "samsung_help_fab",
      tooltip: 'Samsung Notification Help',
      child: const Icon(Icons.help_outline),
    );
  }
}