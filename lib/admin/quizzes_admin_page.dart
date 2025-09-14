import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizzesAdminPage extends StatelessWidget {
  const QuizzesAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  Expanded(child: _QuizzesList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.blueGrey.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quizzes Management",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  "Create and manage quiz questions and assessments",
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
            child: const Icon(Icons.quiz, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  static Future<void> _openCreateOrRenameQuiz(
    BuildContext context, {
    DocumentSnapshot? doc,
  }) async {
    final controller = TextEditingController(text: doc?.id ?? '');
    await showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                doc == null ? 'Create Quiz (Tier)' : 'Rename Quiz (Tier)',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                style: GoogleFonts.poppins(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'e.g., Class 8, Matric, Intermediate',
                  hintStyle: GoogleFonts.poppins(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed:
                      isSaving
                          ? null
                          : () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            setState(() => isSaving = true);
                            try {
                              if (doc == null) {
                                await FirebaseFirestore.instance
                                    .collection('quizzes')
                                    .doc(name)
                                    .set({
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });
                              } else if (doc.id != name) {
                                final data =
                                    await FirebaseFirestore.instance
                                        .collection('quizzes')
                                        .doc(doc.id)
                                        .get();
                                final qs =
                                    await FirebaseFirestore.instance
                                        .collection('quizzes')
                                        .doc(doc.id)
                                        .collection('questions')
                                        .get();
                                await FirebaseFirestore.instance
                                    .collection('quizzes')
                                    .doc(name)
                                    .set(data.data() ?? {});
                                for (final q in qs.docs) {
                                  await FirebaseFirestore.instance
                                      .collection('quizzes')
                                      .doc(name)
                                      .collection('questions')
                                      .doc(q.id)
                                      .set(q.data());
                                }
                                await FirebaseFirestore.instance
                                    .collection('quizzes')
                                    .doc(doc.id)
                                    .delete();
                              }
                              if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                            } finally {
                              setState(() => isSaving = false);
                            }
                          },
                  child: Text(doc == null ? 'Create' : 'Rename'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _QuizzesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('quizzes')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF667EEA)),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No quizzes yet. Click New Quiz to add.',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
          );
        }
        final docs = snapshot.data!.docs;
        return ListView.separated(
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = docs[index];
            final name = doc.id;
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                title: Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Tier',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Manage Questions',
                      onPressed: () => _openQuestionsManager(context, doc),
                      icon: const Icon(Icons.list_alt, color: Colors.white70),
                    ),
                    IconButton(
                      tooltip: 'Rename',
                      onPressed:
                          () => QuizzesAdminPage._openCreateOrRenameQuiz(
                            context,
                            doc: doc,
                          ),
                      icon: const Icon(Icons.edit, color: Colors.white70),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF1A1A2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  'Delete "$name"?',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                        );
                        if (ok == true) {
                          final qs =
                              await FirebaseFirestore.instance
                                  .collection('quizzes')
                                  .doc(doc.id)
                                  .collection('questions')
                                  .get();
                          for (final q in qs.docs) {
                            await FirebaseFirestore.instance
                                .collection('quizzes')
                                .doc(doc.id)
                                .collection('questions')
                                .doc(q.id)
                                .delete();
                          }
                          await FirebaseFirestore.instance
                              .collection('quizzes')
                              .doc(doc.id)
                              .delete();
                        }
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openQuestionsManager(BuildContext context, DocumentSnapshot quizDoc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
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
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.list_alt, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Questions • ${quizDoc.id}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed:
                            () => _openCreateOrEditQuestion(
                              context,
                              quizDoc: quizDoc,
                            ),
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('quizzes')
                              .doc(quizDoc.id)
                              .collection('questions')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF667EEA),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              'No questions yet',
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          );
                        }
                        final qdocs = snapshot.data!.docs;
                        return ListView.separated(
                          controller: scrollController,
                          itemCount: qdocs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final q = qdocs[index];
                            final data = q.data() as Map<String, dynamic>;
                            final question =
                                (data['question'] ?? '').toString();
                            final List options =
                                (data['options'] ?? []) as List;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: ListTile(
                                title: Text(
                                  question,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${options.length} options',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Edit',
                                      onPressed:
                                          () => _openCreateOrEditQuestion(
                                            context,
                                            quizDoc: quizDoc,
                                            questionDoc: q,
                                          ),
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Delete',
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('quizzes')
                                            .doc(quizDoc.id)
                                            .collection('questions')
                                            .doc(q.id)
                                            .delete();
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openCreateOrEditQuestion(
    BuildContext context, {
    required DocumentSnapshot quizDoc,
    DocumentSnapshot? questionDoc,
  }) {
    final questionController = TextEditingController(
      text:
          (questionDoc?.data() as Map<String, dynamic>?)?['question']
              ?.toString() ??
          '',
    );
    final List<Map<String, TextEditingController>> optionControllers = [];
    int selectedCorrectIndex = -1;
    final existingOptions =
        (questionDoc?.data() as Map<String, dynamic>?)?['options']
            as List<dynamic>?;
    if (existingOptions != null && existingOptions.isNotEmpty) {
      for (int i = 0; i < existingOptions.length; i++) {
        final opt = existingOptions[i];
        optionControllers.add({
          'text': TextEditingController(text: opt['text']?.toString() ?? ''),
          'category': TextEditingController(
            text: opt['category']?.toString() ?? '',
          ),
        });
        if (opt['isCorrect'] == true) {
          selectedCorrectIndex = i;
        }
      }
    } else {
      for (int i = 0; i < 4; i++) {
        optionControllers.add({
          'text': TextEditingController(),
          'category': TextEditingController(),
        });
      }
    }

    showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        questionDoc == null ? 'Add Question' : 'Edit Question',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: questionController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Question *',
                          labelStyle: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.07),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Options (text + category)',
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      ...optionControllers.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final ctrls = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Radio<int>(
                                value: idx,
                                groupValue: selectedCorrectIndex,
                                activeColor: const Color(0xFF667EEA),
                                onChanged: (v) {
                                  setState(
                                    () => selectedCorrectIndex = v ?? -1,
                                  );
                                },
                              ),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: ctrls['text'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Option ${idx + 1} text',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white54,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.07),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: ctrls['category'],
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Category',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white54,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.07),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Remove',
                                onPressed: () {
                                  setState(() {
                                    if (optionControllers.length > 1) {
                                      optionControllers.removeAt(idx);
                                      if (selectedCorrectIndex == idx) {
                                        selectedCorrectIndex = -1;
                                      } else if (selectedCorrectIndex > idx) {
                                        selectedCorrectIndex -= 1;
                                      }
                                    }
                                  });
                                },
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                optionControllers.add({
                                  'text': TextEditingController(),
                                  'category': TextEditingController(),
                                });
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add Option'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          GradientButton(
                            isLoading: isSaving,
                            onPressed: () async {
                              if (questionController.text.trim().isEmpty) {
                                return;
                              }
                              final opts =
                                  optionControllers
                                      .asMap()
                                      .entries
                                      .map(
                                        (entry) => {
                                          'text':
                                              entry.value['text']!.text.trim(),
                                          'category':
                                              entry.value['category']!.text
                                                  .trim(),
                                          if (selectedCorrectIndex == entry.key)
                                            'isCorrect': true,
                                        },
                                      )
                                      .where(
                                        (o) =>
                                            (o['text'] as String).isNotEmpty &&
                                            (o['category'] as String)
                                                .isNotEmpty,
                                      )
                                      .toList();
                              if (opts.length < 2) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Add at least 2 options'),
                                  ),
                                );
                                return;
                              }
                              if (selectedCorrectIndex == -1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Select the correct option (radio button)',
                                    ),
                                  ),
                                );
                                return;
                              }
                              setState(() => isSaving = true);
                              try {
                                final data = {
                                  'question': questionController.text.trim(),
                                  'options': opts,
                                  'updatedAt': FieldValue.serverTimestamp(),
                                };
                                if (questionDoc == null) {
                                  await FirebaseFirestore.instance
                                      .collection('quizzes')
                                      .doc(quizDoc.id)
                                      .collection('questions')
                                      .add({
                                        ...data,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                } else {
                                  await FirebaseFirestore.instance
                                      .collection('quizzes')
                                      .doc(quizDoc.id)
                                      .collection('questions')
                                      .doc(questionDoc.id)
                                      .update(data);
                                }
                                if (Navigator.canPop(ctx)) {
                                  Navigator.pop(ctx);
                                }
                              } finally {
                                setState(() => isSaving = false);
                              }
                            },
                            child: Text(
                              questionDoc == null ? 'Save' : 'Update',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
