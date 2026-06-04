import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_screen.dart';
import 'auth_state.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// StatefulWidget is needed so setState() can rebuild
// the screen after login or logout
class _ProfileScreenState extends State<ProfileScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    // Read auth state once at build time
    // so the whole screen reacts to login/logout
    final isLoggedIn = AuthState.instance.isLoggedIn;
    final userName = AuthState.instance.userName ?? 'User';
    final userEmail = AuthState.instance.userEmail ?? '';
    //final userRole = AuthState.instance.userRole;

    return Scaffold(
      // APP BAR 
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // PROFILE CARD 
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar circle
                  /*CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 54,
                      color: _brandGreen,
                    ),
                  ),*/

                 // In the profile card, replace the CircleAvatar with:

                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.white,
                    backgroundImage: AuthState.instance.userPhotoUrl != null
                        ? NetworkImage(AuthState.instance.userPhotoUrl!)
                        : null,
                    child: AuthState.instance.userPhotoUrl == null
                        ? Icon(Icons.person, size: 54, color: _brandGreen)
                        : null,
                  ),

                  const SizedBox(height: 14),

                  // NAME

                  Text(
                    isLoggedIn ? userName : 'Guest user',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  //  EMAIL

                  Text(
                    isLoggedIn ? userEmail : 'Guest user',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // LOGIN BUTTON
                  if (!isLoggedIn)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.login, size: 18),
                      label: const Text('Log In'),
                      onPressed: () async {
                        // Wait for auth screen to close
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AuthScreen()),
                        );
                        // Rebuild screen so name/email updates immediately
                        if (mounted) setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // SECTION LABEL
            _sectionLabel('Account'),

            const SizedBox(height: 10),

            //  ACCOUNT ACTIONS CARD
            _card([
              /*_tile(
                icon: Icons.edit_outlined,
                iconColor: _brandGreen,
                title: 'Edit Profile',
                onTap: () =>
                    _showSnackBar(context, 'Edit profile coming soon'),
              ),*/

              _tile(
                icon: Icons.edit_outlined,
                iconColor: _brandGreen,
                title: 'Edit Profile',
                onTap: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EditProfileScreen()),
                  );
                  if (updated == true && mounted) {
                    setState(() {}); // Refresh the screen
                  }
                },
              ),
              const Divider(height: 1, indent: 56),
              _tile(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Log Out',
                titleColor: Colors.red,
                onTap: () {
                  //REAL LOGOUT
                  // Clears auth state so the whole app knows
                  AuthState.instance.logout();

                  // Rebuild this screen so it shows Guest User immediately
                  setState(() {});

                  _showSnackBar(context, 'Logged out successfully');
                },
              ),
            ]),

            const SizedBox(height: 32),

          

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  //HELPER: Section label
  Widget _sectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // HELPER: White rounded card
  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  //HELPER: Single row tile
  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = Colors.black54,
    Color titleColor = Colors.black87,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  //HELPER: Snackbar
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
