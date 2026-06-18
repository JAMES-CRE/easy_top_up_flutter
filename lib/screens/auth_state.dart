
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthState extends ChangeNotifier {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool isLoggedIn = false;
  String? userName;
  String? userEmail;
  String? userPhotoUrl;
  String userRole = 'user';
  String? token;

  bool get isOperator => userRole == 'operator';
  bool get isAdmin => userRole == 'admin';

  // LOAD SAVED SESSION ON APP START 
  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedToken = prefs.getString('auth_token');
    final savedName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');
    final savedRole = prefs.getString('user_role');
    final savedPhotoUrl = prefs.getString('user_photo_url');
    
    if (savedToken != null && savedToken.isNotEmpty) {
      isLoggedIn = true;
      token = savedToken;
      userName = savedName;
      userEmail = savedEmail;
      userRole = savedRole ?? 'user';
      userPhotoUrl = savedPhotoUrl;
      notifyListeners();
    }
  }

  //  SAVE SESSION AFTER LOGIN
  Future<void> _saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token ?? '');
    await prefs.setString('user_name', userName ?? '');
    await prefs.setString('user_email', userEmail ?? '');
    await prefs.setString('user_role', userRole);
    await prefs.setString('user_photo_url', userPhotoUrl ?? '');
  }



Future<void> refreshSession() async {
  await _saveSession();  // Force save current state
  notifyListeners();
}


  // CLEAR SAVED SESSION ON LOGOUT
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_photo_url');
  }

  void login({
    required String name,
    required String email,
    String role = 'user',
    String? token,
    String? photoUrl,
  }) {
    isLoggedIn = true;
    userName = name;
    userEmail = email;
    userRole = role;
    this.token = token;
    userPhotoUrl = photoUrl;
    _saveSession();  // SAVE TO DISK
    notifyListeners();
  }

  void updateProfile({
  String? name,
  String? email,
  String? phone,
  String? photoUrl,
}) {
  if (name != null) userName = name;
  if (email != null) userEmail = email;
  //if (phone != null) userPhone = phone;
  if (photoUrl != null) userPhotoUrl = photoUrl;
  notifyListeners();
}

  Future<void> logout() async {
    isLoggedIn = false;
    userName = null;
    userEmail = null;
    userPhotoUrl = null;
    userRole = 'user';
    token = null;
    await _clearSession();  // CLEAR FROM DISK
    notifyListeners();
  }
}



