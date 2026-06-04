import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class Slide1Welcome extends StatefulWidget {
  const Slide1Welcome({super.key});

  @override
  State<Slide1Welcome> createState() => _Slide1WelcomeState();
}

class _Slide1WelcomeState extends State<Slide1Welcome>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  //  ICON animation 
  late Animation<double> _iconFade;
  late Animation<Offset> _iconSlide;

  // TITLE animation 
  late Animation<double> _titleFade;

  //  SUBTITLE animation 
  late Animation<double> _subtitleFade;

  // BULLET animations
  late Animation<double> _bullet1Fade;
  late Animation<Offset> _bullet1Slide;

  late Animation<double> _bullet2Fade;
  late Animation<Offset> _bullet2Slide;

  late Animation<double> _bullet3Fade;
  late Animation<Offset> _bullet3Slide;

  // FOOTER animation
  late Animation<double> _footerFade;

  @override
  void initState() {
    super.initState();

    // Same duration as Slide2 — 3 seconds total
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    //  ICON 
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

    
    
    //BULLET 2
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

    
    //BULLET 3 
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

    
    
    //FOOTER
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

              
              //APP ICON 
              // Green circle with a gas station icon 
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
                  style: GoogleFonts.prata(
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

              
              
              
              //  SUBTITLE 
            
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



              // BULLET 1 
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

  //_bulletItem 
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