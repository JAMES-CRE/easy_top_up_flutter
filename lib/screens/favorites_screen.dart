import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/favorite_service.dart';
import 'api_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);
  
  List<Map<String, dynamic>> _favoriteStations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final favoriteIds = FavoriteService().getFavorites();
      
      if (favoriteIds.isEmpty) {
        setState(() {
          _favoriteStations = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch all stations from API
      final allStations = await ApiService.getStations();
      
      // Filter only favorite stations
      final favorites = allStations.where((station) {
        return favoriteIds.contains(station['id'].toString());
      }).toList();

      setState(() {
        _favoriteStations = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }


  void _removeFavorite(String stationId) async {
  await FavoriteService().removeFavorite(stationId);
  // Reload the entire list to ensure consistency
  await _loadFavorites();
}

  // Get distance 
  String _getDistance(double stationLat, double stationLng) {
    return '${(stationLat + stationLng).toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          ' My Favorites',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadFavorites,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _favoriteStations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text(
                            'No favorites yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Start saving your favorite stations\nby tapping the heart on any station',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorites,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _favoriteStations.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey,
                          indent: 56,
                        ),
                        itemBuilder: (context, index) {
                          final station = _favoriteStations[index];
                          final stationId = station['id'].toString();
                          final stationType = station['type'] ?? 'Unknown';
                          
                          // Get icon based on type
                          IconData typeIcon;
                          Color typeColor;
                          switch (stationType) {
                            case 'Petrol/Diesel':
                              typeIcon = Icons.local_gas_station;
                              typeColor = Colors.amber.shade700;
                              break;
                            case 'LPG':
                              typeIcon = Icons.gas_meter;
                              typeColor = Colors.blue.shade600;
                              break;
                            case 'EV':
                              typeIcon = Icons.electric_bolt;
                              typeColor = Colors.green.shade600;
                              break;
                            default:
                              typeIcon = Icons.help_outline;
                              typeColor = Colors.grey;
                          }

                          return InkWell(
                            onTap: () {
                              Navigator.pop(context, station);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: typeColor.withOpacity(0.15),
                                    ),
                                    child: Icon(typeIcon, color: typeColor, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station['name'] ?? 'Unknown Station',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$stationType • ${_getDistance(station['lat'] ?? 0, station['lng'] ?? 0)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _removeFavorite(stationId);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Removed from favorites'),
                                          duration: const Duration(seconds: 1),
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}