import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


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

    // Icon 
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

              // LOCATION ICON 
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
                          color: Colors.green.withValues(alpha:0.35),
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

              //  BULLET 2 
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

              // BULLET 3 
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

              //  PRIVACY NOTE
              FadeTransition(
                opacity: _noteFade,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
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
