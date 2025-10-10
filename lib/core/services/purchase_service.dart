import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../database/database_helper.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final String _defaultUserId = 'default_user';

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final StreamController<PurchaseUpdate> _purchaseUpdateController = 
      StreamController<PurchaseUpdate>.broadcast();

  // Product IDs - these should match your Google Play Console setup
  static const String unlockAllProductId = 'unlock_all_courses';
  static const List<String> courseProductIds = [
    'course_web_development_basics',
    'course_python_basics', 
    'course_basic_cooking',
    'course_persian_cuisine',
    'course_photography_basics',
    'course_guitar_beginner',
    'course_english_basics',
    'course_life_skills',
  ];

  static const List<String> allProductIds = [
    unlockAllProductId,
    ...courseProductIds,
  ];

  bool _isInitialized = false;
  List<ProductDetails> _products = [];
  Set<String> _purchasedProducts = {};

  Stream<PurchaseUpdate> get purchaseStream => _purchaseUpdateController.stream;  /// 
Initialize the purchase service
  Future<bool> initialize() async {
    try {
      if (_isInitialized) return true;

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('In-app purchases not available');
        return false;
      }

      // Load products
      await _loadProducts();

      // Load existing purchases
      await _loadExistingPurchases();

      // Listen to purchase updates
      _subscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          debugPrint('Purchase stream error: $error');
          _purchaseUpdateController.add(PurchaseUpdate(
            status: PurchaseStatus.error,
            error: error.toString(),
          ));
        },
      );

      _isInitialized = true;
      debugPrint('Purchase service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing purchase service: $e');
      return false;
    }
  }

  /// Load available products from the store
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(
        allProductIds.toSet(),
      );

      if (response.error != null) {
        debugPrint('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      debugPrint('Loaded ${_products.length} products');

      for (final product in _products) {
        debugPrint('Product: ${product.id} - ${product.title} - ${product.price}');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  /// Load existing purchases from the store
  Future<void> _loadExistingPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      
      // Also load from local database
      final purchasedCourses = await _databaseHelper.getPurchasedCourses(_defaultUserId);
      final hasUnlockAll = await _databaseHelper.hasUnlockAll(_defaultUserId);

      _purchasedProducts.addAll(purchasedCourses);
      if (hasUnlockAll) {
        _purchasedProducts.add(unlockAllProductId);
      }

      debugPrint('Loaded ${_purchasedProducts.length} existing purchases');
    } catch (e) {
      debugPrint('Error loading existing purchases: $e');
    }
  }

  /// Handle purchase updates from the store
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _processPurchase(purchaseDetails);
    }
  }

  /// Process individual purchase
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          debugPrint('Purchase pending: ${purchaseDetails.productID}');
          _purchaseUpdateController.add(PurchaseUpdate(
            status: PurchaseStatus.pending,
            productId: purchaseDetails.productID,
          ));
          break;

        case PurchaseStatus.purchased:
          debugPrint('Purchase successful: ${purchaseDetails.productID}');
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          debugPrint('Purchase error: ${purchaseDetails.error}');
          _purchaseUpdateController.add(PurchaseUpdate(
            status: PurchaseStatus.error,
            productId: purchaseDetails.productID,
            error: purchaseDetails.error?.message,
          ));
          break;

        case PurchaseStatus.restored:
          debugPrint('Purchase restored: ${purchaseDetails.productID}');
          await _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.canceled:
          debugPrint('Purchase canceled: ${purchaseDetails.productID}');
          _purchaseUpdateController.add(PurchaseUpdate(
            status: PurchaseStatus.canceled,
            productId: purchaseDetails.productID,
          ));
          break;
      }

      // Complete the purchase
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    } catch (e) {
      debugPrint('Error processing purchase: $e');
      _purchaseUpdateController.add(PurchaseUpdate(
        status: PurchaseStatus.error,
        productId: purchaseDetails.productID,
        error: e.toString(),
      ));
    }
  }

  /// Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      final productId = purchaseDetails.productID;
      
      // Record purchase in database
      await _databaseHelper.recordPurchase(
        userId: _defaultUserId,
        courseId: _getCourseIdFromProductId(productId),
        productId: productId,
        purchaseToken: purchaseDetails.purchaseID,
        purchaseTime: DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(purchaseDetails.transactionDate ?? '0') ?? 0,
        ),
        isUnlockAll: productId == unlockAllProductId,
      );

      // Update local state
      _purchasedProducts.add(productId);

      // Notify listeners
      _purchaseUpdateController.add(PurchaseUpdate(
        status: PurchaseStatus.purchased,
        productId: productId,
      ));

      debugPrint('Purchase recorded successfully: $productId');
    } catch (e) {
      debugPrint('Error handling successful purchase: $e');
      rethrow;
    }
  }

  /// Get course ID from product ID
  String? _getCourseIdFromProductId(String productId) {
    if (productId == unlockAllProductId) return null;
    
    // Map product IDs to course IDs
    const productToCourseMap = {
      'course_web_development_basics': 'web-development-basics',
      'course_python_basics': 'python-basics',
      'course_basic_cooking': 'basic-cooking',
      'course_persian_cuisine': 'persian-cuisine',
      'course_photography_basics': 'photography-basics',
      'course_guitar_beginner': 'guitar-beginner',
      'course_english_basics': 'english-basics',
      'course_life_skills': 'life-skills',
    };

    return productToCourseMap[productId];
  }  /// P
