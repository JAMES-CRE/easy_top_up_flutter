
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'auth_state.dart';
import 'all_reviews_screen.dart';

class ReviewsSection extends StatefulWidget {
  final String stationId;
  final String stationName;

  const ReviewsSection({super.key,
   required this.stationId,
    required this.stationName
    });

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  

  // LOAD REVIEWS FROM API 
Future<void> _loadReviews() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    // ─── Only pass token if user is logged in 
    final token = AuthState.instance.isLoggedIn 
        ? AuthState.instance.token 
        : null;

    final reviews = await ApiService.getStationReviews(
      token: token,
      stationId: widget.stationId,
    );

    setState(() {
      _reviews = reviews;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
    });
  }
}


  // GET AVERAGE RATING
  double get _averageRating {
    if (_reviews.isEmpty) return 0.0;
    final total = _reviews.fold<int>(0, (sum, r) => sum + (r['rating'] as int));
    return total / _reviews.length;
  }

  // ADD REVIEW DIALOG
  void _showAddReviewDialog() {
    int selectedStars = 0;
    final commentController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: !isSubmitting,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Write a Review',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rating',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: isSubmitting
                            ? null
                            : () =>
                                setDialogState(() => selectedStars = index + 1),
                        child: Icon(
                          index < selectedStars
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Share your experience...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: _brandGreen, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedStars == 0) return;

                          setDialogState(() => isSubmitting = true);

                          try {
                            final token = AuthState.instance.token ?? '';
                            await ApiService.addReview(
                              token: token,
                              stationId: widget.stationId,
                              rating: selectedStars,
                              comment: commentController.text.trim(),
                            );

                            if (!context.mounted) return;
                            Navigator.pop(context);

                            // Reload reviews
                            await _loadReviews();

                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Review submitted — thank you!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    e.toString().replaceAll('Exception: ', '')),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // BUILD STAR ROW
  Widget _stars(int count, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  // FORMAT TIME
  String _timeAgo(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final diff = DateTime.now().difference(dateTime);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      return '${diff.inDays} day ago';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HEADER ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'REVIEWS',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            if (AuthState.instance.isLoggedIn)
              TextButton.icon(
                onPressed: _showAddReviewDialog,
                icon: const Icon(Icons.rate_review_outlined,
                    size: 16, color: _brandGreen),
                label: const Text(
                  'Add Review',
                  style: TextStyle(
                      color: _brandGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
              ),
          ],
        ),
        const SizedBox(height: 10),

        // LOADING STATE
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          ),

        // ERROR STATE
        if (_errorMessage != null && !_isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, color: Colors.grey[400], size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _loadReviews,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

        // AVERAGE RATING CARD
        if (!_isLoading && _errorMessage == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: _reviews.isEmpty
                ? Column(
                    children: [
                      Icon(Icons.rate_review_outlined,
                          size: 36, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      const Text(
                        'No reviews yet. Add one!',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Text(
                        _averageRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _stars(_averageRating.round(), size: 22),
                          const SizedBox(height: 4),
                          Text(
                            '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),

        const SizedBox(height: 12),

        // INDIVIDUAL REVIEWS
        if (!_isLoading && _errorMessage == null)
          ..._reviews.take(3).map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: _brandGreen.withOpacity(0.15),
                            backgroundImage: review['user_photo'] != null
                                ? NetworkImage(review['user_photo'])
                                : null,
                            child: review['user_photo'] == null
                                ? Text(
                                    (review['user_name'] ?? 'U')
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _brandGreen,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review['user_name'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _timeAgo(review['created_at']),
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _stars(review['rating'] as int),
                  if ((review['comment'] as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      review['comment'],
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ],
              ),
            );
          }),

            // SHOW MORE
        if (!_isLoading && _errorMessage == null && _reviews.length >3)
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllReviewsScreen(
                      stationId: widget.stationId,
                      stationName: widget.stationName,
                    ),
                  ),
                );
              },
              child: Text(
                'See all ${_reviews.length} reviews',
                style: const TextStyle(color: _brandGreen),
              ),
            ),
          ),
      ],
    );
  }
}
