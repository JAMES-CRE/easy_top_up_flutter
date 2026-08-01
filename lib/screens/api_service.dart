import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'auth_state.dart';

class ApiService {
  static const String baseUrl =
      'https://FinalProjectcom2026.pythonanywhere.com/api';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };


   

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? businessName,
  }) async {
    try {
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register/'),
            headers: _headers,
            body: jsonEncode({
              'email': email,
              'first_name': firstName,
              'last_name': lastName,
              'password': password,
              'role': role,
              'business_name': businessName,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final userData = body['data'];
        final fullName =
            '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
                .trim();

        return {
          'id': userData['id'],
          'name': fullName.isEmpty ? email.split('@')[0] : fullName,
          'email': userData['email'],
          'role': userData['role'],
          'token': userData['token'],
          'photo_url': userData['photo_url'],
          'business_name': userData['business_name'],
        };
      } else {
        throw Exception(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/login/'),
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = body['data'];
        final firstName = userData['first_name'] ?? '';
        final lastName = userData['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();

        return {
          'id': userData['id'],
          'name': fullName.isEmpty ? email.split('@')[0] : fullName,
          'email': userData['email'],
          'role': userData['role'],
          'token': userData['token'],
          'photo_url': userData['photo_url'],
        };
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // GET PROFILE
  static Future<Map<String, dynamic>> getProfile({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/profile/'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final userData = body;
        final firstName = userData['first_name'] ?? '';
        final lastName = userData['last_name'] ?? '';
        final fullName = '$firstName $lastName'.trim();

        return {
          'id': userData['id'],
          'name': fullName,
          'email': userData['email'],
          'role': userData['role'],
          'phone': userData['phone'],
          'business_name': userData['business_name'],
          'photo_url': userData['photo_url'],
        };
      } else {
        throw Exception('SOMETHING MIGHT BE WRONG');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE PROFILE
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {};

      // Get current user email from AuthState
      final currentEmail = AuthState.instance.userEmail;

      // Always send email (current or new)
      body['email'] = email ?? currentEmail ?? '';

      if (name != null) {
        final nameParts = name.trim().split(' ');
        body['first_name'] = nameParts.first;
        if (nameParts.length > 1) {
          body['last_name'] = nameParts.sublist(1).join(' ');
        }
      }
      if (photoUrl != null) body['photo_url'] = photoUrl;

      final response = await http
          .put(
            Uri.parse('$baseUrl/users/profile/update/'),
            headers: authHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Parsed response: $responseBody');

        if (responseBody.containsKey('data')) {
          return responseBody['data'];
        } else {
          return responseBody;
        }
      } else {
        throw Exception('SOMETHING IS WRONG');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // GET ALL STATIONS 
  static Future<List<Map<String, dynamic>>> getStations() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('SOMETHING IS WRONG');
      }
    } catch (e) {
      throw Exception('NETWORK ERROR: $e');
    }
  }

  // GET OPERATOR'S STATIONS
  static Future<List<Map<String, dynamic>>> getMyStations({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/my-stations/'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('SOMETHING IS WRONG');
      }
    } catch (e) {
      throw Exception('NETWORK ERROR: $e');
    }
  }

  // GET SINGLE STATION
  static Future<Map<String, dynamic>> getStation({
    required String stationId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/$stationId/'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Station not found');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<void> addStation({
    required String token,
    required Map<String, dynamic> station,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stations/'),
            headers: authHeaders(token),
            body: jsonEncode(station), 
          )
          .timeout(const Duration(seconds: 10));

      print('Add station response status: ${response.statusCode}');
      print('Add station response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to add station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE STATION 
  static Future<void> updateStation({
    required String token,
    required String stationId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      print('=== UPDATE STATION API ===');
      print('URL: $baseUrl/stations/$stationId/');
      print('Data: $updatedData');

      final response = await http
          .put(
            Uri.parse('$baseUrl/stations/$stationId/'),
            headers: authHeaders(token),
            body: jsonEncode(updatedData),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['error'] ??
              errorBody['message'] ??
              'Failed to update station');
        } catch (e) {
          throw Exception('Failed to update station: ${response.body}');
        }
      }
    } catch (e) {
      print('Update error: $e');
      throw Exception('$e');
    }
  }


  // UPDATE PRICE
  static Future<void> updatePrice({
    required String token,
    required String stationId,
    required String price,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stations/$stationId/update-price/'),
            headers: authHeaders(token),
            body: jsonEncode({'price': price}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to update price');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE STATUS
  static Future<void> updateStatus({
    required String token,
    required String stationId,
    required String status,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stations/$stationId/update-status/'),
            headers: authHeaders(token),
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE POWER OUTPUT 
  static Future<void> updatePowerOutput({
    required String token,
    required String stationId,
    required String powerOutput,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stations/$stationId/update-power/'),
            headers: authHeaders(token),
            body: jsonEncode({'power_output': powerOutput}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to update power output');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // DELETE STATION 
static Future<void> deleteStation({
  required String token,
  required String stationId,
}) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/stations/$stationId/'),
      headers: authHeaders(token),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 204 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['error'] ?? 'Failed to delete station');
    }
  } catch (e) {
    throw Exception('$e');
  }
}

  // Submit a report
  static Future<void> submitReport({
    required String token,
    required String stationId,
    required String issueType,
    required Map<String, dynamic> extraData,
    required String notes,
    String? photoUrl,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reports/reports/'),
            headers: authHeaders(token),
            body: jsonEncode({
              'station': stationId,
              'issue_type': issueType,
              'extra_data': extraData,
              'notes': notes,
              'photo_url': photoUrl,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Report response status: ${response.statusCode}');
      print('Report response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to submit report');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<dynamic> getStationReports({
    required String stationId,
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reports/reports/?station=$stationId'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      print('=== GET STATION REPORTS ===');
      print('URL: $baseUrl/reports/?station=$stationId');
      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

// REPLY TO REPORT 
  static Future<void> replyToReport({
    required String token,
    required String reportId,
    required String reply,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reports/reports/$reportId/reply/'),
            headers: authHeaders(token),
            body: jsonEncode({
              'reply': reply,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('Reply response status: ${response.statusCode}');
      print('Reply response body: ${response.body}');

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to send reply');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }



static Future<List<Map<String, dynamic>>> getStationReviews({
  String? token,
  required String stationId,
}) async {
  try {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await http.get(
      Uri.parse('$baseUrl/reports/reviews/?station=$stationId'),
      headers: headers,
    ).timeout(const Duration(seconds: 10));

    print('=== GET STATION REVIEWS ===');
    print('URL: $baseUrl/reports/reviews/?station=$stationId');
    print('Status: ${response.statusCode}');
    print('Has token: ${token != null && token.isNotEmpty}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      print('Failed to load reviews: ${response.body}');
      return [];
    }
  } catch (e) {
    print('Error loading reviews: $e');
    return [];
  }
}

// Add a new review
  static Future<Map<String, dynamic>> addReview({
    required String token,
    required String stationId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reports/reviews/'), // ← CHANGED
            headers: authHeaders(token),
            body: jsonEncode({
              'station': stationId,
              'rating': rating,
              'comment': comment,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to add review');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

// Upload single photo directly to Cloudinary 
  static Future<String?> uploadPhotoToCloudinary({
    required XFile photo,
  }) async {
    try {
      const String cloudinaryCloudName = 'dgipuf3rn';
      const String cloudinaryUploadPreset = 'easy_top_up';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload'),
      );

      request.fields['upload_preset'] = cloudinaryUploadPreset;

      final bytes = await photo.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);

      print('Cloudinary response: $decoded');

      if (response.statusCode == 200) {
        return decoded['secure_url'];
      } else {
        throw Exception(decoded['error']?['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

// Upload multiple photos directly to Cloudinary
  static Future<List<String>> uploadMultiplePhotosToCloudinary({
    required List<XFile> photos,
  }) async {
    List<String> urls = [];

    for (var photo in photos) {
      const String cloudinaryCloudName = 'dgipuf3rn';
      const String cloudinaryUploadPreset = 'easy_top_up';

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload'),
        );

        request.fields['upload_preset'] = cloudinaryUploadPreset;

        final bytes = await photo.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ));

        final response = await request.send();
        final responseData = await response.stream.bytesToString();
        final decoded = jsonDecode(responseData);

        if (response.statusCode == 200) {
          urls.add(decoded['secure_url']);
        }
      } catch (e) {
        print('Upload error for ${photo.path}: $e');
      }
    }

    return urls;
  }

// Upload profile photo directly to Cloudinary
  static Future<String?> uploadProfilePhoto({
    required XFile photo,
  }) async {
    try {
      const String cloudinaryCloudName = 'dgipuf3rn';
      const String cloudinaryUploadPreset = 'easy_top_up';

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload'),
      );

      request.fields['upload_preset'] = cloudinaryUploadPreset;

      final bytes = await photo.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);

      print('Cloudinary profile upload response: $decoded');

      if (response.statusCode == 200) {
        return decoded['secure_url'];
      } else {
        throw Exception(decoded['error']?['message'] ?? 'Upload failed');
      }
    } catch (e) {
      print('Cloudinary profile upload error: $e');
      return null;
    }
  }

  // FUEL PRICES (GhanaAPI)

  static Future<Map<String, dynamic>> getFuelPrices() async {
    try {
      // First try the real API
      final response = await http
          .get(
            Uri.parse('https://api.ghana-api.dev/api/v2/transport/fuel-prices'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data']['petrol'] > 0) {
          return data;
        }
      }

      // If API fails, return mock data
      print('Using mock fuel price data (API unavailable)');
      return _getMockFuelPrices();
    } catch (e) {
      print('Fuel price API error: $e');
      // Return mock data on error
      return _getMockFuelPrices();
    }
  }

  static Map<String, dynamic> _getMockFuelPrices() {
    return {
      'success': true,
      'data': {
        'petrol': 14.80,
        'diesel': 16.20,
        'lpg': 12.70,
        'currency': 'GHS',
        'lastUpdated': DateTime.now().toIso8601String(),
        'source': 'Mock Data (API temporarily unavailable)',
        'status': 'success',
      }
    };
  }

  // GOOGLE PLACES API - ALL FUEL TYPES

  static const String googleApiKey = 'AIzaSyDD6GbX4F4d6NgNk_at_d06205lzkhI9Ck';

// GOOGLE PLACES
  static Future<List<Map<String, dynamic>>> getNearbyFuelStations(
    double lat,
    double lng, {
    int radius = 5000,
  }) async {
    List<Map<String, dynamic>> allStations = [];

    try {
      //  Get Petrol/Diesel stations
      final petrolStations = await _fetchGooglePlaces(
        lat,
        lng,
        radius,
        ['gas_station'],
        'Petrol/Diesel',
      );
      allStations.addAll(petrolStations);

      // Get EV charging stations
      final evStations = await _fetchGooglePlaces(
        lat,
        lng,
        radius,
        ['electric_vehicle_charging_station'],
        'EV',
      );
      allStations.addAll(evStations);

      //  Search for LPG by text
      final lpgStations = await _fetchLpgStations(lat, lng, radius);
      allStations.addAll(lpgStations);

      //  Remove duplicates by place ID
      final seen = <String>{};
      allStations = allStations.where((s) {
        final id = s['id'] as String;
        return seen.add(id);
      }).toList();

      print(' Total Google stations: ${allStations.length}');
      return allStations;
    } catch (e) {
      print(' Error fetching Google stations: $e');
      return allStations;
    }
  }

// FETCH BY TYPE
  static Future<List<Map<String, dynamic>>> _fetchGooglePlaces(
    double lat,
    double lng,
    int radius,
    List<String> types,
    String fuelType,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('https://places.googleapis.com/v1/places:searchNearby'),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': googleApiKey,
              'X-Goog-FieldMask':
                  'places.id,places.displayName,places.location,'
                      'places.types,places.editorialSummary',
            },
            body: jsonEncode({
              'includedTypes': types,
              'locationRestriction': {
                'circle': {
                  'center': {'latitude': lat, 'longitude': lng},
                  'radius': radius.toDouble(),
                },
              },
              'maxResultCount': 20,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final places = data['places'] as List? ?? [];
        print(' Found ${places.length} $fuelType from Google');

        return places
            .map((p) => _parseGooglePlace(p, fuelType))
            .where((s) => s['lat'] != 0.0 && s['lng'] != 0.0)
            .toList();
      } else {
        print('Google API ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print(' Fetch error for $fuelType: $e');
      return [];
    }
  }

// FETCH LPG BY TEXT SEARCH
  static Future<List<Map<String, dynamic>>> _fetchLpgStations(
    double lat,
    double lng,
    int radius,
  ) async {
    // This Search multiple LPG related terms 
    final queries = [
      'LPG gas station',
      'cooking gas refilling station',
      'autogas station',
      'cylinder refill',
      'Gas refilling station',
      'LPG filling station',
    ];

    final List<Map<String, dynamic>> results = [];
    final seen = <String>{};

    for (final query in queries) {
      try {
        final response = await http
            .post(
              Uri.parse('https://places.googleapis.com/v1/places:searchText'),
              headers: {
                'Content-Type': 'application/json',
                'X-Goog-Api-Key': googleApiKey,
                'X-Goog-FieldMask':
                    'places.id,places.displayName,places.location,'
                        'places.types,places.editorialSummary',
              },
              body: jsonEncode({
                'textQuery': '$query near $lat,$lng',
                'locationBias': {
                  'circle': {
                    'center': {'latitude': lat, 'longitude': lng},
                    'radius': radius.toDouble(),
                  },
                },
                'maxResultCount': 10,
              }),
            )
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final places = data['places'] as List? ?? [];

          for (final place in places) {
            final parsed = _parseGooglePlace(place, 'LPG');
            final id = parsed['id'] as String;

            // Skip duplicates 
            if (!seen.contains(id)) {
              seen.add(id);
              results.add(parsed);
            }
          }
        }
      } catch (e) {
        print(' LPG search error for "$query": $e');
      }
    }

    print(' Found ${results.length} LPG stations from Google');
    return results;
  }

// EXPANDED EV DETECTION
  static bool _isEvStation(
    List<dynamic> types,
    String name,
    Map<String, dynamic> place,
  ) {
    final lowerName = name.toLowerCase();

    //Check Google types
    const evTypes = [
      'electric_vehicle_charging_station',
      'ev_charging_station',
      'charging_station',
      'electric_vehicle_charging',
      'ev_charging',
      'electric_charging_point',
    ];

    if (types.any((t) => evTypes.contains(t.toString()))) {
      return true;
    }

    // Check name for EV keywords
    const evKeywords = [
      'tesla',
      'supercharger',
      ' ev ',
      'electric vehicle',
      'ccs',
      'chademo',
      'type 2',
      'mennekes',
      'charging station',
      'charger',
      'charge point',
      'chargepoint',
      'electric car',
      'ev station',
      'ev charging',
      'electric charging',
      'fast charger',
      'rapid charger',
      'evcs',
      'electric vehicle supply',
      'electrify america',
      'ionity',
      'xcharge',
    ];

    if (evKeywords.any((k) => lowerName.contains(k))) {
      return true;
    }

    // Check editorial summary if available
    final description = place['editorialSummary']?['text'] as String? ?? '';
    if (description.isNotEmpty) {
      final lowerDesc = description.toLowerCase();
      const descKeywords = ['ev', 'electric', 'charging', 'charger', 'supercharger', 'tesla', 'ccs', 'chademo',];
      if (descKeywords.any((k) => lowerDesc.contains(k))) {
        return true;
      }
    }

    return false;
  }

// EXPANDED LPG DETECTION
  static bool _isLpgStation(
    List<dynamic> types,
    String name,
    Map<String, dynamic> place,
  ) {
    final lowerName = name.toLowerCase();

    // Check name for LPG keywords
    const lpgKeywords = [
      'lpg',
      'lp gas',
      'liquefied petroleum',
      'autogas',
      'gas refill',
      'cylinder refill',
      'cooking gas',
      'propane',
      'butane',
      'lpg station',
      'lpg filling',
      'lpg refill',
      'gas filling',
      'gas',
      'lpg retail',
      'lpg outlet',
      'lpg dispensing',
      'cylinder exchange',
      'bottled gas',
    ];

    if (lpgKeywords.any((k) => lowerName.contains(k))) {
      return true;
    }

    //  Check types for gas related terms
    for (final type in types) {
      final typeStr = type.toString().toLowerCase();
      if (typeStr.contains('gas') && !typeStr.contains('electric')) {
        if (lowerName.contains('gas') ||
            lowerName.contains('lpg') ||
            lowerName.contains('refill')) {
          return true;
        }
      }
    }

    // Check editorial summary
    final description = place['editorialSummary']?['text'] as String? ?? '';
    if (description.isNotEmpty) {
      final lowerDesc = description.toLowerCase();
      const descKeywords = [
        'lpg',
        'gas refill',
        'cylinder',
        'propane',
        'autogas'
      ];
      if (descKeywords.any((k) => lowerDesc.contains(k))) {
        return true;
      }
    }

    return false;
  }

// PARSE GOOGLE PLACE
  static Map<String, dynamic> _parseGooglePlace(
    Map<String, dynamic> place,
    String fuelType,
  ) {
    final lat = (place['location']?['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (place['location']?['longitude'] as num?)?.toDouble() ?? 0.0;
    final name = place['displayName']?['text'] as String? ?? 'Fuel Station';
    final placeId = place['id'] as String? ?? '';
    final types = place['types'] as List? ?? [];

    // Determine final fuel type using smart detection
    String finalType = fuelType;

    if (_isEvStation(types, name, place)) {
      finalType = 'EV';
    } else if (_isLpgStation(types, name, place)) {
      finalType = 'LPG';
    } else {
      finalType = fuelType;
    }

    return {
      'id': 'google_$placeId',
      'name': name,
      'lat': lat,
      'lng': lng,
      'type': finalType,
      'isGooglePlace': true,
      'placeId': placeId,
    };
  }
}
