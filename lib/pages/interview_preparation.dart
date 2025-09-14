import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';

class InterviewPreparationPage extends StatefulWidget {
  const InterviewPreparationPage({super.key});

  @override
  State<InterviewPreparationPage> createState() =>
      _InterviewPreparationPageState();
}

class _InterviewPreparationPageState extends State<InterviewPreparationPage>
    with TickerProviderStateMixin {
  String selectedCategory = "All";
  String searchQuery = "";
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAnswers = false;

  final List<String> categories = [
    "All",
    "HR Questions",
    "Technical",
    "Behavioral",
    "Body Language",
    "Mock Videos"
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<QuestionItem> get filteredQuestions {
    List<QuestionItem> items = [];
    if (selectedCategory == "All" || selectedCategory == "HR Questions") {
      items.addAll(hrQuestionList);
    }
    if (selectedCategory == "All" || selectedCategory == "Behavioral") {
      items.addAll(behavioralQuestions);
    }
    return items
        .where((q) => q.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
        q.answer.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<QuestionItem> get filteredTechQuestions =>
      (selectedCategory == "All" || selectedCategory == "Technical")
          ? technicalQuestions
          .where((q) => q.question.toLowerCase().contains(searchQuery.toLowerCase()) ||
          q.answer.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList()
          : [];

  List<BodyTipItem> get filteredBodyTips =>
      (selectedCategory == "All" || selectedCategory == "Body Language")
          ? bodyTipList
          .where((b) => b.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          b.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList()
          : [];

  List<MockVideoItem> get filteredVideos =>
      (selectedCategory == "All" || selectedCategory == "Mock Videos")
          ? mockVideoList
          .where((v) => v.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          v.description.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList()
          : [];

  int get totalItems {
    return hrQuestionList.length +
        behavioralQuestions.length +
        technicalQuestions.length +
        bodyTipList.length +
        mockVideoList.length;
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
                SliverToBoxAdapter(child: _buildToggleAnswers()),
                if (filteredQuestions.isNotEmpty)
                  _buildSectionHeader("HR & Behavioral Questions", Icons.help_outline),
                if (filteredQuestions.isNotEmpty)
                  _buildQuestionsGrid(filteredQuestions, Icons.help_outline),
                if (filteredTechQuestions.isNotEmpty)
                  _buildSectionHeader("Technical Questions", Icons.computer),
                if (filteredTechQuestions.isNotEmpty)
                  _buildQuestionsGrid(filteredTechQuestions, Icons.computer),
                if (filteredBodyTips.isNotEmpty)
                  _buildSectionHeader("Body Language Tips", Icons.accessibility),
                if (filteredBodyTips.isNotEmpty)
                  _buildBodyLanguageGrid(),
                if (filteredVideos.isNotEmpty)
                  _buildSectionHeader("Mock Interview Videos", Icons.play_circle_fill),
                if (filteredVideos.isNotEmpty)
                  _buildMockVideosGrid(),
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
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Interview Preparation",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Master your interview skills with comprehensive guidance",
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
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
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 28),
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
          "Preparation Overview",
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
            _buildStatItem("HR", "${hrQuestionList.length + behavioralQuestions.length}", Icons.help_outline),
            _buildDivider(),
            _buildStatItem("Technical", "${technicalQuestions.length}", Icons.computer),
            _buildDivider(),
            _buildStatItem("Tips", "${bodyTipList.length}", Icons.accessibility),
            _buildDivider(),
            _buildStatItem("Videos", "${mockVideoList.length}", Icons.video_library),
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
        style: GoogleFonts.poppins(
          color: Colors.white70,
          fontSize: 12,
        ),
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
          hintText: "Search questions, tips, or videos...",
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.white70),
            onPressed: () => setState(() => searchQuery = ""),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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

  Widget _buildToggleAnswers() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Show Answers: ",
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        Switch(
          value: _showAnswers,
          onChanged: (value) => setState(() => _showAnswers = value),
          activeColor: const Color(0xFF667EEA),
          activeTrackColor: const Color(0xFF667EEA).withOpacity(0.3),
        ),
      ],
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

  Widget _buildQuestionsGrid(List<QuestionItem> list, IconData icon) =>
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final question = list[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(
                    child: _buildQuestionCard(icon, question.question, question.answer),
                  ),
                ),
              );
            },
            childCount: list.length,
          ),
        ),
      );

  Widget _buildBodyLanguageGrid() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final tip = filteredBodyTips[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: _buildTipCard(tip.title, tip.description),
              ),
            ),
          );
        },
        childCount: filteredBodyTips.length,
      ),
    ),
  );

  Widget _buildMockVideosGrid() => SliverPadding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    sliver: SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final video = filteredVideos[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 600),
            child: SlideAnimation(
              verticalOffset: 50,
              child: FadeInAnimation(
                child: _buildVideoCard(video),
              ),
            ),
          );
        },
        childCount: filteredVideos.length,
      ),
    ),
  );

  Widget _buildQuestionCard(IconData icon, String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
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
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          question,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconColor: Colors.white,
        collapsedIconColor: Colors.white70,
        children: [
          if (_showAnswers)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                answer,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTipCard(String title, String description) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
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
        const SizedBox(height: 15),
        Text(
          description,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    ),
  );

  Widget _buildVideoCard(MockVideoItem video) => GestureDetector(
    onTap: () async {
      final uri = Uri.parse(video.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open video')),
        );
      }
    },
    child: Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF667EEA).withOpacity(0.2),
            const Color(0xFF764BA2).withOpacity(0.1),
          ],
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      video.duration,
                      style: GoogleFonts.poppins(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new, color: Colors.white70, size: 20),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            video.description,
            style: GoogleFonts.poppins(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  );
}

