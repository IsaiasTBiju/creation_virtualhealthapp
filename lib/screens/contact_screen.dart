import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Column(
        children: const [
          Navbar(currentRoute: '/contact'),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ContactHeroSection(),
                  SizedBox(height: 120),
                  ContactMainSection(),
                  SizedBox(height: 140),
                  FAQSection(),
                  SizedBox(height: 120),
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

class ContactHeroSection extends StatelessWidget {
  const ContactHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 120),
      width: double.infinity,
      color: const Color(0xFFEFEAF6),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Get in ",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF00C9A7),
                    Color(0xFF6A5CFF),
                  ],
                ).createShader(bounds),
                child: const Text(
                  "Touch",
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
            width: 820,
            child: Text(
              "Have questions? We'd love to hear from you. Send us a message and we'll respond as soon as possible.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                height: 1.6,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// MAIN CONTACT SECTION
//////////////////////////////////////////////////////////////

class ContactMainSection extends StatelessWidget {
  const ContactMainSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 140),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(child: ContactInfoColumn()),
          SizedBox(width: 80),
          Expanded(child: ContactFormCard()),
        ],
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// LEFT COLUMN
//////////////////////////////////////////////////////////////

class ContactInfoColumn extends StatelessWidget {
  const ContactInfoColumn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Contact Information",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        SizedBox(height: 20),
        Text(
          "Fill out the form and our team will get back to you within 24 hours.",
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(height: 50),
        ContactInfoItem(
          icon: Icons.email_outlined,
          colors: [Color(0xFFFF5FA2), Color(0xFFFF8A00)],
          title: "Email",
          lines: [
            "hello@creation.health",
            "support@creation.health",
          ],
        ),
        SizedBox(height: 40),
        ContactInfoItem(
          icon: Icons.phone,
          colors: [Color(0xFF00C853), Color(0xFF00BFA6)],
          title: "Phone",
          lines: [
            "+1 (555) 123-4567",
            "Mon–Fri 9am–6pm EST",
          ],
        ),
        SizedBox(height: 40),
        ContactInfoItem(
          icon: Icons.location_on_outlined,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          title: "Office",
          lines: [
            "123 Wellness Street",
            "San Francisco, CA 94102",
            "United States",
          ],
        ),
      ],
    );
  }
}

class ContactInfoItem extends StatelessWidget {
  final IconData icon;
  final List<Color> colors;
  final String title;
  final List<String> lines;

  const ContactInfoItem({
    super.key,
    required this.icon,
    required this.colors,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(colors: colors),
          ),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            ...lines.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  e,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

//////////////////////////////////////////////////////////////
// FORM CARD
//////////////////////////////////////////////////////////////

class ContactFormCard extends StatelessWidget {
  const ContactFormCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: const [
          Row(
            children: [
              Expanded(
                child: CustomInput(
                  label: "Your Name",
                  hint: "John Doe",
                ),
              ),
              SizedBox(width: 30),
              Expanded(
                child: CustomInput(
                  label: "Email Address",
                  hint: "john@example.com",
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          CustomInput(
            label: "Subject",
            hint: "How can we help you?",
          ),
          SizedBox(height: 30),
          CustomInput(
            label: "Message",
            hint: "Tell us more about your inquiry...",
            maxLines: 5,
          ),
          SizedBox(height: 40),
          SendButton(),
        ],
      ),
    );
  }
}

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final int maxLines;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C3AED),
            Color(0xFFFF3CAC),
          ],
        ),
      ),
      child: const Center(
        child: Text(
          "Send Message",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// FAQ
//////////////////////////////////////////////////////////////

class FAQSection extends StatelessWidget {
  const FAQSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100), // 👈 ONE fixed width
        child: Column(
          children: const [
            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              "Quick answers to common questions",
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 60),

            FAQCard(
              question: "How do I get started with Creation?",
              answer:
                  'Simply click "Get Started" and complete our quick 8-step onboarding process. It takes less than 5 minutes!',
            ),
            SizedBox(height: 30),

            FAQCard(
              question: "Is my health data secure?",
              answer:
                  "Absolutely. We use bank-level encryption and are fully HIPAA compliant. Your data is never shared without your explicit permission.",
            ),
            SizedBox(height: 30),

            FAQCard(
              question: "Is Creation really free?",
              answer:
                  "Yes! Our core features are completely free forever. We offer optional premium features for power users.",
            ),
            SizedBox(height: 30),

            FAQCard(
              question: "Can I use Creation on my phone?",
              answer:
                  "Yes, Creation works on all devices through your web browser. Native mobile apps are coming soon!",
            ),
          ],
        ),
      ),
    );
  }
}

class FAQCard extends StatelessWidget {
  final String question;
  final String answer;

  const FAQCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 👈 important
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
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