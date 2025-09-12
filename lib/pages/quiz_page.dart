import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserTier();
  }

  Future<void> _loadUserTier() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      print("❌ No user logged in");
      return;
    }

    // User ka document uthao
    final userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

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

    final snapshot =
        await FirebaseFirestore.instance
            .collection("quizzes")
            .doc(userTier) // yahan user ka tier uth kar aayega
            .collection("questions")
            .limit(12) // sirf 12 MCQs uthao
            .get();

    setState(() {
      questions =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "question": data["question"],
              // options can include { text, category, isCorrect? }
              "options": List<Map<String, dynamic>>.from(
                (data["options"] as List<dynamic>? ?? <dynamic>[]).map(
                  (e) => Map<String, dynamic>.from(e as Map),
                ),
              ),
            };
          }).toList();
      isLoading = false;
      selectedOptionIndex = null;
      isAnswerCorrect = null;
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedOptionIndex = null;
        isAnswerCorrect = null;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizResultPage()),
      );
    }
  }

  void _onSelectOption(int index) {
    final opts =
        (questions[currentIndex]["options"] as List<Map<String, dynamic>>);
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

    return Scaffold(
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
                  // Question Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
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
                                    color:
                                        isSelected
                                            ? const Color(0xFF667EEA)
                                            : Colors.white.withOpacity(0.1),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child:
                                      isSelected
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
                                if (hasCorrectFlag &&
                                    isSelected &&
                                    isAnswerCorrect != null)
                                  Icon(
                                    isAnswerCorrect == true
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color:
                                        isAnswerCorrect == true
                                            ? Colors.greenAccent
                                            : Colors.redAccent,
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
                            onPressed:
                                selectedOptionIndex == null
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
    );
  }
}

class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Quiz Completed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Your results will help us guide your career path.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
