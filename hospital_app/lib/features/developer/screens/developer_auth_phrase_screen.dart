import 'package:flutter/material.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import 'developer_login_screen.dart';

class DeveloperAuthPhraseScreen extends StatefulWidget {
  const DeveloperAuthPhraseScreen({super.key});

  @override
  State<DeveloperAuthPhraseScreen> createState() =>
      _DeveloperAuthPhraseScreenState();
}

class _DeveloperAuthPhraseScreenState extends State<DeveloperAuthPhraseScreen> {
  final _phraseController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  // The special authentication phrase (same as backend)
  static const String _validPhrase = 'dev@hospital2025';

  void _verifyPhrase() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Simple phrase verification
    if (_phraseController.text.trim() == _validPhrase) {
      // Navigate to developer login screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const DeveloperLoginScreen(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid authentication phrase';
      });
    }
  }

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Developer Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Developer Mode Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.developer_mode,
                  size: 64,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              const Text(
                'Developer Mode',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Enter authentication phrase to continue',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 48),

              // Phrase Input
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  controller: _phraseController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Authentication Phrase',
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    hintText: 'Enter special password',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: Icon(Icons.lock, color: AppColors.warning),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppColors.warning, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                  ),
                  onSubmitted: (_) => _verifyPhrase(),
                ),
              ),
              const SizedBox(height: 16),

              // Error Message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Verify Button
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhrase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 48),

              // Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Developer Mode is for testing only.\nAll data is isolated from production.',
                        style: TextStyle(
                          color: AppColors.warning.withOpacity(0.8),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
