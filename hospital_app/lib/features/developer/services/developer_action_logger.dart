import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for logging developer actions and providing undo capabilities
class DeveloperActionLogger {
  static const String _actionLogKey = 'developer_action_log';
  static const String _sessionActionsKey = 'developer_session_actions';
  static const int _maxLogEntries = 1000;
  static const int _maxSessionActions = 50;

  /// Log a developer action
  Future<void> logAction({
    required String action,
    Map<String, dynamic>? fromCharacter,
    Map<String, dynamic>? toCharacter,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final logEntry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'action': action,
      'fromCharacter': fromCharacter,
      'toCharacter': toCharacter,
      'metadata': metadata ?? {},
      'description': description ??
          _generateDescription(action, fromCharacter, toCharacter),
      'isUndoable': _isActionUndoable(action),
    };

    // Add to main log
    await _addToLog(prefs, _actionLogKey, logEntry, _maxLogEntries);

    // Add to session actions (for undo functionality)
    if (logEntry['isUndoable'] == true) {
      await _addToLog(prefs, _sessionActionsKey, logEntry, _maxSessionActions);
    }
  }

  /// Get action history
  Future<List<Map<String, dynamic>>> getActionHistory({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final logJson = prefs.getString(_actionLogKey);

    if (logJson == null) return [];

    final List<dynamic> log = jsonDecode(logJson);
    final actions = log.cast<Map<String, dynamic>>();

    // Sort by timestamp (newest first)
    actions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

    if (limit != null) {
      return actions.take(limit).toList();
    }

    return actions;
  }

  /// Get undoable session actions
  Future<List<Map<String, dynamic>>> getUndoableActions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionActionsKey);

    if (sessionJson == null) return [];

    final List<dynamic> sessionActions = jsonDecode(sessionJson);
    final actions = sessionActions.cast<Map<String, dynamic>>();

