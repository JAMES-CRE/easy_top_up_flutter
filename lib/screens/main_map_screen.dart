import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'search_filter_screen.dart';
import 'report_issue_screen.dart';
import 'profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'auth_screen.dart';
import 'auth_state.dart';
import 'dart:math';
//import 'operator_dashboard_screen.dart';
//import 'auth_state.dart';
import 'review_section.dart';
import 'api_service.dart';
import '../services/favorite_service.dart';
import 'operator_home_screen.dart';
import 'station_reports_screen.dart';
import '../services/station_cache_service.dart';
import '../models/station.dart';

class MainMapScreen extends StatefulWidget {
  const MainMapScreen({super.key});

  @override
  State<MainMapScreen> createState() => _MainMapScreenState();
}

class _MainMapScreenState extends State<MainMapScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(6.6885, -1.6244),
    zoom: 13,
  );

  GoogleMapController? _mapController;

  Position? _currentPosition;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _stations = [];



  BitmapDescriptor? _petrolMarker;
  BitmapDescriptor? _lpgMarker;
  BitmapDescriptor? _evMarker;
  




  //  LOAD STATIONS WITH CACHING
  Future<void> _loadStations() async {
    setState(() => _isLoading = true);
    try {
      final hasCache = await StationCacheService.hasCachedStations();
      if (hasCache) {
        final cachedStations = await StationCacheService.loadStations();
        final cachedJson = cachedStations.map((s) => s.toJson()).toList();
        setState(() {
          _stations = cachedJson;
          _markers = _buildMarkers();
          _isLoading = false; 
        });
        print(' Loaded ${cachedStations.length} stations from cache');
      } else {
        setState(() => _isLoading = true);
      }



      //  FETCH FRESH DATA IN BACKGROUND
      final freshStations = await ApiService.getStations();

      if (freshStations.isNotEmpty) {
      
        final cached =
            freshStations.map((s) => CachedStation.fromJson(s)).toList();
        await StationCacheService.saveStations(cached);

        setState(() {
          _stations = freshStations;
          _markers = _buildMarkers();
          _isLoading = false;
        });

        print(' Updated with ${freshStations.length} fresh stations');
      }

      if (_currentPosition != null) {
        final googleStations = await ApiService.getNearbyFuelStations(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          radius: 5000,
        );

        if (mounted && googleStations.isNotEmpty) {
          setState(() {
            _stations = [..._stations, ...googleStations];
            _markers = _buildMarkers();
          });
        }
      }
    } catch (e) {
      //  ERROR HANDLING
      if (!await StationCacheService.hasCachedStations()) {
        setState(() {
          _errorMessage = 'Failed to load stations. Check your connection.';
          _isLoading = false;
        });
      }
      print(' Error loading stations: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() => _isLoading = false);
    _getCurrentLocation();
    _loadMarkerAssets();
     
  }

  // GPS LOCATION
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Location permanently denied. Open app settings.')),
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _markers = _buildMarkers(); // Rebuild markers to include user location
        _isLoading = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );

      //Load stations
      _loadStations();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString().contains('TimeoutException') ? 'Request timed out' : e}')),
      );
      setState(() => _isLoading = false);
    }
  }

// PULL TO REFRESH
  Future<void> _refreshStations() async {
    try {
      final freshStations = await ApiService.getStations();
      final cached =
          freshStations.map((s) => CachedStation.fromJson(s)).toList();
      await StationCacheService.saveStations(cached);

      setState(() {
        _stations = freshStations;
        _markers = _buildMarkers();
      });
    } catch (e) {
      print(' Refresh failed: $e');
      rethrow;
    }
  }

  // DISTANCE CALCULATOR
  String _getDistance(double stationLat, double stationLng) {
    if (_currentPosition == null) return '';

    const double earthRadius = 6371;

    double lat1 = _currentPosition!.latitude * pi / 180;
    double lat2 = stationLat * pi / 180;
    double deltaLat = (stationLat - _currentPosition!.latitude) * pi / 180;
    double deltaLng = (stationLng - _currentPosition!.longitude) * pi / 180;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1) * cos(lat2) * sin(deltaLng / 2) * sin(deltaLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m away';
    }
    return '${distance.toStringAsFixed(1)} km away';
  }





