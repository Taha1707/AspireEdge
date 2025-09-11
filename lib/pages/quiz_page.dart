import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

    final snapshot = await FirebaseFirestore.instance
        .collection("quizzes")
        .doc(userTier) // yahan user ka tier uth kar aayega
        .collection("questions")
        .limit(12) // sirf 12 MCQs uthao
        .get();

    setState(() {
      questions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "question": data["question"],
          "options": data["options"],
        };
      }).toList();
      isLoading = false;
    });
  }

  void _nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const QuizResultPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions found for your tier.")),
      );
    }

    final currentQ = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz - $userTier"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Q${currentIndex + 1}. ${currentQ["question"]}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...(currentQ["options"] as List<dynamic>).map((opt) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(opt["text"]), // yahan tumhara text field hai
                  onTap: _nextQuestion,
                ),
              );
            }),
          ],
        ),
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
            )
          ],
        ),
      ),
    );
  }
}
