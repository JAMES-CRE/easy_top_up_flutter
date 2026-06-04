import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  //  New role selection for signup
  String _selectedRole = 'user';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController(); // for operators

  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ── APP BAR ──
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isLogin ? 'Login' : 'Sign Up',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),

                  //  LOGO
                  const Icon(
                    Icons.local_gas_station,
                    size: 80,
                    color: _brandGreen,
                  ),

                  const SizedBox(height: 16),

                  // APP NAME
                  Text(
                    'Easy Top Up',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _brandGreen,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // SUBTITLE
                  Text(
                    _isLogin ? 'Welcome back' : 'Create your account',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 36),

                  // ERROR MESSAGE
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // SIGN UP ONLY FIELDS
                  if (!_isLogin) ...[
                    // Role  selection here during sign up

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Fuel user option
                          RadioListTile<String>(
                            value: 'user',
                            groupValue: _selectedRole,
                            activeColor: _brandGreen,
                            onChanged: (val) => setState(() {
                              _selectedRole = val!;
                              _businessNameController.clear();
                            }),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _brandGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.person_outline,
                                      color: _brandGreen, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Fuel user',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    Text('Find fuel stations',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 1, indent: 16),

                          // Operator option
                          RadioListTile<String>(
                            value: 'operator',
                            groupValue: _selectedRole,
                            activeColor: _brandGreen,
                            onChanged: (val) =>
                                setState(() => _selectedRole = val!),
                            title: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _brandGreen.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.store,
                                      color: _brandGreen, size: 20),
                                ),
                                const SizedBox(width: 12),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Station Operator',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15)),
                                    Text('You can add your station',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // NAME FIELD
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                          borderSide:
                              const BorderSide(color: _brandGreen, width: 2),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // BUSINESS NAME (operators only) 
                    if (_selectedRole == 'operator')
                      Column(
                        children: [
                          TextFormField(
                            controller: _businessNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              labelText: 'Station / Business Name',
                              prefixIcon: const Icon(Icons.store),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: const BorderSide(
                                    color: _brandGreen, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (_selectedRole == 'operator' &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter your station or business name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                  ],

                  // EMAIL FIELD 
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide:
                            const BorderSide(color: _brandGreen, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // PASSWORD FIELD 
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide:
                            const BorderSide(color: _brandGreen, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  // SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isLogin
                            ? _brandGreen
                            : _selectedRole == 'operator'
                                ? _brandGreen
                                : _brandGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isLogin
                                  ? 'Login'
                                  : _selectedRole == 'operator'
                                      ? 'Sign Up as Operator'
                                      : 'Sign Up as Driver',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TOGGLE LOGIN / SIGN UP 
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account?"
                            : 'Already have an account?',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () => setState(() {
                          _isLogin = !_isLogin;
                          _errorMessage = null;
                          _selectedRole = 'user';
                        }),
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Login',
                          style: const TextStyle(
                            color: _brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── DIVIDER ──
                  /* Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: TextStyle(color: Colors.grey[500])),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── GOOGLE SIGN IN ──
                  OutlinedButton.icon(
                    icon: const Icon(Icons.g_mobiledata,
                        color: Colors.red, size: 28),
                    label: const Text('Continue with Google'),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Google Sign In coming soon'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ),*/

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // AUTH HANDLER 
  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> data;

      if (_isLogin) {
        // LOGIN 
        // In _handleAuth method, after successful login
        data = await ApiService.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print('Login response: $data'); // Debug - check if photo_url is present

        AuthState.instance.login(
          name: data['name'],
          email: data['email'],
          role: data['role'] ?? 'user',
          token: data['token'],
          photoUrl: data['photo_url'], // ← ADD THIS
        );

        Navigator.pop(context);
      } else {
        // REGISTER 
        data = await ApiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          role: _selectedRole, // ← sends 'user' or 'operator'
        );
      }

      if (!mounted) return;

      // After successful login, before AuthState.instance.login
      print('=== SAVING TO AUTHSTATE ===');
      print('Name: ${data['name']}');
      print('Email: ${data['email']}');
      print('Role from backend: ${data['role']}');
      print('Token: ${data['token'] != null}');

      // Save to AuthState with real role from backend
      AuthState.instance.login(
          name: data['name'],
          email: data['email'],
          role: data['role'] ?? 'operator',
          token: data['token'],
          photoUrl: data['photo_url']); // ← USE THE CORRECT KEY

      // In your app, after login
      print('=== YOUR TOKEN ===');
      print(AuthState.instance.token);
      print('=================');

      print('After login - AuthState role: ${AuthState.instance.userRole}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Welcome back, ${data['name']}!'
                : _selectedRole == 'operator'
                    ? 'Operator account created successfully!'
                    : 'Account created successfully!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    super.dispose();
  }
}
