
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/main_map_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth_state.dart'; 
import 'services/favorite_service.dart';

void main() async {  //  CHANGE TO ASYNC
  WidgetsFlutterBinding.ensureInitialized();  // 
  
  // Load saved session before running the app
  await AuthState.instance.loadSavedSession();  // 

  await FavoriteService().init();

  runApp(const EasyTopUpApp());
}

class EasyTopUpApp extends StatelessWidget {
  const EasyTopUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easy Top Up',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      home: AuthState.instance.isLoggedIn  // ← CHANGE THIS
          ? const MainMapScreen()
          : const OnboardingScreen(),
    );
  }
}

// Onboarding - 2 slides

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: const [
              Slide1Welcome(),
              Slide2Permission(),
            ],
          ),

          //Info button
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.info_outline),
              color: Colors.green[700],
              iconSize: 20,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About Easy Top Up'),
                    content: const Text(
                        'Easy Top Up helps  people quickly locate nearby fuel stations, LPG refill points, and EV charging stations in Ghana.\n\n'
                        'KNUST final year project developed by:\nKyei\nJames\nFathihu'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      )
                    ],
                  ),
                );
              },
            ),
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainMapScreen()),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          //this creates the page dots on slide 1 and slide 2
          Positioned(
            bottom: 90,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.green[700]
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),

          // Compact centered button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 180,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == 0) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      var status = await Permission.location.request();
                      if (status.isGranted || status.isLimited) {
                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainMapScreen()),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Location permission needed for best experience')),
                        );
                      }
                    }
                  },
                  child: Text(_currentPage == 0 ? 'Next' : 'Allow'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// Slide 1 – Welcome screen
class Slide1Welcome extends StatefulWidget {
  const Slide1Welcome({super.key});

  @override
  State<Slide1Welcome> createState() => _Slide1WelcomeState();
}

class _Slide1WelcomeState extends State<Slide1Welcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // ICON animation
  late Animation<double> _iconFade;
  late Animation<Offset> _iconSlide;

  //TITLE animation 
  late Animation<double> _titleFade;

  //SUBTITLE animation 
  late Animation<double> _subtitleFade;

  //BULLET animations
  late Animation<double> _bullet1Fade;
  late Animation<Offset> _bullet1Slide;

  late Animation<double> _bullet2Fade;
  late Animation<Offset> _bullet2Slide;

  late Animation<double> _bullet3Fade;
  late Animation<Offset> _bullet3Slide;

  //FOOTER animation
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // ICON
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.5), // starts above its position
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // TITLE 
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.40, curve: Curves.easeOut),
      ),
    );

    // SUBTITLE
    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.52, curve: Curves.easeOut),
      ),
    );

    //  BULLET 1 
    _bullet1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
      ),
    );
    _bullet1Slide = Tween<Offset>(
      begin: const Offset(0.3, 0), // slides in from right
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.65, curve: Curves.easeOut),
      ),
    );

    // BULLET 2
    _bullet2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.63, 0.78, curve: Curves.easeOut),
      ),
    );
    _bullet2Slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.63, 0.78, curve: Curves.easeOut),
      ),
    );

    // BULLET 3 
    _bullet3Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.90, curve: Curves.easeOut),
      ),
    );
    _bullet3Slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.76, 0.90, curve: Curves.easeOut),
      ),
    );

    // FOOTER 
    _footerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Same green gradient as Slide2
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // APP ICON 
              FadeTransition(
                opacity: _iconFade,
                child: SlideTransition(
                  position: _iconSlide,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E7D32),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.green.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              //TITLE 
              FadeTransition(
                opacity: _titleFade,
                child: Text(
                  'Easy Top Up',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //SUBTITLE
              FadeTransition(
                opacity: _subtitleFade,
                child: Text(
                  'Find fuel fast anywhere in Ghana',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 17,
                      color: Color(0xFF388E3C),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              //  BULLET 1 
              FadeTransition(
                opacity: _bullet1Fade,
                child: SlideTransition(
                  position: _bullet1Slide,
                  child: _bulletItem(
                    Icons.local_gas_station,
                    Colors.amber.shade500,
                    'Petrol/Diesel stations',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // BULLET 2 
              FadeTransition(
                opacity: _bullet2Fade,
                child: SlideTransition(
                  position: _bullet2Slide,
                  child: _bulletItem(
                    Icons.gas_meter,
                    Colors.blue.shade600,
                    'AutoGas/LPG cylinder refills',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // BULLET 3 
              FadeTransition(
                opacity: _bullet3Fade,
                child: SlideTransition(
                  position: _bullet3Slide,
                  child: _bulletItem(
                    Icons.electric_bolt,
                    Colors.green.shade600,
                    'EV charging stations',
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // FOOTER NOTE 
              FadeTransition(
                opacity: _footerFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'We need your location to show nearby stations.\nPlease enable location access.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Exact same bulletItem as Slide2 — nothing changed
  Widget _bulletItem(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class Slide2Permission extends StatefulWidget {
  const Slide2Permission({super.key});

  @override
  State<Slide2Permission> createState() => _Slide2PermissionState();
}

class _Slide2PermissionState extends State<Slide2Permission>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _iconFade;
  late Animation<Offset> _iconSlide;

  late Animation<double> _titleFade;

  late Animation<double> _bullet1Fade;
  late Animation<Offset> _bullet1Slide;

  late Animation<double> _bullet2Fade;
  late Animation<Offset> _bullet2Slide;

  late Animation<double> _bullet3Fade;
  late Animation<Offset> _bullet3Slide;

  late Animation<double> _noteFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

            //Icons
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
      ),
    );

    // Title fades 
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.40, curve: Curves.easeOut),
      ),
    );

    // Bullet 1 
    _bullet1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.55, curve: Curves.easeOut),
      ),
    );
    _bullet1Slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.55, curve: Curves.easeOut),
      ),
    );

    // Bullet 2 
    _bullet2Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.68, curve: Curves.easeOut),
      ),
    );
    _bullet2Slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.52, 0.68, curve: Curves.easeOut),
      ),
    );

    // Bullet 3 
    _bullet3Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.80, curve: Curves.easeOut),
      ),
    );
    _bullet3Slide = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.80, curve: Curves.easeOut),
      ),
    );

    // Privacy note 
    _noteFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.80, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFC8E6C9),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // ── LOCATION ICON ──
              FadeTransition(
                opacity: _iconFade,
                child: SlideTransition(
                  position: _iconSlide,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2E7D32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.location_on,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // TITLE 
              FadeTransition(
                opacity: _titleFade,
                child: Text(
                  'Allow us to show\nstations near you',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // BULLET 1 
              FadeTransition(
                opacity: _bullet1Fade,
                child: SlideTransition(
                  position: _bullet1Slide,
                  child: _bulletItem(
                    Icons.my_location,
                    Colors.teal.shade500,
                    'See exact stations near you',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // BULLET 2 
              FadeTransition(
                opacity: _bullet2Fade,
                child: SlideTransition(
                  position: _bullet2Slide,
                  child: _bulletItem(
                    Icons.directions,
                    Colors.blue.shade600,
                    'Get directions instantly',
                  ),
                ),
              ),

              const SizedBox(height: 18),

              //  BULLET 3
              FadeTransition(
                opacity: _bullet3Fade,
                child: SlideTransition(
                  position: _bullet3Slide,
                  child: _bulletItem(
                    Icons.rate_review,
                    Colors.orange.shade600,
                    'Provide feedback on stations',
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // PRIVACY NOTE
              FadeTransition(
                opacity: _noteFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'We only use your location while the app is open.\n'
                    'We never share your location with anyone.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulletItem(IconData icon, Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 17,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
