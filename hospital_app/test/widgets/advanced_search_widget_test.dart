import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_app/core/widgets/advanced_search_widget.dart';
import 'package:flutter/material.dart';

void main() {
  group('AdvancedSearchWidget Tests', () {
    testWidgets('Search widget displays correctly',
        (WidgetTester tester) async {
      Map<String, dynamic> searchResults = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Test search hint',
              onSearchChanged: (data) => searchResults = data,
              availableFilters: [
                SearchFilter.text(key: 'name', label: 'Name'),
                SearchFilter.dropdown(
                  key: 'category',
                  label: 'Category',
                  options: ['Option 1', 'Option 2'],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Test search hint'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Search triggers callback with query',
        (WidgetTester tester) async {
      Map<String, dynamic> searchResults = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Search...',
              onSearchChanged: (data) => searchResults = data,
              availableFilters: [],
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      expect(searchResults['query'], 'test query');
    });

    testWidgets('Filter panel toggles correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Search...',
              onSearchChanged: (data) {},
              availableFilters: [
                SearchFilter.text(key: 'name', label: 'Name'),
              ],
            ),
          ),
        ),
      );

      // Initially, filter panel should be hidden
      expect(find.text('Name'), findsNothing);

      // Tap filter button to show panel
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Now filter panel should be visible
      expect(find.text('Name'), findsOneWidget);
    });

    testWidgets('Dropdown filter works correctly', (WidgetTester tester) async {
      Map<String, dynamic> searchResults = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Search...',
              onSearchChanged: (data) => searchResults = data,
              availableFilters: [
                SearchFilter.dropdown(
                  key: 'status',
                  label: 'Status',
                  options: ['Active', 'Inactive'],
                ),
              ],
            ),
          ),
        ),
      );

      // Open filter panel
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Find and tap dropdown
      await tester.tap(find.text('Status'));
      await tester.pumpAndSettle();

      // Select an option
      await tester.tap(find.text('Active'));
      await tester.pumpAndSettle();

      expect(searchResults['filters']['status'], 'Active');
    });

    testWidgets('Date range filter works correctly',
        (WidgetTester tester) async {
      Map<String, dynamic> searchResults = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Search...',
              onSearchChanged: (data) => searchResults = data,
              availableFilters: [
                SearchFilter.dateRange(key: 'dateRange', label: 'Date Range'),
              ],
            ),
          ),
        ),
      );

      // Open filter panel
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      expect(find.text('Date Range'), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
    });

    testWidgets('Clear filters works correctly', (WidgetTester tester) async {
      Map<String, dynamic> searchResults = {};

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdvancedSearchWidget(
              hintText: 'Search...',
              onSearchChanged: (data) => searchResults = data,
              availableFilters: [
                SearchFilter.text(key: 'name', label: 'Name'),
              ],
            ),
          ),
        ),
      );

      // Enter search query
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Open filter panel and clear
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear Filters'));
      await tester.pumpAndSettle();

      expect(searchResults['query'], '');
    });
  });

  group('SearchFilter Tests', () {
    test('SearchFilter.text creates correct filter', () {
      final filter = SearchFilter.text(key: 'test', label: 'Test Label');

      expect(filter.key, 'test');
      expect(filter.label, 'Test Label');
      expect(filter.type, FilterType.text);
    });

    test('SearchFilter.dropdown creates correct filter', () {
      final filter = SearchFilter.dropdown(
        key: 'category',
        label: 'Category',
        options: ['A', 'B', 'C'],
      );

      expect(filter.key, 'category');
      expect(filter.label, 'Category');
      expect(filter.type, FilterType.dropdown);
      expect(filter.options, ['A', 'B', 'C']);
    });

    test('SearchFilter.dateRange creates correct filter', () {
      final filter = SearchFilter.dateRange(key: 'dates', label: 'Date Range');

      expect(filter.key, 'dates');
      expect(filter.label, 'Date Range');
      expect(filter.type, FilterType.dateRange);
    });

    test('SearchFilter.multiSelect creates correct filter', () {
      final filter = SearchFilter.multiSelect(
        key: 'tags',
        label: 'Tags',
        options: ['Tag1', 'Tag2'],
      );

      expect(filter.key, 'tags');
      expect(filter.label, 'Tags');
      expect(filter.type, FilterType.multiSelect);
      expect(filter.options, ['Tag1', 'Tag2']);
    });

    test('SearchFilter.range creates correct filter', () {
      final filter = SearchFilter.range(
        key: 'age',
        label: 'Age Range',
        minValue: 0,
        maxValue: 100,
      );

      expect(filter.key, 'age');
      expect(filter.label, 'Age Range');
      expect(filter.type, FilterType.range);
      expect(filter.minValue, 0);
      expect(filter.maxValue, 100);
    });

    test('SearchFilter.toggle creates correct filter', () {
      final filter = SearchFilter.toggle(key: 'active', label: 'Active Only');

      expect(filter.key, 'active');
      expect(filter.label, 'Active Only');
      expect(filter.type, FilterType.toggle);
    });
  });
}
