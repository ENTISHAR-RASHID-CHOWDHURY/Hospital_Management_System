import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/custom_search_bar.dart';
import '../../../core/widgets/filter_chips.dart';
import '../providers/laboratory_providers.dart';
import '../widgets/lab_order_card.dart';
import '../widgets/lab_result_card.dart';
import '../widgets/add_lab_order_fab.dart';
import '../widgets/lab_statistics_card.dart';

class LaboratoryScreen extends ConsumerStatefulWidget {
  const LaboratoryScreen({super.key});

  @override
  ConsumerState<LaboratoryScreen> createState() => _LaboratoryScreenState();
}

class _LaboratoryScreenState extends ConsumerState<LaboratoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laboratory Management'),
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade900,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade900,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade600,
          tabs: const [
            Tab(text: 'Orders', icon: Icon(Icons.assignment)),
            Tab(text: 'Results', icon: Icon(Icons.science)),
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Search lab orders, patients, tests...',
                  onChanged: (value) {
                    if (_tabController.index == 0) {
                      ref
                          .read(labOrderFiltersProvider.notifier)
                          .updateSearch(value);
                    }
                    // For results tab, we'll add search functionality later
                  },
                ),
                const SizedBox(height: 12),
                _buildFilterChips(),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersTab(),
                _buildResultsTab(),
                _buildOverviewTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0 ? const AddLabOrderFab() : null,
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          if (_tabController.index == 0) ..._buildOrderFilterChips(),
          if (_tabController.index == 1) ..._buildResultFilterChips(),
        ],
      ),
    );
  }

  List<Widget> _buildOrderFilterChips() {
    final filters = ref.watch(labOrderFiltersProvider);

    return [
      FilterChips(
        label: 'Status',
        options: const [
          'ALL',
          'PENDING',
          'IN_PROGRESS',
          'COMPLETED',
          'CANCELLED'
        ],
        selectedOption: filters.status ?? 'ALL',
        onSelected: (status) {
          ref
              .read(labOrderFiltersProvider.notifier)
              .updateStatus(status == 'ALL' ? null : status);
        },
      ),
      const SizedBox(width: 8),
      FilterChips(
        label: 'Urgency',
        options: const ['ALL', 'ROUTINE', 'URGENT', 'STAT'],
        selectedOption: filters.urgency ?? 'ALL',
        onSelected: (urgency) {
          ref
              .read(labOrderFiltersProvider.notifier)
              .updateUrgency(urgency == 'ALL' ? null : urgency);
        },
      ),
    ];
  }

  List<Widget> _buildResultFilterChips() {
    final filters = ref.watch(labResultFiltersProvider);

    return [
      FilterChips(
        label: 'Status',
        options: const ['ALL', 'PENDING', 'COMPLETED', 'VERIFIED', 'CRITICAL'],
        selectedOption: filters.status ?? 'ALL',
        onSelected: (status) {
          ref
              .read(labResultFiltersProvider.notifier)
              .updateStatus(status == 'ALL' ? null : status);
        },
      ),
    ];
  }

  Widget _buildOrdersTab() {
    final filters = ref.watch(labOrderFiltersProvider);
    final ordersAsync = ref.watch(labOrdersProvider(filters));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(labOrdersProvider);
      },
      child: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error loading lab orders',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(labOrdersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final orders = data['orders'] as List;
          final pagination = data['pagination'] as Map<String, dynamic>;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No lab orders found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first lab order to get started',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LabOrderCard(order: orders[index]),
                    );
                  },
                ),
              ),
              _buildPaginationControls(pagination),
            ],
          );
        },
      ),
    );
  }

  Widget _buildResultsTab() {
    final filters = ref.watch(labResultFiltersProvider);
    final resultsAsync = ref.watch(labResultsProvider(filters));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(labResultsProvider);
      },
      child: resultsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error loading lab results',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(labResultsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          final results = data['results'] as List;
          final pagination = data['pagination'] as Map<String, dynamic>;

          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No lab results found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lab results will appear here once tests are completed',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LabResultCard(result: results[index]),
                    );
                  },
                ),
              ),
              _buildPaginationControls(pagination),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab() {
    final statisticsAsync = ref.watch(labStatisticsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(labStatisticsProvider);
        ref.invalidate(pendingOrdersProvider);
        ref.invalidate(urgentOrdersProvider);
        ref.invalidate(criticalResultsProvider);
      },
      child: statisticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                'Error loading statistics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(labStatisticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (statistics) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Laboratory Overview',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                LabStatisticsCard(statistics: statistics),
                const SizedBox(height: 24),
                _buildQuickActions(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaginationControls(Map<String, dynamic> pagination) {
    final currentPage = pagination['currentPage'] as int;
    final totalPages = pagination['totalPages'] as int;
    final hasNextPage = pagination['hasNextPage'] as bool;
    final hasPreviousPage = pagination['hasPreviousPage'] as bool;

    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton.icon(
            onPressed: hasPreviousPage
                ? () {
                    if (_tabController.index == 0) {
                      ref.read(labOrderFiltersProvider.notifier).previousPage();
                    } else {
                      ref
                          .read(labResultFiltersProvider.notifier)
                          .previousPage();
                    }
                  }
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          Text(
            'Page $currentPage of $totalPages',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton.icon(
            onPressed: hasNextPage
                ? () {
                    if (_tabController.index == 0) {
                      ref.read(labOrderFiltersProvider.notifier).nextPage();
                    } else {
                      ref.read(labResultFiltersProvider.notifier).nextPage();
                    }
                  }
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0);
                      ref
                          .read(labOrderFiltersProvider.notifier)
                          .updateStatus('PENDING');
                    },
                    icon: const Icon(Icons.pending_actions),
                    label: const Text('View Pending'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade100,
                      foregroundColor: Colors.orange.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(0);
                      ref
                          .read(labOrderFiltersProvider.notifier)
                          .updateUrgency('URGENT');
                    },
                    icon: const Icon(Icons.priority_high),
                    label: const Text('View Urgent'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(1);
                      ref
                          .read(labResultFiltersProvider.notifier)
                          .updateStatus('CRITICAL');
                    },
                    icon: const Icon(Icons.warning),
                    label: const Text('Critical Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red.shade900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _tabController.animateTo(1);
                      ref
                          .read(labResultFiltersProvider.notifier)
                          .updateStatus('VERIFIED');
                    },
                    icon: const Icon(Icons.verified),
                    label: const Text('Verified Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
