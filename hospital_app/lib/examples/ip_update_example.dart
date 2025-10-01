import '../core/config/app_config.dart';

/// Example demonstrating automatic IP detection in AppConfig
///
/// This shows how the app automatically detects your computer's IP address
/// without requiring any manual configuration.

void main() async {
  print('=== Automatic IP Detection Demo ===\n');

  // 1. Get automatically detected IP
  print('Auto-detecting your computer\'s IP address...');
  final detectedIP = await AppConfig.getCurrentDetectedIP();
  print('Detected IP: $detectedIP\n');

  // 2. Get the API URL that will be used (with auto-detection)
  print('Getting API URL with auto-detection...');
  final apiUrl = await AppConfig.getApiBaseUrl();
  print('API URL: $apiUrl\n');

  // 3. Show current configuration
  print('Current configuration:');
  final currentIP = await AppConfig.getComputerIP();
  final isExternalDevice = await AppConfig.isExternalDeviceMode();
  print('   Current IP: $currentIP');
  print('   External Device Mode: $isExternalDevice\n');

  // 4. Enable pure auto-detection (removes any manual overrides)
  print('Enabling pure auto-detection...');
  await AppConfig.enableAutoDetection();

  final newApiUrl = await AppConfig.getApiBaseUrl();
  print('New API URL: $newApiUrl\n');

  print('IP detection is now fully automatic!');
  print(
      '   The app will automatically discover and use your computer\'s IP address.');
  print('   No manual configuration needed when your IP changes!');
}

/// Example usage in a real app:
///
/// ```dart
/// class ApiService {
///   static Future<String> getBaseUrl() async {
///     // This automatically detects IP - no manual work needed!
///     return await AppConfig.getApiBaseUrl();
///   }
/// }
/// ```
