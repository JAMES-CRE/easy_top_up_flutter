

class ReviewsStore {
  ReviewsStore._();
  static final ReviewsStore instance = ReviewsStore._();

  // Key = station id, Value = list of reviews
  final Map<String, List<Map<String, dynamic>>> _reviews = {};

  // Add a review for a station
  void addReview({
    required String stationId,
    required int stars,        // 1 to 5
    required String comment,
    required String userName,
  }) {
    _reviews[stationId] ??= [];
    _reviews[stationId]!.insert(0, {
      'stars': stars,
      'comment': comment,
      'userName': userName,
      'timestamp': DateTime.now(),
    });
  }

  // Get all reviews for a station
  List<Map<String, dynamic>> getReviews(String stationId) {
    return _reviews[stationId] ?? [];
  }

  // Get average star rating for a station
  double getAverageRating(String stationId) {
    final reviews = _reviews[stationId];
    if (reviews == null || reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(
        0, (sum, r) => sum + (r['stars'] as int));
    return total / reviews.length;
  }
}