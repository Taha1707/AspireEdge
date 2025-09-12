import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CVTipsPage extends StatefulWidget {
  const CVTipsPage({super.key});

  @override
  State<CVTipsPage> createState() => _CVTipsPageState();
}

class _CVTipsPageState extends State<CVTipsPage> with TickerProviderStateMixin {
  String selectedCategory = "All";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    "All",
    "Formats",
    "Templates",
    "Do's",
    "Don'ts",
    "Industries",
    "ATS Tips"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<CVTipItem> get filteredTips {
    if (selectedCategory == "All") return allCVTips;
    return allCVTips.where((tip) => tip.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated gradient background
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
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: _buildQuickStats(),
                ),

                // Category Filter
                SliverToBoxAdapter(
                  child: _buildCategoryFilter(),
                ),

                // CV Tips Content
                _buildCVTipsGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
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
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CV Tips & Guide",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      "Master the art of resume writing",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667EEA).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Hero section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 10),
                Text(
                  "Land Your Dream Job",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Professional templates, expert tips, and industry insights to create a winning resume",
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Templates", "15+", Icons.description),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem("Formats", "8", Icons.format_align_left),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem("Tips", "50+", Icons.lightbulb),
          Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
          _buildStatItem("Industries", "12+", Icons.business),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF667EEA), size: 24),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : null,
              ),
              child: Center(
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCVTipsGrid() {
    final filteredList = filteredTips;

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final tip = filteredList[index];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildTipCard(tip, index),
                ),
              ),
            );
          },
          childCount: filteredList.length,
        ),
      ),
    );
  }

  Widget _buildTipCard(CVTipItem tip, int index) {
    final gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFE9A8B)],
      [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)],
      [const Color(0xFFD299C2), const Color(0xFFFEF9D7)],
    ];

    final gradient = gradients[index % gradients.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tip.icon,
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
                        tip.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tip.subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    tip.category,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.description,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                if (tip.points.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  ...tip.points.map((point) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 6, right: 10),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: gradient[0],
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],

                if (tip.examples.isNotEmpty) ...[
                  const SizedBox(height: 15),
                  Text(
                    "Examples:",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...tip.examples.map((example) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gradient[0].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: gradient[0].withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      example,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )),
                ],

                const SizedBox(height: 15),

                // Action button
                GestureDetector(
                  onTap: () => _showDetailedTip(tip),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "View Details",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailedTip(CVTipItem tip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CVTipDetailSheet(tip: tip),
    );
  }
}

class CVTipDetailSheet extends StatelessWidget {
  final CVTipItem tip;

