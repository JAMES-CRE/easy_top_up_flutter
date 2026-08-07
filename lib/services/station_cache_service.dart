
import 'package:hive/hive.dart';
import '../models/station.dart';

class StationCacheService {
  static const String _stationsBox = 'stations';
  static const String _metadataBox = 'metadata';
  static const String _reviewsBox = 'reviews';
  static const String _reportsBox = 'reports';
  static const String _lastUpdatedKey = 'last_updated';
  static const String _stationCountKey = 'station_count';


static Map<String, dynamic> _deepConvert(Map map) {
  return map.map((key, value) {
    final stringKey = key.toString();

    if (value is Map) {
      return MapEntry(stringKey, _deepConvert(value));
    }

    if (value is List) {
      return MapEntry(stringKey, _deepConvertList(value));
    }

    return MapEntry(stringKey, value);
  });
}
static List _deepConvertList(List list) {
  return list.map((item) {
    if (item is Map) return _deepConvert(item);
    if (item is List) return _deepConvertList(item);
    return item;
  }).toList();
}





  // STATION CACHING  
  static Future<void> saveStations(List<CachedStation> stations) async {
    try {
      final box = await Hive.openBox<CachedStation>(_stationsBox);
      await box.clear();
      
      for (var station in stations) {
        await box.put(station.id, station);
      }

      final metaBox = await Hive.openBox(_metadataBox);
      await metaBox.put(_lastUpdatedKey, DateTime.now().toIso8601String());
      await metaBox.put(_stationCountKey, stations.length);

      print(' Cached ${stations.length} stations');
    } catch (e) {
      print(' Error saving stations: $e');
    }
  }

  static Future<List<CachedStation>> loadStations() async {
    try {
      final box = await Hive.openBox<CachedStation>(_stationsBox);
      return box.values.toList();
    } catch (e) {
      print(' Error loading stations: $e');
      return [];
    }
  }

  static Future<bool> hasCachedStations() async {
    try {
      final box = await Hive.openBox<CachedStation>(_stationsBox);
      return box.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // REVIEW CACHING 
  static Future<void> saveReviews(String stationId, List<Map<String, dynamic>> reviews) async {
    try {
      final box = await Hive.openBox(_reviewsBox);
      await box.put(stationId, reviews);
      print(' Cached ${reviews.length} reviews for station $stationId');
    } catch (e) {
      print(' Error saving reviews: $e');
    }
  }

  

static Future<List<Map<String, dynamic>>> loadReviews(
    String stationId) async {
  try {
    final box = await Hive.openBox(_reviewsBox);
    final data = box.get(stationId);

    if (data != null && data is List) {
      return data
          .map((item) {
            if (item is Map) {
              return _deepConvert(item); 
            }
            return <String, dynamic>{};
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  } catch (e) {
    print(' Error loading reviews: $e');
    return [];
  }
}



  static Future<bool> hasCachedReviews(String stationId) async {
    try {
      final box = await Hive.openBox(_reviewsBox);
      final data = box.get(stationId);
      return data != null && data is List && data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // REPORT CACHING 
  static Future<void> saveReports(String stationId, List<Map<String, dynamic>> reports) async {
    try {
      final box = await Hive.openBox(_reportsBox);
      await box.put(stationId, reports);
      print(' Cached ${reports.length} reports for station $stationId');
    } catch (e) {
      print(' Error saving reports: $e');
    }
  }

  


static Future<List<Map<String, dynamic>>> loadReports(
    String stationId) async {
  try {
    final box = await Hive.openBox(_reportsBox);
    final data = box.get(stationId);

    if (data != null && data is List) {
      return data
          .map((item) {
            if (item is Map) {
              return _deepConvert(item); // ← safe conversion
            }
            return <String, dynamic>{};
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  } catch (e) {
    print('❌ Error loading reports: $e');
    return [];
  }
}



  static Future<bool> hasCachedReports(String stationId) async {
    try {
      final box = await Hive.openBox(_reportsBox);
      final data = box.get(stationId);
      return data != null && data is List && data.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  //  METADATA 
  static Future<String?> getLastUpdated() async {
    try {
      final metaBox = await Hive.openBox(_metadataBox);
      return metaBox.get(_lastUpdatedKey);
    } catch (e) {
      return null;
    }
  }

  static Future<int> getStationCount() async {
    try {
      final metaBox = await Hive.openBox(_metadataBox);
      return metaBox.get(_stationCountKey) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // CLEAR ALL CACHE
  static Future<void> clearCache() async {
    try {
      final stationsBox = await Hive.openBox(_stationsBox);
      await stationsBox.clear();
      
      final reviewsBox = await Hive.openBox(_reviewsBox);
      await reviewsBox.clear();
      
      final reportsBox = await Hive.openBox(_reportsBox);
      await reportsBox.clear();
      
      final metaBox = await Hive.openBox(_metadataBox);
      await metaBox.clear();
      
      print(' All cache cleared');
    } catch (e) {
      print(' Error clearing cache: $e');
    }
  }
}