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
      [const Color(0xFF00D2FF), const Color(0xFF3A7BD5)],
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

final List<CVTipItem> allCVTips = [
  // ------------------ RESUME FORMATS ------------------
  CVTipItem(
    title: "Chronological Resume",
    subtitle: "Most popular format for traditional career paths",
    category: "Formats",
    icon: Icons.timeline,
    description:
    "Lists your work experience in reverse chronological order, highlighting steady career growth.",
    detailedDescription:
    "The chronological resume is the gold standard for most job applications. It provides a clear timeline of your career progression, making it easy for hiring managers to understand your professional growth. Best suited for those with consistent employment history.",
    points: [
      "Reverse chronological work history",
      "Clear and easy to scan",
      "ATS-friendly format",
      "Highlights career stability"
    ],
    detailedPoints: [
      "Start with a compelling professional summary",
      "List jobs with company, title, dates, and achievements",
      "Focus on quantifiable results in bullet points",
      "End with education, certifications, and skills section"
    ],
    examples: [
      "Software Engineer, Google (2021-Present) – Developed 10+ features for core search products",
    ],
    templates: [
      "CONTACT INFO\n\nSUMMARY\nProfessional summary here...\n\nWORK EXPERIENCE\nJob Title | Company | Date\n• Achievement\n• Achievement\n\nEDUCATION\nDegree | University | Year\n\nSKILLS"
    ],
  ),
  CVTipItem(
    title: "Functional Resume",
    subtitle: "Perfect for career changers or freshers",
    category: "Formats",
    icon: Icons.psychology,
    description:
    "Focuses on skills and achievements rather than job history. Ideal for job seekers with gaps or career switchers.",
    detailedDescription:
    "A functional resume highlights what you can do, not just where you worked. Skills are grouped into categories with examples of accomplishments. Employers still expect a small work history section at the end.",
    points: [
      "Focuses on skills instead of timeline",
      "Good for freshers or freelancers",
      "Minimizes gaps in work history",
      "Highlights transferable skills"
    ],
    detailedPoints: [
      "Group your skills by relevance to job",
      "Add real-world examples for each skill",
      "Keep work history minimal at bottom",
      "Tailor skill categories per job posting"
    ],
    examples: [
      "PROJECT MANAGEMENT: Delivered 5 cross-functional projects on time and under budget"
    ],
    templates: [
      "CONTACT INFO\n\nPROFESSIONAL SUMMARY\n...\n\nCORE SKILLS\nSkill 1: Achievement\nSkill 2: Achievement\n\nWORK HISTORY\nCompany | Date\n\nEDUCATION"
    ],
  ),

  // ------------------ DO'S ------------------
  CVTipItem(
    title: "Use Action Verbs",
    subtitle: "Make every bullet point impactful",
    category: "Do's",
    icon: Icons.check_circle,
    description:
    "Start bullet points with strong action verbs to show achievement and responsibility.",
    detailedDescription:
    "Recruiters skim CVs for action-oriented words. Using verbs like 'Led', 'Developed', 'Implemented', or 'Designed' makes your contributions clear and compelling.",
    points: [
      "Use past tense for previous jobs",
      "Show impact rather than duties",
      "Be concise and result-driven"
    ],
    detailedPoints: [
      "Avoid weak openers like 'Responsible for'",
      "Focus on what you achieved, not just tasks",
      "Quantify impact whenever possible"
    ],
    examples: [
      "Led a team of 5 engineers to deliver 3 successful app releases",
      "Reduced website load time by 30% through performance optimization"
    ],
    templates: [],
  ),
  CVTipItem(
    title: "Tailor for Each Job",
    subtitle: "Customize, don't just copy-paste",
    category: "Do's",
    icon: Icons.adjust,
    description:
    "Every job description is unique. Customize your CV to highlight the skills and achievements most relevant to that role.",
    detailedDescription:
    "Sending the same CV to every job rarely works. Read the job description carefully, use similar keywords, and highlight matching skills.",
    points: [
      "Match keywords for ATS",
      "Focus on most relevant experience",
      "Show how you solve employer problems"
    ],
    detailedPoints: [
      "Analyze job description and pick key terms",
      "Reorder achievements so most relevant come first",
      "Mention industry-specific tools if required"
    ],
    examples: [
      "For a data analyst job, highlight SQL, Python, and dashboard projects first."
    ],
    templates: [],
  ),

  // ------------------ DON'TS ------------------
  CVTipItem(
    title: "Avoid Typos",
    subtitle: "Errors can cost you the job",
    category: "Don'ts",
    icon: Icons.close,
    description:
    "Grammar mistakes or typos make a bad first impression and signal carelessness.",
    detailedDescription:
    "Always proofread your CV multiple times. Use spell-check and tools like Grammarly to catch errors. Ask a friend to review it for a fresh perspective.",
    points: [
      "Proofread before sending",
      "Keep formatting consistent",
      "Avoid slang or informal language"
    ],
    detailedPoints: [
      "Check tense consistency",
      "Align bullet points properly",
      "Avoid ALL CAPS or excessive bold text"
    ],
    examples: [
      "Wrong: Maneged a team of 10\nRight: Managed a team of 10"
    ],
    templates: [],
  ),
  CVTipItem(
    title: "Don't Overload with Graphics",
    subtitle: "ATS might reject complex designs",
    category: "Don'ts",
    icon: Icons.warning,
    description:
    "While creative CVs look nice, too much design can confuse ATS systems or make them unreadable.",
    detailedDescription:
    "Keep a balance — clean, minimal designs are easier to scan for recruiters and safer for online applications.",
    points: [
      "Avoid excessive use of colors",
      "Stick to 1-2 fonts max",
      "Maintain enough white space"
    ],
    detailedPoints: [
      "Reserve icons for section headers only",
      "Save creative CVs for in-person networking",
      "Use standard file format: PDF"
    ],
    examples: [],
    templates: [],
  ),

  // ------------------ TEMPLATES ------------------
  CVTipItem(
    title: "Modern Professional Template",
    subtitle: "Clean, ATS-friendly design",
    category: "Templates",
    icon: Icons.description,
    description:
    "A simple one-page CV template with clear headings and plenty of white space.",
    detailedDescription:
    "This template focuses on readability and professional aesthetics. Perfect for corporate jobs.",
    points: ["One-page layout", "Professional font", "Easy to scan"],
    detailedPoints: [
      "Header with name, title, and contact info",
      "Clear sections: Summary, Skills, Work, Education",
      "Bullet points for achievements"
    ],
    examples: [],
    templates: [
      "https://resumegenius.com/resume-templates/modern",
      "https://zety.com/resume-templates"
    ],
  ),

  // ------------------ ATS TIPS ------------------
  CVTipItem(
    title: "Optimize for ATS",
    subtitle: "Ensure your CV passes screening bots",
    category: "ATS Tips",
    icon: Icons.smart_toy,
    description:
    "Use standard formatting, simple fonts, and include relevant keywords to get past Applicant Tracking Systems.",
    detailedDescription:
    "ATS scans for keywords from the job description. Missing them may get your CV rejected before a human sees it.",
    points: [
      "Use job title in your CV",
      "Match keywords exactly",
      "Avoid tables, columns, and images"
    ],
    detailedPoints: [
      "Stick to Word or PDF format",
      "Use plain text for section headers",
      "Don't hide keywords in white text (ATS may flag it)"
    ],
    examples: [
      "Job asks for 'React Developer' – use the exact phrase instead of just 'Frontend Developer'"
    ],
    templates: [],
  ),
];
