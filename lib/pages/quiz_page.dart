import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

// Updated QuizService with dynamic result calculation
class QuizService {
  static Map<String, String> _quizAnswers = {};
  static List<Map<String, dynamic>> _attemptedQuestions = [];

  static void recordAnswer(String questionId, String selectedAnswer) {
    _quizAnswers[questionId] = selectedAnswer;
    print("✅ Recorded answer for $questionId: $selectedAnswer");
  }

  static void recordAttemptedQuestion(Map<String, dynamic> questionData) {
    _attemptedQuestions.add(questionData);
  }

  static void clearAnswers() {
    _quizAnswers.clear();
    _attemptedQuestions.clear();
    print("🔄 Quiz answers cleared");
  }

  static Map<String, String> getCurrentAnswers() {
    return Map.from(_quizAnswers);
  }

  static List<Map<String, dynamic>> getAttemptedQuestions() {
    return List.from(_attemptedQuestions);
  }

  // Calculate quiz results dynamically from attempted questions
  static Future<Map<String, dynamic>> calculateQuizResults({
    required Map<String, String> userAnswers,
    required String userTier,
  }) async {
    int totalScore = 0;
    int totalQuestions = userAnswers.length;
    Map<String, Map<String, int>> categoryScores = {};
    Map<String, Set<String>> categoryQuestions = {};

    // Process each attempted question
    for (String questionId in userAnswers.keys) {
      try {
        DocumentSnapshot questionDoc = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(userTier)
            .collection('questions')
            .doc(questionId)
            .get();

        if (questionDoc.exists) {
          Map<String, dynamic> questionData = questionDoc.data() as Map<String, dynamic>;
          List<dynamic> options = questionData['options'] ?? [];
          String userAnswer = userAnswers[questionId] ?? '';

          bool isCorrect = false;
          Set<String> questionCategories = {};

          // Extract all categories from this question's options
          for (var option in options) {
            Map<String, dynamic> optionMap = Map<String, dynamic>.from(option);
            String optionCategory = optionMap['category']?.toString() ?? '';

            if (optionCategory.isNotEmpty) {
              questionCategories.add(optionCategory);

              // Initialize category tracking
              if (!categoryScores.containsKey(optionCategory)) {
                categoryScores[optionCategory] = {'correct': 0, 'total': 0};
                categoryQuestions[optionCategory] = {};
              }

              // Check if this option is correct and matches user's answer
              if (optionMap['text']?.toString() == userAnswer &&
                  (optionMap['isCorrect'] == true)) {
                isCorrect = true;
              }
            }
          }

          // Update scores for each category this question belongs to
          for (String category in questionCategories) {
            categoryQuestions[category]!.add(questionId);
            categoryScores[category]!['total'] = categoryQuestions[category]!.length;

            if (isCorrect) {
              categoryScores[category]!['correct'] =
                  (categoryScores[category]!['correct'] ?? 0) + 1;
            }
          }

          if (isCorrect) {
            totalScore++;
          }
        }
      } catch (e) {
        print('Error calculating score for question $questionId: $e');
      }
    }

    return {
      'score': totalScore,
      'totalQuestions': totalQuestions,
      'categoryScores': categoryScores,
      'percentage': totalQuestions > 0 ? (totalScore / totalQuestions) * 100 : 0,
    };
  }

  static Future<void> submitQuizAndShowResults({
    required Map<String, String> userAnswers,
    required String userTier,
    required BuildContext context,
  }) async {
    print("🚀 Calculating dynamic results for ${userAnswers.length} answers for tier: $userTier");

    Map<String, dynamic> quizResults = await calculateQuizResults(
      userAnswers: userAnswers,
      userTier: userTier,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TierBasedResultPage(quizResults: quizResults),
      ),
    );
  }
}

// Fully Dynamic Result Page
class TierBasedResultPage extends StatefulWidget {
  final Map<String, dynamic>? quizResults;

