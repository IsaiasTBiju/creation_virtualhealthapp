import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final String currentRoute;

  const Navbar({
    super.key,
    required this.currentRoute,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool menuOpen = false;

  void navigate(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final horizontalPadding = isMobile
        ? 16.0
        : isTablet
            ? 40.0
            : 100.0;

    return Column(
      children: [
        Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ================= LEFT (LOGO) =================
              GestureDetector(
                onTap: () => navigate(context, '/'),
                child: Row(
                  children: const [
                    Icon(Icons.favorite_border,
                        color: Color(0xFFFF4D79), size: 26),
                    SizedBox(width: 10),
                    Text(
                      "Creation",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 6),
                    Text(
                      "by Origin Inc.",
                      style:
                          TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                  ],
                ),
              ),

              // ================= DESKTOP/TABLET NAV =================
              if (!isMobile)
                Row(
                  children: [
                    NavLink(
                      title: "Home",
                      route: '/',
                      currentRoute: widget.currentRoute,
                      onTap: () => navigate(context, '/'),
                    ),
                    const SizedBox(width: 30),
                    NavLink(
                      title: "About Us",
                      route: '/about',
                      currentRoute: widget.currentRoute,
                      onTap: () => navigate(context, '/about'),
                    ),
                    const SizedBox(width: 30),
                    NavLink(
                      title: "Contact",
                      route: '/contact',
                      currentRoute: widget.currentRoute,
                      onTap: () => navigate(context, '/contact'),
                    ),
                  ],
                ),

              // ================= RIGHT SIDE =================
              if (!isMobile)
                Row(
                  children: [
                    NavLink(
                      title: "Sign In",
                      route: '/signin',
                      currentRoute: widget.currentRoute,
                      onTap: () => navigate(context, '/signin'),
                    ),
                    const SizedBox(width: 20),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF4D79),
                            Color(0xFFFF7A18),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 14),
                        ),
                        onPressed: () => navigate(context, '/signup'),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),

              // ================= MOBILE MENU BUTTON =================
              if (isMobile)
                IconButton(
                  icon: Icon(
                    menuOpen ? Icons.close : Icons.menu,
                    size: 28,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    setState(() => menuOpen = !menuOpen);
                  },
                ),
            ],
          ),
        ),

        // ================= MOBILE DROPDOWN MENU =================
        if (menuOpen && isMobile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: const Color(0xFFF8F9FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _mobileLink("Home", '/', context),
                _mobileLink("About Us", '/about', context),
                _mobileLink("Contact", '/contact', context),
                _mobileLink("Sign In", '/signin', context),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF4D79),
                          Color(0xFFFF7A18),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 14),
                      ),
                      onPressed: () => navigate(context, '/signup'),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _mobileLink(String title, String route, BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => menuOpen = false);
        navigate(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
// NAV LINK WIDGET
//////////////////////////////////////////////////////////////

class NavLink extends StatefulWidget {
  final String title;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;

  const NavLink({
    super.key,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  State<NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<NavLink> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.currentRoute == widget.route;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            fontSize: 16,
            fontWeight:
                isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive || isHovering
                ? const Color(0xFF6C2CF3)
                : Colors.black87,
          ),
          child: Text(widget.title),
        ),
      ),
    );
  }
}