// ----------------- Enhanced Data Classes -----------------
class QuestionItem {
  final String question;
  final String answer;
  final String category;

  QuestionItem({
    required this.question,
    required this.answer,
    this.category = "General"
  });
}

class BodyTipItem {
  final String title;
  final String description;

  BodyTipItem({required this.title, required this.description});
}

class MockVideoItem {
  final String title;
  final String url;
  final String description;
  final String duration;

  MockVideoItem({
    required this.title,
    required this.url,
    required this.description,
    required this.duration,
  });
}

// ----------------- Enhanced Data Lists -----------------
final List<QuestionItem> hrQuestionList = [
  QuestionItem(
      question: "Tell me about yourself",
      answer: "Keep it professional, highlight your skills, experience, and achievements relevant to the role. Structure your response using the Present-Past-Future format: what you're doing now, relevant past experiences, and your future goals.",
      category: "HR"
  ),
  QuestionItem(
      question: "Why do you want this job?",
      answer: "Show enthusiasm and align your goals with the company's mission. Research the company values, mention specific aspects that attract you, and explain how your skills can contribute to their goals.",
      category: "HR"
  ),
  QuestionItem(
      question: "What are your strengths?",
      answer: "Choose 2-3 strengths that are relevant to the job. Provide specific examples of how you've used these strengths to achieve results. Use the STAR method (Situation, Task, Action, Result) to structure your examples.",
      category: "HR"
  ),
  QuestionItem(
      question: "What are your weaknesses?",
      answer: "Choose a real weakness but show how you're working to improve it. Focus on professional weaknesses, not personal ones, and always end with what you're doing to address it.",
      category: "HR"
  ),
  QuestionItem(
      question: "Where do you see yourself in 5 years?",
      answer: "Show ambition while staying realistic and relevant to the role. Demonstrate that you see growth opportunities within the company and that your goals align with the career path this position offers.",
      category: "HR"
  ),
  QuestionItem(
      question: "Why are you leaving your current job?",
      answer: "Stay positive and focus on seeking new opportunities rather than escaping problems. Mention growth, learning opportunities, or better alignment with your career goals. Never speak negatively about your current employer.",
      category: "HR"
  ),
];

final List<QuestionItem> behavioralQuestions = [
  QuestionItem(
      question: "Describe a challenging situation you faced and how you handled it",
      answer: "Use the STAR method: Situation (context), Task (what needed to be done), Action (what you did), Result (the outcome). Focus on your problem-solving skills and what you learned from the experience.",
      category: "Behavioral"
  ),
  QuestionItem(
      question: "Tell me about a time you worked in a team",
      answer: "Highlight your collaboration skills, communication abilities, and how you contributed to team success. Mention any leadership roles you took or conflicts you helped resolve.",
      category: "Behavioral"
  ),
  QuestionItem(
      question: "Describe a time you had to meet a tight deadline",
      answer: "Demonstrate your time management, prioritization skills, and ability to work under pressure. Explain your process for organizing tasks and how you ensured quality wasn't compromised.",
      category: "Behavioral"
  ),
  QuestionItem(
      question: "Tell me about a mistake you made and how you handled it",
      answer: "Show accountability, learning ability, and problem-solving skills. Explain what went wrong, how you addressed it, what you learned, and how you prevent similar mistakes now.",
      category: "Behavioral"
  ),
];

final List<QuestionItem> technicalQuestions = [
  QuestionItem(
      question: "Explain Object-Oriented Programming concepts",
      answer: "OOP has four main principles: 1) Encapsulation - bundling data and methods together, 2) Inheritance - creating new classes based on existing ones, 3) Polymorphism - objects taking multiple forms, 4) Abstraction - hiding complex implementation details.",
      category: "Technical"
  ),
  QuestionItem(
      question: "What is a REST API?",
      answer: "REST (Representational State Transfer) is an architectural style for designing web services. It uses HTTP methods (GET, POST, PUT, DELETE) to perform CRUD operations on resources identified by URLs. RESTful APIs are stateless, cacheable, and have a uniform interface.",
      category: "Technical"
  ),
  QuestionItem(
      question: "Explain the difference between SQL and NoSQL databases",
      answer: "SQL databases are relational, use structured schemas, support ACID properties, and use SQL queries. NoSQL databases are non-relational, have flexible schemas, are horizontally scalable, and include types like document, key-value, column-family, and graph databases.",
      category: "Technical"
  ),
  QuestionItem(
      question: "What is version control and why is it important?",
      answer: "Version control systems like Git track changes to code over time, allow multiple developers to collaborate, maintain history of changes, enable branching for features, and provide backup and recovery capabilities. It's essential for software development workflow.",
      category: "Technical"
  ),
  QuestionItem(
      question: "Explain the difference between front-end and back-end development",
      answer: "Front-end development focuses on user interface and user experience using HTML, CSS, JavaScript, and frameworks like React or Vue. Back-end development handles server-side logic, databases, APIs, and infrastructure using languages like Python, Java, or Node.js.",
      category: "Technical"
  ),
];