  const CVTipDetailSheet({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              tip.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  tip.subtitle,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // Full description
                      Text(
                        tip.detailedDescription,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),

                      if (tip.detailedPoints.isNotEmpty) ...[
                        const SizedBox(height: 25),
                        Text(
                          "Key Points:",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...tip.detailedPoints.asMap().entries.map((entry) {
                          int index = entry.key;
                          String point = entry.value;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${index + 1}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      point,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],

                      if (tip.templates.isNotEmpty) ...[
                        const SizedBox(height: 25),
                        Text(
                          "Templates & Examples:",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        ...tip.templates.map((template) => Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            template,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Data Models
class CVTipItem {
  final String title;
  final String subtitle;
  final String description;
  final String detailedDescription;
  final String category;
  final IconData icon;
  final List<String> points;
  final List<String> detailedPoints;
  final List<String> examples;
  final List<String> templates;

  CVTipItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.detailedDescription,
    required this.category,
    required this.icon,
    required this.points,
    required this.detailedPoints,
    required this.examples,
    required this.templates,
  });
}

// Sample Data
final List<CVTipItem> allCVTips = [
// Resume Formats
CVTipItem(
title: "Chronological Resume",
subtitle: "Most popular format for traditional career paths",
category: "Formats",
icon: Icons.timeline,
description: "The chronological resume format lists your work experience in reverse chronological order, starting with your most recent position. This format is ideal for professionals with a steady work history in the same field.",
detailedDescription: "The chronological resume is the gold standard for most job applications. It provides a clear timeline of your career progression, making it easy for hiring managers to understand your professional growth. This format works exceptionally well when you have consistent employment history and want to highlight career advancement within your field.",
points: [
"Lists work experience in reverse chronological order",
"Emphasizes career progression and stability",
"Preferred by most recruiters and ATS systems",
"Easy to read and follow",
],
detailedPoints: [
"Start with your contact information and professional summary at the top",
"List your work experience with most recent job first, including company, position, dates, and achievements",
"Include education section with relevant degrees and certifications",
"Add skills section highlighting relevant technical and soft skills",
"Keep formatting consistent throughout with clear headings and bullet points",
"Use action verbs to describe accomplishments and quantify results where possible"
],
examples: [
"Software Developer at TechCorp (2021-Present): Developed 15+ web applications using React and Node.js",
"Marketing Manager at StartupXYZ (2019-2021): Increased brand awareness by 40% through digital campaigns"
],
templates: [
"CONTACT INFORMATION\n\nPROFESSIONAL SUMMARY\n2-3 lines highlighting your expertise\n\nWORK EXPERIENCE\nJob Title | Company | Dates\n• Achievement 1\n• Achievement 2\n\nEDUCATION\nDegree | University | Year\n\nSKILLS\nTechnical Skills | Soft Skills"
],
),

CVTipItem(
title: "Functional Resume",
subtitle: "Skills-focused format for career changers",
category: "Formats",
icon: Icons.psychology,
description: "The functional resume emphasizes skills and abilities rather than chronological work history. Perfect for career changers, recent graduates, or those with employment gaps.",
detailedDescription: "A functional resume shifts focus away from your work timeline and instead highlights your relevant skills and achievements. This format allows you to group your experiences by skill category rather than by job, making it easier to demonstrate your qualifications for a new field or role type. It's particularly effective when your past job titles don't directly relate to your target position.",
points: [
"Focuses on skills rather than work timeline",
"Groups experiences by skill categories",
"Ideal for career changers and recent graduates",
"Downplays employment gaps",
],
detailedPoints: [
"Start with contact information and a compelling professional summary",
"Create 3-4 skill categories relevant to your target role",
"Under each skill category, list specific achievements and examples",
"Include a brief work history section with just company names and dates",
"Education section should be prominent if you're a recent graduate",
"Customize skill categories for each job application to match requirements"
],
examples: [
"PROJECT MANAGEMENT: Led cross-functional teams of 10+ members, delivered 5 projects on time",
"DIGITAL MARKETING: Managed social media campaigns reaching 50K+ users, increased engagement by 35%"
],
templates: [
"CONTACT INFORMATION\n\nPROFESSIONAL SUMMARY\n\nCORE COMPETENCIES\n\nSKILL CATEGORY 1\n• Relevant achievement\n• Quantified result\n\nSKILL CATEGORY 2\n• Relevant achievement\n• Quantified result\n\nEMPLOYMENT HISTORY\nCompany | Dates\n\nEDUCATION"
],
),
// ✅ Completed Combination Resume
  CVTipItem(
    title: "Combination Resume",
    subtitle: "Best of both chronological and functional formats",
    category: "Formats",
    icon: Icons.merge_type,
    description:
    "The combination resume merges the chronological and functional formats, highlighting both your skills and work history. Ideal for experienced professionals with diverse skill sets.",
    detailedDescription:
    "The combination resume format offers the perfect balance for professionals who want to showcase both their skills and career progression. This hybrid approach allows you to lead with your strongest qualifications while still providing the work history that employers expect to see. It's particularly effective for senior-level positions where both expertise and experience matter equally.",
    points: [
      "Combines skills-focused and chronological approaches",
      "Highlights both competencies and career progression",
      "Perfect for experienced professionals",
      "Shows versatility and depth of experience",
    ],
    detailedPoints: [
      "Begin with contact information and a strong professional summary",
      "Create a core competencies section with 6-8 key skills",
      "Follow with detailed work experience in reverse chronological order",
      "Include quantified achievements under each role",
      "Highlight career progression along with technical expertise",
      "Finish with education, certifications, and relevant projects",
    ],
    examples: [
      "CORE SKILLS: Project Management | Data Analysis | Leadership",
      "Senior Developer at InnovateTech (2018-Present): Led team of 8 developers, delivered 10+ apps"
    ],
    templates: [
      "CONTACT INFORMATION\n\nPROFESSIONAL SUMMARY\n...\n\nCORE COMPETENCIES\nSkill 1 | Skill 2 | Skill 3\n\nWORK EXPERIENCE\nJob Title | Company | Dates\n• Achievement\n• Achievement\n\nEDUCATION\nDegree | University | Year"
    ],
  ),
];