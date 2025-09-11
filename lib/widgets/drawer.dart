import 'package:auth_reset_pass/pages/career_bank.dart';
import 'package:auth_reset_pass/pages/quiz_intro.dart';
import 'package:flutter/material.dart';
import '../pages/testimonials.dart';
import '../pages/contact_page.dart';
import '../pages/feedback_page.dart';

class UserDrawer extends StatelessWidget {
  final Function(String) onMenuItemSelected;

  const UserDrawer({super.key, required this.onMenuItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.blueGrey.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(3, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            // Drawer title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Center(
                child: Text(
                  "Explore",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white24),

            // 0) Home
            _sectionHeader("Home"),
            _menuItem(context, Icons.home, "Home"),

            // 1) Career Bank
            _sectionHeader("Career Bank"),
            _menuItem(
              context,
              Icons.work,
              "Career Bank",
              page: const CareerBankPage(),
            ),

            // 2) Admission and Coaching Tools
            _sectionHeader("Admission & Coaching"),
            _subMenuItem(context, Icons.school, "Stream Selector"),
            _subMenuItem(context, Icons.article, "CV Tips"),
            _subMenuItem(
              context,
              Icons.record_voice_over,
              "Interview Preparation",
            ),

            // 3) Resources Hub
            _sectionHeader("Resources Hub"),
            _menuItem(context, Icons.folder, "Resources Hub"),

            // 4) Career Quiz
            _sectionHeader("Career Quiz"),
            _menuItem(
              context,
              Icons.quiz,
              "Career Quiz",
              page: const QuizIntroPage(),
            ),

            // 5) Multimedia Guidance
            _sectionHeader("Multimedia Guidance"),
            _menuItem(context, Icons.video_library, "Multimedia Guidance"),

            // 6) Testimonials (with navigation)
            _sectionHeader("Testimonials"),
            _menuItem(
              context,
              Icons.people,
              "Testimonials",
              page: const TestimonialsPage(),
            ),

            // 7) Feedback
            _sectionHeader("Feedback"),
            _menuItem(
              context,
              Icons.feedback,
              "Feedback",
              page: const FeedbackPage(),
            ),

            // 8) Contact
            _sectionHeader("Contact"),
            _menuItem(
              context,
              Icons.contact_mail,
              "Contact",
              page: const ContactUsPage(),
            ),
          ],
        ),
      ),
    );
  }

  // Big section headers
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 15, bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.lightBlueAccent.shade100,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Main menu item (with optional navigation page)
  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? page,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.lightBlueAccent),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      onTap: () {
        onMenuItemSelected(title);
        Navigator.pop(context); // close drawer
        if (page != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        }
      },
      hoverColor: Colors.blueGrey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  // Sub menu items (indented)
  Widget _subMenuItem(BuildContext context, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent.shade200, size: 20),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        onTap: () {
          onMenuItemSelected(title);
          Navigator.pop(context);
        },
        hoverColor: Colors.blueGrey.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
