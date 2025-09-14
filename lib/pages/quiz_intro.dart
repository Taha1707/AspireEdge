
// ===== FILE 1: quiz_intro_page.dart =====
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'quiz_page.dart';

class QuizIntroPage extends StatefulWidget {
  const QuizIntroPage({super.key});

  @override
  State<QuizIntroPage> createState() => _QuizIntroPageState();
}

class _QuizIntroPageState extends State<QuizIntroPage> {
  String? name;
  String? tier;
  bool isLoading = true;
  bool isQuizAvailable = true;
  DateTime? lastExitTime;
  Timer? cooldownTimer;
  Duration remainingCooldown = Duration.zero;

  static const Duration cooldownDuration = Duration(seconds: 1); // Changed to 5 minutes for better UX

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .get();

        if (mounted) {
          setState(() {
            name = doc.data()?["name"] ?? "User";
            tier = doc.data()?["tier"] ?? "Unknown";

            // Safe null checking for lastQuizExitTime
            if (doc.data()?.containsKey("lastQuizExitTime") == true) {
              final exitTimeStamp = doc["lastQuizExitTime"];
              if (exitTimeStamp is Timestamp) {
                lastExitTime = exitTimeStamp.toDate();
                _checkCooldownStatus();
              }
            }

            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          name = "User";
          tier = "Unknown";
        });
      }
    }
  }

  void _checkCooldownStatus() {
    if (lastExitTime == null) return;

    final now = DateTime.now();
    final timeSinceExit = now.difference(lastExitTime!);

    if (timeSinceExit < cooldownDuration) {
      remainingCooldown = cooldownDuration - timeSinceExit;
      isQuizAvailable = false;
      _startCooldownTimer();
    } else {
      isQuizAvailable = true;
      _clearCooldownFromFirestore();
    }
  }

  void _startCooldownTimer() {
    cooldownTimer?.cancel();
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (remainingCooldown.inSeconds > 0) {
        setState(() {
          remainingCooldown = remainingCooldown - const Duration(seconds: 1);
        });
      } else {
        setState(() {
          isQuizAvailable = true;
        });
        timer.cancel();
        _clearCooldownFromFirestore();
      }
    });
  }

  Future<void> _clearCooldownFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"lastQuizExitTime": FieldValue.delete()});
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _formatCooldownTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _navigateToQuiz() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(userTier: tier ?? "Unknown"),
      ),
    );

    // If result is null, user exited without completing
    if (result == null) {
      await _setQuizExitCooldown();
    }

    _loadUserData();
  }

  Future<void> _setQuizExitCooldown() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .update({"lastQuizExitTime": FieldValue.serverTimestamp()});
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
      )
          : _buildIntroContent(),
    );
  }

  Widget _buildIntroContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
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
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Colors.white,
                  size: 76,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Welcome, ${name ?? 'User'}!",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Tier: ${tier ?? 'Unknown'}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.yellowAccent, size: 32),
                    SizedBox(height: 12),
                    Text(
                      "Discover Your Perfect Academic Stream",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Answer personalized questions to get recommendations for your educational path and future career options.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              if (!isQuizAvailable) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange, size: 24),
                      const SizedBox(height: 8),
                      const Text(
                        "Please wait before taking another quiz",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Time remaining: ${_formatCooldownTime(remainingCooldown)}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isQuizAvailable
                        ? Colors.blueAccent
                        : Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    elevation: isQuizAvailable ? 8 : 0,
                    shadowColor: isQuizAvailable
                        ? Colors.blueAccent.withOpacity(0.4)
                        : Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isQuizAvailable ? _navigateToQuiz : null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isQuizAvailable ? Icons.play_arrow : Icons.lock,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isQuizAvailable ? "Start Quiz" : "Quiz Locked",
                        style: const TextStyle(
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
    );
  }
}