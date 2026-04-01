import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Stack(
        children: const [
          SmoothParticles(),
          _HomeScrollContent(),
        ],
      ),
    );
  }
}

class _HomeScrollContent extends StatelessWidget {
  const _HomeScrollContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: const [
          Navbar(currentRoute: '/'),
          SizedBox(height: 80),
          HeroSection(),
          SizedBox(height: 120),
          FeaturesSection(),
          SizedBox(height: 120),
          StatsSection(),
          SizedBox(height: 120),
          TestimonialsSection(),
          SizedBox(height: 120),
          CTASection(),
          SizedBox(height: 120),
          Footer(),
        ],
      ),
    );
  }
}

class SmoothParticles extends StatefulWidget {
  const SmoothParticles({super.key});

  @override
  State<SmoothParticles> createState() => _SmoothParticlesState();
}

class _SmoothParticlesState extends State<SmoothParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final int count = 50;
  final Random random = Random();

  late List<Offset> positions;
  late List<Offset> velocities;
  late List<Color> colors;

  @override
  void initState() {
    super.initState();

    positions = List.generate(
      count,
      (_) => Offset(random.nextDouble(), random.nextDouble()),
    );

    velocities = List.generate(
      count,
      (_) => Offset(
        (random.nextDouble() - 0.5) * 0.0008,
        (random.nextDouble() - 0.5) * 0.0008,
      ),
    );

    final pastel = [
      const Color(0xFFB14EFF),
      const Color(0xFFFF7A18),
      const Color(0xFF4BC0C8),
      const Color(0xFFFFC857),
      const Color(0xFF6C2CF3),
    ];

    colors = List.generate(
      count,
      (_) => pastel[random.nextInt(pastel.length)],
    );

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    )..addListener(() {
        setState(() {
          for (int i = 0; i < count; i++) {
            positions[i] += velocities[i];

            if (positions[i].dx < 0 || positions[i].dx > 1) {
              velocities[i] = Offset(-velocities[i].dx, velocities[i].dy);
            }
            if (positions[i].dy < 0 || positions[i].dy > 1) {
              velocities[i] = Offset(velocities[i].dx, -velocities[i].dy);
            }
          }
        });
      });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: ParticlePainter(positions, colors),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ParticlePainter extends CustomPainter {
  final List<Offset> positions;
  final List<Color> colors;

  ParticlePainter(this.positions, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFFB0B6C3).withOpacity(0.08)
      ..strokeWidth = 0.8;

    final absolute = positions
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();

    for (int i = 0; i < absolute.length; i++) {
      particlePaint.color = colors[i].withOpacity(0.25);
      canvas.drawCircle(absolute[i], 2.5, particlePaint);

      for (int j = i + 1; j < absolute.length; j++) {
        if ((absolute[i] - absolute[j]).distance < 120) {
          canvas.drawLine(absolute[i], absolute[j], linePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 60.0
            : 100.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          SizedBox(height: isMobile ? 40 : 100),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.favorite_border,
                color: Color(0xFF6C2CF3),
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                "BY ORIGIN INC.",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 1.2,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFB14EFF),
                Color(0xFF6C2CF3),
              ],
            ).createShader(bounds),
            child: Text(
              "Creation",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 42 : (isTablet ? 56 : 72),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Your Complete Wellness Companion",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 18 : 24,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Text(
              "Track fitness, monitor wellness, connect with friends, and achieve your health goals with our inclusive, accessible platform designed for everyone.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                color: Colors.black54,
              ),
            ),
          ),

          const SizedBox(height: 40),

          Wrap(
            spacing: 20,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              gradientButton1(context, "Get Started"),
              outlinedButton(context, "Sign In"),
            ],
          ),

          const SizedBox(height: 20),

          const Text(
            "No credit card required • Free forever • Join 50,000+ users",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45),
          ),

          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/admin-login'),
                child: const Text(
                  'Administrator portal',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
              Text(
                '·',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/signin'),
                child: const Text(
                  'Practice & clinical sign in',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 60.0
            : 120.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const Text(
            "Everything You Need to Thrive",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "A comprehensive health platform that grows with you",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxCardWidth = 350.0;
              final availableWidth = constraints.maxWidth;
              final cardWidth = availableWidth < maxCardWidth
                  ? availableWidth
                  : maxCardWidth;

              return Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  FeatureCard(
                    icon: Icons.show_chart,
                    title: "Fitness Tracking",
                    desc:
                        "Log workouts, track steps, monitor calories, and see your progress with beautiful charts.",
                    color: Colors.blue,
                    width: cardWidth,
                  ),
                  FeatureCard(
                    icon: Icons.favorite,
                    title: "Wellness Monitoring",
                    desc:
                        "Track mood, sleep, hydration, and mindfulness to maintain balance.",
                    color: Colors.pink,
                    width: cardWidth,
                  ),
                  FeatureCard(
                    icon: Icons.emoji_events,
                    title: "Achievements & Streaks",
                    desc:
                        "Unlock badges, maintain streaks, and celebrate milestones.",
                    color: Colors.orange,
                    width: cardWidth,
                  ),
                  FeatureCard(
                    icon: Icons.groups,
                    title: "Social & Challenges",
                    desc: "Connect with friends and compete on leaderboards.",
                    color: Colors.purple,
                    width: cardWidth,
                  ),
                  FeatureCard(
                    icon: Icons.shield,
                    title: "Privacy First",
                    desc: "Your health data is private and secure.\n",
                    color: Colors.green,
                    width: cardWidth,
                  ),
                  FeatureCard(
                    icon: Icons.star,
                    title: "Fully Inclusive",
                    desc:
                        "Gender-neutral language and full accessibility support.",
                    color: Colors.red,
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final double width;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              desc,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    int crossAxisCount = 4; // desktop default

    if (isMobile) {
      crossAxisCount = 2;
    } else if (isTablet) {
      crossAxisCount = 2;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C2CF3), Color(0xFFFF7A18)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 40,
            crossAxisSpacing: 40,
            childAspectRatio: isMobile ? 1.3 : 1.8,
            children: const [
              StatItem("50K+", "Active Users"),
              StatItem("2M+", "Workouts Logged"),
              StatItem("15M+", "Steps Tracked"),
              StatItem("98%", "Satisfaction Rate"),
            ],
          ),
        ),
      ),
    );
  }
}


