import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesHubPage extends StatefulWidget {
  const ResourcesHubPage({super.key});

  @override
  State<ResourcesHubPage> createState() => _ResourcesHubPageState();
}

class _ResourcesHubPageState extends State<ResourcesHubPage> with TickerProviderStateMixin {
  String selectedCategory = "All";
  String searchQuery = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _searchController;

  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Categories and content
  List<String> categories = ["All", "Blogs", "EBooks", "Videos", "Gallery"];
  List<ResourceItem> allResources = [];
  List<ResourceItem> bookmarkedResources = [];
  bool isLoading = true;
  bool showBookmarksOnly = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadResources();
    _loadBookmarkedResources();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadResources() async {
    try {
      // Try to load from Firebase first
      final snapshot = await _firestore.collection('resources').get();

      List<ResourceItem> resources = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        resources.add(ResourceItem(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? 'Blogs',
          type: data['type'] ?? 'Career Tips',
          author: data['author'] ?? 'Unknown',
          publishDate: data['publishDate']?.toDate() ?? DateTime.now(),
          imageUrl: data['imageUrl'] ?? '',
          contentUrl: data['contentUrl'] ?? '',
          downloadUrl: data['downloadUrl'] ?? '',
          videoUrl: data['videoUrl'] ?? '',
          tags: List<String>.from(data['tags'] ?? []),
          isBookmarked: false,
        ));
      }

      // If no resources in Firebase, load sample data
      if (resources.isEmpty) {
        resources = _getSampleResources();
      }

      setState(() {
        allResources = resources;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading resources: $e');
      // Load sample data on error
      setState(() {
        allResources = _getSampleResources();
        isLoading = false;
      });
    }
  }

  Future<void> _loadBookmarkedResources() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('user_bookmarks')
          .doc(user.uid)
          .collection('resources')
          .get();

      List<String> bookmarkedIds = snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        bookmarkedResources = allResources
            .where((resource) => bookmarkedIds.contains(resource.id))
            .toList();

        // Update bookmark status in all resources
        for (var resource in allResources) {
          resource.isBookmarked = bookmarkedIds.contains(resource.id);
        }
      });
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  Future<void> _toggleBookmark(ResourceItem resource) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to bookmark resources'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final bookmarkRef = _firestore
          .collection('user_bookmarks')
          .doc(user.uid)
          .collection('resources')
          .doc(resource.id);

      if (resource.isBookmarked) {
        await bookmarkRef.delete();
      } else {
        await bookmarkRef.set({
          'resourceId': resource.id,
          'title': resource.title,
          'category': resource.category,
          'bookmarkedAt': FieldValue.serverTimestamp(),
        });
      }

      setState(() {
        resource.isBookmarked = !resource.isBookmarked;
        if (resource.isBookmarked) {
          bookmarkedResources.add(resource);
        } else {
          bookmarkedResources.removeWhere((r) => r.id == resource.id);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resource.isBookmarked
                ? 'Added to bookmarks'
                : 'Removed from bookmarks',
          ),
          backgroundColor: resource.isBookmarked ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ResourceItem> get filteredResources {
    List<ResourceItem> resources = showBookmarksOnly ? bookmarkedResources : allResources;

    if (selectedCategory != "All") {
      resources = resources.where((resource) => resource.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      resources = resources.where((resource) =>
      resource.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          resource.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          resource.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()))).toList();
    }

    return resources;
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No URL available for this resource'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $url'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                : FadeTransition(
              opacity: _fadeAnimation,
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

                  // Search Bar
                  SliverToBoxAdapter(
                    child: _buildSearchBar(),
                  ),

                  // Category Filter
                  SliverToBoxAdapter(
                    child: _buildCategoryFilter(),
                  ),

                  // Resources Content
                  _buildResourcesGrid(),
                ],
              ),
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
            "Loading Resources...",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait while we fetch the latest resources",
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
                  "Resources Hub",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Curated content for your career journey",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                showBookmarksOnly = !showBookmarksOnly;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: showBookmarksOnly
                    ? const LinearGradient(
                  colors: [Color(0xFF43E97B), Color(0xFF38D9A9)],
                )
                    : LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: showBookmarksOnly
                      ? const Color(0xFF43E97B).withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                showBookmarksOnly ? Icons.bookmark : Icons.bookmark_border,
                color: showBookmarksOnly ? Colors.white : Colors.white70,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              "Total Resources",
              allResources.length.toString(),
              Icons.library_books,
              const Color(0xFF667EEA),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              "Bookmarked",
              bookmarkedResources.length.toString(),
              Icons.bookmark,
              const Color(0xFF43E97B),
            ),
          ),
          Expanded(
            child: _buildStatItem(
              "Categories",
              (categories.length - 1).toString(),
              Icons.category,
              const Color(0xFFFA709A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(15),
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
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: "Search resources...",
          hintStyle: GoogleFonts.poppins(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: () {
              _searchController.clear();
              setState(() {
                searchQuery = "";
              });
            },
          )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
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
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                )
                    : null,
                color: isSelected ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.2),
                ),
                boxShadow: isSelected
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
  }

  Widget _buildResourcesGrid() {
    final resources = filteredResources;

    if (resources.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                color: Colors.white.withOpacity(0.5),
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                showBookmarksOnly
                    ? "No bookmarked resources yet"
                    : "No resources found",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                showBookmarksOnly
                    ? "Start bookmarking resources to see them here"
                    : "Try adjusting your search or filters",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 375),
              columnCount: 2,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: _buildResourceCard(resources[index]),
                ),
              ),
            );
          },
          childCount: resources.length,
        ),
      ),
    );
  }

  Widget _buildResourceCard(ResourceItem resource) {
    return GestureDetector(
      onTap: () => _showResourceDetails(resource),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
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
            // Image/Thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: _getCategoryGradient(resource.category),
                ),
                child: Stack(
                  children: [
                    // Category Icon
                    Center(
                      child: Icon(
                        _getCategoryIcon(resource.category),
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    // Bookmark Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleBookmark(resource),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            resource.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: resource.isBookmarked ? Colors.yellow : Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    // Category Badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          resource.category,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resource.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        resource.description,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 10,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white54,
                          size: 10,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            resource.author,
                            style: GoogleFonts.poppins(
                              color: Colors.white54,
                              fontSize: 9,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  void _showResourceDetails(ResourceItem resource) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.95,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F4C75),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: _getCategoryGradient(resource.category),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _getCategoryIcon(resource.category),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                resource.title,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                resource.category,
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Description
                          Text(
                            "Description",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            resource.description,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Author and Date
                          Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white54, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "Author: ${resource.author}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                "Published: ${_formatDate(resource.publishDate)}",
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Tags
                          if (resource.tags.isNotEmpty) ...[
                            Text(
                              "Tags",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: resource.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF43E97B).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: const Color(0xFF43E97B).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF43E97B),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Action Buttons
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildActionButton(
                                  resource.isBookmarked ? "Remove" : "Bookmark",
                                  resource.isBookmarked ? Icons.bookmark_remove : Icons.bookmark_add,
                                  resource.isBookmarked ? Colors.orange : const Color(0xFF43E97B),
                                      () {
                                    _toggleBookmark(resource);
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildActionButton(
                                  "Open",
                                  Icons.open_in_new,
                                  const Color(0xFF667EEA),
                                      () {
                                    Navigator.pop(context);
                                    _openResource(resource);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openResource(ResourceItem resource) {
    String url = '';

    switch (resource.category) {
      case 'Videos':
        url = resource.videoUrl.isNotEmpty ? resource.videoUrl : resource.contentUrl;
        break;
      case 'EBooks':
        url = resource.downloadUrl.isNotEmpty ? resource.downloadUrl : resource.contentUrl;
        break;
      default:
        url = resource.contentUrl;
        break;
    }

    _launchUrl(url);
  }

  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Blogs':
        return Icons.article;
      case 'EBooks':
        return Icons.menu_book;
      case 'Videos':
        return Icons.play_circle;
      case 'Gallery':
        return Icons.photo_library;
      default:
        return Icons.library_books;
    }
  }

  LinearGradient _getCategoryGradient(String category) {
    switch (category) {
      case 'Blogs':
        return const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        );
      case 'EBooks':
        return const LinearGradient(
          colors: [Color(0xFF43E97B), Color(0xFF38D9A9)],
        );
      case 'Videos':
        return const LinearGradient(
          colors: [Color(0xFFFA709A), Color(0xFFFE9A8B)],
        );
      case 'Gallery':
        return const LinearGradient(
          colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFD299C2), Color(0xFFFED6E3)],
        );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  // Sample data with working URLs
  List<ResourceItem> _getSampleResources() {
    return [
      ResourceItem(
        id: '1',
        title: 'Career Planning Guide 2024',
        description: 'Comprehensive guide to career planning and development strategies for professionals.',
        category: 'Blogs',
        type: 'Career Tips',
        author: 'Dr. Sarah Johnson',
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        imageUrl: '',
        contentUrl: 'https://www.indeed.com/career-advice/finding-a-job/career-planning',
        downloadUrl: '',
        videoUrl: '',
        tags: ['career', 'planning', 'development', 'strategy'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '2',
        title: 'Digital Marketing Fundamentals',
        description: 'Learn the basics of digital marketing with this comprehensive eBook.',
        category: 'EBooks',
        type: 'Study Materials',
        author: 'Marketing Pro',
        publishDate: DateTime.now().subtract(const Duration(days: 10)),
        imageUrl: '',
        contentUrl: 'https://blog.hubspot.com/marketing/digital-marketing',
        downloadUrl: 'https://www.coursera.org/learn/digital-marketing',
        videoUrl: '',
        tags: ['marketing', 'digital', 'fundamentals', 'ebook'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '3',
        title: 'Tech Industry Trends 2024',
        description: 'Expert analysis of emerging trends in the technology industry.',
        category: 'Videos',
        type: 'Industry Trends',
        author: 'Tech Insights',
        publishDate: DateTime.now().subtract(const Duration(days: 3)),
        imageUrl: '',
        contentUrl: '',
        downloadUrl: '',
        videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        tags: ['technology', 'trends', 'industry', 'analysis'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '4',
        title: 'Resume Writing Masterclass',
        description: 'Professional tips and templates for creating winning resumes.',
        category: 'Blogs',
        type: 'Expert Advice',
        author: 'HR Specialist',
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        imageUrl: '',
        contentUrl: 'https://www.indeed.com/career-advice/resumes-cover-letters/how-to-write-a-resume',
        downloadUrl: '',
        videoUrl: '',
        tags: ['resume', 'writing', 'templates', 'career'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '5',
        title: 'Python Programming Tutorial',
        description: 'Complete beginner to advanced Python programming course.',
        category: 'Videos',
        type: 'Tutorials',
        author: 'Code Academy',
        publishDate: DateTime.now().subtract(const Duration(days: 15)),
        imageUrl: '',
        contentUrl: '',
        downloadUrl: '',
        videoUrl: 'https://www.youtube.com/watch?v=kqtD5dpn9C8',
        tags: ['python', 'programming', 'tutorial', 'coding'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '6',
        title: 'Success Stories Gallery',
        description: 'Inspiring career transformation stories from our community.',
        category: 'Gallery',
        type: 'Career Tips',
        author: 'Community Team',
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        imageUrl: '',
        contentUrl: 'https://www.linkedin.com/pulse/success-stories-career-transformation',
        downloadUrl: '',
        videoUrl: '',
        tags: ['success', 'stories', 'inspiration', 'community'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '7',
        title: 'Data Science Career Path',
        description: 'Complete roadmap for building a successful career in data science.',
        category: 'Blogs',
        type: 'Career Tips',
        author: 'Data Science Expert',
        publishDate: DateTime.now().subtract(const Duration(days: 4)),
        imageUrl: '',
        contentUrl: 'https://www.coursera.org/articles/what-is-data-science',
        downloadUrl: '',
        videoUrl: '',
        tags: ['data science', 'career', 'roadmap', 'analytics'],
        isBookmarked: false,
      ),
      ResourceItem(
        id: '8',
        title: 'UI/UX Design Principles',
        description: 'Essential eBook covering user interface and user experience design.',
        category: 'EBooks',
        type: 'Study Materials',
        author: 'Design Studio',
        publishDate: DateTime.now().subtract(const Duration(days: 8)),
        imageUrl: '',
        contentUrl: 'https://www.interaction-design.org/literature/topics/ui-design',
        downloadUrl: 'https://www.udemy.com/course/ui-ux-web-design-using-adobe-xd/',
        videoUrl: '',
        tags: ['ui', 'ux', 'design', 'principles'],
        isBookmarked: false,
      ),
    ];
  }
}

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type;
  final String author;
  final DateTime publishDate;
  final String imageUrl;
  final String contentUrl;
  final String downloadUrl;
  final String videoUrl;
  final List<String> tags;
  bool isBookmarked;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.author,
    required this.publishDate,
    required this.imageUrl,
    required this.contentUrl,
    required this.downloadUrl,
    required this.videoUrl,
    required this.tags,
    required this.isBookmarked,
  });
}