urchase a product
  Future<bool> purchaseProduct(String productId) async {
    try {
      if (!_isInitialized) {
        debugPrint('Purchase service not initialized');
        return false;
      }

      final product = _products.firstWhere(
        (p) => p.id == productId,
        orElse: () => throw ArgumentError('Product not found: $productId'),
      );

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      debugPrint('Initiating purchase for: $productId');
      final bool success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      _purchaseUpdateController.add(PurchaseUpdate(
        status: PurchaseStatus.error,
        productId: productId,
        error: e.toString(),
      ));
      return false;
    }
  }

  /// Check if a product is purchased
  bool isPurchased(String productId) {
    return _purchasedProducts.contains(productId) || 
           _purchasedProducts.contains(unlockAllProductId);
  }

  /// Check if a course is purchased
  Future<bool> isCourseUnlocked(String courseId) async {
    try {
      // Check if unlock all is purchased
      if (_purchasedProducts.contains(unlockAllProductId)) {
        return true;
      }

      // Check if specific course is purchased
      final purchasedCourses = await _databaseHelper.getPurchasedCourses(_defaultUserId);
      return purchasedCourses.contains(courseId);
    } catch (e) {
      debugPrint('Error checking course unlock status: $e');
      return false;
    }
  }

  /// Get purchased courses
  Future<Set<String>> getPurchasedCourses() async {
    try {
      final purchasedCourses = await _databaseHelper.getPurchasedCourses(_defaultUserId);
      return purchasedCourses.toSet();
    } catch (e) {
      debugPrint('Error getting purchased courses: $e');
      return {};
    }
  }

  /// Check if unlock all is purchased
  Future<bool> hasUnlockAll() async {
    try {
      return await _databaseHelper.hasUnlockAll(_defaultUserId);
    } catch (e) {
      debugPrint('Error checking unlock all status: $e');
      return false;
    }
  }

  /// Get product details
  List<ProductDetails> getProducts() {
    return List.unmodifiable(_products);
  }

  /// Get product by ID
  ProductDetails? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      debugPrint('Restoring purchases...');
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      _purchaseUpdateController.add(PurchaseUpdate(
        status: PurchaseStatus.error,
        error: 'Failed to restore purchases: $e',
      ));
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _purchaseUpdateController.close();
    _isInitialized = false;
    debugPrint('Purchase service disposed');
  }
}

/// Purchase update model
class PurchaseUpdate {
  final PurchaseStatus status;
  final String? productId;
  final String? error;

  PurchaseUpdate({
    required this.status,
    this.productId,
    this.error,
  });

  @override
  String toString() {
    return 'PurchaseUpdate(status: $status, productId: $productId, error: $error)';
  }
}

/// Purchase status enum
enum PurchaseStatus {
  pending,
  purchased,
  error,
  restored,
  canceled,
}