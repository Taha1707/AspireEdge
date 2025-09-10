import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CareerBankPage extends StatefulWidget {
  const CareerBankPage({super.key});

  @override
  State<CareerBankPage> createState() => _CareerBankPageState();
}

class _CareerBankPageState extends State<CareerBankPage> with TickerProviderStateMixin {
  String selectedCategory = "All";
  String searchQuery = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> categories = [
    "All",
    "Technology",
    "Healthcare",
    "Engineering",
    "Design",
    "Business",
    "Education",
    "Arts & Media",
    "Science",
    "Agriculture",
    "Law & Legal",
    "Finance"
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

  List<Career> get filteredCareers {
    return careers.where((career) {
      bool matchesCategory = selectedCategory == "All" || career.category == selectedCategory;
      bool matchesSearch = searchQuery.isEmpty ||
          career.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          career.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          career.skills.any((skill) => skill.toLowerCase().contains(searchQuery.toLowerCase()));
      return matchesCategory && matchesSearch;
    }).toList();
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
            child: Column(
              children: [
                // Custom Header
                _buildHeader(),

                // Search Bar
                _buildSearchBar(),

                // Category Filter
                _buildCategoryFilter(),

                // Career Stats
                _buildStatsRow(),

                // Careers Grid
                Expanded(
                  child: _buildCareersGrid(),
                ),
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
      child: Row(
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
                  "Career Bank",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Explore ${careers.length}+ career paths",
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
              Icons.work_history,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          hintText: "Search careers, skills, or industries...",
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withOpacity(0.7),
            size: 24,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            onPressed: () {
              setState(() {
                searchQuery = "";
              });
            },
            icon: Icon(
              Icons.clear,
              color: Colors.white.withOpacity(0.7),
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 10),
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

  Widget _buildStatsRow() {
    final filteredCount = filteredCareers.length;
    final categoryCount = categories.length - 1; // Exclude "All"

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
          _buildStatItem("Careers", filteredCount.toString(), Icons.work),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem("Categories", categoryCount.toString(), Icons.category),
          Container(
            width: 1,
            height: 30,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildStatItem("Industries", "12+", Icons.business),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF667EEA),
          size: 24,
        ),
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

  Widget _buildCareersGrid() {
    final filteredList = filteredCareers;

    if (filteredList.isEmpty) {
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
                Icons.search_off,
                color: Colors.white.withOpacity(0.6),
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No careers found",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try adjusting your search or filter",
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.75 : 0.85,
        ),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final career = filteredList[index];

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 600),
            columnCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: _buildCareerCard(career, index),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerCard(Career career, int index) {
    final gradients = [
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
      [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
      [const Color(0xFFFA709A), const Color(0xFFFE9A8B)],
      [const Color(0xFFA8EDEA), const Color(0xFFFED6E3)],
      [const Color(0xFFD299C2), const Color(0xFFFEF9D7)],
    ];

    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () => _showCareerDetails(career),
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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Stack(
                children: [
                  // Icon
                  Positioned(
                    top: 15,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        career.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  // Category badge
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        career.category,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      career.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      career.description,
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    // Salary
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: gradient[0].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: gradient[0].withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: gradient[0],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            career.salaryRange,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Skills preview
                    Wrap(
                      spacing: 5,
                      runSpacing: 5,
                      children: career.skills.take(3).map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            skill,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // View details button
                    Container(
                      width: double.infinity,
                      height: 35,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => _showCareerDetails(career),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Details",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCareerDetails(Career career) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CareerDetailSheet(career: career),
    );
  }
}

class CareerDetailSheet extends StatelessWidget {
  final Career career;

  const CareerDetailSheet({super.key, required this.career});

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
                              career.icon,
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
                                  career.title,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  career.category,
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

                      // Description
                      _buildSection(
                        "Overview",
                        Icons.description,
                        Text(
                          career.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ),

                      // Salary
                      _buildSection(
                        "Salary Range",
                        Icons.attach_money,
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.trending_up,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                career.salaryRange,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Skills
                      _buildSection(
                        "Required Skills",
                        Icons.psychology,
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: career.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                skill,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Education Path
                      _buildSection(
                        "Education Path",
                        Icons.school,
                        Column(
                          children: career.educationPath.asMap().entries.map((entry) {
                            int index = entry.key;
                            String step = entry.value;
                            bool isLast = index == career.educationPath.length - 1;

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
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
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 40,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Text(
                                      step,
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // CTA Button
                      Container(
                        width: double.infinity,
                        height: 55,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF667EEA).withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Navigate to career roadmap or resources
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Opening ${career.title} roadmap..."),
                                backgroundColor: const Color(0xFF667EEA),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.rocket_launch,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Start Your Journey",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF667EEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          content,
        ],
      ),
    );
  }
}

// Career Model
class Career {
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final String salaryRange;
  final List<String> educationPath;
  final IconData icon;

  Career({
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.salaryRange,
    required this.educationPath,
    required this.icon,
  });
}

// Comprehensive Career Database
final List<Career> careers = [
  // Technology Careers
  Career(
    title: "Software Engineer",
    description: "Design, develop, and maintain software applications and systems. Work with programming languages, databases, and frameworks to create innovative digital solutions that solve real-world problems.",
    category: "Technology",
    skills: ["Programming", "Problem Solving", "Algorithms", "Database Design", "Git", "Testing", "API Development"],
    salaryRange: "\$70,000 - \$200,000",
    educationPath: [
      "Complete high school with strong mathematics and science foundation",
      "Pursue Bachelor's degree in Computer Science, Software Engineering, or related field",
      "Learn programming languages (Python, Java, JavaScript, C++)",
      "Build personal projects and contribute to open-source",
      "Complete internships at tech companies",
      "Consider specialization (Frontend, Backend, Full-Stack, Mobile)",
      "Obtain industry certifications (AWS, Google Cloud, Microsoft Azure)",
      "Stay updated with latest technologies and frameworks"
    ],
    icon: Icons.computer,
  ),

  Career(
    title: "Data Scientist",
    description: "Extract insights from large datasets using statistical analysis, machine learning, and data visualization techniques. Help organizations make data-driven decisions and predict future trends.",
    category: "Technology",
    skills: ["Python/R", "Statistics", "Machine Learning", "SQL", "Data Visualization", "Big Data Tools", "Business Acumen"],
    salaryRange: "\$80,000 - \$180,000",
    educationPath: [
      "Strong foundation in mathematics, statistics, and computer science",
      "Bachelor's degree in Data Science, Statistics, Mathematics, or Computer Science",
      "Master programming languages: Python, R, SQL",
      "Learn statistical analysis and machine learning algorithms",
      "Gain experience with data visualization tools (Tableau, Power BI, matplotlib)",
      "Work with big data technologies (Hadoop, Spark, Apache Kafka)",
      "Complete data science bootcamps or online certifications",
      "Build portfolio with real-world data projects"
    ],
    icon: Icons.analytics,
  ),

  Career(
    title: "Cybersecurity Specialist",
    description: "Protect organizations from digital threats by implementing security measures, monitoring networks, and responding to cyber attacks. Ensure data privacy and system integrity.",
    category: "Technology",
    skills: ["Network Security", "Ethical Hacking", "Risk Assessment", "Incident Response", "Cryptography", "Compliance", "Forensics"],
    salaryRange: "\$75,000 - \$160,000",
    educationPath: [
      "Complete high school with focus on mathematics and computer science",
      "Pursue Bachelor's degree in Cybersecurity, Computer Science, or Information Technology",
      "Learn networking fundamentals and operating systems",
      "Study ethical hacking and penetration testing",
      "Obtain industry certifications (CISSP, CEH, CompTIA Security+)",
      "Gain hands-on experience through internships or security labs",
      "Stay updated with latest threats and security technologies",
      "Consider specialization in specific areas (cloud security, forensics, compliance)"
    ],
    icon: Icons.security,
  ),

  Career(
    title: "Mobile App Developer",
    description: "Create mobile applications for iOS and Android platforms. Design user interfaces, implement functionality, and optimize performance for mobile devices.",
    category: "Technology",
    skills: ["Swift/Kotlin", "React Native/Flutter", "UI/UX Design", "Mobile Architecture", "App Store Optimization", "Testing", "API Integration"],
    salaryRange: "\$65,000 - \$150,000",
    educationPath: [
      "Learn programming fundamentals and object-oriented programming",
      "Choose platform specialization: iOS (Swift), Android (Kotlin/Java), or Cross-platform",
      "Master mobile development frameworks and SDKs",
      "Study mobile UI/UX design principles",
      "Learn database integration and API consumption",
      "Build and publish apps to app stores",
      "Gain experience with mobile testing and debugging",
      "Stay updated with platform-specific guidelines and updates"
    ],
    icon: Icons.phone_android,
  ),

  // Healthcare Careers
  Career(
    title: "Medical Doctor",
    description: "Diagnose and treat illnesses, injuries, and medical conditions. Provide comprehensive healthcare services and work collaboratively with healthcare teams to ensure patient well-being.",
    category: "Healthcare",
    skills: ["Medical Knowledge", "Diagnosis", "Patient Care", "Communication", "Critical Thinking", "Empathy", "Research", "Teamwork"],
    salaryRange: "\$200,000 - \$500,000",
    educationPath: [
      "Excel in high school sciences (Biology, Chemistry, Physics) and Mathematics",
      "Complete Bachelor's degree with pre-medical requirements",
      "Maintain high GPA and gain healthcare experience through volunteering",
      "Take and excel in MCAT (Medical College Admission Test)",
      "Apply to and complete 4-year medical school program",
      "Complete residency training in chosen specialty (3-7 years)",
      "Obtain medical license and board certification",
      "Consider fellowship training for subspecialization"
    ],
    icon: Icons.medical_services,
  ),

  Career(
    title: "Registered Nurse",
    description: "Provide direct patient care, administer medications, monitor patient conditions, and collaborate with healthcare teams to deliver quality medical care in various settings.",
    category: "Healthcare",
    skills: ["Patient Care", "Medical Knowledge", "Communication", "Critical Thinking", "Compassion", "Attention to Detail", "Time Management"],
    salaryRange: "\$60,000 - \$120,000",
    educationPath: [
      "Complete high school with strong science and mathematics foundation",
      "Pursue Associate Degree in Nursing (ADN) or Bachelor of Science in Nursing (BSN)",
      "Complete clinical rotations in various healthcare settings",
      "Pass the NCLEX-RN licensing examination",
      "Gain experience in different nursing specialties",
      "Consider pursuing BSN if started with ADN",
      "Obtain specialty certifications (ICU, Emergency, Pediatric, etc.)",
      "Pursue advanced practice roles (Nurse Practitioner, Nurse Anesthetist)"
    ],
    icon: Icons.healing,
  ),

  Career(
    title: "Physical Therapist",
    description: "Help patients recover from injuries, surgeries, or medical conditions through therapeutic exercises, manual therapy, and rehabilitation programs to restore mobility and function.",
    category: "Healthcare",
    skills: ["Anatomy & Physiology", "Manual Therapy", "Exercise Prescription", "Patient Assessment", "Communication", "Empathy", "Problem Solving"],
    salaryRange: "\$75,000 - \$120,000",
    educationPath: [
      "Complete high school with strong foundation in sciences",
      "Pursue Bachelor's degree with prerequisite courses in biology, chemistry, physics, and anatomy",
      "Gain observation hours in physical therapy settings",
      "Apply to Doctor of Physical Therapy (DPT) program (3 years)",
      "Complete extensive clinical internships and rotations",
      "Pass the National Physical Therapy Examination (NPTE)",
      "Obtain state licensure to practice",
      "Consider specialization through residency or fellowship programs"
    ],
    icon: Icons.accessibility,
  ),

  // Engineering Careers
  Career(
    title: "Civil Engineer",
    description: "Design, build, and maintain infrastructure projects including roads, bridges, buildings, and water systems. Ensure public safety and environmental sustainability in construction projects.",
    category: "Engineering",
    skills: ["Structural Design", "AutoCAD", "Project Management", "Mathematics", "Problem Solving", "Environmental Knowledge", "Safety Protocols"],
    salaryRange: "\$65,000 - \$130,000",
    educationPath: [
      "Excel in high school mathematics, physics, and chemistry",
      "Pursue Bachelor's degree in Civil Engineering (ABET-accredited)",
      "Learn engineering software (AutoCAD, Revit, STAAD Pro)",
      "Complete internships with engineering firms or government agencies",
      "Take the Fundamentals of Engineering (FE) exam",
      "Gain 4 years of professional experience under licensed engineer",
      "Pass the Professional Engineering (PE) exam for licensure",
      "Consider specialization (structural, transportation, environmental, geotechnical)"
    ],
    icon: Icons.engineering,
  ),

  Career(
    title: "Mechanical Engineer",
    description: "Design, develop, and test mechanical systems and devices. Work on everything from small components to large industrial machinery, focusing on efficiency and innovation.",
    category: "Engineering",
    skills: ["CAD Design", "Thermodynamics", "Materials Science", "Manufacturing Processes", "Problem Solving", "Mathematics", "Project Management"],
    salaryRange: "\$70,000 - \$140,000",
    educationPath: [
      "Strong foundation in mathematics, physics, and chemistry in high school",
      "Complete Bachelor's degree in Mechanical Engineering",
      "Learn computer-aided design (CAD) software (SolidWorks, AutoCAD, CATIA)",
      "Gain hands-on experience through internships and co-op programs",
      "Understand manufacturing processes and materials science",
      "Take the Fundamentals of Engineering (FE) exam",
      "Accumulate professional experience for PE licensure",
      "Consider specialization (automotive, aerospace, robotics, HVAC)"
    ],
    icon: Icons.settings,
  ),

  Career(
    title: "Electrical Engineer",
    description: "Design and develop electrical systems, from microprocessors to power generation equipment. Work on projects ranging from consumer electronics to large-scale power grids.",
    category: "Engineering",
    skills: ["Circuit Design", "Programming", "Signal Processing", "Power Systems", "Electronics", "Control Systems", "Problem Solving"],
    salaryRange: "\$75,000 - \$145,000",
    educationPath: [
      "Excel in mathematics, physics, and chemistry during high school",
      "Pursue Bachelor's degree in Electrical Engineering or Electrical & Computer Engineering",
      "Master circuit analysis, digital systems, and signal processing",
      "Learn programming languages relevant to embedded systems",
      "Complete laboratory work and design projects",
      "Gain industry experience through internships",
      "Take the Fundamentals of Engineering (FE) exam",
      "Work toward Professional Engineering (PE) licensure"
    ],
    icon: Icons.electrical_services,
  ),

  // Design Careers
  Career(
    title: "UX/UI Designer",
    description: "Create intuitive and engaging user experiences for digital products. Research user needs, design interfaces, and test usability to ensure products are user-friendly and accessible.",
    category: "Design",
    skills: ["User Research", "Wireframing", "Prototyping", "Visual Design", "Usability Testing", "Design Tools", "Psychology", "Communication"],
    salaryRange: "\$55,000 - \$130,000",
    educationPath: [
      "Study design principles, psychology, and human-computer interaction",
      "Pursue degree in Design, Psychology, Computer Science, or related field",
      "Learn design tools (Figma, Sketch, Adobe Creative Suite, InVision)",
      "Understand user research methodologies and usability testing",
      "Build a strong portfolio showcasing design process and thinking",
      "Gain experience through internships or freelance projects",
      "Stay updated with design trends and accessibility standards",
      "Consider specialization in UX research, visual design, or interaction design"
    ],
    icon: Icons.design_services,
  ),

  Career(
    title: "Graphic Designer",
    description: "Create visual content for print and digital media including logos, brochures, websites, and advertising materials. Communicate ideas through compelling visual design and typography.",
    category: "Design",
    skills: ["Adobe Creative Suite", "Typography", "Color Theory", "Branding", "Layout Design", "Creativity", "Client Communication", "Project Management"],
    salaryRange: "\$40,000 - \$80,000",
    educationPath: [
      "Develop artistic skills and visual creativity from early age",
      "Complete high school with art and design courses",
      "Pursue Bachelor's degree in Graphic Design, Visual Arts, or related field",
      "Master design software (Photoshop, Illustrator, InDesign, After Effects)",
      "Study typography, color theory, and composition principles",
      "Build comprehensive portfolio showcasing diverse design work",
      "Gain experience through internships with design agencies or in-house teams",
      "Stay current with design trends and emerging technologies"
    ],
    icon: Icons.palette,
  ),

  Career(
    title: "Interior Designer",
    description: "Plan and design interior spaces that are functional, safe, and aesthetically pleasing. Work with clients to create environments that reflect their needs and personal style.",
    category: "Design",
    skills: ["Space Planning", "Color Theory", "CAD Software", "Material Knowledge", "Client Relations", "Project Management", "Building Codes", "Creativity"],
    salaryRange: "\$45,000 - \$90,000",
    educationPath: [
      "Develop artistic sense and spatial awareness",
      "Complete high school with art, mathematics, and technical drawing courses",
      "Pursue Bachelor's degree in Interior Design from CIDA-accredited program",
      "Learn design software (AutoCAD, SketchUp, Revit, 3ds Max)",
      "Study building codes, safety regulations, and accessibility standards",
      "Complete internship with established interior design firm",
      "Take the NCIDQ examination for professional certification",
      "Build portfolio and establish professional network"
    ],
    icon: Icons.home_work,
  ),

  // Business Careers
  Career(
    title: "Marketing Manager",
    description: "Develop and execute marketing strategies to promote products and services. Analyze market trends, manage campaigns, and coordinate with teams to achieve business objectives.",
    category: "Business",
    skills: ["Strategic Planning", "Digital Marketing", "Analytics", "Communication", "Project Management", "Creativity", "Market Research", "Leadership"],
    salaryRange: "\$60,000 - \$130,000",
    educationPath: [
      "Excel in communication, mathematics, and social studies in high school",
      "Pursue Bachelor's degree in Marketing, Business Administration, or Communications",
      "Learn digital marketing tools and platforms (Google Analytics, social media, SEO)",
      "Gain experience through internships in marketing departments",
      "Develop skills in market research and consumer behavior analysis",
      "Stay updated with digital marketing trends and technologies",
      "Consider MBA or marketing certifications for advancement",
      "Build expertise in specific areas (content marketing, social media, brand management)"
    ],
    icon: Icons.trending_up,
  ),

  Career(
    title: "Financial Analyst",
    description: "Evaluate investment opportunities, analyze financial data, and provide recommendations for business decisions. Help organizations optimize their financial performance and manage risk.",
    category: "Business",
    skills: ["Financial Modeling", "Excel", "Data Analysis", "Investment Analysis", "Risk Assessment", "Communication", "Attention to Detail", "Critical Thinking"],
    salaryRange: "\$55,000 - \$120,000",
    educationPath: [
      "Strong foundation in mathematics and economics in high school",
      "Pursue Bachelor's degree in Finance, Economics, Accounting, or Business",
      "Master financial modeling and Excel advanced functions",
      "Learn financial analysis software and databases (Bloomberg, Reuters)",
      "Gain internship experience in banking, investment firms, or corporate finance",
      "Consider professional certifications (CFA, FRM, CPA)",
      "Develop understanding of financial markets and investment instruments",
      "Pursue MBA for senior analyst or management roles"
    ],
    icon: Icons.account_balance,
  ),

  Career(
    title: "Human Resources Manager",
    description: "Oversee recruitment, employee relations, training, and organizational development. Ensure compliance with labor laws and create positive workplace culture.",
    category: "Business",
    skills: ["Communication", "Leadership", "Conflict Resolution", "Employment Law", "Recruitment", "Training & Development", "Analytics", "Empathy"],
    salaryRange: "\$65,000 - \$125,000",
    educationPath: [
      "Develop strong communication and interpersonal skills",
      "Complete Bachelor's degree in Human Resources, Business, Psychology, or related field",
      "Learn employment law and HR best practices",
      "Gain experience through HR internships or entry-level positions",
      "Master HR information systems and analytics tools",
      "Obtain professional certifications (PHR, SHRM-CP, SHRM-SCP)",
      "Develop expertise in areas like recruitment, compensation, or training",
      "Pursue advanced degree for senior HR leadership roles"
    ],
    icon: Icons.people,
  ),

  // Education Careers
  Career(
    title: "Elementary School Teacher",
    description: "Educate and nurture young learners in foundational subjects. Create engaging lesson plans, assess student progress, and communicate with parents to support child development.",
    category: "Education",
    skills: ["Curriculum Development", "Classroom Management", "Communication", "Patience", "Creativity", "Assessment", "Technology Integration", "Empathy"],
    salaryRange: "\$40,000 - \$70,000",
    educationPath: [
      "Excel in all academic subjects with focus on areas you want to teach",
      "Complete Bachelor's degree in Elementary Education or subject area with education minor",
      "Complete student teaching or field experience requirements",
      "Pass state-required teacher certification exams (Praxis, CSET, etc.)",
      "Obtain teaching license/credential in your state",
      "Participate in ongoing professional development and training",
      "Consider Master's degree in Education for salary advancement",
      "Maintain certification through continuing education requirements"
    ],
    icon: Icons.school,
  ),

  Career(
    title: "University Professor",
    description: "Teach undergraduate and graduate courses, conduct research in your field of expertise, and contribute to academic knowledge through publications and presentations.",
    category: "Education",
    skills: ["Subject Expertise", "Research", "Writing", "Public Speaking", "Critical Thinking", "Mentoring", "Grant Writing", "Publishing"],
    salaryRange: "\$55,000 - \$150,000",
    educationPath: [
      "Excel academically throughout high school and undergraduate studies",
      "Complete Bachelor's degree with high GPA in chosen field",
      "Pursue Master's degree to deepen subject knowledge",
      "Complete Ph.D. in specific field of study (4-7 years)",
      "Conduct original research and publish dissertation",
      "Gain teaching experience as graduate assistant or adjunct instructor",
      "Apply for tenure-track faculty positions",
      "Build research portfolio and continue publishing in academic journals"
    ],
    icon: Icons.menu_book,
  ),

  // Arts & Media
  Career(
    title: "Journalist",
    description: "Research, write, and report news stories for newspapers, magazines, television, radio, or online platforms. Investigate events and communicate information to the public.",
    category: "Arts & Media",
    skills: ["Writing", "Research", "Interviewing", "Ethics", "Critical Thinking", "Communication", "Technology", "Deadline Management"],
    salaryRange: "\$35,000 - \$80,000",
    educationPath: [
      "Excel in English, writing, and social studies courses",
      "Complete Bachelor's degree in Journalism, Communications, English, or related field",
      "Gain experience writing for school newspaper or local publications",
      "Complete internships at news organizations or media outlets",
      "Develop expertise in specific beat (politics, sports, business, etc.)",
      "Learn digital media tools and social media platforms",
      "Build portfolio of published work and establish professional network",
      "Stay updated with media ethics and journalism best practices"
    ],
    icon: Icons.article,
  ),

  Career(
    title: "Film Director",
    description: "Oversee the creative aspects of film production from pre-production through post-production. Guide actors, coordinate with crew, and bring stories to life on screen.",
    category: "Arts & Media",
    skills: ["Storytelling", "Leadership", "Creativity", "Communication", "Project Management", "Visual Arts", "Collaboration", "Technical Knowledge"],
    salaryRange: "\$50,000 - \$250,000",
    educationPath: [
      "Develop storytelling abilities and visual creativity",
      "Study film, theater, communications, or fine arts in college",
      "Learn filmmaking techniques through hands-on practice",
      "Create short films and build a directing portfolio",
      "Gain experience in various film production roles",
      "Network with industry professionals and attend film festivals",
      "Start with smaller projects and work up to feature films",
      "Continuously study film history and contemporary cinema"
    ],
    icon: Icons.movie,
  ),

  // Science Careers
  Career(
    title: "Research Scientist",
    description: "Conduct experiments and studies to advance knowledge in specific scientific fields. Design research methodologies, analyze data, and publish findings in peer-reviewed journals.",
    category: "Science",
    skills: ["Scientific Method", "Data Analysis", "Critical Thinking", "Research Design", "Laboratory Skills", "Writing", "Statistics", "Collaboration"],
    salaryRange: "\$65,000 - \$140,000",
    educationPath: [
      "Excel in science and mathematics courses throughout high school",
      "Complete Bachelor's degree in relevant scientific field",
      "Participate in undergraduate research opportunities",
      "Pursue Ph.D. in specialized area of science (4-6 years)",
      "Complete post-doctoral research fellowships",
      "Develop expertise in specific research area",
      "Publish research in peer-reviewed journals",
      "Apply for research positions in academia, government, or industry"
    ],
    icon: Icons.science,
  ),

  Career(
    title: "Environmental Scientist",
    description: "Study environmental problems and develop solutions to protect human health and the environment. Conduct field research, analyze pollution data, and recommend policy changes.",
    category: "Science",
    skills: ["Environmental Assessment", "Data Collection", "GIS", "Research Methods", "Problem Solving", "Communication", "Field Work", "Regulatory Knowledge"],
    salaryRange: "\$50,000 - \$100,000",
    educationPath: [
      "Strong foundation in biology, chemistry, earth science, and mathematics",
      "Complete Bachelor's degree in Environmental Science, Biology, Chemistry, or related field",
      "Gain field experience through internships with environmental agencies",
      "Learn environmental monitoring techniques and equipment",
      "Master GIS software and data analysis tools",
      "Consider Master's degree for advanced research positions",
      "Stay updated with environmental regulations and policies",
      "Specialize in areas like air quality, water resources, or waste management"
    ],
    icon: Icons.eco,
  ),

  // Agriculture
  Career(
    title: "Agricultural Engineer",
    description: "Apply engineering principles to agricultural production and processing. Design farm equipment, irrigation systems, and facilities to improve efficiency and sustainability.",
    category: "Agriculture",
    skills: ["Engineering Design", "Agricultural Systems", "Problem Solving", "CAD Software", "Project Management", "Sustainability", "Technology Integration"],
    salaryRange: "\$60,000 - \$120,000",
    educationPath: [
      "Strong background in mathematics, physics, and biology",
      "Complete Bachelor's degree in Agricultural Engineering or Biological Systems Engineering",
      "Learn agricultural production systems and farm equipment",
      "Gain hands-on experience through internships on farms or with equipment manufacturers",
      "Master engineering software and design tools",
      "Understand sustainability principles and precision agriculture",
      "Consider Professional Engineer (PE) licensure",
      "Specialize in areas like irrigation, machinery design, or food processing"
    ],
    icon: Icons.agriculture,
  ),

  Career(
    title: "Veterinarian",
    description: "Diagnose and treat diseases and injuries in animals. Provide medical care for pets, livestock, and wildlife while educating owners about animal health and welfare.",
    category: "Agriculture",
    skills: ["Animal Anatomy", "Medical Diagnosis", "Surgery", "Communication", "Compassion", "Problem Solving", "Research", "Physical Stamina"],
    salaryRange: "\$75,000 - \$160,000",
    educationPath: [
      "Excel in biology, chemistry, physics, and mathematics in high school",
      "Complete Bachelor's degree with pre-veterinary requirements",
      "Gain animal experience through volunteering or work",
      "Take the Veterinary College Admission Test (VCAT)",
      "Complete 4-year Doctor of Veterinary Medicine (DVM) program",
      "Pass the North American Veterinary Licensing Examination (NAVLE)",
      "Obtain state veterinary license",
      "Consider specialization through internship and residency programs"
    ],
    icon: Icons.pets,
  ),

  // Law & Legal
  Career(
    title: "Lawyer",
    description: "Represent clients in legal matters, provide legal advice, and advocate for justice in courts. Specialize in areas such as corporate law, criminal defense, or family law.",
    category: "Law & Legal",
    skills: ["Legal Research", "Writing", "Oral Advocacy", "Critical Thinking", "Negotiation", "Ethics", "Client Relations", "Analytical Skills"],
    salaryRange: "\$60,000 - \$200,000+",
    educationPath: [
      "Excel in English, history, government, and debate in high school",
      "Complete Bachelor's degree in any field with strong GPA",
      "Take the Law School Admission Test (LSAT)",
      "Complete 3-year Juris Doctor (J.D.) program at accredited law school",
      "Participate in internships, clinics, or law review",
      "Pass the bar examination in the state where you plan to practice",
      "Consider specialization through additional coursework or experience",
      "Maintain continuing legal education requirements"
    ],
    icon: Icons.gavel,
  ),

  Career(
    title: "Paralegal",
    description: "Assist lawyers with legal research, document preparation, and case management. Support legal teams in litigation, corporate transactions, and client communication.",
    category: "Law & Legal",
    skills: ["Legal Research", "Document Preparation", "Case Management", "Communication", "Organization", "Attention to Detail", "Ethics", "Technology"],
    salaryRange: "\$35,000 - \$65,000",
    educationPath: [
      "Complete high school with strong writing and research skills",
      "Pursue Associate degree in Paralegal Studies or Bachelor's degree with paralegal certificate",
      "Complete internship with law firm or legal department",
      "Learn legal research databases and document management systems",
      "Stay updated with legal procedures and regulations",
      "Consider specialization in specific areas of law",
      "Maintain continuing education requirements",
      "Join professional paralegal associations"
    ],
    icon: Icons.balance,
  ),

  // Finance
  Career(
    title: "Investment Banker",
    description: "Help corporations and governments raise capital through securities offerings. Provide advisory services for mergers, acquisitions, and other financial transactions.",
    category: "Finance",
    skills: ["Financial Modeling", "Valuation", "Client Relations", "Communication", "Analytics", "Risk Assessment", "Market Knowledge", "Negotiation"],
    salaryRange: "\$100,000 - \$300,000+",
    educationPath: [
      "Excel in mathematics and economics in high school",
      "Complete Bachelor's degree in Finance, Economics, or Business with high GPA",
      "Gain relevant internships at investment banks or financial firms",
      "Master financial modeling and valuation techniques",
      "Learn advanced Excel and financial software",
      "Network with industry professionals and alumni",
      "Consider MBA from top-tier business school for advancement",
      "Obtain relevant certifications (CFA, FRM) for specialization"
    ],
    icon: Icons.trending_up,
  ),

  Career(
    title: "Actuary",
    description: "Analyze risk and uncertainty for insurance companies and financial institutions. Use mathematics, statistics, and financial theory to assess the probability of future events.",
    category: "Finance",
    skills: ["Mathematics", "Statistics", "Risk Analysis", "Programming", "Communication", "Problem Solving", "Attention to Detail", "Business Acumen"],
    salaryRange: "\$80,000 - \$180,000",
    educationPath: [
      "Excel in advanced mathematics, statistics, and calculus in high school",
      "Complete Bachelor's degree in Actuarial Science, Mathematics, Statistics, or Economics",
      "Pass actuarial examinations from Society of Actuaries (SOA) or Casualty Actuarial Society (CAS)",
      "Gain internship experience with insurance companies or consulting firms",
      "Learn programming languages (R, Python, SQL, VBA)",
      "Continue passing actuarial exams while working (typically 5-7 exams total)",
      "Gain relevant work experience for fellowship status",
      "Specialize in specific areas (life insurance, health insurance, property & casualty)"
    ],
    icon: Icons.calculate,
  ),
];