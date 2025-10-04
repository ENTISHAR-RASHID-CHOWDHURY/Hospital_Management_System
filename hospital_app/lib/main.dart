import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/hospital_theme.dart'; // Updated import
import 'features/account/screens/streamlined_login_screen.dart';
import 'features/dashboard/screens/role_based_dashboard.dart';
import 'core/routing/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: HospitalApp(),
    ),
  );
}

class HospitalApp extends ConsumerWidget {
  const HospitalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeModeState = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hospital Management System',
      theme: HospitalTheme.lightTheme, // Use unified theme
      darkTheme: HospitalTheme.darkTheme, // Use unified theme
      themeMode: themeModeState.themeMode,
      home: _buildHome(authState),
      routes: {
        AppRoutes.login: (context) => const StreamlinedLoginScreen(),
        AppRoutes.dashboard: (context) => const RoleBasedDashboard(),
      },
      onGenerateRoute: (settings) {
        // Handle routes that need parameters
        if (settings.name == AppRoutes.developerDashboard) {
          // For developer dashboard, we'll navigate without parameters for now
          // In production, pass actual token and developer info
          return MaterialPageRoute(
            builder: (context) =>
                const RoleBasedDashboard(isDeveloperMode: true),
          );
        }
        return null;
      },
    );
  }

  Widget _buildHome(AuthState authState) {
    if (authState.isLoading) {
      return const SplashScreen();
    }

    if (authState.error != null) {
      return ErrorScreen(error: authState.error!);
    }

    if (authState.isAuthenticated) {
      return const RoleBasedDashboard();
    } else {
      return const StreamlinedLoginScreen();
    }
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF3B82F6), // Primary blue
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 24),
            Text(
              'Hospital Management System',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app or navigate to login
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
