import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class AssetManager {
  static final AssetManager _instance = AssetManager._internal();
  factory AssetManager() => _instance;
  AssetManager._internal();

  final Map<String, dynamic> _cache = {};

  /// Load JSON asset from the assets folder
  Future<Map<String, dynamic>> loadJsonAsset(String path) async {
    try {
      // Check cache first
      if (_cache.containsKey(path)) {
        debugPrint('Loading from cache: $path');
        return _cache[path] as Map<String, dynamic>;
      }

      debugPrint('Loading asset: $path');
      final String jsonString = await rootBundle.loadString(path);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Cache the loaded data
      _cache[path] = jsonData;
      
      return jsonData;
    } catch (e) {
      debugPrint('Error loading asset $path: $e');
      throw AssetLoadException('Failed to load asset: $path', e);
    }
  }

  /// Get list of available categories
  Future<List<String>> getAvailableCategories() async {
    try {
      final categoriesData = await loadJsonAsset('assets/data/categories.json');
      final List<dynamic> categories = categoriesData['categories'] ?? [];
      return categories.map((cat) => cat['id'] as String).toList();
    } catch (e) {
      debugPrint('Error getting categories: $e');
      return [];
    }
  }

  /// Get image path for assets
  String getImagePath(String imageName) {
    if (imageName.startsWith('assets/')) {
      return imageName;
    }
    return 'assets/images/$imageName';
  }

  /// Get icon path for assets
  String getIconPath(String iconName) {
    if (iconName.startsWith('assets/')) {
      return iconName;
    }
    return 'assets/icons/$iconName';
  }

  /// Load course data for a specific category
  Future<Map<String, dynamic>> loadCategoryData(String categoryId) async {
    final path = 'assets/data/$categoryId.json';
    return await loadJsonAsset(path);
  }

  /// Check if asset exists
  Future<bool> assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear cache
  void clearCache() {
    _cache.clear();
    debugPrint('Asset cache cleared');
  }

  /// Get cache size
  int getCacheSize() {
    return _cache.length;
  }

  /// Preload essential assets
  Future<void> preloadEssentialAssets() async {
    try {
      debugPrint('Preloading essential assets...');
      
      // Load categories first
      await loadJsonAsset('assets/data/categories.json');
      
      // Load all category data
      final categories = await getAvailableCategories();
      for (final categoryId in categories) {
        try {
          await loadCategoryData(categoryId);
        } catch (e) {
          debugPrint('Warning: Could not preload $categoryId: $e');
        }
      }
      
      debugPrint('Essential assets preloaded successfully');
    } catch (e) {
      debugPrint('Error preloading assets: $e');
      // Don't throw here, app should still work without preloading
    }
  }
}

/// Custom exception for asset loading errors
class AssetLoadException implements Exception {
  final String message;
  final dynamic originalError;

  AssetLoadException(this.message, [this.originalError]);

  @override
  String toString() {
    if (originalError != null) {
      return 'AssetLoadException: $message\nOriginal error: $originalError';
    }
    return 'AssetLoadException: $message';
  }
}