  const TierBasedResultPage({Key? key, this.quizResults}) : super(key: key);

  @override
  State<TierBasedResultPage> createState() => _TierBasedResultPageState();
}

class _TierBasedResultPageState extends State<TierBasedResultPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userTier = '';
  List<DynamicTierCategory> tierCategories = [];
  List<DynamicCategoryRecommendation> recommendations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDynamicUserTierAndCategories();
  }

  Future<void> fetchDynamicUserTierAndCategories() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Fetch user's tier
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      String tier = userData?['tier'] ?? userData?['class'] ?? 'class8';

      setState(() {
        userTier = tier;
      });

      print("📊 Fetching dynamic categories for tier: $tier");

      // Get ALL questions from this tier to extract categories dynamically
      QuerySnapshot questionsSnapshot = await _firestore
          .collection('quizzes')
          .doc(tier)
          .collection('questions')
          .get();

      Map<String, DynamicCategoryInfo> categoryData = {};

      // Analyze all questions in this tier
      for (QueryDocumentSnapshot doc in questionsSnapshot.docs) {
        Map<String, dynamic> questionData = doc.data() as Map<String, dynamic>;
        List<dynamic> options = questionData['options'] ?? [];

        for (var option in options) {
          Map<String, dynamic> optionMap = Map<String, dynamic>.from(option);
          String categoryName = optionMap['category']?.toString() ?? '';

          if (categoryName.isNotEmpty) {
            if (!categoryData.containsKey(categoryName)) {
              categoryData[categoryName] = DynamicCategoryInfo(
                name: categoryName,
                totalQuestions: 0,
                questionsWithCategory: {},
                isAttempted: false,
                userScore: 0,
                userTotal: 0,
              );
            }

            // Track unique questions for this category
            categoryData[categoryName]!.questionsWithCategory.add(doc.id);
          }
        }
      }

      // Update total questions per category
      for (String categoryName in categoryData.keys) {
        categoryData[categoryName]!.totalQuestions =
            categoryData[categoryName]!.questionsWithCategory.length;
      }

      // Get user's performance in attempted categories
      Map<String, dynamic>? categoryScores = widget.quizResults?['categoryScores'];

      List<DynamicTierCategory> categories = [];

      for (String categoryName in categoryData.keys) {
        DynamicCategoryInfo info = categoryData[categoryName]!;

        bool isAttempted = categoryScores?.containsKey(categoryName) ?? false;
        int userCorrect = 0;
        int userTotal = 0;
        double performancePercentage = 0.0;

        if (isAttempted) {
          userCorrect = categoryScores![categoryName]['correct'] ?? 0;
          userTotal = categoryScores[categoryName]['total'] ?? 0;
          performancePercentage = userTotal > 0 ? (userCorrect / userTotal) * 100 : 0.0;
        }

        // Calculate dynamic weightage based on:
        // 1. How many questions in this category exist in the tier
        // 2. User's performance if attempted
        double dynamicWeightage = calculateDynamicWeightage(
          totalQuestionsInTier: questionsSnapshot.docs.length,
          categoryQuestions: info.totalQuestions,
          isAttempted: isAttempted,
          userPerformance: performancePercentage,
        );

        categories.add(DynamicTierCategory(
          name: categoryName,
          totalQuestionsInTier: info.totalQuestions,
          dynamicWeightage: dynamicWeightage,
          isAttempted: isAttempted,
          userCorrect: userCorrect,
          userTotal: userTotal,
          performancePercentage: performancePercentage,
          tier: tier,
          description: generateDynamicDescription(categoryName, isAttempted, performancePercentage),
        ));
      }

      // Sort by dynamic weightage (highest first)
      categories.sort((a, b) => b.dynamicWeightage.compareTo(a.dynamicWeightage));

      setState(() {
        tierCategories = categories;
      });

      print("📋 Found ${categories.length} dynamic categories for tier $tier");
      for (var cat in categories) {
        print("   - ${cat.name}: ${cat.dynamicWeightage.toStringAsFixed(1)}% (${cat.isAttempted ? 'Attempted' : 'Not Attempted'})");
      }

      generateDynamicRecommendations();

    } catch (e) {
      print('❌ Error fetching dynamic tier categories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double calculateDynamicWeightage({
    required int totalQuestionsInTier,
    required int categoryQuestions,
    required bool isAttempted,
    required double userPerformance,
  }) {
    // Base weightage based on question distribution in tier
    double baseWeightage = totalQuestionsInTier > 0
        ? (categoryQuestions / totalQuestionsInTier) * 100
        : 0.0;

    // Bonus for attempted categories
    double attemptBonus = isAttempted ? 10.0 : 0.0;

    // Performance factor
    double performanceFactor = isAttempted ? (userPerformance / 100) * 5 : 0.0;

    return (baseWeightage + attemptBonus + performanceFactor).clamp(0.0, 100.0);
  }

  String generateDynamicDescription(String category, bool isAttempted, double performance) {
    if (!isAttempted) {
      return 'This category is available in your tier but not attempted in this quiz.';
    }

    if (performance >= 80) {
      return 'You performed excellently in this category.';
    } else if (performance >= 60) {
      return 'Good performance in this category with room for improvement.';
    } else if (performance >= 40) {
      return 'Average performance - consider focusing more on this area.';
    } else {
      return 'This category needs significant attention and practice.';
    }
  }

  void generateDynamicRecommendations() {
    List<DynamicCategoryRecommendation> recs = [];

    for (DynamicTierCategory category in tierCategories) {
      // Priority calculation based on:
      // 1. Dynamic weightage (40%)
      // 2. Whether attempted (30%)
      // 3. Performance if attempted (30%)

      double weightageScore = category.dynamicWeightage * 0.4;
      double attemptScore = category.isAttempted ? 30.0 : 0.0;
      double performanceScore = category.isAttempted ?
      (category.performancePercentage * 0.3) : 0.0;

      double priority = weightageScore + attemptScore + performanceScore;

      recs.add(DynamicCategoryRecommendation(
        category: category.name,
        priority: priority,
        dynamicWeightage: category.dynamicWeightage,
        isAttempted: category.isAttempted,
        performance: category.performancePercentage,
        recommendation: getDynamicRecommendationText(category),
        tier: userTier,
      ));
    }

    // Sort by priority and take top 5
    recs.sort((a, b) => b.priority.compareTo(a.priority));

    setState(() {
      recommendations = recs.take(5).toList();
    });

    print("🎯 Generated ${recommendations.length} dynamic recommendations");
  }

  String getDynamicRecommendationText(DynamicTierCategory category) {
    if (!category.isAttempted) {
      if (category.dynamicWeightage > 20) {
        return 'This is an important category for your tier. Consider taking quizzes in ${category.name} to explore this field.';
      } else {
        return '${category.name} is available for exploration in your tier.';
      }
    }

    bool isHighWeightage = category.dynamicWeightage > 25;
    bool isGoodPerformance = category.performancePercentage > 70;

    if (isHighWeightage && isGoodPerformance) {
      return 'Excellent work in ${category.name}! This is a strong area for your tier. Consider advanced topics in this field.';
    } else if (isHighWeightage && !isGoodPerformance) {
      return '${category.name} is important for your tier but needs improvement. Focus on strengthening fundamentals here.';
    } else if (!isHighWeightage && isGoodPerformance) {
      return 'Great performance in ${category.name}! While not the highest priority, you show aptitude in this area.';
    } else {
      return '${category.name} needs attention. Practice more questions and review fundamental concepts.';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
                Color(0xFF0F4C75),
                Color(0xFF3282B8),
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Analyzing your dynamic results...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F4C75),
              Color(0xFF3282B8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                if (widget.quizResults != null) _buildOverallScore(),
                const SizedBox(height: 24),
                _buildDynamicTierCategories(),
                const SizedBox(height: 24),
                _buildDynamicRecommendations(),
                const SizedBox(height: 24),
                if (widget.quizResults != null) _buildDynamicCategoryPerformance(),
                const SizedBox(height: 24),
                _buildBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(
            'Dynamic Interest Analysis',
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tier: ${userTier.toUpperCase()} • ${tierCategories.length} Categories Available',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallScore() {
    final results = widget.quizResults!;
    int score = results['score'] ?? 0;
    int totalQuestions = results['totalQuestions'] ?? 1;
    double percentage = (results['percentage'] ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz Performance',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  score.toString(),
                  'Correct',
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreCard(
                  '${percentage.round()}%',
                  'Accuracy',
                  Colors.blueAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreCard(
                  totalQuestions.toString(),
                  'Total',
                  Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicTierCategories() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Categories for ${userTier.toUpperCase()}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...tierCategories.map((category) => _buildDynamicCategoryCard(category)),
        ],
      ),
    );
  }

  Widget _buildDynamicCategoryCard(DynamicTierCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: category.isAttempted
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.white.withOpacity(0.1)
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      category.isAttempted ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: category.isAttempted ? Colors.greenAccent : Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF667EEA).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF667EEA).withOpacity(0.5)),
                ),
                child: Text(
                  '${category.dynamicWeightage.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF667EEA),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.description,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Questions in tier: ${category.totalQuestionsInTier}',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              if (category.isAttempted) ...[
                const SizedBox(width: 16),
                Text(
                  'Score: ${category.userCorrect}/${category.userTotal}',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: category.dynamicWeightage / 100,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(
                category.isAttempted ? Colors.greenAccent : const Color(0xFF667EEA)
            ),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicRecommendations() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dynamic Recommendations',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...recommendations.asMap().entries.map((entry) {
            int index = entry.key;
            DynamicCategoryRecommendation rec = entry.value;
            return _buildDynamicRecommendationCard(rec, index + 1);
          }),
        ],
      ),
    );
  }

  Widget _buildDynamicRecommendationCard(DynamicCategoryRecommendation rec, int rank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: const Color(0xFF667EEA), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667EEA).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#$rank',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF667EEA),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    rec.category,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    rec.isAttempted ? Icons.check_circle_outline : Icons.explore_outlined,
                    color: rec.isAttempted ? Colors.greenAccent : Colors.orangeAccent,
                    size: 16,
                  ),
                ],
              ),
              Text(
                'Priority: ${rec.priority.toStringAsFixed(1)}',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            rec.recommendation,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            children: [
              Text(
                'Weight: ${rec.dynamicWeightage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              if (rec.isAttempted)
                Text(
                  'Performance: ${rec.performance.toStringAsFixed(1)}%',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              Text(
                rec.isAttempted ? 'Attempted' : 'Not Attempted',
                style: GoogleFonts.poppins(
                  color: rec.isAttempted ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCategoryPerformance() {
    Map<String, dynamic>? categoryScores = widget.quizResults?['categoryScores'];
    if (categoryScores == null || categoryScores.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white54,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              'No category performance data available',
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Complete more questions to see detailed analysis',
              style: GoogleFonts.poppins(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Attempted Categories Performance',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...categoryScores.entries.map((entry) {
            String category = entry.key;
            Map<String, dynamic> score = entry.value;
            int correct = score['correct'] ?? 0;
            int total = score['total'] ?? 1;
            double percentage = (correct / total) * 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$correct/$total',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              percentage >= 80 ? Colors.greenAccent :
                              percentage >= 60 ? Colors.orangeAccent : Colors.redAccent
                          ),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${percentage.round()}%',
                        style: GoogleFonts.poppins(
                          color: percentage >= 80 ? Colors.greenAccent :
                          percentage >= 60 ? Colors.orangeAccent : Colors.redAccent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Back to Home',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// Dynamic Data Models
class DynamicTierCategory {
  final String name;
  final int totalQuestionsInTier;
  final double dynamicWeightage;
  final bool isAttempted;
  final int userCorrect;
  final int userTotal;
  final double performancePercentage;
  final String tier;
  final String description;

  DynamicTierCategory({
    required this.name,
    required this.totalQuestionsInTier,
    required this.dynamicWeightage,
    required this.isAttempted,
    required this.userCorrect,
    required this.userTotal,
    required this.performancePercentage,
    required this.tier,
    required this.description,
  });
}

class DynamicCategoryRecommendation {
  final String category;
  final double priority;
  final double dynamicWeightage;
  final bool isAttempted;
  final double performance;
  final String recommendation;
  final String tier;

  DynamicCategoryRecommendation({
    required this.category,
    required this.priority,
    required this.dynamicWeightage,
    required this.isAttempted,
    required this.performance,
    required this.recommendation,
    required this.tier,
  });
}

class DynamicCategoryInfo {
  final String name;
  int totalQuestions;
  Set<String> questionsWithCategory;
  bool isAttempted;
  int userScore;
  int userTotal;

  DynamicCategoryInfo({
    required this.name,
    required this.totalQuestions,
    required this.questionsWithCategory,
    required this.isAttempted,
    required this.userScore,
    required this.userTotal,
  });
}

// Updated QuizPage - Key changes to record attempted questions
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  bool isLoading = true;
  String? userTier;
  int? selectedOptionIndex;
  bool? isAnswerCorrect;

  Timer? _timer;
  int _timeRemaining = 30;
  static const int _timePerQuestion = 30;

  @override
  void initState() {
    super.initState();
    _loadUserTier();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = _timePerQuestion;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        _timeUp();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _timeUp() {
    _stopTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Time\'s up!'),
        backgroundColor: Colors.orange,
        duration: Duration(milliseconds: 800),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  Color _getTimerColor() {
    if (_timeRemaining > 15) return Colors.greenAccent;
    if (_timeRemaining > 5) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds
        .toString()
        .padLeft(2, '0')}';
  }

  Future<void> _loadUserTier() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("❌ No user logged in");
      return;
    }

    final userDoc = await FirebaseFirestore.instance.collection("users").doc(
        uid).get();
    if (userDoc.exists) {
      userTier = userDoc.data()?["tier"];
      print("✅ User tier: $userTier");
      _loadQuestions();
    } else {
      print("❌ User document not found");
    }
  }

  Future<void> _loadQuestions() async {
    if (userTier == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("quizzes")
        .doc(userTier)
        .collection("questions")
        .limit(12)
        .get();

    setState(() {
      questions = snapshot.docs.map((doc) {
        final data = doc.data();
        Map<String, dynamic> questionData = {
          "id": doc.id,
          "question": data["question"],
          "options": List<Map<String, dynamic>>.from(
            (data["options"] as List<dynamic>? ?? <dynamic>[]).map(
                  (e) => Map<String, dynamic>.from(e as Map),
            ),
          ),
        };

        // Record this question as attempted
        QuizService.recordAttemptedQuestion(questionData);

        return questionData;
      }).toList();
      isLoading = false;
      selectedOptionIndex = null;
      isAnswerCorrect = null;
    });

    if (questions.isNotEmpty) {
      _startTimer();
    }
  }

  void _nextQuestion() {
    _stopTimer();

    if (selectedOptionIndex != null) {
      final currentQ = questions[currentIndex];
      final selectedOption = (currentQ["options"] as List<
          Map<String, dynamic>>)[selectedOptionIndex!];

      QuizService.recordAnswer(
        currentQ["id"] ?? "q${currentIndex + 1}",
        selectedOption["text"] ?? "",
      );
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOptionIndex = null;
        isAnswerCorrect = null;
      });
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _stopTimer();
    Map<String, String> allAnswers = QuizService.getCurrentAnswers();

    QuizService.submitQuizAndShowResults(
      userAnswers: allAnswers,
      userTier: userTier ?? "",
      context: context,
    );

    QuizService.clearAnswers();
  }

  void _onSelectOption(int index) {
    final opts = (questions[currentIndex]["options"] as List<
        Map<String, dynamic>>);
    final hasCorrectFlag = opts.any((o) => o.containsKey('isCorrect'));
    bool? correct;
    if (hasCorrectFlag) {
      correct = opts[index]['isCorrect'] == true;
    }
    setState(() {
      selectedOptionIndex = index;
      isAnswerCorrect = correct;
    });
    if (correct != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(correct ? 'Correct answer' : 'Wrong answer'),
          backgroundColor: correct ? Colors.green : Colors.redAccent,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<bool> _showExitConfirmation() async {
    _stopTimer();
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
          ),
          title: Text(
            'Exit Quiz?',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to exit the quiz? Your progress will be lost.',
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.red],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Exit',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ) ?? false;

    if (!shouldExit) {
      _startTimer();
    }
    return shouldExit;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            "No questions found for your tier.",
            style: GoogleFonts.poppins(color: Colors.white70),
          ),
        ),
      );
    }

    final currentQ = questions[currentIndex];
    final options = currentQ["options"] as List<Map<String, dynamic>>;

    return WillPopScope(
      onWillPop: _showExitConfirmation,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: const Icon(
                            Icons.quiz,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Quiz - ${userTier ?? ''}',
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          'Q${currentIndex + 1}/${questions.length}',
                          style: GoogleFonts.poppins(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: _getTimerColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _getTimerColor().withOpacity(
                            0.5)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer,
                            color: _getTimerColor(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: GoogleFonts.poppins(
                              color: _getTimerColor(),
                              fontSize: _timeRemaining <= 5 ? 18 : 16,
                              fontWeight: _timeRemaining <= 5
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            child: Text(_formatTime(_timeRemaining)),
                          ),
                          if (_timeRemaining <= 5) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.warning,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(
                            0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        currentQ["question"]?.toString() ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: options.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final opt = options[index];
                          final isSelected = selectedOptionIndex == index;
                          final hasCorrectFlag = options.any(
                                (o) => o.containsKey('isCorrect'),
                          );
                          Color borderColor = Colors.white.withOpacity(0.15);
                          Color bgColor = Colors.white.withOpacity(0.06);

                          if (isSelected && isAnswerCorrect != null) {
                            if (isAnswerCorrect == true) {
                              borderColor = Colors.greenAccent;
                              bgColor = Colors.green.withOpacity(0.15);
                            } else {
                              borderColor = Colors.redAccent;
                              bgColor = Colors.redAccent.withOpacity(0.15);
                            }
                          } else if (isSelected) {
                            borderColor = const Color(0xFF667EEA);
                            bgColor = const Color(0xFF667EEA).withOpacity(0.15);
                          }

                          return GestureDetector(
                            onTap: () => _onSelectOption(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF667EEA)
                                          : Colors.white.withOpacity(0.1),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                        : const SizedBox.shrink(),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      (opt["text"] ?? '').toString(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (hasCorrectFlag && isSelected &&
                                      isAnswerCorrect != null)
                                    Icon(
                                      isAnswerCorrect == true ? Icons
                                          .check_circle : Icons.cancel,
                                      color: isAnswerCorrect == true ? Colors
                                          .greenAccent : Colors.redAccent,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ElevatedButton(
                              onPressed: selectedOptionIndex == null
                                  ? null
                                  : _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                currentIndex < questions.length - 1
                                    ? 'Next'
                                    : 'Finish',
                                style: GoogleFonts.poppins(color: Colors.white),
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
          ],
        ),
      ),
    );
  }
}