    // Sort by timestamp (newest first) and filter undoable
    actions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return actions.where((action) => action['isUndoable'] == true).toList();
  }

  /// Get the last undoable action
  Future<Map<String, dynamic>?> getLastUndoableAction() async {
    final undoableActions = await getUndoableActions();
    return undoableActions.isNotEmpty ? undoableActions.first : null;
  }

  /// Check if undo is available
  Future<bool> canUndo() async {
    final lastAction = await getLastUndoableAction();
    return lastAction != null;
  }

  /// Perform undo operation
  Future<Map<String, dynamic>?> undoLastAction() async {
    final lastAction = await getLastUndoableAction();
    if (lastAction == null) return null;

    // Log the undo action
    await logAction(
      action: 'UNDO_ACTION',
      metadata: {
        'undoTarget': lastAction,
        'originalAction': lastAction['action'],
      },
      description: 'Undid: ${lastAction['description']}',
    );

    // Remove the action from session actions
    await _removeFromSessionActions(lastAction['id']);

    return lastAction;
  }

  /// Clear session actions (typically called when switching characters)
  Future<void> clearSessionActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionActionsKey);
  }

  /// Clear all action logs
  Future<void> clearAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_actionLogKey);
    await prefs.remove(_sessionActionsKey);
  }

  /// Get action statistics
  Future<Map<String, dynamic>> getActionStatistics() async {
    final actions = await getActionHistory();

    final stats = <String, dynamic>{
      'totalActions': actions.length,
      'sessionStart': actions.isNotEmpty ? actions.last['timestamp'] : null,
      'lastAction': actions.isNotEmpty ? actions.first['timestamp'] : null,
      'actionTypes': <String, int>{},
      'charactersUsed': <String>{},
      'undoableActions': 0,
    };

    for (final action in actions) {
      // Count action types
      final actionType = action['action'] as String;
      stats['actionTypes'][actionType] =
          (stats['actionTypes'][actionType] ?? 0) + 1;

      // Track characters used
      if (action['toCharacter'] != null) {
        final charName =
            '${action['toCharacter']['firstName']} ${action['toCharacter']['lastName']}';
        (stats['charactersUsed'] as Set<String>).add(charName);
      }

      // Count undoable actions
      if (action['isUndoable'] == true) {
        stats['undoableActions']++;
      }
    }

    // Convert set to list for JSON serialization
    stats['charactersUsed'] = (stats['charactersUsed'] as Set<String>).toList();

    return stats;
  }

  /// Helper method to add entry to log with size limit
  Future<void> _addToLog(
    SharedPreferences prefs,
    String key,
    Map<String, dynamic> entry,
    int maxEntries,
  ) async {
    final logJson = prefs.getString(key);
    List<dynamic> log = [];

    if (logJson != null) {
      log = jsonDecode(logJson);
    }

    log.insert(0, entry); // Add to beginning

    // Trim to max entries
    if (log.length > maxEntries) {
      log = log.take(maxEntries).toList();
    }

    await prefs.setString(key, jsonEncode(log));
  }

  /// Remove specific action from session actions
  Future<void> _removeFromSessionActions(String actionId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = prefs.getString(_sessionActionsKey);

    if (sessionJson == null) return;

    final List<dynamic> sessionActions = jsonDecode(sessionJson);
    sessionActions.removeWhere((action) => action['id'] == actionId);

    await prefs.setString(_sessionActionsKey, jsonEncode(sessionActions));
  }

  /// Generate human-readable description for actions
  String _generateDescription(
    String action,
    Map<String, dynamic>? fromCharacter,
    Map<String, dynamic>? toCharacter,
  ) {
    switch (action) {
      case 'CHARACTER_SWITCH':
        final fromName = fromCharacter != null
            ? '${fromCharacter['firstName']} ${fromCharacter['lastName']}'
            : 'None';
        final toName = toCharacter != null
            ? '${toCharacter['firstName']} ${toCharacter['lastName']}'
            : 'None';
        return 'Switched from $fromName to $toName';

      case 'LOGIN':
        final charName = toCharacter != null
            ? '${toCharacter['firstName']} ${toCharacter['lastName']}'
            : 'Developer';
        return 'Logged in as $charName';

      case 'LOGOUT':
        final charName = fromCharacter != null
            ? '${fromCharacter['firstName']} ${fromCharacter['lastName']}'
            : 'Developer';
        return 'Logged out from $charName';

      case 'VIEW_DASHBOARD':
        return 'Viewed dashboard';

      case 'ACCESS_PATIENT_RECORDS':
        return 'Accessed patient medical records';

      case 'CREATE_APPOINTMENT':
        return 'Created new appointment';

      case 'PRESCRIBE_MEDICATION':
        return 'Prescribed medication';

      case 'UPDATE_PROFILE':
        return 'Updated profile information';

      case 'UNDO_ACTION':
        return 'Performed undo operation';

      default:
        return 'Performed $action';
    }
  }

  /// Determine if an action can be undone
  bool _isActionUndoable(String action) {
    final undoableActions = {
      'CHARACTER_SWITCH',
      'UPDATE_PROFILE',
      'CREATE_APPOINTMENT',
      'PRESCRIBE_MEDICATION',
      'UPDATE_PATIENT_NOTES',
      'SCHEDULE_LAB_TEST',
      'DISPENSE_MEDICATION',
    };

    return undoableActions.contains(action);
  }

  /// Get action type color for UI
  static Color getActionTypeColor(String actionType) {
    switch (actionType) {
      case 'CHARACTER_SWITCH':
        return const Color(0xFF3B82F6); // Blue
      case 'LOGIN':
      case 'LOGOUT':
        return const Color(0xFF10B981); // Green
      case 'CREATE_APPOINTMENT':
      case 'PRESCRIBE_MEDICATION':
        return const Color(0xFF8B5CF6); // Purple
      case 'ACCESS_PATIENT_RECORDS':
        return const Color(0xFF06B6D4); // Cyan
      case 'UNDO_ACTION':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Get action type icon for UI
  static IconData getActionTypeIcon(String actionType) {
    switch (actionType) {
      case 'CHARACTER_SWITCH':
        return Icons.switch_account;
      case 'LOGIN':
        return Icons.login;
      case 'LOGOUT':
        return Icons.logout;
      case 'CREATE_APPOINTMENT':
        return Icons.event_note;
      case 'PRESCRIBE_MEDICATION':
        return Icons.medication;
      case 'ACCESS_PATIENT_RECORDS':
        return Icons.folder_shared;
      case 'UPDATE_PROFILE':
        return Icons.person;
      case 'UNDO_ACTION':
        return Icons.undo;
      case 'VIEW_DASHBOARD':
        return Icons.dashboard;
      default:
        return Icons.settings;
    }
  }
}

/// Extension to add color getter
extension DeveloperActionLoggerExtension on DeveloperActionLogger {
  static Color getActionColor(String actionType) =>
      DeveloperActionLogger.getActionTypeColor(actionType);

  static IconData getActionIcon(String actionType) =>
      DeveloperActionLogger.getActionTypeIcon(actionType);
}
