import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PremiumEventsScreen extends StatefulWidget {
  const PremiumEventsScreen({super.key});

  @override
  State<PremiumEventsScreen> createState() => _PremiumEventsScreenState();
}

class _PremiumEventsScreenState extends State<PremiumEventsScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;

  // Premium color palette
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF7B2CBF);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color softWhite = Color(0xFFF8F8F8);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

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
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: deepBlack,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              _HeroPage(pulseController: _pulseController),
              const _EventsListPage(),
              const _FeaturedEventPage(),
            ],
          ),
          // Custom navigation
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: accentOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'EVNTS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: softWhite,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                    // Menu button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: softWhite.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MENU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: softWhite,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: _currentPage == index
                          ? const LinearGradient(
                              colors: [accentOrange, accentPurple],
                            )
                          : null,
                      color: _currentPage == index
                          ? null
                          : softWhite.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
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

// Page 1: Hero Landing
class _HeroPage extends StatelessWidget {
  final AnimationController pulseController;

  const _HeroPage({required this.pulseController});

  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF7B2CBF);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color softWhite = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            deepBlack,
            const Color(0xFF1A1A2E),
            deepBlack,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated background circles
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + (pulseController.value * 0.1),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentOrange.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 100,
            left: -150,
            child: AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + ((1 - pulseController.value) * 0.1),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          accentPurple.withValues(alpha: 0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  // Year badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentOrange, accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '2025',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Main title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [softWhite, Color(0xFFAAAAAA)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds),
                    child: const Text(
                      'Experience\nThe\nExtraordinary',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 52,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.1,
                        letterSpacing: -2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Description
                  Text(
                    'Curated events that inspire,\nconnect, and transform.',
                    style: TextStyle(
                      fontSize: 16,
                      color: softWhite.withValues(alpha: 0.6),
                      height: 1.6,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const Spacer(),
                  // Bottom stats
                  Row(
                    children: [
                      _buildStat('50+', 'Events'),
                      const SizedBox(width: 48),
                      _buildStat('12', 'Cities'),
                      const SizedBox(width: 48),
                      _buildStat('10K', 'Attendees'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // CTA Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentOrange, accentPurple],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'EXPLORE EVENTS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: softWhite,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: softWhite.withValues(alpha: 0.5),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Page 2: Events List
class _EventsListPage extends StatelessWidget {
  const _EventsListPage();

  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color softWhite = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    final events = [
      {
        'title': 'Digital Arts Festival',
        'date': 'MAR 15',
        'location': 'Barcelona',
        'category': 'Art & Design'
      },
      {
        'title': 'Tech Summit 2025',
        'date': 'APR 22',
        'location': 'Berlin',
        'category': 'Technology'
      },
      {
        'title': 'Sound & Vision',
        'date': 'MAY 08',
        'location': 'Amsterdam',
        'category': 'Music'
      },
      {
        'title': 'Future of Work',
        'date': 'JUN 12',
        'location': 'London',
        'category': 'Business'
      },
    ];

    return Container(
      color: deepBlack,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              // Section header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      color: softWhite,
                      letterSpacing: -1,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: softWhite.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${events.length} events',
                      style: TextStyle(
                        fontSize: 12,
                        color: softWhite.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Don\'t miss these experiences',
                style: TextStyle(
                  fontSize: 14,
                  color: softWhite.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 32),
              // Events list
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return _EventCard(
                      title: event['title']!,
                      date: event['date']!,
                      location: event['location']!,
                      category: event['category']!,
                      index: index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String location;
  final String category;
  final int index;

  const _EventCard({
    required this.title,
    required this.date,
    required this.location,
    required this.category,
    required this.index,
  });

  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF7B2CBF);
  static const Color softWhite = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: softWhite.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: softWhite.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: index % 2 == 0
                    ? [accentOrange, accentOrange.withValues(alpha: 0.7)]
                    : [accentPurple, accentPurple.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                date,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Event info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: softWhite,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: softWhite.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13,
                        color: softWhite.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: softWhite.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        color: index % 2 == 0 ? accentOrange : accentPurple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: softWhite.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

// Page 3: Featured Event
class _FeaturedEventPage extends StatelessWidget {
  const _FeaturedEventPage();

  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFF7B2CBF);
  static const Color deepBlack = Color(0xFF0D0D0D);
  static const Color softWhite = Color(0xFFF8F8F8);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: deepBlack,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FEATURED',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.bookmark_border,
                        color: softWhite.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Event title
                  Text(
                    'Global\nCreative\nSummit',
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: softWhite,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Event card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accentOrange,
                      accentPurple,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: -30,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date display
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '28',
                                style: TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.w200,
                                  color: Colors.white,
                                  height: 0.9,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  const Text(
                                    'MAY',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                    ),
                                  ),
                                  Text(
                                    '2025',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white.withValues(alpha: 0.9),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tokyo, Japan',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Speakers
                          const Text(
                            'Speakers',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildSpeakerChip('Sarah Chen'),
                              const SizedBox(width: 8),
                              _buildSpeakerChip('Marcus Lee'),
                              const SizedBox(width: 8),
                              _buildSpeakerChip('+12'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Get tickets button
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'GET TICKETS',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: deepBlack,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
