/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ApiService {
  // ── BASE URL ──
  static const String baseUrl =
      'https://FinalProjectcom2026.pythonanywhere.com/api';

  // ── HEADERS ──
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─────────────────────────────────────────
  // STATIONS
  // ─────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getStations() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/'), // Note trailing slash
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        // Django returns list directly, not wrapped in 'data'
        return List<Map<String, dynamic>>.from(body);
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // ─────────────────────────────────────────
  // AUTH
  // ─────────────────────────────────────────

static Future<Map<String, dynamic>> register({
  required String name,
  required String email,
  required String password,
  String role = 'user',
  String? businessName,
}) async {
  try {
    // Split name into first_name and last_name
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final response = await http.post(
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
    ).timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      final userData = body['data'];
      
      // Combine first_name and last_name
      final fullName = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
      
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


 /* static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? businessName,
  }) async {
    try {
      // Split name into first_name and last_name
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
        return body['data'];
      } else {
        throw Exception(body['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }*/

  /*static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
                '$baseUrl/users/login/'), // Note: /users/login/ (trailing slash)
            headers: _headers,
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Django returns {success: true, data: {...}}
        return body['data'];
      } else {
        throw Exception(body['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }*/


static Future<Map<String, dynamic>> login({
  required String email,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login/'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    ).timeout(const Duration(seconds: 10));

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final userData = body['data'];
      
      // Combine first_name and last_name into a single name field
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';
      final fullName = '$firstName $lastName'.trim();
      
      return {
        'id': userData['id'],
        'name': fullName.isEmpty ? userData['email'].split('@')[0] : fullName,
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


  // ─────────────────────────────────────────
  // REPORTS
  // ─────────────────────────────────────────

  static Future<void> submitReport({
    required String token,
    required String stationId,
    required String issueType,
    required Map<String, dynamic> extraData,
    required String notes,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/reports'),
            headers: authHeaders(token),
            body: jsonEncode({
              'station_id': stationId,
              'issue_type': issueType,
              'extra_data': extraData,
              'notes': notes,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to submit report');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<List<Map<String, dynamic>>> getStationReports(
      String stationId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reports/$stationId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List data = body['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // ─────────────────────────────────────────
  // OPERATOR STATIONS
  // ─────────────────────────────────────────

  /*static Future<void> addStation({
    required String token,
    required Map<String, dynamic> station,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/stations'),
            headers: authHeaders(token),
            body: jsonEncode(station),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to add station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }*/

  

static Future<void> addStation({
  required String token,
  required Map<String, dynamic> station,
}) async {
  try {
    final body = jsonEncode(station);
    print('Request body: $body');
    
    final response = await http.post(
      Uri.parse('$baseUrl/stations/'),
      headers: authHeaders(token),
      body: body,
    ).timeout(const Duration(seconds: 10));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to add station: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('$e');
  }
}

  

  static Future<void> updatePrice({
    required String token,
    required String stationId,
    required String price,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/stations/$stationId/price'),
            headers: authHeaders(token),
            body: jsonEncode({'price': price}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update price');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<void> updatePowerOutput({
    required String token,
    required String stationId,
    required String powerOutput,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/stations/$stationId/power'),
            headers: authHeaders(token),
            body: jsonEncode({'power_output': powerOutput}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update power output');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<void> updateStatus({
    required String token,
    required String stationId,
    required String status,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/stations/$stationId/status'),
            headers: authHeaders(token),
            body: jsonEncode({'status': status}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<Map<String, dynamic>?> getMyStation({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/my-station'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return body['data'];
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<void> updateStation({
    required String token,
    required String stationId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/stations/$stationId'),
            headers: authHeaders(token),
            body: jsonEncode(updatedData),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw Exception(body['message'] ?? 'Failed to update station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  static Future<List<Map<String, dynamic>>> getMyStations({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/stations/my-stations'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(body['data']);
      } else {
        throw Exception(body['message'] ?? 'Failed to fetch stations');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // ─────────────────────────────────────────
  // PHOTO UPLOADS
  // ─────────────────────────────────────────

  static Future<List<String>> uploadPhotos({
    required String token,
    required List<XFile> photos,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload');
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        final file = File(photo.path);

        if (!await file.exists()) {
          continue;
        }

        final multipartFile = await http.MultipartFile.fromPath(
          'photos',
          file.path,
        );
        request.files.add(multipartFile);
      }

      if (request.files.isEmpty) {
        throw Exception('No valid files to upload');
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return List<String>.from(decoded['data']);
      } else {
        throw Exception(decoded['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload photos: $e');
    }
  }

  // ── UPLOAD PROFILE PHOTO ──
  static Future<String?> uploadProfilePhoto({
    required String token,
    required XFile photo,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/profile'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await photo.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return decoded['data'];
      } else {
        throw Exception(decoded['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }

  // ── UPDATE USER PROFILE ──
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (photoUrl != null) body['photo_url'] = photoUrl;

      final response = await http
          .put(
            Uri.parse('$baseUrl/auth/profile'),
            headers: authHeaders(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['data'];
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
*/

/*import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'auth_state.dart';

class ApiService {
  // ── BASE URL ── (Update with your PythonAnywhere URL)
  static const String baseUrl = 'https://FinalProjectcom2026.pythonanywhere.com/api';
  

  // ── HEADERS ──
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─────────────────────────────────────────
  // AUTHENTICATION
  // ─────────────────────────────────────────

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? businessName,
  }) async {
    try {
      // Split name into first_name and last_name
      final nameParts = name.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final response = await http.post(
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
      ).timeout(const Duration(seconds: 10));

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final userData = body['data'];
        final fullName = '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'.trim();
        
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
      final response = await http.post(
        Uri.parse('$baseUrl/users/login/'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 10));

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
      final response = await http.get(
        Uri.parse('$baseUrl/users/profile/'),
        headers: authHeaders(token),
      ).timeout(const Duration(seconds: 10));

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
        throw Exception('Failed to get profile');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE PROFILE
  /*static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
  }) async {
    try {
      final Map<String, dynamic> body = {};
      
      if (name != null) {
        final nameParts = name.trim().split(' ');
        body['first_name'] = nameParts.first;
        if (nameParts.length > 1) {
          body['last_name'] = nameParts.sublist(1).join(' ');
        }
      }
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (photoUrl != null) body['photo_url'] = photoUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/update/'),
        headers: authHeaders(token),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 10));

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody['data'];
      } else {
        throw Exception(responseBody['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }*/


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
    
    final response = await http.put(
      
      Uri.parse('$baseUrl/users/profile/update/'),
      headers: authHeaders(token),
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 10));

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
      throw Exception('Failed to update profile');
    }
  } catch (e) {
    throw Exception('$e');
  }
}

  // ─────────────────────────────────────────
  // STATIONS
  // ─────────────────────────────────────────

  // GET ALL STATIONS (Public - only verified)
  static Future<List<Map<String, dynamic>>> getStations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET OPERATOR'S STATIONS
  static Future<List<Map<String, dynamic>>> getMyStations({
    required String token,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/my-stations/'),
        headers: authHeaders(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // GET SINGLE STATION
  static Future<Map<String, dynamic>> getStation({
    required String stationId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stations/$stationId/'),
        headers: _headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Station not found');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // ADD STATION (Operator only)
  static Future<void> addStation({
    required String token,
    required Map<String, dynamic> station,
  }) async {
    try {
       print('Sending station data: ${jsonEncode(station)}');  // Debug
      // Remove fields that should not be sent
      final cleanedStation = Map<String, dynamic>.from(station);
      cleanedStation.remove('id'); // Let Django auto-generate
      cleanedStation.remove('pending');
      cleanedStation.remove('verified');
      cleanedStation.remove('created_at');
      
      final response = await http.post(
        Uri.parse('$baseUrl/stations/'),
        headers: authHeaders(token),
        body: jsonEncode(cleanedStation),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to add station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE STATION (Full update)
  /*static Future<void> updateStation({
    required String token,
    required String stationId,
    required Map<String, dynamic> updatedData,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/stations/$stationId/'),
        headers: authHeaders(token),
        body: jsonEncode(updatedData),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to update station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }*/

  static Future<void> updateStation({
  required String token,
  required String stationId,
  required Map<String, dynamic> updatedData,
}) async {
  try {
    print('=== UPDATE STATION API ===');
    print('URL: $baseUrl/stations/$stationId/');
    print('Data: $updatedData');
    
    final response = await http.put(
      Uri.parse('$baseUrl/stations/$stationId/'),
      headers: authHeaders(token),
      body: jsonEncode(updatedData),
    ).timeout(const Duration(seconds: 10));

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      // Try to parse the error message
      try {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['error'] ?? errorBody['message'] ?? 'Failed to update station');
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
      final response = await http.post(
        Uri.parse('$baseUrl/stations/$stationId/update-price/'),
        headers: authHeaders(token),
        body: jsonEncode({'price': price}),
      ).timeout(const Duration(seconds: 10));

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
      final response = await http.post(
        Uri.parse('$baseUrl/stations/$stationId/update-status/'),
        headers: authHeaders(token),
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to update status');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE POWER OUTPUT (EV only)
  static Future<void> updatePowerOutput({
    required String token,
    required String stationId,
    required String powerOutput,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/stations/$stationId/update-power/'),
        headers: authHeaders(token),
        body: jsonEncode({'power_output': powerOutput}),
      ).timeout(const Duration(seconds: 10));

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
        throw Exception(body['message'] ?? 'Failed to delete station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }


 // ─────────────────────────────────────────
// REPORTS
// ─────────────────────────────────────────

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
    final response = await http.post(
      Uri.parse('$baseUrl/reports/'),
      headers: authHeaders(token),
      body: jsonEncode({
        'station': stationId,
        'issue_type': issueType,
        'extra_data': extraData,
        'notes': notes,
        'photo_url': photoUrl,
      }),
    ).timeout(const Duration(seconds: 10));

    print('Report response status: ${response.statusCode}');
    print('Report response body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Failed to submit report');
    }
  } catch (e) {
    throw Exception('$e');
  }
}

// Get reports for a station
static Future<List<Map<String, dynamic>>> getStationReports({
  required String stationId,
  required String token,
}) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/reports/?station=$stationId'),
      headers: authHeaders(token),
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch reports');
    }
  } catch (e) {
    throw Exception('$e');
  }
}






  // ─────────────────────────────────────────
  // PHOTO UPLOADS (Cloudinary)
  // ─────────────────────────────────────────

  static Future<List<String>> uploadPhotos({
    required String token,
    required List<XFile> photos,
  }) async {
    try {
      var uri = Uri.parse('$baseUrl/upload/');
      var request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        final file = File(photo.path);
        
        if (!await file.exists()) continue;
        
        final multipartFile = await http.MultipartFile.fromPath(
          'photos',
          file.path,
        );
        request.files.add(multipartFile);
      }
      
      if (request.files.isEmpty) {
        throw Exception('No valid files to upload');
      }
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return List<String>.from(decoded['data']);
      } else {
        throw Exception(decoded['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload photos: $e');
    }
  }



// ── UPLOAD PROFILE PHOTO ──
  static Future<String?> uploadProfilePhoto({
    required String token,
    required XFile photo,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/profile/'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      
      final bytes = await photo.readAsBytes();
      final multipartFile = http.MultipartFile.fromBytes(
        'photo',
        bytes,
        filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      request.files.add(multipartFile);
      
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final decoded = jsonDecode(responseData);
      
      if (response.statusCode == 200) {
        return decoded['data'];
      } else {
        throw Exception(decoded['message'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }
}*/

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
//import 'dart:io';
import 'auth_state.dart';

class ApiService {
  // ── BASE URL ── (Update with your PythonAnywhere URL)
  static const String baseUrl =
      'https://FinalProjectcom2026.pythonanywhere.com/api';

  // ── HEADERS ──
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ─────────────────────────────────────────
  // AUTHENTICATION
  // ─────────────────────────────────────────

  // REGISTER
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String role = 'user',
    String? businessName,
  }) async {
    try {
      // Split name into first_name and last_name
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
        throw Exception('Failed to get profile');
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
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // ─────────────────────────────────────────
  // STATIONS
  // ─────────────────────────────────────────

  // GET ALL STATIONS (Public - only verified)
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
        throw Exception('Failed to load stations');
      }
    } catch (e) {
      throw Exception('Network error: $e');
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
        return [];
      }
    } catch (e) {
      return [];
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

  // ADD STATION (Operator only)
  static Future<void> addStation({
    required String token,
    required Map<String, dynamic> station,
  }) async {
    try {
      print('Sending station data: ${jsonEncode(station)}');

      // Remove fields that should not be sent
      final cleanedStation = Map<String, dynamic>.from(station);
      cleanedStation.remove('id'); // Let Django auto-generate
      cleanedStation.remove('pending');
      cleanedStation.remove('verified');
      cleanedStation.remove('created_at');

      final response = await http
          .post(
            Uri.parse('$baseUrl/stations/'),
            headers: authHeaders(token),
            body: jsonEncode(cleanedStation),
          )
          .timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 201) {
        final body = jsonDecode(response.body);
        throw Exception(body['error'] ?? 'Failed to add station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // UPDATE STATION (Full update)
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

  // UPDATE POWER OUTPUT (EV only)
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
      final response = await http
          .delete(
            Uri.parse('$baseUrl/stations/$stationId/'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 204 && response.statusCode != 200) {
        final body = jsonDecode(response.body);
        throw Exception(body['message'] ?? 'Failed to delete station');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  // ─────────────────────────────────────────
  // REPORTS
  // ─────────────────────────────────────────

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

  // Get reports for a station
  static Future<List<Map<String, dynamic>>> getStationReports({
    required String stationId,
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reports/?station=$stationId'),
            headers: authHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to fetch reports');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

// Get reviews for a specific station
  static Future<List<Map<String, dynamic>>> getStationReviews({
    required String token, // ← ADD THIS
    required String stationId,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/reports/reviews/?station=$stationId'),
            headers: authHeaders(token), // ← FIX: Now includes Bearer token
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      throw Exception('$e');
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

  // ─────────────────────────────────────────
// DIRECT CLOUDINARY UPLOADS (No backend needed)
// ─────────────────────────────────────────

// Upload single photo directly to Cloudinary (for reports)
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

// Upload multiple photos directly to Cloudinary (for stations)
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

// Upload profile photo directly to Cloudinary (for profile picture)
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
}
