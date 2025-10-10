import 'package:flutter/foundation.dart';
import '../services/purchase_service.dart';
import 'purchase_repository.dart';

class LocalPurchaseRepository implements PurchaseRepository {
  final PurchaseService _purchaseService;

  // Map course IDs to product IDs
  static const Map<String, String> _courseToProductMap = {
    'web-development-basics': 'course_web_development_basics',
    'python-basics': 'course_python_basics',
    'basic-cooking': 'course_basic_cooking',
    'persian-cuisine': 'course_persian_cuisine',
    'photography-basics': 'course_photography_basics',
    'guitar-beginner': 'course_guitar_beginner',
    'english-basics': 'course_english_basics',
    'life-skills': 'course_life_skills',
  };

  LocalPurchaseRepository({PurchaseService? purchaseService})
      : _purchaseService = purchaseService ?? PurchaseService();

  @override
  Future<bool> isPurchased(String courseId) async {
    try {
      return await _purchaseService.isCourseUnlocked(courseId);
    } catch (e) {
      debugPrint('Error checking purchase status: $e');
      return false;
    }
  }

  @override
  Future<void> recordPurchase(String courseId) async {
    try {
      // This is handled automatically by PurchaseService when a purchase is made
      debugPrint('Purchase recorded for course: $courseId');
    } catch (e) {
      debugPrint('Error recording purchase: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getPurchasedCourses() async {
    try {
      final purchasedCourses = await _purchaseService.getPurchasedCourses();
      return purchasedCourses.toList();
    } catch (e) {
      debugPrint('Error getting purchased courses: $e');
      return [];
    }
  }

  @override
  Future<bool> hasUnlockAll() async {
    try {
      return await _purchaseService.hasUnlockAll();
    } catch (e) {
      debugPrint('Error checking unlock all status: $e');
      return false;
    }
  }

  @override
  Stream<PurchaseUpdate> get purchaseStream => _purchaseService.purchaseStream;

  @override
  Future<bool> purchaseCourse(String courseId) async {
    try {
      final productId = _courseToProductMap[courseId];
      if (productId == null) {
        debugPrint('No product ID found for course: $courseId');
        return false;
      }

      return await _purchaseService.purchaseProduct(productId);
    } catch (e) {
      debugPrint('Error purchasing course: $e');
      return false;
    }
  }

  @override
  Future<bool> purchaseUnlockAll() async {
    try {
      return await _purchaseService.purchaseProduct(PurchaseService.unlockAllProductId);
    } catch (e) {
      debugPrint('Error purchasing unlock all: $e');
      return false;
    }
  }

  @override
  Future<void> restorePurchases() async {
    try {
      await _purchaseService.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      rethrow;
    }
  }

  /// Get product ID for a course
  String? getProductIdForCourse(String courseId) {
    return _courseToProductMap[courseId];
  }

  /// Get course ID from product ID
  String? getCourseIdFromProduct(String productId) {
    for (final entry in _courseToProductMap.entries) {
      if (entry.value == productId) {
        return entry.key;
      }
    }
    return null;
  }

  /// Initialize purchase service
  Future<bool> initialize() async {
    try {
      return await _purchaseService.initialize();
    } catch (e) {
      debugPrint('Error initializing purchase repository: $e');
      return false;
    }
  }

  /// Get available products
  List<ProductDetails> getAvailableProducts() {
    return _purchaseService.getProducts();
  }

  /// Get product details for a course
  ProductDetails? getProductForCourse(String courseId) {
    final productId = _courseToProductMap[courseId];
    if (productId == null) return null;
    
    return _purchaseService.getProduct(productId);
  }

  /// Get unlock all product details
  ProductDetails? getUnlockAllProduct() {
    return _purchaseService.getProduct(PurchaseService.unlockAllProductId);
  }
}