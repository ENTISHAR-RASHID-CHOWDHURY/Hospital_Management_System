import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/widgets/standard_cards.dart';
import '../../../core/accessibility/accessibility_features.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() =>
      _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState
    extends ConsumerState<AccessibilitySettingsScreen> {
  bool _highContrastMode = false;
  bool _largeFontSize = false;
  bool _reduceAnimations = false;
  bool _hapticFeedback = true;
  bool _voiceAnnouncements = true;
  bool _screenReaderOptimized = false;
  double _textScaleFactor = 1.0;
  double _buttonSize = 1.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highContrastMode = prefs.getBool('accessibility_high_contrast') ?? false;
      _largeFontSize = prefs.getBool('accessibility_large_font') ?? false;
      _reduceAnimations =
          prefs.getBool('accessibility_reduce_animations') ?? false;
      _hapticFeedback = prefs.getBool('accessibility_haptic_feedback') ?? true;
      _voiceAnnouncements =
          prefs.getBool('accessibility_voice_announcements') ?? true;
      _screenReaderOptimized =
          prefs.getBool('accessibility_screen_reader') ?? false;
      _textScaleFactor = prefs.getDouble('accessibility_text_scale') ?? 1.0;
      _buttonSize = prefs.getDouble('accessibility_button_size') ?? 1.0;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accessibility_high_contrast', _highContrastMode);
    await prefs.setBool('accessibility_large_font', _largeFontSize);
    await prefs.setBool('accessibility_reduce_animations', _reduceAnimations);
    await prefs.setBool('accessibility_haptic_feedback', _hapticFeedback);
    await prefs.setBool(
        'accessibility_voice_announcements', _voiceAnnouncements);
    await prefs.setBool('accessibility_screen_reader', _screenReaderOptimized);
    await prefs.setDouble('accessibility_text_scale', _textScaleFactor);
    await prefs.setDouble('accessibility_button_size', _buttonSize);

    if (mounted) {
      VoiceAnnouncementService.announceSuccess(
          context, 'Accessibility settings saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Accessibility Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          AccessibilityFeatures.accessibleButton(
            semanticLabel: 'Save accessibility settings',
            onPressed: _saveSettings,
            child: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Access Section
            _buildSectionHeader('Quick Access'),
            StandardCard(
              child: Column(
                children: [
                  AccessibilityFeatures.accessibleButton(
                    semanticLabel: 'Enable recommended accessibility settings',
                    semanticHint:
                        'Activates high contrast, large fonts, and reduced animations',
                    onPressed: _enableRecommendedSettings,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.accessibility_new),
                        SizedBox(width: 8),
                        Text('Enable Recommended Settings'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AccessibilityFeatures.accessibleButton(
                    semanticLabel:
                        'Reset all accessibility settings to default',
                    onPressed: _resetToDefaults,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh),
                        SizedBox(width: 8),
                        Text('Reset to Defaults'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Visual Accessibility Section
            _buildSectionHeader('Visual Accessibility'),
            StandardCard(
              child: Column(
                children: [
                  AccessibilityFeatures.accessibleSwitch(
                    value: _highContrastMode,
                    onChanged: (value) {
                      setState(() => _highContrastMode = value);
                      if (value) {
                        VoiceAnnouncementService.announceInfo(
                            context, 'High contrast mode enabled');
                      } else {
                        VoiceAnnouncementService.announceInfo(
                            context, 'High contrast mode disabled');
                      }
                    },
                    label: 'High Contrast Mode',
                    semanticHint:
                        'Improves visibility with high contrast colors',
                  ),
                  const SizedBox(height: 16),
                  AccessibilityFeatures.accessibleSwitch(
                    value: _largeFontSize,
                    onChanged: (value) {
                      setState(() => _largeFontSize = value);
                      VoiceAnnouncementService.announceInfo(
                          context,
                          value
                              ? 'Large font size enabled'
                              : 'Large font size disabled');
                    },
                    label: 'Large Font Size',
                    semanticHint: 'Increases font size for better readability',
                  ),
                  const SizedBox(height: 16),
                  _buildSliderSetting(
                    label: 'Text Size',
                    value: _textScaleFactor,
                    min: 0.8,
                    max: 2.0,
                    divisions: 12,
                    onChanged: (value) {
                      setState(() => _textScaleFactor = value);
                    },
                    semanticFormatter: (value) =>
                        'Text size ${(value * 100).round()} percent',
                  ),
                  const SizedBox(height: 16),
                  _buildSliderSetting(
                    label: 'Button Size',
                    value: _buttonSize,
                    min: 0.8,
                    max: 1.5,
                    divisions: 7,
                    onChanged: (value) {
                      setState(() => _buttonSize = value);
                    },
                    semanticFormatter: (value) =>
                        'Button size ${(value * 100).round()} percent',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Motion and Animation Section
            _buildSectionHeader('Motion and Animation'),
            StandardCard(
              child: Column(
                children: [
                  AccessibilityFeatures.accessibleSwitch(
                    value: _reduceAnimations,
                    onChanged: (value) {
                      setState(() => _reduceAnimations = value);
                      VoiceAnnouncementService.announceInfo(
                          context,
                          value
                              ? 'Animations reduced'
                              : 'Full animations enabled');
                    },
                    label: 'Reduce Animations',
                    semanticHint:
                        'Minimizes motion and animations that may cause discomfort',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Audio and Haptic Section
            _buildSectionHeader('Audio and Haptic Feedback'),
            StandardCard(
              child: Column(
                children: [
                  AccessibilityFeatures.accessibleSwitch(
                    value: _hapticFeedback,
                    onChanged: (value) {
                      setState(() => _hapticFeedback = value);
                      if (value) {
                        AccessibilityFeatures.provideFeedback(
                            FeedbackType.success);
                        VoiceAnnouncementService.announceInfo(
                            context, 'Haptic feedback enabled');
                      } else {
                        VoiceAnnouncementService.announceInfo(
                            context, 'Haptic feedback disabled');
                      }
                    },
                    label: 'Haptic Feedback',
                    semanticHint: 'Provides vibration feedback for actions',
                  ),
                  const SizedBox(height: 16),
                  AccessibilityFeatures.accessibleSwitch(
                    value: _voiceAnnouncements,
                    onChanged: (value) {
                      setState(() => _voiceAnnouncements = value);
                      VoiceAnnouncementService.announceInfo(
                          context,
                          value
                              ? 'Voice announcements enabled'
                              : 'Voice announcements disabled');
                    },
                    label: 'Voice Announcements',
                    semanticHint: 'Announces important actions and updates',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Screen Reader Section
            _buildSectionHeader('Screen Reader Support'),
            StandardCard(
              child: Column(
                children: [
                  AccessibilityFeatures.accessibleSwitch(
                    value: _screenReaderOptimized,
                    onChanged: (value) {
                      setState(() => _screenReaderOptimized = value);
                      VoiceAnnouncementService.announceInfo(
                          context,
                          value
                              ? 'Screen reader optimization enabled'
                              : 'Screen reader optimization disabled');
                    },
                    label: 'Screen Reader Optimization',
                    semanticHint: 'Optimizes interface for screen reader users',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.info.withOpacity(0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Screen Reader Tips:',
                          style: TextStyle(
                            color: AppColors.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Use TalkBack (Android) or VoiceOver (iOS)\n'
                          '• Swipe to navigate between elements\n'
                          '• Double tap to activate buttons\n'
                          '• Use explore by touch for detailed navigation',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Keyboard Navigation Section
            _buildSectionHeader('Keyboard Navigation'),
            StandardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Keyboard Shortcuts:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildShortcutItem('Ctrl + E', 'Emergency Alert'),
                  _buildShortcutItem('Ctrl + N', 'New Patient'),
                  _buildShortcutItem('Ctrl + F', 'Search Patients'),
                  _buildShortcutItem('Ctrl + S', 'Quick Save'),
                  _buildShortcutItem('F5', 'Refresh Data'),
                  _buildShortcutItem('Esc', 'Go Back'),
                  _buildShortcutItem('F1', 'Show Help'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Accessibility Test Section
            _buildSectionHeader('Accessibility Test'),
            StandardCard(
              child: Column(
                children: [
                  const Text(
                    'Test your accessibility settings with these examples:',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  AccessibilityFeatures.accessibleButton(
                    semanticLabel: 'Test button with success feedback',
                    semanticHint:
                        'Press to test haptic feedback and voice announcements',
                    onPressed: () {
                      if (_hapticFeedback) {
                        AccessibilityFeatures.provideFeedback(
                            FeedbackType.success);
                      }
                      if (_voiceAnnouncements) {
                        VoiceAnnouncementService.announceSuccess(
                            context, 'Test button pressed successfully');
                      }
                    },
                    child: const Text('Test Feedback'),
                  ),
                  const SizedBox(height: 12),
                  AccessibilityFeatures.accessibleTextField(
                    label: 'Test Input Field',
                    controller: TextEditingController(),
                    hint: 'Type here to test text input accessibility',
                  ),
                  const SizedBox(height: 12),
                  AccessibilityFeatures.accessibleSlider(
                    value: 0.5,
                    onChanged: (value) {
                      if (_hapticFeedback) {
                        AccessibilityFeatures.provideFeedback(
                            FeedbackType.selection);
                      }
                    },
                    label: 'Test Slider',
                    min: 0.0,
                    max: 1.0,
                    semanticFormatterCallback: (value) =>
                        '${(value * 100).round()} percent',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        header: true,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    int? divisions,
    String Function(double)? semanticFormatter,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        AccessibilityFeatures.accessibleSlider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
          label: label,
          semanticFormatterCallback: semanticFormatter,
        ),
        const SizedBox(height: 4),
        Text(
          semanticFormatter?.call(value) ?? value.toStringAsFixed(1),
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              shortcut,
              style: const TextStyle(
                color: AppColors.accent,
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _enableRecommendedSettings() {
    setState(() {
      _highContrastMode = true;
      _largeFontSize = true;
      _reduceAnimations = true;
      _hapticFeedback = true;
      _voiceAnnouncements = true;
      _textScaleFactor = 1.3;
      _buttonSize = 1.2;
    });

    VoiceAnnouncementService.announceSuccess(
        context, 'Recommended accessibility settings enabled');
    AccessibilityFeatures.provideFeedback(FeedbackType.success);
  }

  void _resetToDefaults() {
    setState(() {
      _highContrastMode = false;
      _largeFontSize = false;
      _reduceAnimations = false;
      _hapticFeedback = true;
      _voiceAnnouncements = true;
      _screenReaderOptimized = false;
      _textScaleFactor = 1.0;
      _buttonSize = 1.0;
    });

    VoiceAnnouncementService.announceInfo(
        context, 'Accessibility settings reset to defaults');
    AccessibilityFeatures.provideFeedback(FeedbackType.light);
  }
}
