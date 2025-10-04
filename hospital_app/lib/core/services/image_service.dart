import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_colors.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  late Directory _cacheDirectory;
  late SharedPreferences _prefs;
  final Map<String, Uint8List> _memoryCache = {};
  static const int maxMemoryCacheSize = 50; // Max items in memory cache
  static const int maxDiskCacheSize = 100; // Max items in disk cache

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    _cacheDirectory = Directory('${appDir.path}/image_cache');

    if (!await _cacheDirectory.exists()) {
      await _cacheDirectory.create(recursive: true);
    }

    await _cleanOldCache();
  }

  Future<Uint8List?> getImage(String url) async {
    final key = _generateCacheKey(url);

    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    // Check disk cache
    final file = File('${_cacheDirectory.path}/$key');
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      _addToMemoryCache(key, bytes);
      return bytes;
    }

    return null;
  }

  Future<void> cacheImage(String url, Uint8List bytes) async {
    final key = _generateCacheKey(url);

    // Add to memory cache
    _addToMemoryCache(key, bytes);

    // Add to disk cache
    final file = File('${_cacheDirectory.path}/$key');
    await file.writeAsBytes(bytes);

    // Update cache metadata
    await _updateCacheMetadata(key);
  }

  void _addToMemoryCache(String key, Uint8List bytes) {
    if (_memoryCache.length >= maxMemoryCacheSize) {
      // Remove oldest item
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[key] = bytes;
  }

  String _generateCacheKey(String url) {
    return md5.convert(url.codeUnits).toString();
  }

  Future<void> _updateCacheMetadata(String key) async {
    final cacheKeys = _prefs.getStringList('cache_keys') ?? [];
    cacheKeys.remove(key); // Remove if exists
    cacheKeys.add(key); // Add to end (most recent)

    if (cacheKeys.length > maxDiskCacheSize) {
      // Remove oldest files
      final keysToRemove = cacheKeys.take(cacheKeys.length - maxDiskCacheSize);
      for (final keyToRemove in keysToRemove) {
        final file = File('${_cacheDirectory.path}/$keyToRemove');
        if (await file.exists()) {
          await file.delete();
        }
      }
      cacheKeys.removeRange(0, cacheKeys.length - maxDiskCacheSize);
    }

    await _prefs.setStringList('cache_keys', cacheKeys);
  }

  Future<void> _cleanOldCache() async {
    final cacheKeys = _prefs.getStringList('cache_keys') ?? [];
    final existingFiles = await _cacheDirectory.list().toList();

    // Remove files that are not in metadata
    for (final entity in existingFiles) {
      if (entity is File) {
        final fileName = entity.path.split('/').last;
        if (!cacheKeys.contains(fileName)) {
          await entity.delete();
        }
      }
    }
  }

  Future<void> clearCache() async {
    _memoryCache.clear();

    if (await _cacheDirectory.exists()) {
      await _cacheDirectory.delete(recursive: true);
      await _cacheDirectory.create();
    }

    await _prefs.remove('cache_keys');
  }

  Future<int> getCacheSize() async {
    int totalSize = 0;

    if (await _cacheDirectory.exists()) {
      final files = await _cacheDirectory.list().toList();
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
    }

    return totalSize;
  }
}

class CachedNetworkImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const CachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  State<CachedNetworkImage> createState() => _CachedNetworkImageState();
}

class _CachedNetworkImageState extends State<CachedNetworkImage> {
  final ImageCacheManager _cacheManager = ImageCacheManager();
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      // Try to get from cache first
      _imageBytes = await _cacheManager.getImage(widget.imageUrl);

      if (_imageBytes != null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load from network
      await _loadFromNetwork();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Future<void> _loadFromNetwork() async {
    try {
      // Simulate network image loading
      await Future.delayed(const Duration(milliseconds: 1000));

      // In a real implementation, you would use http package to download the image
      // For now, we'll use a placeholder
      final ByteData? data =
          await rootBundle.load('assets/images/placeholder.png');
      if (data != null) {
        _imageBytes = data.buffer.asUint8List();
        await _cacheManager.cacheImage(widget.imageUrl, _imageBytes!);

        setState(() {
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = widget.placeholder ?? _buildDefaultPlaceholder();
    } else if (_hasError) {
      content = widget.errorWidget ?? _buildDefaultErrorWidget();
    } else {
      content = Image.memory(
        _imageBytes!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
      );
    }

    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: content,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceDark.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceDark.withOpacity(0.3),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: AppColors.error,
          size: 32,
        ),
      ),
    );
  }
}

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
      );

      return pickedFile != null ? File(pickedFile.path) : null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  static Future<List<File>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth?.toDouble(),
        maxHeight: maxHeight?.toDouble(),
        imageQuality: imageQuality,
        limit: limit,
      );

      return pickedFiles.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  static Future<File?> captureImage({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    return pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
}

class ImageProcessor {
  static Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required int maxWidth,
    required int maxHeight,
    int quality = 85,
  }) async {
    final ui.Codec codec = await ui.instantiateImageCodec(
      imageBytes,
      targetWidth: maxWidth,
      targetHeight: maxHeight,
    );

    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ui.Image image = frameInfo.image;

    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> compressImage(
    Uint8List imageBytes, {
    int quality = 85,
  }) async {
    // In a real implementation, you would use a package like flutter_image_compress
    // For now, we'll return the original bytes
    return imageBytes;
  }

  static Future<String> generateThumbnail(
    File imageFile, {
    int size = 150,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final resizedBytes = await resizeImage(
      bytes,
      maxWidth: size,
      maxHeight: size,
    );

    // Save thumbnail to cache
    final tempDir = await getTemporaryDirectory();
    final thumbnailFile = File(
        '${tempDir.path}/thumb_${DateTime.now().millisecondsSinceEpoch}.png');
    await thumbnailFile.writeAsBytes(resizedBytes);

    return thumbnailFile.path;
  }
}

class ImageUploadWidget extends StatefulWidget {
  final Function(File file) onImageSelected;
  final String? initialImageUrl;
  final double size;
  final bool allowCamera;
  final bool allowGallery;

  const ImageUploadWidget({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
    this.size = 120,
    this.allowCamera = true,
    this.allowGallery = true,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  File? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImagePickerOptions,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(widget.size / 2),
          border: Border.all(
            color: AppColors.border.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    if (_isUploading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: Image.file(
          _selectedImage!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (widget.initialImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: CachedNetworkImage(
          imageUrl: widget.initialImageUrl!,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.cover,
        ),
      );
    }

    return const Center(
      child: Icon(
        Icons.add_a_photo,
        color: AppColors.primary,
        size: 32,
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            if (widget.allowCamera)
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title:
                    const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            if (widget.allowGallery)
              ListTile(
                leading:
                    const Icon(Icons.photo_library, color: AppColors.secondary),
                title: const Text('Gallery',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            if (_selectedImage != null || widget.initialImageUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title:
                    const Text('Remove', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final file = await ImagePickerService.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          _selectedImage = file;
        });
        widget.onImageSelected(file);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