final List<BodyTipItem> bodyTipList = [
  BodyTipItem(
      title: "Maintain Good Posture",
      description: "Sit upright with shoulders relaxed and feet flat on the floor. Good posture projects confidence and professionalism. Avoid slouching or leaning back too much in your chair."
  ),
  BodyTipItem(
      title: "Eye Contact",
      description: "Maintain steady, natural eye contact to build trust and show engagement. Look at the interviewer when speaking and listening. If multiple interviewers, distribute your attention among all of them."
  ),
  BodyTipItem(
      title: "Hand Gestures",
      description: "Use open, controlled hand gestures to emphasize points. Keep hands visible and avoid fidgeting, crossing arms, or pointing. Natural gestures help convey enthusiasm and confidence."
  ),
  BodyTipItem(
      title: "Facial Expressions",
      description: "Smile genuinely when appropriate and maintain pleasant, attentive facial expressions. Show interest through your expressions and nod to acknowledge understanding."
  ),
  BodyTipItem(
      title: "Voice and Tone",
      description: "Speak clearly at a moderate pace with varied intonation. Project confidence through your voice while remaining conversational. Avoid speaking too fast when nervous."
  ),
  BodyTipItem(
      title: "Personal Space",
      description: "Respect personal boundaries and maintain appropriate distance. If shaking hands, offer a firm handshake. Be mindful of the interviewer's comfort zone."
  ),
  BodyTipItem(
      title: "Active Listening",
      description: "Show engagement by leaning slightly forward when listening, nodding appropriately, and asking clarifying questions. Demonstrate that you're fully present in the conversation."
  ),
  BodyTipItem(
      title: "Professional Appearance",
      description: "Dress appropriately for the company culture, ensure good grooming, and pay attention to details like clean shoes and wrinkle-free clothing. First impressions matter significantly."
  ),
];

final List<MockVideoItem> mockVideoList = [
  MockVideoItem(
      title: "Complete Mock Interview - Software Developer",
      url: "https://www.youtube.com/watch?v=1qw5ITr3k9E",
      description: "A comprehensive mock interview covering technical and behavioral questions for software development roles. Includes feedback and tips for improvement.",
      duration: "45 min"
  ),
  MockVideoItem(
      title: "HR Interview Questions and Answers",
      url: "https://www.youtube.com/watch?v=naIkpQ_cIt0",
      description: "Common HR interview questions with detailed sample answers. Learn how to effectively communicate your strengths, weaknesses, and career goals.",
      duration: "25 min"
  ),
  MockVideoItem(
      title: "Behavioral Interview Techniques",
      url: "https://www.youtube.com/watch?v=PJKYqLP6MRE",
      description: "Master the STAR method for answering behavioral questions. Real examples and practice scenarios to help you prepare compelling stories.",
      duration: "30 min"
  ),
  MockVideoItem(
      title: "Technical Interview Coding Challenge",
      url: "https://www.youtube.com/watch?v=XKu_SEDAykw",
      description: "Watch a live coding interview session with explanations of thought processes, problem-solving approaches, and communication during technical challenges.",
      duration: "55 min"
  ),
  MockVideoItem(
      title: "Body Language in Interviews",
      url: "https://www.youtube.com/watch?v=vYwKxroOjWY",
      description: "Learn how to project confidence through your body language. Tips on posture, eye contact, hand gestures, and professional presence.",
      duration: "20 min"
  ),
  MockVideoItem(
      title: "Phone Interview Best Practices",
      url: "https://www.youtube.com/watch?v=9No2t8qWi6o",
      description: "Special considerations for phone and video interviews. Technical setup, voice projection, and creating a professional environment at home.",
      duration: "15 min"
  ),
  MockVideoItem(
      title: "Questions to Ask Your Interviewer",
      url: "https://www.youtube.com/watch?v=Y95eI-ek4TY",
      description: "Smart, thoughtful questions that show your interest in the role and company. Learn what to ask and what to avoid in different interview situations.",
      duration: "18 min"
  ),
  MockVideoItem(
      title: "Salary Negotiation Strategies",
      url: "https://www.youtube.com/watch?v=WChxbBSlWnQ",
      description: "Learn how to research, prepare for, and conduct salary negotiations. Timing, tactics, and scripts for getting the compensation you deserve.",
      duration: "35 min"
  ),
];