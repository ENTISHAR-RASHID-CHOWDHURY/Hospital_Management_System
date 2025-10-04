import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_colors.dart';

class AdvancedSearchWidget extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSearchChanged;
  final List<SearchFilter> availableFilters;
  final String hintText;
  final bool showFilters;
  final Map<String, dynamic>? initialFilters;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearchChanged,
    required this.availableFilters,
    this.hintText = 'Search...',
    this.showFilters = true,
    this.initialFilters,
  });

  @override
  ConsumerState<AdvancedSearchWidget> createState() =>
      _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends ConsumerState<AdvancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, dynamic> _activeFilters = {};
  bool _showFilterPanel = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _activeFilters.addAll(widget.initialFilters!);
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final searchData = {
      'query': _searchController.text,
      'filters': Map<String, dynamic>.from(_activeFilters),
    };
    widget.onSearchChanged(searchData);
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null || (value is String && value.isEmpty)) {
        _activeFilters.remove(key);
      } else {
        _activeFilters[key] = value;
      }
    });
    _onSearchChanged();
  }

  void _clearAllFilters() {
    setState(() {
      _activeFilters.clear();
    });
    _onSearchChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              // Main Search Input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        hintStyle:
                            TextStyle(color: Colors.white.withOpacity(0.5)),
                        prefixIcon:
                            const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white70),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (widget.showFilters) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() => _showFilterPanel = !_showFilterPanel);
                      },
                      icon: Icon(
                        _showFilterPanel
                            ? Icons.filter_list_off
                            : Icons.filter_list,
                        color: _activeFilters.isNotEmpty
                            ? AppColors.primary
                            : Colors.white70,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: _activeFilters.isNotEmpty
                            ? AppColors.primary.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Active Filters Display
              if (_activeFilters.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._activeFilters.entries
                        .map((entry) => _buildActiveFilterChip(entry)),
                    if (_activeFilters.length > 1)
                      FilterChip(
                        label: const Text('Clear All'),
                        onSelected: (_) => _clearAllFilters(),
                        backgroundColor: AppColors.error.withOpacity(0.2),
                        labelStyle: const TextStyle(color: AppColors.error),
                        side: const BorderSide(color: AppColors.error),
                        deleteIcon: const Icon(Icons.clear_all, size: 16),
                        onDeleted: _clearAllFilters,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Filter Panel
        if (_showFilterPanel && widget.showFilters) ...[
          const SizedBox(height: 8),
          _buildFilterPanel(),
        ],
      ],
    );
  }

  Widget _buildActiveFilterChip(MapEntry<String, dynamic> filterEntry) {
    final filter = widget.availableFilters.firstWhere(
      (f) => f.key == filterEntry.key,
      orElse: () =>
          SearchFilter.text(key: filterEntry.key, label: filterEntry.key),
    );

    String displayValue = filterEntry.value.toString();
    if (filter.type == FilterType.dateRange && filterEntry.value is Map) {
      final range = filterEntry.value as Map<String, dynamic>;
      displayValue = '${range['start']} - ${range['end']}';
    }

    return FilterChip(
      label: Text('${filter.label}: $displayValue'),
      onSelected: (_) => _updateFilter(filterEntry.key, null),
      backgroundColor: AppColors.primary.withOpacity(0.2),
      labelStyle: const TextStyle(color: AppColors.primary),
      side: const BorderSide(color: AppColors.primary),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: () => _updateFilter(filterEntry.key, null),
    );
  }

  Widget _buildFilterPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Advanced Filters',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.clear_all, size: 16),
                label: const Text('Clear All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter Controls
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: widget.availableFilters
                .map((filter) => _buildFilterControl(filter))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControl(SearchFilter filter) {
    switch (filter.type) {
      case FilterType.dropdown:
        return _buildDropdownFilter(filter);
      case FilterType.dateRange:
        return _buildDateRangeFilter(filter);
      case FilterType.multiSelect:
        return _buildMultiSelectFilter(filter);
      case FilterType.range:
        return _buildRangeFilter(filter);
      case FilterType.toggle:
        return _buildToggleFilter(filter);
      case FilterType.text:
      default:
        return _buildTextFilter(filter);
    }
  }

  Widget _buildDropdownFilter(SearchFilter filter) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: _activeFilters[filter.key],
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(color: Colors.white),
            dropdownColor: AppColors.surfaceDark,
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All', style: TextStyle(color: Colors.white70)),
              ),
              ...filter.options!.map((option) => DropdownMenuItem<String>(
                    value: option,
                    child: Text(option,
                        style: const TextStyle(color: Colors.white)),
                  )),
            ],
            onChanged: (value) => _updateFilter(filter.key, value),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(SearchFilter filter) {
    final currentRange = _activeFilters[filter.key] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildDatePicker(
              'Start Date',
              currentRange?['start'],
              (date) {
                final range = Map<String, dynamic>.from(currentRange ?? {});
                range['start'] = date;
                _updateFilter(filter.key, range);
              },
            ),
            const SizedBox(width: 8),
            _buildDatePicker(
              'End Date',
              currentRange?['end'],
              (date) {
                final range = Map<String, dynamic>.from(currentRange ?? {});
                range['end'] = date;
                _updateFilter(filter.key, range);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
      String label, String? currentValue, Function(String) onChanged) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (date != null) {
            onChanged('${date.day}/${date.month}/${date.year}');
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentValue ?? label,
                  style: TextStyle(
                    color: currentValue != null ? Colors.white : Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiSelectFilter(SearchFilter filter) {
    final selectedValues = (_activeFilters[filter.key] as List<String>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: filter.options!.map((option) {
            final isSelected = selectedValues.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                final newValues = List<String>.from(selectedValues);
                if (selected) {
                  newValues.add(option);
                } else {
                  newValues.remove(option);
                }
                _updateFilter(filter.key, newValues.isEmpty ? null : newValues);
              },
              backgroundColor: isSelected
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : Colors.white70,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary
                    : Colors.white.withOpacity(0.2),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRangeFilter(SearchFilter filter) {
    final currentRange = _activeFilters[filter.key] as Map<String, dynamic>?;
    final min = currentRange?['min']?.toDouble() ?? filter.minValue ?? 0.0;
    final max = currentRange?['max']?.toDouble() ?? filter.maxValue ?? 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          filter.label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
        const SizedBox(height: 4),
        RangeSlider(
          values: RangeValues(min, max),
          min: filter.minValue ?? 0.0,
          max: filter.maxValue ?? 100.0,
          divisions:
              ((filter.maxValue ?? 100.0) - (filter.minValue ?? 0.0)).toInt(),
          labels: RangeLabels(min.round().toString(), max.round().toString()),
          activeColor: AppColors.primary,
          inactiveColor: Colors.white.withOpacity(0.3),
          onChanged: (values) {
            _updateFilter(filter.key, {
              'min': values.start,
              'max': values.end,
            });
          },
        ),
      ],
    );
  }

  Widget _buildToggleFilter(SearchFilter filter) {
    final isActive = _activeFilters[filter.key] as bool? ?? false;

    return Row(
      children: [
        Switch(
          value: isActive,
          onChanged: (value) => _updateFilter(filter.key, value),
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        Text(
          filter.label,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTextFilter(SearchFilter filter) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            filter.label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
          const SizedBox(height: 4),
          TextField(
            onChanged: (value) => _updateFilter(filter.key, value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter ${filter.label.toLowerCase()}',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

enum FilterType {
  text,
  dropdown,
  dateRange,
  multiSelect,
  range,
  toggle,
}

class SearchFilter {
  final String key;
  final String label;
  final FilterType type;
  final List<String>? options;
  final double? minValue;
  final double? maxValue;

  const SearchFilter({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.minValue,
    this.maxValue,
  });

  factory SearchFilter.text({required String key, required String label}) {
    return SearchFilter(key: key, label: label, type: FilterType.text);
  }

  factory SearchFilter.dropdown({
    required String key,
    required String label,
    required List<String> options,
  }) {
    return SearchFilter(
      key: key,
      label: label,
      type: FilterType.dropdown,
      options: options,
    );
  }

  factory SearchFilter.dateRange({required String key, required String label}) {
    return SearchFilter(key: key, label: label, type: FilterType.dateRange);
  }

  factory SearchFilter.multiSelect({
    required String key,
    required String label,
    required List<String> options,
  }) {
    return SearchFilter(
      key: key,
      label: label,
      type: FilterType.multiSelect,
      options: options,
    );
  }

  factory SearchFilter.range({
    required String key,
    required String label,
    required double minValue,
    required double maxValue,
  }) {
    return SearchFilter(
      key: key,
      label: label,
      type: FilterType.range,
      minValue: minValue,
      maxValue: maxValue,
    );
  }

  factory SearchFilter.toggle({required String key, required String label}) {
    return SearchFilter(key: key, label: label, type: FilterType.toggle);
  }
}
