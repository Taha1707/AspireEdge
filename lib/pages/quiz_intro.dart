import 'dart:async';
import 'package:auth_reset_pass/pages/quiz_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static const Duration cooldownDuration = Duration(minutes: 30);

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
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      setState(() {
        name = doc["name"];
        tier = doc["tier"];

        // Check for last quiz exit time
        if (doc.data()?.containsKey("lastQuizExitTime") == true) {
          final exitTimeStamp = doc["lastQuizExitTime"] as Timestamp?;
          if (exitTimeStamp != null) {
            lastExitTime = exitTimeStamp.toDate();
            _checkCooldownStatus();
          }
        }

        isLoading = false;
      });
    }
  }

  void _checkCooldownStatus() {
    if (lastExitTime == null) return;

    final now = DateTime.now();
    final timeSinceExit = now.difference(lastExitTime!);

    if (timeSinceExit < cooldownDuration) {
      // Still in cooldown
      remainingCooldown = cooldownDuration - timeSinceExit;
      isQuizAvailable = false;
      _startCooldownTimer();
    } else {
      // Cooldown expired
      isQuizAvailable = true;
      _clearCooldownFromFirestore();
    }
  }

  void _startCooldownTimer() {
    cooldownTimer?.cancel();

    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingCooldown.inSeconds > 0) {
        setState(() {
          remainingCooldown = remainingCooldown - const Duration(seconds: 1);
        });
      } else {
        // Cooldown finished
        setState(() {
          isQuizAvailable = true;
        });
        timer.cancel();
        _clearCooldownFromFirestore();
      }
    });
  }

  Future<void> _clearCooldownFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"lastQuizExitTime": FieldValue.delete()});
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
        builder: (_) => const QuizPage(),
      ),
    );

    if (result == null) {
      await _setQuizExitCooldown();
    }

    _loadUserData();
  }

  Future<void> _setQuizExitCooldown() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({"lastQuizExitTime": FieldValue.serverTimestamp()});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Colors.white),
      )
          : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C1D95), Color(0xFF0EA5E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
                  ),
                  child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.quiz, color: Colors.white, size: 76),
            const SizedBox(height: 20),
            Text(
              "Welcome, $name",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Your Tier: $tier",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            // Cooldown Timer Display
            if (!isQuizAvailable && remainingCooldown.inSeconds > 0) ...[
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black12,
                      Colors.black45,
                      Colors.black12
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time_filled,
                            color: Colors.redAccent,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Quiz Cooldown Active",
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Next attempt available in:",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        _formatCooldownTime(remainingCooldown),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 40),
            Text(
              isQuizAvailable
                  ? "You are about to start your Career Interest Quiz. This will help us guide you towards the right path!"
                  : "Quiz temporarily unavailable due to recent exit/attempt. Please wait till the cooldown ends for next attempt.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isQuizAvailable ? Colors.white70 : Colors.white60,
                fontSize: 16,
                height: 1.5,
                fontStyle: isQuizAvailable ? FontStyle.normal : FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isQuizAvailable
                        ? Colors.blueAccent
                        : Colors.grey.shade600,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isQuizAvailable ? _navigateToQuiz : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isQuizAvailable) ...[
                        Icon(
                          Icons.lock,
                          size: 16,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        isQuizAvailable ? "Start Quiz" : "Quiz Locked",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isQuizAvailable ? Colors.white : Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ],
                  ),
                ),
    );
  }
}