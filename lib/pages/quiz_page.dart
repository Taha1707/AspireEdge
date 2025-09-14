// ===== FILE 2: quiz_page.dart =====

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'quiz_service.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  final String userTier;

  const QuizPage({super.key, required this.userTier});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  List<Map<String, dynamic>> questions = [];
  int currentIndex = 0;
  bool isLoading = true;
  int? selectedOptionIndex;

  Timer? _timer;
  int _timeRemaining = 30;
  static const int _timePerQuestion = 30;

  late AnimationController _progressController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    QuizService.setCurrentTier(widget.userTier);
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = _timePerQuestion;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_timeRemaining > 0) {
        setState(() => _timeRemaining--);
      } else {
        _timeUp();
      }
    });
  }

  void _stopTimer() => _timer?.cancel();

  void _timeUp() {
    _stopTimer();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Time's up! Moving to next question."),
          duration: Duration(seconds: 1),
          backgroundColor: Colors.orange,
        ),
      );
      Future.delayed(const Duration(seconds: 1), _nextQuestion);
    }
  }

  void _loadQuestions() async {
    try {
      final tierQuestions = await QuizService.getQuestionsForTier(widget.userTier);

      setState(() {
        questions = tierQuestions;
        isLoading = false;
        selectedOptionIndex = null;
        currentIndex = 0;
      });

      if (questions.isNotEmpty) {
        _progressController.animateTo((currentIndex + 1) / questions.length);
        _fadeController.forward();
        _startTimer();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        questions = [];
      });
    }
  }

  void _selectOption(int index) {
    setState(() {
      selectedOptionIndex = index;
    });
  }

  void _nextQuestion() async {
    _stopTimer();

    if (selectedOptionIndex != null) {
      final currentQ = questions[currentIndex];
      final options = List<Map<String, dynamic>>.from(currentQ["options"]);
      final selectedOption = options[selectedOptionIndex!];

      // ✅ Save category instead of text
      QuizService.recordAnswer(currentQ["id"], selectedOption["category"]);
    }

    if (currentIndex < questions.length - 1) {
      await _fadeController.reverse();

      if (mounted) {
        setState(() {
          currentIndex++;
          selectedOptionIndex = null;
        });

        _progressController.animateTo((currentIndex + 1) / questions.length);
        await _fadeController.forward();
        _startTimer();
      }
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    _stopTimer();
    QuizService.calculateStreamRecommendations().then((results) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => StreamRecommendationResultPage(results: results)),
      );
      QuizService.clearAnswers();
    });

    QuizService.clearAnswers();
  }

  Color _getTimerColor() {
    if (_timeRemaining <= 5) return Colors.red;
    if (_timeRemaining <= 10) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF3282B8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                SizedBox(height: 20),
                Text(
                  "Loading your personalized quiz...",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF3282B8)],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 64),
                SizedBox(height: 16),
                Text(
                  "No questions available for your tier",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentQuestion = questions[currentIndex];
    final options = List<Map<String, dynamic>>.from(currentQuestion["options"]);

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
          child: Column(
            children: [
              // Header with progress and timer
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Progress bar
                    Row(
                      children: [
                        Text(
                          "Question ${currentIndex + 1} of ${questions.length}",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getTimerColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getTimerColor().withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.timer,
                                color: _getTimerColor(),
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${_timeRemaining}s",
                                style: GoogleFonts.poppins(
                                  color: _getTimerColor(),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progressController.value,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.blueAccent,
                          ),
                          minHeight: 6,
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Question content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Question card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            currentQuestion['question'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Options
                        Expanded(
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options[index];
                              final isSelected = selectedOptionIndex == index;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () => _selectOption(index),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blueAccent.withOpacity(0.2)
                                            : Colors.white.withOpacity(0.06),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.blueAccent
                                              : Colors.white.withOpacity(0.15),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blueAccent
                                                    : Colors.white.withOpacity(0.4),
                                                width: 2,
                                              ),
                                              color: isSelected
                                                  ? Colors.blueAccent
                                                  : Colors.transparent,
                                            ),
                                            child: isSelected
                                                ? const Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            )
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              option["text"] ?? "",
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.white,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Next button
                        Container(
                          width: double.infinity,
                          height: 56,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: ElevatedButton(
                            onPressed: selectedOptionIndex != null
                                ? _nextQuestion
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedOptionIndex != null
                                  ? Colors.blueAccent
                                  : Colors.grey.shade600,
                              foregroundColor: Colors.white,
                              elevation: selectedOptionIndex != null ? 8 : 0,
                              shadowColor: Colors.blueAccent.withOpacity(0.4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  currentIndex == questions.length - 1
                                      ? "Finish Quiz"
                                      : "Next Question",
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  currentIndex == questions.length - 1
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}