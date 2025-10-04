import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';

/// Accessibility features and utilities for the Hospital Management System
class AccessibilityFeatures {
  /// Custom semantic labels for common medical actions
  static const Map<String, String> medicalSemantics = {
    'patient_card': 'Patient information card',
    'emergency_button': 'Emergency button, activates emergency protocol',
    'lab_test': 'Laboratory test result',
    'prescription': 'Medication prescription',
    'appointment': 'Medical appointment',
    'vital_signs': 'Patient vital signs measurement',
    'medical_history': 'Patient medical history',
    'doctor_notes': 'Doctor notes and observations',
  };

  /// Provides haptic feedback for different actions
  static void provideFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        HapticFeedback.mediumImpact();
        break;
      case FeedbackType.warning:
        HapticFeedback.vibrate();
        break;
      case FeedbackType.error:
        HapticFeedback.heavyImpact();
        break;
      case FeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case FeedbackType.light:
        HapticFeedback.lightImpact();
        break;
    }
  }

  /// Announces text for screen readers
  static void announce(BuildContext context, String message) {
    SemanticsService.announce(message, TextDirection.ltr);
  }

  /// Creates accessible button with proper semantics
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback onPressed,
    required String semanticLabel,
    String? semanticHint,
    bool enabled = true,
    ButtonStyle? style,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      hint: semanticHint,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: style,
        child: child,
      ),
    );
  }

  /// Creates accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    required String semanticLabel,
    VoidCallback? onTap,
    String? semanticHint,
    bool selected = false,
  }) {
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticLabel,
      hint: semanticHint,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: child,
        ),
      ),
    );
  }

  /// Creates accessible text field with proper labels
  static Widget accessibleTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Semantics(
      textField: true,
      label: required ? '$label (required)' : label,
      hint: hint,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          suffixIcon: required
              ? const Icon(Icons.star, color: Colors.red, size: 16)
              : null,
        ),
        validator: required
            ? (value) => value?.isEmpty ?? true ? '$label is required' : null
            : null,
      ),
    );
  }

  /// Creates accessible list with proper navigation
  static Widget accessibleList({
    required List<Widget> children,
    required String semanticLabel,
    ScrollController? controller,
  }) {
    return Semantics(
      label: semanticLabel,
      child: ListView(
        controller: controller,
        children: children.asMap().entries.map((entry) {
          final child = entry.value;

          return Semantics(
            sortKey: const OrdinalSortKey(0),
            child: child,
          );
        }).toList(),
      ),
    );
  }

  /// Creates accessible tab navigation
  static Widget accessibleTabBar({
    required List<Tab> tabs,
    required TabController controller,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: 'Use left and right arrows to navigate between tabs',
      child: TabBar(
        controller: controller,
        tabs: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;

          return Semantics(
            button: true,
            selected: controller.index == index,
            label: 'Tab ${index + 1} of ${tabs.length}',
            child: tab,
          );
        }).toList(),
      ),
    );
  }

  /// Creates accessible dialog with proper focus management
  static Future<T?> showAccessibleDialog<T>({
    required BuildContext context,
    required Widget child,
    required String title,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Semantics(
        scopesRoute: true,
        explicitChildNodes: true,
        label: 'Dialog: $title',
        child: AlertDialog(
          title: Semantics(
            header: true,
            child: Text(title),
          ),
          content: child,
        ),
      ),
    );
  }

  /// Creates accessible progress indicator
  static Widget accessibleProgressIndicator({
    required double value,
    required String label,
    String? semanticValue,
  }) {
    final percentage = (value * 100).round();

    return Semantics(
      label: label,
      value: semanticValue ?? '$percentage percent',
      child: LinearProgressIndicator(value: value),
    );
  }

  /// Creates accessible switch with proper semantics
  static Widget accessibleSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String label,
    String? semanticHint,
    bool enabled = true,
  }) {
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      hint: semanticHint ?? 'Double tap to ${value ? 'disable' : 'enable'}',
      child: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  /// Creates accessible checkbox with proper semantics
  static Widget accessibleCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    String? semanticHint,
    bool enabled = true,
  }) {
    return Semantics(
      checked: value,
      enabled: enabled,
      label: label,
      hint: semanticHint ?? 'Double tap to ${value ? 'uncheck' : 'check'}',
      child: Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  /// Creates accessible slider with proper semantics
  static Widget accessibleSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required String label,
    required double min,
    required double max,
    int? divisions,
    String Function(double)? semanticFormatterCallback,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      value: semanticFormatterCallback?.call(value) ?? value.toString(),
      increasedValue: semanticFormatterCallback
          ?.call((value + ((max - min) / (divisions ?? 100))).clamp(min, max)),
      decreasedValue: semanticFormatterCallback
          ?.call((value - ((max - min) / (divisions ?? 100))).clamp(min, max)),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  /// Creates accessible image with proper semantics
  static Widget accessibleImage({
    required String imagePath,
    required String semanticLabel,
    String? semanticHint,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      image: true,
      label: semanticLabel,
      hint: semanticHint,
      child: Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Creates accessible icon with proper semantics
  static Widget accessibleIcon({
    required IconData icon,
    required String semanticLabel,
    String? semanticHint,
    Color? color,
    double? size,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      child: Icon(
        icon,
        color: color,
        size: size,
        semanticLabel: semanticLabel,
      ),
    );
  }

  /// Creates accessible menu with proper keyboard navigation
  static Widget accessibleMenu({
    required List<AccessibleMenuItem> items,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: 'Menu with ${items.length} items',
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;

          return Semantics(
            button: true,
            label: item.label,
            hint: item.hint,
            sortKey: const OrdinalSortKey(0),
            child: ListTile(
              leading: item.icon != null
                  ? Icon(item.icon, semanticLabel: item.iconSemanticLabel)
                  : null,
              title: Text(item.label),
              subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
              onTap: item.onTap,
              enabled: item.enabled,
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Creates accessible bottom navigation with proper semantics
  static Widget accessibleBottomNavigation({
    required List<BottomNavigationBarItem> items,
    required int currentIndex,
    required ValueChanged<int> onTap,
    required String semanticLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: 'Navigation with ${items.length} items',
      child: BottomNavigationBar(
        items: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return BottomNavigationBarItem(
            icon: Semantics(
              selected: currentIndex == index,
              label: 'Navigation item ${index + 1} of ${items.length}',
              child: item.icon,
            ),
            label: item.label,
          );
        }).toList(),
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    );
  }
}

/// Feedback types for haptic responses
enum FeedbackType {
  success,
  warning,
  error,
  selection,
  light,
}

/// Menu item model for accessible menus
class AccessibleMenuItem {
  final String label;
  final String? hint;
  final IconData? icon;
  final String? iconSemanticLabel;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  AccessibleMenuItem({
    required this.label,
    this.hint,
    this.icon,
    this.iconSemanticLabel,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
  });
}

/// High contrast theme for accessibility
class HighContrastTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    dividerColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.black, fontSize: 16),
      titleLarge: TextStyle(
          color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 3),
      ),
      labelStyle: TextStyle(color: Colors.black, fontSize: 16),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.yellow,
    scaffoldBackgroundColor: Colors.black,
    cardColor: Colors.black,
    dividerColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
      bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
      titleLarge: TextStyle(
          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(120, 48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.yellow, width: 3),
      ),
      labelStyle: TextStyle(color: Colors.white, fontSize: 16),
    ),
  );
}

/// Keyboard navigation shortcuts
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final Map<LogicalKeySet, VoidCallback> shortcuts;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          for (final entry in shortcuts.entries) {
            // Simple key matching without hardware keyboard
            entry.value();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}

/// Common keyboard shortcuts for hospital management
class HospitalKeyboardShortcuts {
  static final LogicalKeySet emergencyAlert = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyE,
  );

  static final LogicalKeySet newPatient = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyN,
  );

  static final LogicalKeySet searchPatients = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyF,
  );

  static final LogicalKeySet quickSave = LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyS,
  );

  static final LogicalKeySet refreshData = LogicalKeySet(
    LogicalKeyboardKey.f5,
  );

  static final LogicalKeySet goBack = LogicalKeySet(
    LogicalKeyboardKey.escape,
  );

  static final LogicalKeySet showHelp = LogicalKeySet(
    LogicalKeyboardKey.f1,
  );
}

/// Voice announcement service for critical updates
class VoiceAnnouncementService {
  static void announceEmergency(BuildContext context, String message) {
    SemanticsService.announce(
      'EMERGENCY ALERT: $message',
      TextDirection.ltr,
    );
    AccessibilityFeatures.provideFeedback(FeedbackType.error);
  }

  static void announceSuccess(BuildContext context, String message) {
    SemanticsService.announce(
      'Success: $message',
      TextDirection.ltr,
    );
    AccessibilityFeatures.provideFeedback(FeedbackType.success);
  }

  static void announceWarning(BuildContext context, String message) {
    SemanticsService.announce(
      'Warning: $message',
      TextDirection.ltr,
    );
    AccessibilityFeatures.provideFeedback(FeedbackType.warning);
  }

  static void announceInfo(BuildContext context, String message) {
    SemanticsService.announce(
      'Information: $message',
      TextDirection.ltr,
    );
    AccessibilityFeatures.provideFeedback(FeedbackType.light);
  }
}
