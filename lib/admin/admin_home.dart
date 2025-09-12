import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'careers_admin_page.dart';
import 'quizzes_admin_page.dart';
import 'content_admin_page.dart';
import '../widgets/drawer.dart';
import 'content_admin_page.dart' show AdminResourcesPage, AdminMultimediaPage;
import '_feature_card_tile.dart';
import '../services/authentication.dart';
import 'admin_lists.dart';
import '../pages/login_page.dart';

class AdminHomePage extends StatefulWidget {
  final int initialIndex;
  const AdminHomePage({super.key, this.initialIndex = 0});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavBar(context),
      drawer: AdminDrawer(
        onMenuItemSelected: (title) {
          if (title == 'Resources Hub') {
            _safePush(const AdminResourcesPage());
          } else if (title == 'Multimedia Guidance') {
            _safePush(const AdminMultimediaPage());
          } else if (title == 'Testimonials/Success Carousel') {
            _safePush(const AdminTestimonialsListPage());
          } else if (title == 'Feedback Forms') {
            _safePush(const AdminFeedbackListPage());
          } else if (title == 'Contact Us') {
            _safePush(const AdminInquiriesListPage());
          } else if (title == 'Logout') {
            AuthenticationHelper().signOut().then((_) {
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            });
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F4C75),
                    Color(0xFF3282B8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildDashboardCard(),
                    const SizedBox(height: 16),
                    _buildAllStatsGrid(),
                    const SizedBox(height: 20),
                    _buildFeatureGrid(),
                    const SizedBox(height: 20),
                    _buildAnnouncementsCard(),
                  ],
                ),
              ),
            ),
          ],
        );
      case 1:
        return const CareersAdminPage();
      case 2:
        return const QuizzesAdminPage();
      case 3:
        return const ContentAdminPage();
      case 4:
        return _placeholderTab(title: "Settings");
      default:
        return const SizedBox.shrink();
    }
  }

  void _safePush(Widget page) {
    try {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Navigation error: $e')));
    }
  }

  Widget _placeholderTab({required String title}) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F4C75),
                Color(0xFF3282B8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _cardWrapper(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.blueGrey.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: _selectedIndex,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedItemColor: Colors.cyanAccent.shade200,
            unselectedItemColor: Colors.white70,
            selectedLabelStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            onTap: (index) {
              if (index == 4) {
                _scaffoldKey.currentState?.openDrawer();
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center),
                label: 'Careers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz),
                label: 'Quizzes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Content',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "Admin Panel",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _cardWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildDashboardCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome Admin 🛠",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Manage your platform efficiently from one place.",
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final features = [
      {
        "icon": Icons.business_center,
        "title": "Careers",
        "onTap": () => setState(() => _selectedIndex = 1),
      },
      {
        "icon": Icons.quiz,
        "title": "Quizzes",
        "onTap": () => setState(() => _selectedIndex = 2),
      },
      {
        "icon": Icons.group,
        "title": "Users",
        "onTap": () => _safePush(const AdminUsersPage()),
      },
      {
        "icon": Icons.people,
        "title": "Testimonials",
        "onTap": () => _safePush(const AdminTestimonialsListPage()),
      },
      {
        "icon": Icons.feedback,
        "title": "Feedback",
        "onTap": () => _safePush(const AdminFeedbackListPage()),
      },
      {
        "icon": Icons.contact_mail,
        "title": "Inquiries",
        "onTap": () => _safePush(const AdminInquiriesListPage()),
      },
      {
        "icon": Icons.folder,
        "title": "Resources",
        "onTap": () => _safePush(const AdminResourcesPage()),
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        const int crossAxisCount = 2; // Always show 2 items per row

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                width >= 900
                    ? 3.8
                    : width >= 700
                    ? 3.4
                    : width >= 500
                    ? 3.0
                    : 2.4,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _featureCard(
              icon: features[index]["icon"] as IconData,
              title: features[index]["title"] as String,
              onTap: features[index]["onTap"] as VoidCallback,
            );
          },
        );
      },
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return FeatureCardTile(icon: icon, title: title, onTap: onTap);
  }

  // Removed old separate stats rows; consolidated into _buildAllStatsGrid

  Widget _buildAllStatsGrid() {
    final List<Widget> tiles = [
      _statTile('Careers', Icons.business_center, 'careers'),
      _statTile('Quizzes', Icons.quiz, 'quizzes'),
      _statTile('Testimonials', Icons.people, 'testimonials'),
      _userStatTile(
        'Users',
        Icons.group,
        FirebaseFirestore.instance.collection('users'),
      ),
      _userStatTile(
        'Active',
        Icons.verified_user,
        FirebaseFirestore.instance
            .collection('users')
            .where('active', isEqualTo: true),
      ),
      _userStatTile(
        'Inactive',
        Icons.person_off,
        FirebaseFirestore.instance
            .collection('users')
            .where('active', isEqualTo: false),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final int cols = width < 360 ? 1 : 2;
        double aspect;
        if (cols == 1) {
          aspect = 5.2; // wider tile, more height on very narrow screens
        } else if (width < 420) {
          aspect = 2.4;
        } else {
          aspect = 2.8;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: aspect,
          ),
          itemCount: tiles.length,
          itemBuilder: (context, index) => tiles[index],
        );
      },
    );
  }

  Widget _statTile(String title, IconData icon, String collection) {
    return _cardWrapper(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(collection).snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool tight =
                  constraints.maxHeight <= 56 || constraints.maxWidth <= 180;
              final double iconSize = tight ? 16 : 20;
              final double pad = tight ? 8 : 10;
              final double titleSize = tight ? 11 : 12;
              final double valueSize = tight ? 18 : 20;
              final double gap = tight ? 8 : 12;

              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: iconSize),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: titleSize,
                            ),
                          ),
                          Text(
                            '$count',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: valueSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _userStatTile(String title, IconData icon, Query query) {
    return _cardWrapper(
      child: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
          return LayoutBuilder(
            builder: (context, constraints) {
              final bool tight =
                  constraints.maxHeight <= 56 || constraints.maxWidth <= 180;
              final double iconSize = tight ? 16 : 20;
              final double pad = tight ? 8 : 10;
              final double titleSize = tight ? 11 : 12;
              final double valueSize = tight ? 18 : 20;
              final double gap = tight ? 8 : 12;

              return Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(pad),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: Colors.white, size: iconSize),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: titleSize,
                            ),
                          ),
                          Text(
                            '$count',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: valueSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsCard() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📢 Admin Announcements",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              "No new updates at the moment",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
