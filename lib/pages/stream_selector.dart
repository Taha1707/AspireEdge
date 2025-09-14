import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class StreamSelectorPage extends StatefulWidget {
  const StreamSelectorPage({super.key});

  @override
  State<StreamSelectorPage> createState() => _StreamSelectorPageState();
}

class _StreamSelectorPageState extends State<StreamSelectorPage>
    with TickerProviderStateMixin {
  String selectedCategory = "All";
  String searchQuery = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    "All",
    "Matric",
    "Intermediate",
    "Graduate",
    "Career Guidance",
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

  List<StreamInfo> get filteredMatricStreams =>
      (selectedCategory == "All" || selectedCategory == "Matric")
          ? matricStreams
              .where(
                (s) =>
                    s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    s.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    s.subjects.any(
                      (subject) => subject.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList()
          : [];

  List<StreamInfo> get filteredIntermediateStreams =>
      (selectedCategory == "All" || selectedCategory == "Intermediate")
          ? intermediateStreams
              .where(
                (s) =>
                    s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    s.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    s.subjects.any(
                      (subject) => subject.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList()
          : [];

  List<StreamInfo> get filteredGraduateStreams =>
      (selectedCategory == "All" || selectedCategory == "Graduate")
          ? graduateStreams
              .where(
                (s) =>
                    s.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    s.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    s.subjects.any(
                      (subject) => subject.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    ),
              )
              .toList()
          : [];

  List<CareerTip> get filteredCareerTips =>
      (selectedCategory == "All" || selectedCategory == "Career Guidance")
          ? careerTips
              .where(
                (t) =>
                    t.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
                    t.description.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ),
              )
              .toList()
          : [];

  int get totalStreams {
    return matricStreams.length +
        intermediateStreams.length +
        graduateStreams.length +
        careerTips.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F0C29),
              Color(0xFF24243e),
              Color(0xFF302B63),
              Color(0xFF0F4C75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildQuickStats()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: _buildCategoryFilter()),
                if (filteredMatricStreams.isNotEmpty)
                  _buildSectionHeader(
                    "Matric - Specialization Streams",
                    Icons.science,
                  ),
                if (filteredMatricStreams.isNotEmpty)
                  _buildStreamsGrid(filteredMatricStreams),
                if (filteredIntermediateStreams.isNotEmpty)
                  _buildSectionHeader(
                    "Intermediate - Advanced Streams",
                    Icons.auto_stories,
                  ),
                if (filteredIntermediateStreams.isNotEmpty)
                  _buildStreamsGrid(filteredIntermediateStreams),
                if (filteredGraduateStreams.isNotEmpty)
                  _buildSectionHeader(
                    "Graduate - Bachelor's Degree Programs",
                    Icons.school,
                  ),
                if (filteredGraduateStreams.isNotEmpty)
                  _buildStreamsGrid(filteredGraduateStreams),
                if (filteredCareerTips.isNotEmpty)
                  _buildSectionHeader("Career Guidance Tips", Icons.lightbulb),
                if (filteredCareerTips.isNotEmpty) _buildCareerTipsGrid(),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
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
                "Stream Selector",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Choose the right academic path for your future success",
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
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
          ),
          child: const Icon(Icons.explore, color: Colors.white, size: 28),
        ),
      ],
    ),
  );

  Widget _buildQuickStats() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          "Educational Pathways",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem("Matric", "${matricStreams.length}", Icons.science),
            _buildDivider(),
            _buildStatItem(
              "Inter",
              "${intermediateStreams.length}",
              Icons.auto_stories,
            ),
            _buildDivider(),
            _buildStatItem(
              "Graduate",
              "${graduateStreams.length}",
              Icons.school,
            ),
            _buildDivider(),
            _buildStatItem("Tips", "${careerTips.length}", Icons.lightbulb),
          ],
        ),
      ],
    ),
  );

  Widget _buildDivider() => Container(
    width: 1,
    height: 40,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );

  Widget _buildStatItem(String label, String value, IconData icon) => Column(
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
      ),
    ],
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          hintText: "Search streams, subjects, or careers...",
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon:
              searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () => setState(() => searchQuery = ""),
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
        onChanged: (value) => setState(() => searchQuery = value),
      ),
    ),
  );

  Widget _buildCategoryFilter() => Container(
    height: 60,
    margin: const EdgeInsets.symmetric(vertical: 15),
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () => setState(() => selectedCategory = category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      )
                      : null,
              color: isSelected ? null : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color:
                    isSelected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
              ),
              boxShadow:
                  isSelected
                      ? [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                      : null,
            ),
            child: Center(
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _buildSectionHeader(String title, IconData icon) => SliverToBoxAdapter(
    child: Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildStreamsGrid(List<StreamInfo> streams) => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final stream = streams[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(child: _buildStreamCard(stream)),
          ),
        );
      }, childCount: streams.length),
    ),
  );

  Widget _buildCareerTipsGrid() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tip = filteredCareerTips[index];
        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 600),
          child: SlideAnimation(
            verticalOffset: 50,
            child: FadeInAnimation(child: _buildCareerTipCard(tip)),
          ),
        );
      }, childCount: filteredCareerTips.length),
    ),
  );

  Widget _buildStreamCard(StreamInfo stream) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(stream.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stream.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stream.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Core Subjects
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Color(0xFF667EEA),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Core Subjects:",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      stream.subjects
                          .map(
                            (subject) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF667EEA),
                                    Color(0xFF764BA2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                subject,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Career Opportunities
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.work, color: Color(0xFF667EEA), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Career Opportunities:",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      stream.careers
                          .map(
                            (career) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xFF667EEA),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      career,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),

          if (stream.requirements.isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color(0xFF667EEA),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Requirements:",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    stream.requirements,
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCareerTipCard(CareerTip tip) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip.title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          tip.description,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

// ----------------- Data Classes -----------------
class StreamInfo {
  final String title;
  final String description;
  final List<String> subjects;
  final List<String> careers;
  final String requirements;
  final IconData icon;

  StreamInfo({
    required this.title,
    required this.description,
    required this.subjects,
    required this.careers,
    this.requirements = "",
    required this.icon,
  });
}

class CareerTip {
  final String title;
  final String description;

  CareerTip({required this.title, required this.description});
}

// ----------------- Data Lists -----------------
final List<StreamInfo> matricStreams = [
  StreamInfo(
    title: "Computer Science",
    description:
        "Introduction to programming, computer systems, and digital technology. Perfect foundation for tech careers.",
    subjects: [
      "Computer Science",
      "Mathematics",
      "Physics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Software Developer",
      "Web Developer",
      "IT Support",
      "Database Administrator",
      "System Analyst",
    ],
    requirements:
        "Strong logical thinking, interest in mathematics and technology, minimum 65% in Class 8.",
    icon: Icons.computer,
  ),
  StreamInfo(
    title: "Biology",
    description:
        "Study of living organisms, human body systems, and life processes. Foundation for medical and health sciences.",
    subjects: [
      "Biology",
      "Chemistry",
      "Physics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Lab Technician",
      "Pharmacy Assistant",
      "Health Care Worker",
      "Research Assistant",
      "Medical Representative",
    ],
    requirements:
        "Interest in life sciences, good observation skills, minimum 70% in Class 8.",
    icon: Icons.biotech,
  ),
  StreamInfo(
    title: "Commerce",
    description:
        "Business principles, basic accounting, and economic concepts. Prepares students for business and finance fields.",
    subjects: [
      "Commerce",
      "Economics",
      "Accounting",
      "Business Studies",
      "English",
      "Mathematics",
    ],
    careers: [
      "Bookkeeper",
      "Sales Representative",
      "Banking Assistant",
      "Office Administrator",
      "Business Assistant",
    ],
    requirements:
        "Good mathematical skills, interest in business concepts, minimum 60% in Class 8.",
    icon: Icons.business,
  ),
];

final List<StreamInfo> intermediateStreams = [
  StreamInfo(
    title: "Pre-Engineering",
    description:
        "Advanced mathematics and physics preparation for engineering universities. Focus on problem-solving and technical skills.",
    subjects: [
      "Physics",
      "Chemistry",
      "Mathematics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Engineering Student",
      "Technical Assistant",
      "CAD Operator",
      "Quality Control Inspector",
      "Engineering Technician",
    ],
    requirements:
        "Strong mathematical foundation, excellent problem-solving skills, minimum 75% in Matric.",
    icon: Icons.engineering,
  ),
  StreamInfo(
    title: "Pre-Medical",
    description:
        "Comprehensive biological sciences and chemistry for medical university admission. Prepares for healthcare professions.",
    subjects: [
      "Biology",
      "Chemistry",
      "Physics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Medical Student",
      "Pharmacy Student",
      "Nursing Student",
      "Veterinary Student",
      "Physiotherapy Student",
    ],
    requirements:
        "Excellent memory, attention to detail, strong science background, minimum 80% in Matric.",
    icon: Icons.medical_services,
  ),
  StreamInfo(
    title: "Commerce (ICS/ICS)",
    description:
        "Advanced business studies, accounting, and economics. Preparation for business universities and professional courses.",
    subjects: [
      "Accounting",
      "Economics",
      "Business Studies",
      "Statistics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Business Student",
      "Accounting Assistant",
      "Banking Trainee",
      "Sales Executive",
      "Office Manager",
    ],
    requirements:
        "Strong analytical skills, interest in business, minimum 65% in Matric Commerce.",
    icon: Icons.account_balance,
  ),
  StreamInfo(
    title: "Computer Science (ICS)",
    description:
        "Advanced programming, software development, and computer systems. Gateway to computer science universities.",
    subjects: [
      "Computer Science",
      "Mathematics",
      "Physics",
      "English",
      "Urdu/Local Language",
    ],
    careers: [
      "Programming Student",
      "IT Technician",
      "Web Developer",
      "Software Tester",
      "Database Operator",
    ],
    requirements:
        "Logical thinking, programming aptitude, minimum 70% in Matric with Computer Science/Mathematics.",
    icon: Icons.code,
  ),
];

final List<StreamInfo> graduateStreams = [
  StreamInfo(
    title: "Bachelor of Computer Science (BCS)",
    description:
        "Comprehensive computer science program covering programming, algorithms, software engineering, and emerging technologies.",
    subjects: [
      "Programming Languages",
      "Data Structures",
      "Database Systems",
      "Software Engineering",
      "Computer Networks",
      "Artificial Intelligence",
    ],
    careers: [
      "Software Engineer",
      "Data Scientist",
      "AI Specialist",
      "Cybersecurity Expert",
      "Tech Entrepreneur",
      "Research Scientist",
    ],
    requirements:
        "Intermediate in Computer Science/Pre-Engineering with minimum 60% marks.",
    icon: Icons.computer,
  ),
  StreamInfo(
    title: "Bachelor of Business Administration (BBA)",
    description:
        "Complete business education covering management, marketing, finance, and entrepreneurship skills.",
    subjects: [
      "Management Principles",
      "Marketing",
      "Finance",
      "Human Resources",
      "Business Law",
      "Entrepreneurship",
    ],
    careers: [
      "Business Manager",
      "Marketing Executive",
      "Financial Advisor",
      "HR Manager",
      "Business Consultant",
      "Entrepreneur",
    ],
    requirements:
        "Intermediate in Commerce/General with minimum 50% marks, good communication skills.",
    icon: Icons.business_center,
  ),
  StreamInfo(
    title: "Bachelor of Medicine (MBBS)",
    description:
        "Medical degree program to become a qualified doctor. Includes theoretical knowledge and practical clinical training.",
    subjects: [
      "Anatomy",
      "Physiology",
      "Biochemistry",
      "Pathology",
      "Pharmacology",
      "Clinical Medicine",
    ],
    careers: [
      "General Physician",
      "Specialist Doctor",
      "Surgeon",
      "Medical Researcher",
      "Public Health Officer",
      "Medical Consultant",
    ],
    requirements:
        "Intermediate Pre-Medical with minimum 85% marks, entrance test qualification (MDCAT).",
    icon: Icons.local_hospital,
  ),
  StreamInfo(
    title: "Bachelor of Engineering (B.E)",
    description:
    "Engineering degree program covering design, analysis, and development of systems in various branches of engineering.",
    subjects: [
      "Engineering Mathematics",
      "Mechanics",
      "Thermodynamics",
      "Electronics",
      "Material Science",
      "Control Systems",
    ],
    careers: [
      "Mechanical Engineer",
      "Civil Engineer",
      "Electrical Engineer",
      "Industrial Engineer",
      "Project Manager",
      "R&D Specialist",
    ],
    requirements:
    "Intermediate Pre-Engineering with minimum 70% marks, entrance test qualification (ECAT).",
    icon: Icons.engineering,
  ),
  StreamInfo(
    title: "Bachelor of Architecture (B.Arch)",
    description:
    "Professional program focusing on architectural design, construction techniques, and sustainable development.",
    subjects: [
      "Architectural Design",
      "Building Materials",
      "Urban Planning",
      "Construction Technology",
      "Environmental Design",
      "Interior Design",
    ],
    careers: [
      "Architect",
      "Urban Planner",
      "Interior Designer",
      "Landscape Designer",
      "Construction Consultant",
      "Design Entrepreneur",
    ],
    requirements:
    "Intermediate with Mathematics and aptitude test for architecture programs.",
    icon: Icons.apartment,
  ),
  StreamInfo(
    title: "Bachelor of Arts in Psychology",
    description:
    "Study of human mind and behavior, preparing students for careers in counseling, therapy, and mental health research.",
    subjects: [
      "General Psychology",
      "Developmental Psychology",
      "Abnormal Psychology",
      "Social Psychology",
      "Cognitive Science",
      "Research Methods",
    ],
    careers: [
      "Clinical Psychologist",
      "Counselor",
      "Researcher",
      "School Psychologist",
      "HR Specialist",
      "Therapist",
    ],
    requirements:
    "Intermediate in Arts/Science with minimum 50% marks, interest in human behavior and research.",
    icon: Icons.psychology,
  ),
  StreamInfo(
    title: "Bachelor of Fine Arts (BFA)",
    description:
    "Creative degree focused on visual arts, design, and creative expression through multiple mediums.",
    subjects: [
      "Drawing & Painting",
      "Sculpture",
      "Graphic Design",
      "Art History",
      "Photography",
      "Digital Media",
    ],
    careers: [
      "Artist",
      "Graphic Designer",
      "Animator",
      "Art Director",
      "Creative Entrepreneur",
      "Illustrator",
    ],
    requirements:
    "Intermediate with a strong portfolio or aptitude test in fine arts.",
    icon: Icons.brush,
  ),
  StreamInfo(
    title: "Bachelor of Commerce (B.Com)",
    description:
    "Commerce degree covering finance, accounting, economics, and business law, preparing students for corporate roles.",
    subjects: [
      "Accounting",
      "Economics",
      "Auditing",
      "Taxation",
      "Business Mathematics",
      "Banking & Finance",
    ],
    careers: [
      "Accountant",
      "Bank Officer",
      "Auditor",
      "Tax Consultant",
      "Financial Analyst",
      "Corporate Executive",
    ],
    requirements:
    "Intermediate in Commerce with minimum 50% marks.",
    icon: Icons.attach_money,
  ),
  StreamInfo(
    title: "Bachelor of Education (B.Ed)",
    description:
    "Professional teaching degree focusing on pedagogy, educational psychology, and classroom management.",
    subjects: [
      "Educational Psychology",
      "Curriculum Development",
      "Teaching Methodologies",
      "Assessment & Evaluation",
      "Classroom Management",
      "Special Education",
    ],
    careers: [
      "School Teacher",
      "Education Consultant",
      "Curriculum Developer",
      "School Administrator",
      "Educational Researcher",
      "Trainer",
    ],
    requirements:
    "Intermediate in any stream with minimum 50% marks, passion for teaching and mentoring.",
    icon: Icons.school,
  ),
  StreamInfo(
    title: "Bachelor of Law (LLB)",
    description:
    "Professional law degree providing understanding of legal systems, civil & criminal law, and legal drafting.",
    subjects: [
      "Constitutional Law",
      "Criminal Law",
      "Civil Law",
      "Contract Law",
      "International Law",
      "Legal Drafting",
    ],
    careers: [
      "Lawyer",
      "Legal Advisor",
      "Corporate Counsel",
      "Judge (after exams)",
      "Public Prosecutor",
      "Human Rights Activist",
    ],
    requirements:
    "Intermediate with minimum 50% marks, law college admission test (LAT) qualification required.",
    icon: Icons.gavel,
  ),
];

final List<CareerTip> careerTips = [
  CareerTip(
      title: "Know Your Interests",
      description: "Take time to understand what subjects you enjoy most and what activities make you feel energized. Your interests often align with careers where you'll be most successful and satisfied."
  ),
  CareerTip(
      title: "Assess Your Strengths",
      description: "Identify your natural abilities and skills. Are you good at problem-solving, communication, creativity, or working with numbers? Choose streams that leverage your strengths."
  ),
  CareerTip(
      title: "Research Career Prospects",
      description: "Investigate job market trends, salary expectations, and growth opportunities in different fields. Consider both current demand and future prospects in your chosen area."
  ),
  CareerTip(
      title: "Consider Your Learning Style",
      description: "Some students learn better through hands-on experience, while others prefer theoretical study. Choose a stream that matches how you learn best for optimal success."
  ),
  CareerTip(
      title: "Don't Follow the Crowd",
      description: "Popular doesn't always mean right for you. Make decisions based on your own interests, abilities, and goals rather than what your friends or family expect."
  ),
  CareerTip(
      title: "Keep Options Open",
      description: "Choose streams that provide flexibility and multiple career paths. This allows you to explore different opportunities as you learn more about yourself and the job market."
  ),
  CareerTip(
      title: "Seek Guidance",
      description: "Talk to professionals in fields you're interested in, career counselors, teachers, and family members. Their insights can help you make informed decisions about your future."
  ),
  CareerTip(
      title: "Consider Financial Factors",
      description: "While money shouldn't be the only factor, consider the cost of education and potential return on investment. Some fields require expensive education but offer high earning potential."
  ),
  CareerTip(
      title: "Plan for Continuous Learning",
      description: "The modern job market values lifelong learning. Choose fields where you're willing to continuously update your skills and knowledge throughout your career."
  ),
  CareerTip(
      title: "Balance Passion and Practicality",
      description: "Try to find a balance between what you're passionate about and what's practical in terms of career opportunities and financial stability. The ideal career combines both."
  ),
];
