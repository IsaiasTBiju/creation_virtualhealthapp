import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: const [
          Navbar(currentRoute: '/about'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AboutHeroSection(),
                  SizedBox(height: 120),
                  MissionSection(),
                  SizedBox(height: 120),
                  ValuesSection(),
                  SizedBox(height: 120),
                  TeamSection(),
                  SizedBox(height: 120),
                  StatsSection(),
                  Footer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// HERO
//////////////////////////////////////////////////////////////

class AboutHeroSection extends StatelessWidget {
  const AboutHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120),
      color: const Color(0xFFEFEAF6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "About ",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFFFF8A00),
                    Color(0xFFFF3CAC),
                  ],
                ).createShader(bounds),
                child: const Text(
                  "Creation",
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const SizedBox(
            width: 800,
            child: Text(
              "We're on a mission to make health and wellness accessible, inclusive, and empowering for everyone, everywhere.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 1.6,
                color: Color(0xFF6B7280),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// MISSION
//////////////////////////////////////////////////////////////

class MissionSection extends StatelessWidget {
  const MissionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Our Mission",
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  "At Origin Inc., we believe that everyone deserves access to comprehensive wellness tools that respect their identity and empower their journey.",
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    color: Color(0xFF6B7280),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Creation was born from the vision of creating a health platform that truly understands and celebrates diversity—from gender-neutral language to comprehensive accessibility features.",
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.8,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF5FA2),
                    Color(0xFF6A5CFF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 30,
                  )
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 120,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// VALUES
//////////////////////////////////////////////////////////////

class ValuesSection extends StatelessWidget {
  const ValuesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120),
      child: Column(
        children: const [
          Text(
            "Our Values",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "The principles that guide everything we do",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 40,
            children: [
              ValueCard(
                "Inclusivity First",
                "We celebrate diversity and create experiences that welcome everyone, regardless of gender, age, or ability.",
              ),
              ValueCard(
                "Privacy & Security",
                "Your health data is sacred. We use industry-leading security and give you complete control over your information.",
              ),
              ValueCard(
                "Evidence-Based",
                "Every feature is grounded in health science and designed with input from medical professionals.",
              ),
              ValueCard(
                "User Empowerment",
                "We provide tools and insights, but you remain in control of your wellness journey.",
              ),
              ValueCard(
                "Holistic Wellness",
                "True health encompasses physical, mental, and emotional well-being. We track it all.",
              ),
              ValueCard(
                "Accessibility",
                "From color-blind modes to voice control, we ensure everyone can use Creation effectively.",
              ),
            ],
          )
        ],
      ),
    );
  }
}

class ValueCard extends StatelessWidget {
  final String title;
  final String desc;

  const ValueCard(this.title, this.desc, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(
              height: 1.6,
              color: Color(0xFF6B7280),
            ),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// TEAM
//////////////////////////////////////////////////////////////

class TeamSection extends StatelessWidget {
  const TeamSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 120),
      child: Column(
        children: const [
          Text(
            "Our Team",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Passionate individuals dedicated to your wellness",
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 60),
          Wrap(
            spacing: 40,
            runSpacing: 40,       
            alignment: WrapAlignment.center, 
            children: [
              TeamCard(
                "Isaias Thomas Biju",
                "Project Lead & Scrum Master",
                "Aspiring software engineer with a passion for health tech and agile methodologies.",
                [Color(0xFFFF5FA2), Color(0xFFFF8A00)],
              ),
              TeamCard(
                "Ali Khosroshahi",
                "Coding Lead and Backend Architect",
                "Former Google PM passionate about inclusive design and accessibility.",
                [Color(0xFF6A5CFF), Color(0xFF5F9CFF)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
              TeamCard(
                "Jordan Kim",
                "Lead Engineer",
                "Full-stack engineer committed to building secure, scalable health tech.",
                [Color(0xFF00C9A7), Color(0xFF007CF0)],
              ),
            ],
          )
        ],
      ),
    );
  }
}

class TeamCard extends StatelessWidget {
  final String name;
  final String role;
  final String desc;
  final List<Color> colors;

  const TeamCard(this.name, this.role, this.desc, this.colors,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: colors),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            role,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.6,
              color: Color(0xFF6B7280),
            ),
          )
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// STATS
//////////////////////////////////////////////////////////////

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF4F46E5),
            Color(0xFF9333EA),
            Color(0xFFFF3CAC),
          ],
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatItem("2020", "Founded"),
          StatItem("50K+", "Active Users"),
          StatItem("25+", "Team Members"),
          StatItem("15", "Countries"),
        ],
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
            fontSize: 42,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
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

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0C1A2E),
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP GRID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LEFT BRAND COLUMN
              SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.favorite_border,
                            color: Colors.purple, size: 28),
                        SizedBox(width: 10),
                        Text(
                          "Creation",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
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
                ),
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

          // Divider
          Container(
            height: 1,
            color: Colors.white12,
          ),

          const SizedBox(height: 30),

          // BOTTOM ROW
          Row(
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
              )
            ],
          )
        ],
      ),
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
              fontWeight: FontWeight.w600),
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
      decoration: BoxDecoration(
        color: Colors.white10,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white70, size: 20),
    );
  }
}