// LOAD MARKER ASSETS 
Future<void> _loadMarkerAssets() async {
  try {
    final petrol = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/marker_petrol.png',
      width: 30,
      height: 30,
    );
    final lpg = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/marker_lpg.png',
      width: 30,
      height: 30,
    );
    final ev = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/marker_ev.png',
      width: 30,
      height: 30,
    );

    if (mounted) {
      setState(() {
        _petrolMarker = petrol;
        _lpgMarker = lpg;
        _evMarker = ev;
      });
    }
  } catch (e) {
    print(' Error loading marker assets: $e');
  }
}






  //  BUILD MARKERS 
Set<Marker> _buildMarkers() {
  final markers = <Marker>{};

  // Add user location marker (important for web since myLocationEnabled doesn't work)
  if (_currentPosition != null) {
    markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
        zIndex: 999, // Make sure it appears on top
      ),
    );
  }

  for (final station in _stations) {
    try {
      final id = station['id'];
      final lat = station['lat'];
      final lng = station['lng'];
      final type = station['type'] ?? 'Petrol/Diesel';
      final isGoogle = station['isGooglePlace'] == true;

      if (id == null || lat == null || lng == null) continue;

      final latDouble = (lat as num).toDouble();
      final lngDouble = (lng as num).toDouble();

      if (latDouble == 0.0 && lngDouble == 0.0) continue;

      // GET MARKER ICON 
      final icon = _getMarkerIcon(type);

      markers.add(
        Marker(
          markerId: MarkerId(id.toString()),
          position: LatLng(latDouble, lngDouble),
          icon: icon,
          onTap: isGoogle
              ? () => _openInGoogleMaps(station)
              : () => _showBottomSheet(station),
        ),
      );
    } catch (e) {
      print(' Marker error: $e');
    }
  }

  print('Markers built: ${markers.length} (including user location)');
  return markers;
}

