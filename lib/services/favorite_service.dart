import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();
  factory FavoriteService() => _instance;
  FavoriteService._internal();

  static const String _favoritesKey = 'favorite_stations';

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Initialize SharedPreferences
  Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // Get all favorite station IDs
  List<String> getFavorites() {
    if (!_isInitialized) return [];
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  // Check if a station is favorited
  bool isFavorite(String stationId) {
    return getFavorites().contains(stationId);
  }

  // Get favorite count
  int getFavoriteCount() {
    return getFavorites().length;
  }

  // Add a station to favorites
  Future<bool> addFavorite(String stationId) async {
    if (!_isInitialized) await init();
    
    final favorites = getFavorites();
    if (favorites.contains(stationId)) return false;
    
    favorites.add(stationId);
    return await _prefs.setStringList(_favoritesKey, favorites);
  }

  // Remove a station from favorites
  Future<bool> removeFavorite(String stationId) async {
    if (!_isInitialized) await init();
    
    final favorites = getFavorites();
    if (!favorites.contains(stationId)) return false;
    
    favorites.remove(stationId);
    return await _prefs.setStringList(_favoritesKey, favorites);
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(String stationId) async {
    if (isFavorite(stationId)) {
      return await removeFavorite(stationId);
    } else {
      return await addFavorite(stationId);
    }
  }

  // Clear all favorites
  Future<bool> clearAllFavorites() async {
    if (!_isInitialized) await init();
    return await _prefs.remove(_favoritesKey);
  }
}