import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../../../core/constants/app_colors.dart';
import '../services/developer_action_logger.dart';

/// Screen to view developer action history and perform undo operations
class DeveloperActionHistoryScreen extends ConsumerStatefulWidget {
  const DeveloperActionHistoryScreen({super.key});

  @override
  ConsumerState<DeveloperActionHistoryScreen> createState() =>
      _DeveloperActionHistoryScreenState();
}

class _DeveloperActionHistoryScreenState
    extends ConsumerState<DeveloperActionHistoryScreen>
    with TickerProviderStateMixin {
  final DeveloperActionLogger _actionLogger = DeveloperActionLogger();
  late TabController _tabController;

  List<Map<String, dynamic>> _actionHistory = [];
  List<Map<String, dynamic>> _undoableActions = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final history = await _actionLogger.getActionHistory();
      final undoable = await _actionLogger.getUndoableActions();
      final stats = await _actionLogger.getActionStatistics();

      setState(() {
        _actionHistory = history;
        _undoableActions = undoable;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $error')),
        );
      }
    }
  }

  Future<void> _performUndo() async {
    final confirmed = await _showUndoConfirmation();
    if (!confirmed) return;

    try {
      final undoneAction = await _actionLogger.undoLastAction();
      if (undoneAction != null) {
        await _loadData(); // Refresh data
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Undid: ${undoneAction['description']}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Undo failed: $error')),
        );
      }
    }
  }

  Future<bool> _showUndoConfirmation() async {
    final lastAction = await _actionLogger.getLastUndoableAction();
    if (lastAction == null) return false;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.undo, color: Colors.orange),
                SizedBox(width: 8),
                Text('Confirm Undo'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('You are about to undo the following action:'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            DeveloperActionLogger.getActionTypeIcon(
                                lastAction['action']),
                            size: 16,
                            color: DeveloperActionLogger.getActionTypeColor(
                                lastAction['action']),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lastAction['description'],
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(lastAction['timestamp']),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This action cannot be undone once confirmed.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Undo Action'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _clearAllLogs() async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.delete_forever, color: Colors.red),
                SizedBox(width: 8),
                Text('Clear All Logs'),
              ],
            ),
            content: const Text(
              'This will permanently delete all action history and statistics. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Clear All'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      await _actionLogger.clearAllLogs();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All action logs cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.warning,
        title: const Row(
          children: [
            Icon(Icons.history, size: 24),
            SizedBox(width: 8),
            Text('Action History'),
          ],
        ),
        actions: [
          if (_undoableActions.isNotEmpty)
            IconButton(
              onPressed: _performUndo,
              icon: const Icon(Icons.undo),
              tooltip: 'Undo Last Action',
            ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'clear') {
                _clearAllLogs();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Clear All Logs'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list, size: 16),
                  const SizedBox(width: 4),
                  Text('History (${_actionHistory.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.undo, size: 16),
                  const SizedBox(width: 4),
                  Text('Undoable (${_undoableActions.length})'),
                ],
              ),
            ),
            const Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics, size: 16),
                  SizedBox(width: 4),
                  Text('Statistics'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildHistoryTab(),
                _buildUndoableTab(),
                _buildStatisticsTab(),
              ],
            ),
    );
  }

  Widget _buildHistoryTab() {
    if (_actionHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No Action History',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Your developer actions will appear here',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _actionHistory.length,
      itemBuilder: (context, index) {
        final action = _actionHistory[index];
        return _buildActionCard(action, showUndoButton: false);
      },
    );
  }

  Widget _buildUndoableTab() {
    if (_undoableActions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.undo, size: 64, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              'No Undoable Actions',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Actions that can be undone will appear here',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _undoableActions.length,
      itemBuilder: (context, index) {
        final action = _undoableActions[index];
        return _buildActionCard(action, showUndoButton: index == 0);
      },
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Actions',
                  _statistics!['totalActions'].toString(),
                  Icons.timeline,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Undoable Actions',
                  _statistics!['undoableActions'].toString(),
                  Icons.undo,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Characters used
          _buildSectionHeader('Characters Used'),
          const SizedBox(height: 8),
          ...((_statistics!['charactersUsed'] as List<dynamic>)
              .map((char) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Text(char.toString(),
                            style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ))),

          const SizedBox(height: 24),

          // Action types breakdown
          _buildSectionHeader('Action Types'),
          const SizedBox(height: 8),
          ...(_statistics!['actionTypes'] as Map<String, dynamic>)
              .entries
              .map((entry) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: DeveloperActionLogger.getActionTypeColor(entry.key)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            DeveloperActionLogger.getActionTypeColor(entry.key)
                                .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          DeveloperActionLogger.getActionTypeIcon(entry.key),
                          color: DeveloperActionLogger.getActionTypeColor(
                              entry.key),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.key
                                .replaceAll('_', ' ')
                                .toLowerCase()
                                .split(' ')
                                .map((word) =>
                                    word[0].toUpperCase() + word.substring(1))
                                .join(' '),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: DeveloperActionLogger.getActionTypeColor(
                                    entry.key)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            entry.value.toString(),
                            style: TextStyle(
                              color: DeveloperActionLogger.getActionTypeColor(
                                  entry.key),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action,
      {required bool showUndoButton}) {
    final actionType = action['action'] as String;
    final color = DeveloperActionLogger.getActionTypeColor(actionType);
    final icon = DeveloperActionLogger.getActionTypeIcon(actionType);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        action['description'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(action['timestamp']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showUndoButton)
                  ElevatedButton.icon(
                    onPressed: _performUndo,
                    icon: const Icon(Icons.undo, size: 16),
                    label: const Text('Undo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
              ],
            ),

            // Show character transition if applicable
            if (action['fromCharacter'] != null ||
                action['toCharacter'] != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    if (action['fromCharacter'] != null) ...[
                      _buildCharacterChip(action['fromCharacter']),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                    ],
                    if (action['toCharacter'] != null)
                      _buildCharacterChip(action['toCharacter']),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterChip(Map<String, dynamic> character) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        '${character['firstName']} ${character['lastName']}',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
