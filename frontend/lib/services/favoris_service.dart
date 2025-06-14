// lib/services/favoris_service.dart
import 'package:flutter/material.dart';
import 'package:restaurant_app/models/plat.dart';
import 'package:rxdart/rxdart.dart'; // Add rxdart to your pubspec.yaml

/// A singleton service to manage favorite dishes.
class FavorisService {
  // Use a BehaviorSubject to allow listening to changes in the favorites list
  final BehaviorSubject<List<Plat>> _favorisController =
      BehaviorSubject<List<Plat>>.seeded([]);

  // Expose the stream for other widgets to listen to
  Stream<List<Plat>> get favorisStream => _favorisController.stream;

  // Private list to hold favorite dishes
  final List<Plat> _favoris = [];

  // Private constructor
  FavorisService._privateConstructor();

  // Singleton instance
  static final FavorisService _instance = FavorisService._privateConstructor();

  // Factory constructor to return the singleton instance
  factory FavorisService() {
    return _instance;
  }

  /// Adds a plat to favorites if it's not already there.
  void addFavorite(Plat plat) {
    if (!isFavorite(plat)) {
      _favoris.add(plat);
      _favorisController.add(_favoris.toList()); // Notify listeners
      debugPrint('Added to favorites: ${plat.nomPlat}');
    }
  }

  /// Removes a plat from favorites by its ID.
  void removeFavorite(String platId) {
    _favoris.removeWhere((plat) => plat.id == platId);
    _favorisController.add(_favoris.toList()); // Notify listeners
    debugPrint('Removed from favorites: $platId');
  }

  /// Checks if a plat is in favorites.
  bool isFavorite(Plat plat) {
    return _favoris.any((favPlat) => favPlat.id == plat.id);
  }

  /// Returns the current list of favorite dishes.
  List<Plat> getFavoris() {
    return _favoris.toList();
  }

  /// Clears all favorites. (Useful for testing or specific scenarios)
  void clearFavoris() {
    _favoris.clear();
    _favorisController.add(_favoris.toList());
    debugPrint('All favorites cleared.');
  }

  void dispose() {
    _favorisController.close();
  }
}
