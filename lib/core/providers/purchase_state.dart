import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/purchase_repository.dart';
import '../repositories/local_purchase_repository.dart';
import '../services/purchase_service.dart';

class PurchaseState extends ChangeNotifier {
  final PurchaseRepository _purchaseRepository;
  StreamSubscription<PurchaseUpdate>? _purchaseSubscription;
  
  Set<String> _purchasedCourses = {};
  bool _isPurchasing = false;
  String? _lastPurchaseError;
  bool _hasUnlockAll = false;
  bool _isInitialized = false;

  PurchaseState({PurchaseRepository? purchaseRepository}) 
      : _purchaseRepository = purchaseRepository ?? LocalPurchaseRepository() {
    _initializePurchaseListener();
  }

  Set<String> get purchasedCourses => _purchasedCourses;
  bool get isPurchasing => _isPurchasing;
  String? get lastPurchaseError => _lastPurchaseError;
  bool get hasUnlockAll => _hasUnlockAll;
  bool get isInitialized => _isInitialized;

  void setPurchasing(bool purchasing) {
    if (_isPurchasing != purchasing) {
      _isPurchasing = purchasing;
      notifyListeners();
    }
  }

  void setPurchaseError(String? error) {
    if (_lastPurchaseError != error) {
      _lastPurchaseError = error;
      notifyListeners();
    }
  }

  void addPurchasedCourse(String courseId) {
    if (!_purchasedCourses.contains(courseId)) {
      _purchasedCourses.add(courseId);
      notifyListeners();
    }
  }

  void setUnlockAll(bool unlocked) {
    if (_hasUnlockAll != unlocked) {
      _hasUnlockAll = unlocked;
      notifyListeners();
    }
  }

  bool isPurchased(String courseId) {
    return _hasUnlockAll || _purchasedCourses.contains(courseId);
  }

  void loadPurchasedCourses(Set<String> courses) {
    _purchasedCourses = courses;
    notifyListeners();
  }
}  //
/ Initialize purchase listener
  void _initializePurchaseListener() {
    _purchaseSubscription = _purchaseRepository.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (error) {
        debugPrint('Purchase stream error: $error');
        setPurchaseError(error.toString());
      },
    );
  }

  /// Handle purchase updates
  void _handlePurchaseUpdate(PurchaseUpdate update) {
    switch (update.status) {
      case PurchaseStatus.pending:
        setPurchasing(true);
        setPurchaseError(null);
        break;
        
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        setPurchasing(false);
        setPurchaseError(null);
        _refreshPurchaseData();
        break;
        
      case PurchaseStatus.error:
        setPurchasing(false);
        setPurchaseError(update.error ?? 'Purchase failed');
        break;
        
      case PurchaseStatus.canceled:
        setPurchasing(false);
        setPurchaseError(null);
        break;
    }
  }

  /// Initialize purchase data
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize the purchase repository if it's LocalPurchaseRepository
      if (_purchaseRepository is LocalPurchaseRepository) {
        final success = await (_purchaseRepository as LocalPurchaseRepository).initialize();
        if (!success) {
          debugPrint('Failed to initialize purchase service');
        }
      }
      
      await _refreshPurchaseData();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing purchase state: $e');
      setPurchaseError('Failed to initialize purchases: $e');
    }
  }

  /// Refresh purchase data from repository
  Future<void> _refreshPurchaseData() async {
    try {
      final purchasedCourses = await _purchaseRepository.getPurchasedCourses();
      final hasUnlockAll = await _purchaseRepository.hasUnlockAll();
      
      loadPurchasedCourses(purchasedCourses.toSet());
      setUnlockAll(hasUnlockAll);
    } catch (e) {
      debugPrint('Error refreshing purchase data: $e');
    }
  }

  /// Purchase a course
  Future<bool> purchaseCourse(String courseId) async {
    try {
      setPurchasing(true);
      setPurchaseError(null);
      
      final success = await _purchaseRepository.purchaseCourse(courseId);
      
      if (!success) {
        setPurchasing(false);
        setPurchaseError('Failed to initiate purchase');
      }
      
      return success;
    } catch (e) {
      setPurchasing(false);
      setPurchaseError('Purchase error: $e');
      return false;
    }
  }

  /// Purchase unlock all
  Future<bool> purchaseUnlockAll() async {
    try {
      setPurchasing(true);
      setPurchaseError(null);
      
      final success = await _purchaseRepository.purchaseUnlockAll();
      
      if (!success) {
        setPurchasing(false);
        setPurchaseError('Failed to initiate unlock all purchase');
      }
      
      return success;
    } catch (e) {
      setPurchasing(false);
      setPurchaseError('Purchase error: $e');
      return false;
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      setPurchasing(true);
      setPurchaseError(null);
      
      await _purchaseRepository.restorePurchases();
      await _refreshPurchaseData();
    } catch (e) {
      setPurchaseError('Failed to restore purchases: $e');
    } finally {
      setPurchasing(false);
    }
  }

  /// Check if a course is purchased
  Future<bool> isCourseUnlocked(String courseId) async {
    try {
      return await _purchaseRepository.isPurchased(courseId);
    } catch (e) {
      debugPrint('Error checking course unlock status: $e');
      return false;
    }
  }

  /// Clear purchase error
  void clearError() {
    setPurchaseError(null);
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}