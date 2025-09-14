import 'package:cloud_firestore/cloud_firestore.dart';

class QuizService {
  static Map<String, String> _quizAnswers = {};
  static String _currentTier = '';

  /// Record an answer -> now storing category instead of text
  static void recordAnswer(String questionId, String selectedCategory) {
    _quizAnswers[questionId] = selectedCategory;
    print("✅ Recorded answer for $questionId: '$selectedCategory'");
  }

  static void setCurrentTier(String tier) {
    _currentTier = tier;
  }

  static void clearAnswers() {
    _quizAnswers.clear();
    _currentTier = '';
    print("🔄 Quiz answers cleared");
  }

  static Map<String, String> getCurrentAnswers() {
    return Map.from(_quizAnswers);
  }

  /// 🔹 Fetch questions for a specific tier (questions subcollection)
  static Future<List<Map<String, dynamic>>> getQuestionsForTier(String tier) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(tier)
        .collection('questions')
        .get();

    if (snapshot.docs.isEmpty) return [];

    List<Map<String, dynamic>> questions = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      questions.add({
        'id': doc.id,
        'question': data['question'],
        'options': data['options'], // must be a List in Firestore
      });
    }

    return questions;
  }

  static Future<Map<String, dynamic>> calculateStreamRecommendations() async {
    Map<String, int> categoryScores = {};
    int totalAnswers = _quizAnswers.length;

    // 🔍 Debug
    print("📊 Calculating recommendations...");
    print("Tier: $_currentTier");
    print("Answers: $_quizAnswers");

    if (totalAnswers == 0) {
      return {
        'recommendations': [],
        'topRecommendation': null,
        'totalAnswers': 0,
        'tier': _currentTier,
      };
    }

    // ✅ Just count categories directly
    _quizAnswers.forEach((_, category) {
      categoryScores[category] = (categoryScores[category] ?? 0) + 1;
    });

    // Build recommendations
    List<StreamRecommendation> recommendations = [];
    categoryScores.forEach((category, score) {
      double percentage = (score / totalAnswers) * 100;
      recommendations.add(StreamRecommendation(
        streamName: category,
        percentage: percentage,
        matchingAnswers: score,
        totalAnswers: totalAnswers,
        description: _getStreamDescription(category, _currentTier),
        careerPaths: List<String>.from(_getCareerPaths(category, _currentTier)),
      ));
    });

    recommendations.sort((a, b) => b.percentage.compareTo(a.percentage));

    return {
      'recommendations': recommendations,
      'topRecommendation': recommendations.isNotEmpty ? recommendations.first : null,
      'totalAnswers': totalAnswers,
      'tier': _currentTier,
    };
  }

  /// 🔹 Stream Descriptions (hardcoded for now)
  static String _getStreamDescription(String category, String tier) {
    Map<String, Map<String, String>> descriptions = {
      'Class 8': {
        'Computer Science/Engineering': 'You show strong interest in technology, problem-solving, and logical thinking. Consider focusing on mathematics and science subjects.',
        'Biology/Pre-Medical': 'You have a natural curiosity about living things and how they work. Biology and chemistry will be your key subjects.',
        'Commerce': 'You enjoy organizing, managing resources, and understanding how business works. Focus on mathematics and social studies.',
        'Arts/Humanities': 'You have a creative mind and enjoy expressing yourself. Language arts, history, and creative subjects suit you well.',
      },
      'Matric': {
        'Pre-Engineering': 'Your logical thinking and technical aptitude suggest engineering is a great fit. Focus on Physics, Chemistry, and Mathematics.',
        'Pre-Medical': 'Your attention to detail and research-oriented mindset indicate medical field potential. Biology, Chemistry, and Physics are essential.',
        'Commerce': 'Your organizational skills and practical approach suit business studies. Economics, Accounting, and Mathematics are key.',
        'Computer Science/Arts': 'You combine technical thinking with creativity. Computer Science or Arts subjects would serve you well.',
      },
      'Intermediate': {
        'Engineering/Architecture/BSCS': 'Your desire to build and create aligns perfectly with engineering or computer science careers.',
        'Economics/Accounting & Finance': 'Your analytical approach to financial problems suggests a strong future in finance or economics.',
        'MBBS/Pharmacy/Psychology': 'Your caring nature and desire to help others indicates medical or healthcare professions.',
        'BBA': 'Your leadership ambitions and organizational skills point toward business administration.',
        'Media Studies/Arts/Law': 'Your passion for communication and cultural expression suggests media, arts, or legal careers.',
      },
    };

    return descriptions[tier]?[category] ?? 'This stream aligns with your interests and aptitudes.';
  }

  /// 🔹 Career Paths (hardcoded for now)
  static List<String> _getCareerPaths(String category, String tier) {
    Map<String, Map<String, List<String>>> careerPaths = {
      'Class 8': {
        'Computer Science/Engineering': ['Software Developer', 'Engineer', 'Game Designer', 'Robotics Expert'],
        'Biology/Pre-Medical': ['Doctor', 'Veterinarian', 'Biologist', 'Medical Researcher'],
        'Commerce': ['Business Owner', 'Accountant', 'Banker', 'Marketing Manager'],
        'Arts/Humanities': ['Artist', 'Writer', 'Teacher', 'Designer', 'Musician'],
      },
      'Matric': {
        'Pre-Engineering': ['Mechanical Engineer', 'Electrical Engineer', 'Civil Engineer', 'Software Engineer'],
        'Pre-Medical': ['Doctor', 'Pharmacist', 'Lab Technician', 'Medical Researcher'],
        'Commerce': ['Chartered Accountant', 'Business Analyst', 'Financial Advisor', 'Entrepreneur'],
        'Computer Science/Arts': ['Web Developer', 'Graphic Designer', 'Game Developer', 'Digital Artist'],
      },
      'Intermediate': {
        'Engineering/Architecture/BSCS': ['Software Architect', 'Civil Engineer', 'System Designer', 'Tech Entrepreneur'],
        'Economics/Accounting & Finance': ['Financial Analyst', 'Investment Banker', 'Economist', 'Auditor'],
        'MBBS/Pharmacy/Psychology': ['Specialist Doctor', 'Clinical Pharmacist', 'Psychologist', 'Healthcare Manager'],
        'BBA': ['CEO', 'Operations Manager', 'Business Consultant', 'Project Manager'],
        'Media Studies/Arts/Law': ['Lawyer', 'Journalist', 'Content Creator', 'Legal Advisor'],
      },
    };

    return careerPaths[tier]?[category] ?? ['Explore various opportunities in this field'];
  }
}

/// 🔹 Model Class
class StreamRecommendation {
  final String streamName;
  final double percentage;
  final int matchingAnswers;
  final int totalAnswers;
  final String description;
  final List<String> careerPaths;

  StreamRecommendation({
    required this.streamName,
    required this.percentage,
    required this.matchingAnswers,
    required this.totalAnswers,
    required this.description,
    required this.careerPaths,
  });
}
