import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'slide1_welcome.dart';
import 'slide2_permission.dart';
import '../screens/main_map_screen.dart';

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
        fit: StackFit.expand, // ensures content fills the screen
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
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
                        'Easy Top Up helps drivers quickly locate nearby fuel stations, LPG refill points, and EV charging stations in Ghana.\n'
                        'KNUST final year project Developed by:\nKyei\nJames\nFathihu'),
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

          //skkip button
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
                  //color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          ),

          // Page indicator dots
          Positioned(
            bottom: 100,
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

          // Control button at the bottom
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_currentPage == 0) {
                      // Go to slide 2
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Request location permission
                      final status = await Permission.location.request();
                      if (status.isGranted || status.isLimited) {
                        if (!mounted) return;
                        Navigator.pushReplacement(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainMapScreen()),
                        );
                      } else {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'For better experience, please allow location access')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 32),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
