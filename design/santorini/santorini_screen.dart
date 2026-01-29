import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SantoriniScreen extends StatefulWidget {
  const SantoriniScreen({super.key});

  @override
  State<SantoriniScreen> createState() => _SantoriniScreenState();
}

class _SantoriniScreenState extends State<SantoriniScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color primaryBlue = Color(0xFF2B4CFF);

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: const [
              _SantoriniTitlePage(),
              _CretePage(),
              _SantoriniInfoPage(),
            ],
          ),
          // Page indicators
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? primaryBlue
                        : primaryBlue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Page 1: Santorini Title
class _SantoriniTitlePage extends StatelessWidget {
  const _SantoriniTitlePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2B4CFF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Rotated Santorini text
              Expanded(
                flex: 8,
                child: Center(
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      'Santorini',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 90,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Bottom info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Administrative region:',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'South Aegean',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page 2: Crete
class _CretePage extends StatelessWidget {
  const _CretePage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Title
              const Text(
                'Crete',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 56,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF2B4CFF),
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Location:',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                'Eastern Mediterranean',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2B4CFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              // Crete island silhouette
              Center(
                child: CustomPaint(
                  size: const Size(280, 80),
                  painter: CreteIslandPainter(),
                ),
              ),
              const SizedBox(height: 40),
              // Coordinates
              Text(
                'Coordinates',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '35°10\'6"N 24°54\'6"E',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2B4CFF),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 32),
              // Description
              Text(
                'Crete (Greek: Κρήτη, Modern: Kríti, Ancient: Krḗtē, [krɛ́ːtɛː]) is the largest and most populous of the Greek islands, the 88th largest island in the world and the fifth largest island in the Mediterranean Sea, after Sicily, Sardinia, Cyprus and Corsica. It bounds the southern border of the Aegean Sea. Crete rests approximately 160 km (99 mi) south of the Greek mainland. It has an area of 8,336 km2 (3,219 sq mi) and a coastline of 1,046 km (650 mi).',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[800],
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Page 3: Santorini Info
class _SantoriniInfoPage extends StatelessWidget {
  const _SantoriniInfoPage();

  @override
  Widget build(BuildContext context) {
    final towns = [
      'Akrotiri',
      'Ammoudi',
      'Athinios',
      'Emporio',
      'Finikia',
      'Fira',
      'Firostefani',
      'Imerovigli',
      'Kamari',
    ];

    return Container(
      color: const Color(0xFFFAFAFA),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Top label
              Text(
                'Administrative region:',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const Text(
                'South Aegean',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF2B4CFF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              // Main text
              const Text(
                'Santorini was named by the Latin Empire in the thirteenth century, and is a reference to Saint Irene',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 32,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A1A),
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              // Divider
              Container(
                height: 1,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 24),
              // Towns section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      'Towns',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: towns
                          .map(
                            (town) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                town,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for Crete island silhouette
class CreteIslandPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B4CFF)
      ..style = PaintingStyle.fill;

    final path = Path();

    // Simplified Crete island shape
    path.moveTo(size.width * 0.02, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.3,
      size.width * 0.15, size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.35, size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.45, size.height * 0.15,
      size.width * 0.55, size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.2,
      size.width * 0.75, size.height * 0.35,
    );
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.25,
      size.width * 0.95, size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.98, size.height * 0.5,
      size.width * 0.95, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.85, size.height * 0.75,
      size.width * 0.75, size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.65, size.height * 0.8,
      size.width * 0.55, size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.45, size.height * 0.85,
      size.width * 0.35, size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.8,
      size.width * 0.15, size.height * 0.65,
    );
    path.quadraticBezierTo(
      size.width * 0.05, size.height * 0.7,
      size.width * 0.02, size.height * 0.5,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
