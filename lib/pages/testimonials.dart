import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class TestimonialsPage extends StatelessWidget {
  const TestimonialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4C1D95),
                  Color(0xFF0EA5E9),
                  Color(0xFF1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),

          // Floating particles effect overlay
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/login_banner.jpeg"),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
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
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Success Stories",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              "Inspiring journeys of achievers",
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Stories List
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('testimonials')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.auto_stories_outlined,
                                  color: Colors.white.withOpacity(0.6),
                                  size: 60,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "No success stories yet",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Be the first to share your inspiring journey!",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      final testimonials = snapshot.data!.docs;

                      return AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          itemCount: testimonials.length,
                          itemBuilder: (context, index) {
                            final data = testimonials[index].data()
                            as Map<String, dynamic>;
                            final name = data['name'] ?? 'Anonymous';
                            final story = data['story'] ?? '';
                            final imageUrl = data['imageUrl'] ?? '';

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 800),
                              child: SlideAnimation(
                                verticalOffset: 80.0,
                                child: FadeInAnimation(
                                  child: _buildTestimonialCard(
                                      name, story, imageUrl, index),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF2196F3).withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => _openAddTestimonialDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: Text(
            "Share Story",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          icon: const Icon(
            Icons.add_circle_outline,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard(
      String name, String story, String imageUrl, int index) {
    final colors = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFE1A7E7)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFF6B9D)],
    ];

    final gradientColors = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Top quote
              Positioned(
                top: -30,
                left: -15,
                child: Text(
                  "“",
                  style: GoogleFonts.playfairDisplay(
                    color: gradientColors[0].withOpacity(0.3),
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Bottom quote
              Positioned(
                bottom: -40,
                right: -10,
                child: Transform.rotate(
                  angle: 3.14159, // 180 degrees
                  child: Text(
                    "“",
                    style: GoogleFonts.playfairDisplay(
                      color: gradientColors[1].withOpacity(0.2),
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Gradient accent line
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      bottomLeft: Radius.circular(25),
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile section
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: Colors.white,
                                backgroundImage: imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : null,
                                child: imageUrl.isEmpty
                                    ? Text(
                                  name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : 'A',
                                  style: GoogleFonts.poppins(
                                    color: gradientColors[0],
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: gradientColors
                                      .map((c) => c.withOpacity(0.2))
                                      .toList(),
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: gradientColors[0].withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                name,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 20),

                        // Story content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Text(
                                  story,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 15,
                                    height: 1.5,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Inspirational footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: gradientColors[0],
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Another success story",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.star_rounded,
                          color: gradientColors[1],
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddTestimonialDialog(BuildContext context) {
    final nameController = TextEditingController();
    final storyController = TextEditingController();
    final imageUrlController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3),
                                    Color(0xFF0D47A1)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(
                                Icons.auto_stories,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Share Your Story",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Inspire others with your journey",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // Name field
                        _buildDialogTextField(
                          controller: nameController,
                          label: "Your Name",
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 15),

                        // Story field
                        _buildDialogTextField(
                          controller: storyController,
                          label: "Your Success Story",
                          icon: Icons.edit_note,
                          maxLines: 4,
                          isRequired: true,
                        ),

                        const SizedBox(height: 15),

                        // Image URL field
                        _buildDialogTextField(
                          controller: imageUrlController,
                          label: "Image URL (optional)",
                          icon: Icons.image_outlined,
                        ),

                        const SizedBox(height: 25),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2196F3),
                                      Color(0xFF0D47A1)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF2196F3).withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : () async {
                                    if (storyController.text
                                        .trim()
                                        .isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Please enter your story"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      await FirebaseFirestore.instance
                                          .collection('testimonials')
                                          .add({
                                        "name": nameController.text
                                            .trim()
                                            .isEmpty
                                            ? "Anonymous"
                                            : nameController.text.trim(),
                                        "story":
                                        storyController.text.trim(),
                                        "imageUrl": imageUrlController
                                            .text
                                            .trim(),
                                        "createdAt":
                                        FieldValue.serverTimestamp(),
                                      });

                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Success story shared! 🎉",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          backgroundColor: Colors.green,
                                          behavior:
                                          SnackBarBehavior.floating,
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                10),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              "Error: ${e.toString()}"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                      AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                      : Text(
                                    "Share Story",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label + (isRequired ? " *" : ""),
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        hintStyle: GoogleFonts.poppins(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
      ),
    );
  }
}
