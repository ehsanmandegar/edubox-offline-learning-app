import '../services/purchase_service.dart';

abstract class PurchaseRepository {
  Future<bool> isPurchased(String courseId);
  Future<void> recordPurchase(String courseId);
  Future<List<String>> getPurchasedCourses();
  Future<bool> hasUnlockAll();
  Stream<PurchaseUpdate> get purchaseStream;
  Future<bool> purchaseCourse(String courseId);
  Future<bool> purchaseUnlockAll();
  Future<void> restorePurchases();
}