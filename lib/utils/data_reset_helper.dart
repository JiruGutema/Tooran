import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Helper class to completely reset all app data
class DataResetHelper {
  
  /// Show confirmation dialog and reset all data
  static Future<void> showResetDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Reset All Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• All categories and tasks'),
            Text('• All app settings'),
            Text('• All notification schedules'),
            Text('• Theme preferences'),
            SizedBox(height: 16),
            Text(
              'This action cannot be undone!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetAllData(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('RESET ALL DATA'),
          ),
        ],
      ),
    );
  }
  
  /// Actually reset all data
  static Future<void> _resetAllData(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Resetting all data...'),
            ],
          ),
        ),
      );
      
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Clear all Hive boxes
      try {
        // Close all boxes first
        await Hive.close();
        
        // Delete all Hive data
        await Hive.deleteFromDisk();
        
        // Reinitialize Hive
        await Hive.initFlutter();
      } catch (e) {
        print('Error clearing Hive data: $e');
      }
      
      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data has been reset. Please restart the app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
      
    } catch (e) {
      // Close loading dialog if still open
      if (context.mounted) {
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resetting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  /// Quick reset function for debug menu
  static Future<void> quickReset(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      await Hive.close();
      await Hive.deleteFromDisk();
      await Hive.initFlutter();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data reset complete - restart app'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reset failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}