BitmapDescriptor _getMarkerIcon(String type) {
  if (_petrolMarker != null && type == 'Petrol/Diesel') return _petrolMarker!;
  if (_lpgMarker != null && type == 'LPG') return _lpgMarker!;
  if (_evMarker != null && type == 'EV') return _evMarker!;

  // Fallback: use default colored markers 
  switch (type) {
    case 'Petrol/Diesel':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
    case 'LPG':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    case 'EV':
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
    default:
      return BitmapDescriptor.defaultMarker;
  }
}

  //  STATION TYPE BADGE
  Widget _typeBadge(String type) {
    Color color;
    IconData icon;

    switch (type) {
      case 'Petrol/Diesel':
        color = Colors.amber.shade700;
        icon = Icons.local_gas_station;
        break;
      case 'LPG':
        color = Colors.blue.shade600;
        icon = Icons.gas_meter;
        break;
      case 'EV':
        color = Colors.green.shade600;
        icon = Icons.electric_bolt;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            type,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// GET STATUS COLOR
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Open':
        return Colors.green;
      case 'Closed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }


  // BOTTOM SHEET
  void _showBottomSheet(Map<String, dynamic> station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          snap: true,
          snapSizes: const [0.35, 0.55, 0.95],
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8FA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              station['name'],
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),

                          // Heart icon for favorites (only for logged-in users)
                          if (AuthState.instance.isLoggedIn)
                            GestureDetector(
                              onTap: () async {
                                final stationId = station['id'].toString();
                                await FavoriteService()
                                    .toggleFavorite(stationId);
                                final nowFavorite =
                                    FavoriteService().isFavorite(stationId);
                                setState(() {}); // Refresh the bottom sheet
                                _loadStations(); // Refresh markers on the map

                                // Show feedback reaction
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: nowFavorite
                                        ? Colors.red.shade600
                                        : Colors.grey.shade800,
                                    duration: const Duration(seconds: 2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    content: Row(
                                      children: [
                                        Icon(
                                          nowFavorite
                                              ? Icons.favorite
                                              : Icons.heart_broken,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            nowFavorite
                                                ? 'Added ${station['name']} to favorites'
                                                : 'Removed ${station['name']} from favorites',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  FavoriteService()
                                          .isFavorite(station['id'].toString())
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: FavoriteService()
                                          .isFavorite(station['id'].toString())
                                      ? Colors.red
                                      : Colors.grey,
                                  size: 24,
                                ),
                              ),
                            ),

                          _typeBadge(station['type']),
                        ],
                      ),

                      //
                      if (station['source'] == 'google')
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              'Google',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.blue.shade700),
                            ),
                          ),
                        ),

                      // Show rating if available
                      if (station['rating'] != null && station['rating'] > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(
                                '${station['rating']} (${station['ratingCount']} reviews)',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                      // Show photos if available
                      if (station['photos'] != null &&
                          (station['photos'] as List).isNotEmpty)
                        // Add photo carousel here (same as your existing photo display)

                        const SizedBox(height: 8),

                      const SizedBox(height: 12),

                      // DISTANCE + STATUS CARD
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Distance
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 18, color: _brandGreen),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      _getDistance(
                                              station['lat'], station['lng'])
                                          .isEmpty
                                          ? 'Distance N/A'
                                          : _getDistance(
                                              station['lat'], station['lng']),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 20,
                              color: Colors.grey.shade200,
                            ),
                            // Status
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: _getStatusColor(station['status']),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      station['status'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(
                                            station['status']),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // NATIONAL AVERAGE
                      _buildNationalAverage(station),

                      // DELIVERY BADGE (LPG only)
                      if (station['type'] == 'LPG' &&
                          station['delivery_available'] == true)
                        _buildDeliveryBadge(true),

                      // BACKUP GENERATOR BADGE (EV only)
                      if (station['type'] == 'EV' &&
                          station['has_backup_generator'] == true)
                        _buildBackupGeneratorBadge(true),

                      const SizedBox(height: 20),

                      // PETROL SECTION
                      if (station['type'] == 'Petrol/Diesel' &&
                          station['petrol'] != null &&
                          station['petrol']['available'] == true)
                        _buildPetrolSection(station['petrol']),

                      // DIESEL SECTION
                      if (station['type'] == 'Petrol/Diesel' &&
                          station['diesel'] != null &&
                          station['diesel']['available'] == true)
                        _buildDieselSection(station['diesel']),

                      // LPG type badges
                      if (station['type'] == 'LPG' &&
                          station['lpg_type'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children:
                                (station['lpg_type'] as List).map((lpgType) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      lpgType == 'Autogas'
                                          ? Icons.directions_car
                                          : Icons.propane_tank,
                                      size: 14,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      lpgType,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                      const SizedBox(height: 15),

                      // LPG SECTION
                      if (station['type'] == 'LPG') _buildLpgSection(station),

                      // EV SECTION
                      if (station['type'] == 'EV' &&
                          station['charging_points'] != null)
                        _buildEvSection(station),

                      // Old data format

                      if (station['type'] == 'Petrol/Diesel' &&
                          (station['petrol'] == null ||
                              station['petrol']['available'] != true) &&
                          station['price'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.sell_outlined,
                                  size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                station['price'] ?? 'Price N/A',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 20),

                      // PHOTO CAROUSEL
                      if (station['photos'] != null &&
                          (station['photos'] as List).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PHOTOS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 140,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (station['photos'] as List).length,
                                itemBuilder: (context, index) {
                                  final photoUrl = station['photos'][index];
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: GestureDetector(
                                        onTap: () => _showFullScreenImage(
                                            context, photoUrl),
                                        child: Image.network(
                                          photoUrl,
                                          width: 180,
                                          height: 140,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child,
                                              loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child;
                                            }
                                            return Container(
                                              width: 180,
                                              height: 140,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              width: 180,
                                              height: 140,
                                              color: Colors.grey[200],
                                              child: const Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.broken_image,
                                                      size: 40,
                                                      color: Colors.grey),
                                                  SizedBox(height: 4),
                                                  Text('Failed to load',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.grey)),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 32),

                      // Reviews section
                      ReviewsSection(
                        stationId: station['id'] as String,
                        stationName: station['name'] as String,
                      ),

                      // REPORTS SECTION
                      const SizedBox(height: 24),
                      Text(
                        'REPORTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Load and display reports count
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getStationReports(station['id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }

                          final reportCount =
                              snapshot.hasData ? snapshot.data!.length : 0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StationReportsScreen(
                                    stationId: station['id'],
                                    stationName: station['name'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Leading icon
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.forum_outlined,
                                      color: Colors.blue.shade600,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'See what others reported',
                                          style: GoogleFonts.poppins(
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1A1A1A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          reportCount == 0
                                              ? 'No reports yet'
                                              : '$reportCount report${reportCount == 1 ? '' : 's'} submitted',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Count badge (if reports exist)
                                  if (reportCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade600,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '$reportCount',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      // Phone call row
                      if (station['phone'] != null)
                        InkWell(
                          onTap: () => _makePhoneCall(station['phone']!),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.phone,
                                      color: Colors.green, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  station['phone']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // WhatsApp row
                      if (station['whatsapp'] != null)
                        InkWell(
                          onTap: () => _openWhatsApp(station['whatsapp']!),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.chat,
                                      color: Colors.green, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  station['whatsapp']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 40),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.directions_rounded,
                                  size: 20),
                              label: const Text('Navigate'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _brandGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                if (_currentPosition == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Current location not available')),
                                  );
                                  return;
                                }
                                final Uri url = Uri.parse(
                                  'https://www.google.com/maps/dir/?api=1'
                                  '&origin=${_currentPosition!.latitude},${_currentPosition!.longitude}'
                                  '&destination=${station['lat']},${station['lng']}'
                                  '&travelmode=driving',
                                );
                                _launchUrl(url);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.flag_outlined, size: 20),
                              label: const Text('Report'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.orange.shade800,
                                side: BorderSide(
                                    color: Colors.orange.shade300, width: 1.5),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                textStyle: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ReportIssueScreen(station: station),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

// GET STATION REPORTS
  // Future<List<Map<String, dynamic>>> _getStationReports(
  //     String stationId) async {
  //   try {
  //     final token = AuthState.instance.token ?? '';
  //     final response = await ApiService.getStationReports(
  //       stationId: stationId,
  //       token: token,
  //     );

  //     if (response is List) {
  //       return response.cast<Map<String, dynamic>>();
  //     } else if (response is Map) {
  //       return [response.cast<String, dynamic>()];
  //     }
  //     return [];
  //   } catch (e) {
  //     return [];
  //   }
  // }


  // GET STATION REPORTS  
Future<List<Map<String, dynamic>>> _getStationReports(String stationId) async {
  try {
    final token = AuthState.instance.token ?? '';

    final hasCache = await StationCacheService.hasCachedReports(stationId);
    
    if (hasCache) {
      final cachedReports = await StationCacheService.loadReports(stationId);
      print('✅ Loaded ${cachedReports.length} reports from cache');
      return cachedReports;
    }

    final response = await ApiService.getStationReports(
      stationId: stationId,
      token: token,
    );

    List<Map<String, dynamic>> reportsList = [];
    if (response is List) {
      reportsList = response.cast<Map<String, dynamic>>();
    } else if (response is Map) {
      reportsList = [response.cast<String, dynamic>()];
    }
    if (reportsList.isNotEmpty) {
      await StationCacheService.saveReports(stationId, reportsList);
    }

    return reportsList;

  } catch (e) {
    print('Error loading reports: $e');
    
    final cachedReports = await StationCacheService.loadReports(stationId);
    if (cachedReports.isNotEmpty) {
      print(' Using cached reports (${cachedReports.length} reports)');
      return cachedReports;
    }
    return [];
  }
}

  // PETROL SECTION
  Widget _buildPetrolSection(Map<String, dynamic> petrolData) {
    final octanes = petrolData['octane_ratings'] as List?;
    if (octanes == null || octanes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PETROL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Octane',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Price',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              ...octanes.map((octane) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(octane['name'] ?? 'N/A',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'GH₵ ${octane['price']?.toString() ?? '0'}/L',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            octane['in_stock'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: octane['in_stock'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            octane['in_stock'] == true
                                ? 'In Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                                fontSize: 12,
                                color: octane['in_stock'] == true
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  //  DIESEL SECTION
  Widget _buildDieselSection(Map<String, dynamic> dieselData) {
    final diesels = dieselData['diesel_types'] as List?;
    if (diesels == null || diesels.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIESEL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Colors.grey.shade300)),
                ),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Price',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('Status',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              ...diesels.map((diesel) {
                return TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(diesel['name'] ?? 'N/A',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'GH₵ ${diesel['price']?.toString() ?? '0'}/L',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            diesel['in_stock'] == true
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: 16,
                            color: diesel['in_stock'] == true
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            diesel['in_stock'] == true
                                ? 'In Stock'
                                : 'Out of Stock',
                            style: TextStyle(
                                fontSize: 12,
                                color: diesel['in_stock'] == true
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // LPG SECTION
  Widget _buildLpgSection(Map<String, dynamic> station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Price per kg:', style: TextStyle(fontSize: 14)),
              Text(
                station['price'] ?? 'N/A',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  // EV SECTION
  Widget _buildEvSection(Map<String, dynamic> station) {
    final chargingPoints = station['charging_points'] as List?;
    if (chargingPoints == null || chargingPoints.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EV CHARGING',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: const [
                        SizedBox(
                            width: 80,
                            child: Text('Connector',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 70,
                            child: Text('Power',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 80,
                            child: Text('Price/kWh',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                        SizedBox(
                            width: 80,
                            child: Text('Status',
                                style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  // Data Rows
                  ...chargingPoints.map((point) {
                    final isAvailable = point['available'] == true;
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: Colors.grey.shade100)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              point['connector'] ?? 'N/A',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              '${point['power_kw'] ?? 0} kW',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'GH₵ ${point['price_per_kwh']?.toString() ?? '0'}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Row(
                              children: [
                                Icon(
                                  isAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  size: 14,
                                  color:
                                      isAvailable ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    isAvailable ? 'Available' : 'Busy',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // URL LAUNCHER
  Future<void> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open navigation')),
      );
    }
  }

//Open in google map
  Future<void> _openInGoogleMaps(Map<String, dynamic> station) async {
    final lat = station['lat'];
    final lng = station['lng'];
    final placeId = station['placeId'] as String?;
    final name = station['name'] as String? ?? '';

    // Prefer the Google Place ID so Maps opens the actual place page
    // (full info: address, hours, rating, reviews, photos, directions)
    // instead of just dropping a pin at the coordinates.
    final Uri url;
    if (placeId != null && placeId.isNotEmpty) {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${Uri.encodeComponent(name)}'
        '&query_place_id=$placeId',
      );
    } else {
      // Fallback: no place id available, search by coordinates.
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=$lat,$lng',
      );
    }

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open Google Maps'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // SHOW FULL SCREEN IMAGE
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PHONE CALL
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open dialer')),
      );
    }
  }

  // WHATSAPP
  Future<void> _openWhatsApp(String phoneNumber) async {
    final String clean = phoneNumber.replaceAll('+', '');
    final Uri url = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print('User role: ${AuthState.instance.userRole}');
    print('Is operator: ${AuthState.instance.isOperator}');

    return ListenableBuilder(
      listenable: AuthState.instance,
      builder: (context, _) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: _brandGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              title: Text(
                'Easy Top Up',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              actions: [
                // Cache Status Indicator
                // FutureBuilder<String?>(
                //   future: StationCacheService.getLastUpdated(),
                //   builder: (context, snapshot) {
                //     if (snapshot.hasData && snapshot.data != null) {
                //       try {
                //         final lastUpdated = DateTime.parse(snapshot.data!);
                //         final diff = DateTime.now().difference(lastUpdated);
                //         String label;
                //         if (diff.inMinutes < 1)
                //           label = 'Just now';
                //         else if (diff.inMinutes < 60)
                //           label = '${diff.inMinutes}m ago';
                //         else if (diff.inHours < 24)
                //           label = '${diff.inHours}h ago';
                //         else
                //           label = '${diff.inDays}d ago';

                //         return Padding(
                //           padding: const EdgeInsets.only(right: 8),
                //           child: Container(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 8, vertical: 4),
                //             decoration: BoxDecoration(
                //               color: Colors.white.withOpacity(0.2),
                //               borderRadius: BorderRadius.circular(12),
                //             ),
                //              child: Text(
                //               ' $label',
                //               style: const TextStyle(
                //                 fontSize: 11,
                //                 color: Colors.white70,
                //               ),
                //             ),
                //           ),
                //         );
                //       } catch (e) {
                //         return const SizedBox.shrink();
                //       }
                //     }
                //     return const SizedBox.shrink();
                //   },
                // ),

                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Search stations',
                  onPressed: () async {
                    final selectedStation =
                        await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchFilterScreen(stations: _stations),
                      ),
                    );
                    if (selectedStation != null && mounted) {
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              selectedStation['lat'],
                              selectedStation['lng'],
                            ),
                            zoom: 16,
                          ),
                        ),
                      );
                      await Future.delayed(const Duration(milliseconds: 600));
                      if (!mounted) return;
                      _showBottomSheet(selectedStation);
                    }
                  },
                ),
                if (AuthState.instance.isOperator)
                  IconButton(
                    icon: const Icon(Icons.store_outlined),
                    tooltip: 'Dashboard',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OperatorHomeScreen(),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.person_outline),
                  tooltip: 'Profile',
                  onPressed: () async {
                    final selectedStation = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                    if (selectedStation != null && mounted) {
                      _showBottomSheet(selectedStation);
                    }
                  },
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: _refreshStations,
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _brandGreen),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.wifi_off,
                                  size: 52, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                _errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 15, color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                    _errorMessage = null;
                                  });
                                  _loadStations();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _brandGreen,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            GoogleMap(
                              initialCameraPosition: _initialPosition,
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                              zoomControlsEnabled: false,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                if (_currentPosition != null) {
                                  controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      CameraPosition(
                                        target: LatLng(
                                          _currentPosition!.latitude,
                                          _currentPosition!.longitude,
                                        ),
                                        zoom: 15,
                                      ),
                                    ),
                                  );
                                }
                              },
                              markers: _buildMarkers(),
                            ),
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _LegendItem(
                                        color: Colors.amber,
                                        label: 'Petrol/Diesel'),
                                    SizedBox(height: 4),
                                    _LegendItem(
                                        color: Colors.blue, label: 'LPG'),
                                    SizedBox(height: 4),
                                    _LegendItem(
                                        color: Colors.green,
                                        label: 'EV Charging'),
                                    SizedBox(height: 8),
                                    Divider(height: 1, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'Stations from Google',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      'open in Google Maps ',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                    Text(
                                      'for easy access ',
                                      style: TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 32,
                              right: 16,
                              child: FloatingActionButton(
                                onPressed: _getCurrentLocation,
                                backgroundColor: _brandGreen,
                                tooltip: 'My Location',
                                child: const Icon(Icons.my_location,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
            ));
      },
    );
  }

  // NATIONAL AVERAGE PRICE
  Widget _buildNationalAverage(Map<String, dynamic> station) {
    final stationType = station['type'];

    // For Petrol/Diesel stations, show both petrol and diesel
    if (stationType == 'Petrol/Diesel') {
      final petrolAvg = AuthState.instance.getFormattedFuelPrice('petrol');
      final dieselAvg = AuthState.instance.getFormattedFuelPrice('diesel');

      if (petrolAvg == 'N/A' && dieselAvg == 'N/A') {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'National Average:',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            const SizedBox(height: 2),
            if (petrolAvg != 'N/A')
              Text(
                'Petrol: $petrolAvg',
                style: const TextStyle(
                    fontSize: 12, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            if (dieselAvg != 'N/A')
              Text(
                'Diesel: $dieselAvg',
                style: const TextStyle(
                    fontSize: 12, color: Color.fromARGB(255, 0, 0, 0)),
              ),
          ],
        ),
      );
    }

    // For LPG, show LPG price
    if (stationType == 'LPG') {
      final avgPrice = AuthState.instance.getFormattedFuelPrice('lpg');
      if (avgPrice == 'N/A') return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            const Icon(Icons.trending_up, size: 16, color: Colors.blue),
            const SizedBox(width: 6),
            Text(
              'National Avg: $avgPrice',
              style: const TextStyle(
                  fontSize: 13, color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ],
        ),
      );
    }

    if (stationType == 'EV') {
      return const SizedBox.shrink();
    }

    return const SizedBox.shrink();
  }

  //BUILD DELIVERY BADGE
  Widget _buildDeliveryBadge(bool isAvailable) {
    if (!isAvailable) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delivery_dining, size: 16, color: Colors.blue.shade700),
          const SizedBox(width: 6),
          Text(
            'Home Delivery Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

// BUILD BACKUP GENERATOR
  Widget _buildBackupGeneratorBadge(bool hasBackupGenerator) {
    if (!hasBackupGenerator) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.electrical_services,
              size: 16, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Text(
            'Backup Generator Available',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// LEGEND ITEM
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black87),
        ),
      ],
    );
  }
}
