import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Performance optimization utilities for the Hospital Management System
class PerformanceOptimizer {
  /// Lazy loading provider for large datasets
  static Provider<LazyDataLoader> lazyLoaderProvider =
      Provider((ref) => LazyDataLoader());

  /// Pagination manager for efficient data loading
  static Provider<PaginationManager> paginationProvider =
      Provider((ref) => PaginationManager());

  /// Image optimization service
  static Provider<ImageOptimizer> imageOptimizerProvider =
      Provider((ref) => ImageOptimizer());

  /// Memory management utilities
  static Provider<MemoryManager> memoryManagerProvider =
      Provider((ref) => MemoryManager());
}

/// Lazy loading implementation for large datasets
class LazyDataLoader {
  final Map<String, List<dynamic>> _cache = {};
  final Map<String, bool> _loading = {};

  /// Load data lazily with caching
  Future<List<T>> loadData<T>({
    required String key,
    required Future<List<T>> Function(int page, int limit) dataLoader,
    int page = 1,
    int limit = 20,
    bool useCache = true,
  }) async {
    final cacheKey = '${key}_${page}_$limit';

    // Return cached data if available and caching is enabled
    if (useCache && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!.cast<T>();
    }

    // Prevent duplicate loading
    if (_loading[cacheKey] == true) {
      // Wait for existing load to complete
      while (_loading[cacheKey] == true) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cache[cacheKey]?.cast<T>() ?? [];
    }

    _loading[cacheKey] = true;

    try {
      final data = await dataLoader(page, limit);
      if (useCache) {
        _cache[cacheKey] = data;
      }
      return data;
    } finally {
      _loading[cacheKey] = false;
    }
  }

  /// Clear cache for specific key or all data
  void clearCache([String? key]) {
    if (key != null) {
      _cache.removeWhere((k, v) => k.startsWith(key));
    } else {
      _cache.clear();
    }
  }

  /// Get cache size for monitoring
  int getCacheSize() => _cache.length;
}

/// Pagination management for efficient data loading
class PaginationManager {
  final Map<String, PaginationState> _states = {};

  /// Get pagination state for a specific key
  PaginationState getState(String key) {
    return _states[key] ??= PaginationState();
  }

  /// Update pagination state
  void updateState(String key, PaginationState state) {
    _states[key] = state;
  }

  /// Reset pagination for a key
  void reset(String key) {
    _states[key] = PaginationState();
  }

  /// Load next page
  Future<List<T>> loadNextPage<T>(
    String key,
    Future<List<T>> Function(int page, int limit) loader,
  ) async {
    final state = getState(key);

    if (state.isLoading || !state.hasMoreData) {
      return [];
    }

    state.isLoading = true;
    updateState(key, state);

    try {
      final newData = await loader(state.currentPage + 1, state.pageSize);

      state.currentPage++;
      state.totalItems += newData.length;
      state.hasMoreData = newData.length == state.pageSize;
      state.data.addAll(newData);

      return newData;
    } finally {
      state.isLoading = false;
      updateState(key, state);
    }
  }

  /// Refresh data (reset and load first page)
  Future<List<T>> refresh<T>(
    String key,
    Future<List<T>> Function(int page, int limit) loader,
  ) async {
    reset(key);
    return loadNextPage(key, loader);
  }
}

/// Pagination state management
class PaginationState {
  int currentPage;
  int pageSize;
  int totalItems;
  bool hasMoreData;
  bool isLoading;
  List<dynamic> data;

  PaginationState({
    this.currentPage = 0,
    this.pageSize = 20,
    this.totalItems = 0,
    this.hasMoreData = true,
    this.isLoading = false,
    List<dynamic>? data,
  }) : data = data ?? [];

  PaginationState copyWith({
    int? currentPage,
    int? pageSize,
    int? totalItems,
    bool? hasMoreData,
    bool? isLoading,
    List<dynamic>? data,
  }) {
    return PaginationState(
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      isLoading: isLoading ?? this.isLoading,
      data: data ?? this.data,
    );
  }
}

/// Image optimization for better performance
class ImageOptimizer {
  final Map<String, String> _optimizedCache = {};

  /// Optimize image for display
  Future<String> optimizeImage({
    required String originalPath,
    int? maxWidth,
    int? maxHeight,
    int quality = 85,
    bool useCache = true,
  }) async {
    final cacheKey = '${originalPath}_${maxWidth}_${maxHeight}_$quality';

    if (useCache && _optimizedCache.containsKey(cacheKey)) {
      return _optimizedCache[cacheKey]!;
    }

    // Simulate image optimization
    await Future.delayed(const Duration(milliseconds: 100));

    final optimizedPath = '${originalPath}_optimized';

    if (useCache) {
      _optimizedCache[cacheKey] = optimizedPath;
    }

    return optimizedPath;
  }

  /// Generate thumbnail
  Future<String> generateThumbnail({
    required String imagePath,
    int size = 150,
  }) async {
    return optimizeImage(
      originalPath: imagePath,
      maxWidth: size,
      maxHeight: size,
      quality: 70,
    );
  }

  /// Clear optimization cache
  void clearCache() {
    _optimizedCache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _optimizedCache.length,
      'memoryUsage': _optimizedCache.length * 1024, // Estimated
    };
  }
}