class StatItem extends StatelessWidget {
  final String value;
  final String label;

  const StatItem(this.value, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class TestimonialsSection extends StatelessWidget {
  const TestimonialsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 60.0
            : 120.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const Text(
            "Loved by Thousands",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            "See what our community has to say",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 60),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxCardWidth = 350.0;
              final availableWidth = constraints.maxWidth;
              final cardWidth = availableWidth < maxCardWidth
                  ? availableWidth
                  : maxCardWidth;

              return Wrap(
                spacing: 40,
                runSpacing: 40,
                alignment: WrapAlignment.center,
                children: [
                  TestimonialCard(
                    quote:
                        "Creation has completely transformed how I approach my health.",
                    name: "Prof. Abrar Ullah",
                    role: "Professor for F29SO",
                    width: cardWidth,
                  ),
                  TestimonialCard(
                    quote:
                        "Finally, a wellness app that guides me and makes me feel seen.",
                    name: "Prof. Hani Ragab",
                    role: "Line Manager for Dubai Group 2",
                    width: cardWidth,
                  ),
                  TestimonialCard(
                    quote: "I recommend Creation to all my clients.",
                    name: "Prof. Ali Muzaffar",
                    role: "Group Project Coordinator for F29SO",
                    width: cardWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class TestimonialCard extends StatelessWidget {
  final String quote;
  final String name;
  final String role;
  final double width;

  const TestimonialCard({
    super.key,
    required this.quote,
    required this.name,
    required this.role,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "★★★★★",
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 20),
            Text(
              "\"$quote\"",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              role,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class CTASection extends StatelessWidget {
  const CTASection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 20.0
        : isTablet
            ? 60.0
            : 120.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        children: [
          const Text(
            "Start Your Wellness Journey Today",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            "Join thousands already transforming their health with Creation",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          gradientButton1(context, "Get Started"),
        ],
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 700;

    final horizontalPadding = isMobile ? 20.0 : 120.0;

    return Container(
      color: const Color(0xFF0C1A2E),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 60,
      ),
      child: Column(
        crossAxisAlignment:
            isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.start,
        children: [
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _brandColumn(),
                const SizedBox(height: 40),
                footerColumn(
                  "Product",
                  ["Features", "Pricing", "Mobile App", "Integrations"],
                ),
                const SizedBox(height: 30),
                footerColumn(
                  "Company",
                  ["About Us", "Careers", "Blog", "Contact"],
                ),
                const SizedBox(height: 30),
                footerColumn(
                  "Legal",
                  [
                    "Privacy Policy",
                    "Terms of Service",
                    "Cookie Policy",
                    "HIPAA Compliance"
                  ],
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 320,
                  child: _brandColumn(),
                ),
                const Spacer(),
                footerColumn(
                  "Product",
                  ["Features", "Pricing", "Mobile App", "Integrations"],
                ),
                const SizedBox(width: 100),
                footerColumn(
                  "Company",
                  ["About Us", "Careers", "Blog", "Contact"],
                ),
                const SizedBox(width: 100),
                footerColumn(
                  "Legal",
                  [
                    "Privacy Policy",
                    "Terms of Service",
                    "Cookie Policy",
                    "HIPAA Compliance"
                  ],
                ),
              ],
            ),
          const SizedBox(height: 60),
          Container(
            height: 1,
            color: Colors.white12,
          ),
          const SizedBox(height: 30),
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "© 2026 Origin Inc. All rights reserved.",
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        socialIcon(Icons.business),
                        const SizedBox(width: 20),
                        socialIcon(Icons.camera_alt_outlined),
                        const SizedBox(width: 20),
                        socialIcon(Icons.alternate_email),
                        const SizedBox(width: 20),
                        socialIcon(Icons.email_outlined),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "© 2026 Origin Inc. All rights reserved.",
                      style: TextStyle(color: Colors.white54),
                    ),
                    Row(
                      children: [
                        socialIcon(Icons.business),
                        const SizedBox(width: 20),
                        socialIcon(Icons.camera_alt_outlined),
                        const SizedBox(width: 20),
                        socialIcon(Icons.alternate_email),
                        const SizedBox(width: 20),
                        socialIcon(Icons.email_outlined),
                      ],
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _brandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          children: [
            Icon(Icons.favorite_border, color: Colors.purple, size: 28),
            SizedBox(width: 10),
            Text(
              "Creation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          "Your complete wellness companion.\nTrack, monitor, and achieve your health goals.",
          style: TextStyle(
            color: Colors.white60,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  static Widget footerColumn(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        ...items.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              e,
              style: const TextStyle(color: Colors.white60),
            ),
          ),
        )
      ],
    );
  }

  static Widget socialIcon(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: const BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }
}

Widget gradientButton1(BuildContext context, String text) {
  return Container(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF4D79), Color(0xFFFF7A18)],
      ),
      borderRadius: BorderRadius.circular(12),
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 20,
        ),
      ),
      onPressed: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Text(text),
    ),
  );
}

Widget outlinedButton(BuildContext context, String text) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      side: const BorderSide(color: Colors.purple),
    ),
    onPressed: () {
      Navigator.pushNamed(context, '/signin');
    },
    child: Text(
      text,
      style: const TextStyle(color: Colors.purple),
    ),
  );
}
