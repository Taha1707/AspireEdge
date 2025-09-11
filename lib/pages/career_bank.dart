import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Firebase instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Categories will be dynamically loaded
  List<String> categories = ["All"];
  List<Career> allCareers = [];
  bool isLoading = true;

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
    _loadCareersFromFirebase();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCareersFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('careers').get();

      List<Career> careers = [];
      Set<String> uniqueCategories = {"All"};

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Safely read category (works with both Industry & industry)
        String category = (data['Industry'] ?? data['industry'] ?? '').toString();

        // Safely read education path & skills
        List<String> educationPath = (data['education_path'] != null)
            ? List<String>.from(data['education_path'])
            : [];

        List<String> skills = (data['skills'] != null)
            ? List<String>.from(data['skills'])
            : [];

        if (category.isNotEmpty) {
          uniqueCategories.add(category);
        }

        careers.add(Career(
          id: doc.id,
          title: data['Title'] ?? data['title'] ?? '',
          description: data['Description'] ?? data['description'] ?? '',
          category: category,
          skills: skills,
          salaryRange:
          data['Salary_Range'] ?? data['salary_range'] ?? 'Not specified',
          educationPath: educationPath,
          icon: _getIconForCategory(category),
        ));
      }

      setState(() {
        allCareers = careers;
        categories = uniqueCategories.toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading careers: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load careers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper method to assign icons based on category
  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return Icons.computer;
      case 'healthcare':
        return Icons.medical_services;
      case 'engineering':
        return Icons.engineering;
      case 'design':
        return Icons.design_services;
      case 'business':
        return Icons.business;
      case 'education':
        return Icons.school;
      case 'arts & media':
        return Icons.palette;
      case 'science':
        return Icons.science;
      case 'agriculture':
        return Icons.agriculture;
      case 'law & legal':
        return Icons.gavel;
      case 'finance':
        return Icons.account_balance;
      default:
        return Icons.work;
    }
  }

  List<Career> get filteredCareers {
    if (isLoading) return [];

    return allCareers.where((career) {
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
            child: isLoading
                ? _buildLoadingWidget()
                : Column(
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

  Widget _buildLoadingWidget() {
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
            child: const CircularProgressIndicator(
              color: Color(0xFF667EEA),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Loading Careers...",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait while we fetch the latest career data",
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
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
                  "Explore ${allCareers.length}+ career paths",
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
          _buildStatItem("Industries", "$categoryCount+", Icons.business),
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

// Updated Career Model with id field
class Career {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final String salaryRange;
  final List<String> educationPath;
  final IconData icon;

  Career({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.salaryRange,
    required this.educationPath,
    required this.icon,
  });
}