/// Memory management utilities
class MemoryManager {
  final List<VoidCallback> _disposables = [];
  int _memoryWarningThreshold = 100; // MB

  /// Register a disposable resource
  void registerDisposable(VoidCallback dispose) {
    _disposables.add(dispose);
  }

  /// Dispose all registered resources
  void disposeAll() {
    for (final dispose in _disposables) {
      try {
        dispose();
      } catch (e) {
        debugPrint('Error disposing resource: $e');
      }
    }
    _disposables.clear();
  }

  /// Simulate memory usage check
  Future<bool> checkMemoryUsage() async {
    // In a real implementation, you'd use platform-specific APIs
    // to check actual memory usage
    await Future.delayed(const Duration(milliseconds: 50));
    return false; // Simulate no memory pressure
  }

  /// Force garbage collection (platform-specific)
  void forceGarbageCollection() {
    // In a real implementation, you'd call platform-specific GC
    debugPrint('Forcing garbage collection');
  }

  /// Get memory statistics
  Future<Map<String, dynamic>> getMemoryStats() async {
    return {
      'registeredDisposables': _disposables.length,
      'memoryWarningThreshold': _memoryWarningThreshold,
      'isMemoryPressure': await checkMemoryUsage(),
    };
  }
}

/// Lazy loading ListView widget
class LazyListView<T> extends ConsumerStatefulWidget {
  final String cacheKey;
  final Future<List<T>> Function(int page, int limit) dataLoader;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Widget? loadingWidget;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final int pageSize;
  final EdgeInsets? padding;
  final ScrollController? controller;

  const LazyListView({
    super.key,
    required this.cacheKey,
    required this.dataLoader,
    required this.itemBuilder,
    this.loadingWidget,
    this.emptyWidget,
    this.errorWidget,
    this.pageSize = 20,
    this.padding,
    this.controller,
  });

  @override
  ConsumerState<LazyListView<T>> createState() => _LazyListViewState<T>();
}

class _LazyListViewState<T> extends ConsumerState<LazyListView<T>> {
  late ScrollController _scrollController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    final paginationManager = ref.read(PerformanceOptimizer.paginationProvider);
    try {
      await paginationManager.refresh(widget.cacheKey, widget.dataLoader);
      setState(() => _error = null);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _loadMoreData() async {
    final paginationManager = ref.read(PerformanceOptimizer.paginationProvider);
    final state = paginationManager.getState(widget.cacheKey);

    if (!state.isLoading && state.hasMoreData) {
      try {
        await paginationManager.loadNextPage(
            widget.cacheKey, widget.dataLoader);
        setState(() => _error = null);
      } catch (e) {
        setState(() => _error = e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginationManager =
        ref.watch(PerformanceOptimizer.paginationProvider);
    final state = paginationManager.getState(widget.cacheKey);

    if (_error != null && state.data.isEmpty) {
      return widget.errorWidget ?? Center(child: Text('Error: $_error'));
    }

    if (state.data.isEmpty && state.isLoading) {
      return widget.loadingWidget ??
          const Center(child: CircularProgressIndicator());
    }

    if (state.data.isEmpty) {
      return widget.emptyWidget ??
          const Center(child: Text('No data available'));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: widget.padding,
      itemCount: state.data.length + (state.hasMoreData ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.data.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = state.data[index] as T;
        return widget.itemBuilder(context, item, index);
      },
    );
  }
}

/// Optimized image widget with lazy loading
class OptimizedImage extends ConsumerWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableOptimization;

  const OptimizedImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableOptimization = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!enableOptimization) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const Icon(Icons.error),
      );
    }

    return FutureBuilder<String>(
      future: _getOptimizedImage(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
        }

        if (snapshot.hasError) {
          return errorWidget ?? const Icon(Icons.error);
        }

        return Image.asset(
          snapshot.data ?? imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? const Icon(Icons.error),
        );
      },
    );
  }

  Future<String> _getOptimizedImage(WidgetRef ref) async {
    final optimizer = ref.read(PerformanceOptimizer.imageOptimizerProvider);
    return optimizer.optimizeImage(
      originalPath: imagePath,
      maxWidth: width?.toInt(),
      maxHeight: height?.toInt(),
    );
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends ConsumerWidget {
  final Widget child;
  final bool showStats;

  const PerformanceMonitor({
    super.key,
    required this.child,
    this.showStats = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!showStats) return child;

    return Stack(
      children: [
        child,
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _getPerformanceStats(ref),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final stats = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Performance Stats:',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    ...stats.entries.map((entry) => Text(
                          '${entry.key}: ${entry.value}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 10),
                        )),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _getPerformanceStats(WidgetRef ref) async {
    final memoryManager = ref.read(PerformanceOptimizer.memoryManagerProvider);
    final imageOptimizer =
        ref.read(PerformanceOptimizer.imageOptimizerProvider);
    final lazyLoader = ref.read(PerformanceOptimizer.lazyLoaderProvider);

    final memoryStats = await memoryManager.getMemoryStats();
    final imageStats = imageOptimizer.getCacheStats();

    return {
      'Cached Data': lazyLoader.getCacheSize(),
      'Optimized Images': imageStats['cachedImages'],
      'Memory Disposables': memoryStats['registeredDisposables'],
      'Memory Pressure': memoryStats['isMemoryPressure'],
    };
  }
}
