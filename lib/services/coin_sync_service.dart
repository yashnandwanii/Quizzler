import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quizzler/repository/authentication_repository/authentication_repository.dart';
import 'package:quizzler/services/firestore_service.dart';

/// Service to handle coin synchronization across the app
/// This ensures that coin values are always up-to-date when needed
class CoinSyncService extends GetxController {
  static CoinSyncService get instance => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable coin value that widgets can listen to
  final RxInt currentCoins = 0.obs;
  final RxBool isLoading = false.obs;

  // Cache for coin values with timestamp
  Map<String, dynamic> _coinCache = {};
  static const int _cacheValidityMs = 30000; // 30 seconds

  @override
  void onInit() {
    super.onInit();
    _initializeCoinSync();
  }

  /// Initialize coin synchronization for the current user
  void _initializeCoinSync() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    if (userId != null) {
      await refreshCoins(userId);
    }
  }

  /// Refresh coins from Firebase for a specific user
  Future<int> refreshCoins(String userId) async {
    try {
      isLoading.value = true;

      // Check cache first
      if (_isCacheValid(userId)) {
        final cachedCoins = _coinCache[userId]['coins'] as int;
        currentCoins.value = cachedCoins;
        isLoading.value = false;
        return cachedCoins;
      }

      // Fetch from Firebase
      final coins = await FirestoreService.getUserCoins(userId);

      // Update cache
      _coinCache[userId] = {
        'coins': coins,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Update observable
      currentCoins.value = coins;

      debugPrint('CoinSyncService: Refreshed coins for user $userId: $coins');
      return coins;
    } catch (e) {
      debugPrint('CoinSyncService: Error refreshing coins: $e');
      return currentCoins.value;
    } finally {
      isLoading.value = false;
    }
  }

  /// Force refresh coins (ignores cache)
  Future<int> forceRefreshCoins(String userId) async {
    _coinCache.remove(userId); // Clear cache
    return await refreshCoins(userId);
  }

  /// Check if cached coins are still valid
  bool _isCacheValid(String userId) {
    if (!_coinCache.containsKey(userId)) return false;

    final cachedTime = _coinCache[userId]['timestamp'] as int;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    return (currentTime - cachedTime) < _cacheValidityMs;
  }

  /// Get current coins for the logged-in user
  Future<int> getCurrentUserCoins() async {
    final authRepo = Get.find<AuthenticationRepository>();
    final userId = authRepo.firebaseUser.value?.uid;

    if (userId == null) return 0;

    return await refreshCoins(userId);
  }

  /// Update coins locally (for immediate UI updates)
  void updateCoinsLocally(String userId, int newCoins) {
    currentCoins.value = newCoins;

    // Update cache
    _coinCache[userId] = {
      'coins': newCoins,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    debugPrint(
        'CoinSyncService: Updated coins locally for user $userId: $newCoins');
  }

  /// Increment coins locally (for immediate UI updates after earning)
  void incrementCoinsLocally(String userId, int coinsEarned) {
    final newCoins = currentCoins.value + coinsEarned;
    updateCoinsLocally(userId, newCoins);
  }

  /// Clear cache for a specific user
  void clearUserCache(String userId) {
    _coinCache.remove(userId);
  }

  /// Clear all cache
  void clearAllCache() {
    _coinCache.clear();
  }

  /// Listen to real-time coin updates from Firebase
  Stream<int> watchUserCoins(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        final coins = doc.data()!['coins'] ?? 0;
        updateCoinsLocally(userId, coins);
        return coins;
      }
      return 0;
    });
  }
}
