/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import 'auth_state.dart';
import 'edit_profile_screen.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brandGreen = Color(0xFF2E7D32);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _darkGreen = Color(0xFF1B5E20);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.instance.isLoggedIn;
    final userName = AuthState.instance.userName ?? 'User';
    final userEmail = AuthState.instance.userEmail ?? '';
    final userRole = AuthState.instance.userRole;

    return Scaffold(
      backgroundColor: _lightGreen,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brandGreen, _darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // ========== PROFILE CARD ==========
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_brandGreen, _darkGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _brandGreen.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Animated Avatar with border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: AuthState.instance.userPhotoUrl !=
                                    null
                                ? NetworkImage(AuthState.instance.userPhotoUrl!)
                                : null,
                            child: AuthState.instance.userPhotoUrl == null
                                ? Icon(Icons.person,
                                    size: 55, color: _brandGreen)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // User Name
                        Text(
                          isLoggedIn ? userName : 'Guest User',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // User Email
                        Text(
                          isLoggedIn ? userEmail : 'guest@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Role Badge
                        if (isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userRole == 'operator'
                                  ? 'Station Operator'
                                  : 'Fuel User',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Login Button (if not logged in)
                        if (!isLoggedIn)
                          SizedBox(
                            width: 180,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('Log In'),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AuthScreen()),
                                );
                                if (mounted) setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 1.5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ========== ACCOUNT SECTION ==========
                _sectionLabel('Account Settings'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Edit Profile Tile
                      _buildProfileTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        iconColor: _brandGreen,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                          if (updated == true && mounted) {
                            setState(() {});
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 16),

                      // My Stations (for operators)
                      if (userRole == 'operator')
                        Column(
                          children: [
                            _buildProfileTile(
                              icon: Icons.store_outlined,
                              title: 'My Stations',
                              subtitle: 'Manage your stations',
                              iconColor: Colors.blue.shade600,
                              onTap: () {
                                Navigator.pushNamed(context, '/my-stations');
                              },
                            ),
                            const Divider(height: 1, indent: 70, endIndent: 16),
                          ],
                        ),

                      // Logout Tile
                      _buildProfileTile(
                        icon: Icons.logout,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ========== APP INFO SECTION ==========
                _sectionLabel('About'),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildInfoTile(
                        icon: Icons.info_outline,
                        title: 'App Version',
                        value: '2.0.0',
                        iconColor: Colors.blue.shade600,
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.star_outline,
                        title: 'Rate Us',
                        value: '',
                        iconColor: Colors.amber.shade700,
                        onTap: () => _showSnackBar(
                            context, 'Rate us feature coming soon'),
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 16),
                      _buildInfoTile(
                        icon: Icons.share_outlined,
                        title: 'Share App',
                        value: '',
                        iconColor: Colors.green.shade600,
                        onTap: () =>
                            _showSnackBar(context, 'Share feature coming soon'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Footer text
                Center(
                  child: Text(
                    '© 2026 Easy Top Up • All rights reserved',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section label widget
  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Profile tile widget
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color titleColor = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }

  // Info tile widget (for app info section)
  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      trailing: value.isNotEmpty
          ? Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            )
          : Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
      onTap: onTap,
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              AuthState.instance.logout();
              setState(() {});
              Navigator.pop(context);
              _showSnackBar(context, 'Logged out successfully');
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Snackbar helper
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import 'auth_state.dart';
import 'main_map_screen.dart';
import 'edit_profile_screen.dart';
import '../services/favorite_service.dart';
import 'favorites_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brandGreen = Color(0xFF2E7D32);
  static const Color _lightGreen = Color(0xFFE8F5E9);
  static const Color _darkGreen = Color(0xFF1B5E20);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = AuthState.instance.isLoggedIn;
    final userName = AuthState.instance.userName ?? 'User';
    final userEmail = AuthState.instance.userEmail ?? '';
    final userRole = AuthState.instance.userRole;

    return Scaffold(
      backgroundColor: _lightGreen,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_brandGreen, _darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (!AuthState.instance.isLoggedIn) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const MainMapScreen(),
                ),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 8),

                // PROFILE CARD
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [_brandGreen, _darkGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: _brandGreen.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Animated Avatar with border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.white,
                            backgroundImage: AuthState.instance.userPhotoUrl !=
                                    null
                                ? NetworkImage(AuthState.instance.userPhotoUrl!)
                                : null,
                            child: AuthState.instance.userPhotoUrl == null
                                ? Icon(Icons.person,
                                    size: 55, color: _brandGreen)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // User Name
                        Text(
                          isLoggedIn ? userName : 'Guest User',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),

                        // User Email
                        Text(
                          isLoggedIn ? userEmail : 'guest@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Role Badge
                        if (isLoggedIn)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              userRole == 'operator'
                                  ? 'Station Operator'
                                  : 'Fuel User',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Login Button
                        if (!isLoggedIn)
                          SizedBox(
                            width: 180,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.login, size: 18),
                              label: const Text('Log In'),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AuthScreen()),
                                );
                                if (mounted) setState(() {});
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 1.5),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                //  ACCOUNT
                _sectionLabel('Account '),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Edit Profile Tile
                      _buildProfileTile(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        iconColor: _brandGreen,
                        onTap: () async {
                          final updated = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EditProfileScreen()),
                          );
                          if (updated == true && mounted) {
                            // Refresh AuthState from SharedPreferences
                            await AuthState.instance.refreshSession();

                            setState(() {});
                          }
                        },
                      ),
                      const Divider(height: 1, indent: 70, endIndent: 16),

                      //  MY FAVORITES TILE
                      if (isLoggedIn) ...[
                        _buildProfileTile(
                          icon: Icons.favorite,
                          title: 'My Favorites',
                          subtitle: 'View your saved stations',
                          iconColor: Colors.grey,
                          trailing: Text(
                            '${FavoriteService().getFavoriteCount()}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          onTap: () async {
                            final selectedStation = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FavoritesScreen(),
                              ),
                            );
                            if (selectedStation != null && mounted) {
                              Navigator.pop(context, selectedStation);
                            }
                          },
                        ),
                        const Divider(height: 1, indent: 70, endIndent: 16),
                      ],
                      const Divider(height: 1, indent: 70, endIndent: 16),

                      // Logout Tile
                      _buildProfileTile(
                        icon: Icons.logout,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        iconColor: Colors.red,
                        titleColor: Colors.red,
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section label
  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  // Profile tile widget
  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color titleColor = Colors.black87,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: trailing ??
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      onTap: onTap,
    );
  }

  // Logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () async {
              // ── Step 1: Close the dialog ──
              Navigator.pop(context);

              // ── Step 2: Clear auth data ──
              await AuthState.instance.logout();

              // ── Step 3: Clear stack and go to onboarding ──
              // ── After logout — stay on ProfileScreen as guest ──
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
