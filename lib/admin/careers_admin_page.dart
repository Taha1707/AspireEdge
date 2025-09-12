import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CareersAdminPage extends StatelessWidget {
  const CareersAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                        Icons.business_center,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Careers Management',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _openCategoriesManager(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.category_outlined, size: 18),
                      label: const Text('Categories'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(child: _CareersList()),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: () => _openCreateOrEditDialog(context),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  static Future<void> _openCategoriesManager(BuildContext context) async {
    final TextEditingController newCategoryController = TextEditingController();
    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.4,
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
                        child: const Icon(Icons.category, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Manage Categories',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: newCategoryController,
                          style: GoogleFonts.poppins(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Add new category',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.white70,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
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
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = newCategoryController.text.trim();
                            if (name.isEmpty) return;
                            try {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .add({
                                    'name': name,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });
                              newCategoryController.clear();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            child: Text('Add'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('categories')
                              .orderBy('createdAt', descending: true)
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
                              'No categories yet',
                              style: GoogleFonts.poppins(color: Colors.white70),
                            ),
                          );
                        }
                        final docs = snapshot.data!.docs;
                        return ListView.separated(
                          controller: scrollController,
                          itemCount: docs.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final d = docs[index];
                            final name = (d['name'] ?? '').toString();
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: ListTile(
                                title: Text(
                                  name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (ctx) => AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF1A1A2E,
                                            ),
                                            title: Text(
                                              'Delete "$name"?',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      ctx,
                                                      false,
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      ctx,
                                                      true,
                                                    ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (ok == true) {
                                      await FirebaseFirestore.instance
                                          .collection('categories')
                                          .doc(d.id)
                                          .delete();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
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

  static Future<void> _openCreateOrEditDialog(
    BuildContext context, {
    DocumentSnapshot? doc,
  }) async {
    final title = TextEditingController(
      text: _safeGet(doc, 'title') ?? _safeGet(doc, 'Title'),
    );
    final description = TextEditingController(
      text: _safeGet(doc, 'description') ?? _safeGet(doc, 'Description'),
    );
    final category = TextEditingController(
      text: _safeGet(doc, 'industry') ?? _safeGet(doc, 'Industry'),
    );
    final salaryRange = TextEditingController(
      text: _safeGet(doc, 'salary_range') ?? _safeGet(doc, 'Salary_Range'),
    );
    final skills = TextEditingController(
      text:
          (doc != null &&
                  (doc.data() as Map<String, dynamic>)['skills'] is List)
              ? List<String>.from(
                (doc.data() as Map<String, dynamic>)['skills'],
              ).join(', ')
              : '',
    );

    await showDialog(
      context: context,
      builder: (ctx) {
        bool isSaving = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF667EEA),
                                      Color(0xFF764BA2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.business_center,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  doc == null ? 'Create Career' : 'Edit Career',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(
                            color: Colors.white.withOpacity(0.08),
                            height: 1,
                          ),
                          const SizedBox(height: 12),
                          _inputField(
                            controller: title,
                            label: 'Title *',
                            icon: Icons.title,
                          ),
                          const SizedBox(height: 10),
                          _inputField(
                            controller: description,
                            label: 'Description *',
                            icon: Icons.description,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          _inputField(
                            controller: category,
                            label: 'Category / Industry',
                            icon: Icons.category,
                          ),
                          const SizedBox(height: 10),
                          _inputField(
                            controller: salaryRange,
                            label: 'Salary Range',
                            icon: Icons.attach_money,
                          ),
                          const SizedBox(height: 10),
                          _inputField(
                            controller: skills,
                            label: 'Skills (comma separated)',
                            icon: Icons.psychology,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'Cancel',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF667EEA),
                                        Color(0xFF764BA2),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        isSaving
                                            ? null
                                            : () async {
                                              if (title.text.trim().isEmpty ||
                                                  description.text
                                                      .trim()
                                                      .isEmpty) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Title and Description are required',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              setState(() => isSaving = true);
                                              final data = {
                                                'title': title.text.trim(),
                                                'description':
                                                    description.text.trim(),
                                                'industry':
                                                    category.text.trim(),
                                                'salary_range':
                                                    salaryRange.text.trim(),
                                                'skills':
                                                    skills.text
                                                        .split(',')
                                                        .map((e) => e.trim())
                                                        .where(
                                                          (e) => e.isNotEmpty,
                                                        )
                                                        .toList(),
                                                'updatedAt':
                                                    FieldValue.serverTimestamp(),
                                              };
                                              try {
                                                if (doc == null) {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('careers')
                                                      .add({
                                                        ...data,
                                                        'createdAt':
                                                            FieldValue.serverTimestamp(),
                                                      });
                                                } else {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('careers')
                                                      .doc(doc.id)
                                                      .update(data);
                                                }
                                                if (Navigator.canPop(context)) {
                                                  Navigator.pop(context);
                                                }
                                              } catch (e) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Error: $e'),
                                                  ),
                                                );
                                              } finally {
                                                setState(
                                                  () => isSaving = false,
                                                );
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child:
                                        isSaving
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : Text(
                                              'Save',
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                              ),
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
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String? _safeGet(DocumentSnapshot? doc, String key) {
    if (doc == null) return null;
    final data = doc.data() as Map<String, dynamic>;
    if (!data.containsKey(key)) return null;
    final value = data[key];
    return value?.toString();
  }

  static Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }
}

class _CareersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const _CareersListStateful();
}

class _CareersListStateful extends StatefulWidget {
  const _CareersListStateful();

  @override
  State<_CareersListStateful> createState() => _CareersListState();
}

class _CareersListState extends State<_CareersListStateful> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortKey = 'created_desc';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isCreatedSort = _sortKey.startsWith('created_');
    final bool createdDesc = _sortKey.endsWith('desc');

    return Column(
      children: [
        _buildToolbar(context),
        const SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('careers').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading careers: ${snapshot.error}',
                    style: GoogleFonts.poppins(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF667EEA)),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No careers yet. Tap + to add.',
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                );
              }

              List<QueryDocumentSnapshot> docs = List.from(snapshot.data!.docs);

              if (_searchQuery.isNotEmpty) {
                docs =
                    docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final title =
                          (data['title'] ?? data['Title'] ?? '').toString();
                      final description =
                          (data['description'] ?? data['Description'] ?? '')
                              .toString();
                      final category =
                          (data['industry'] ?? data['Industry'] ?? '')
                              .toString();
                      final blob =
                          '$title $description $category'.toLowerCase();
                      return blob.contains(_searchQuery.toLowerCase());
                    }).toList();
              }

              // Category filter
              if (_selectedCategory != 'All') {
                docs =
                    docs.where((d) {
                      final data = d.data() as Map<String, dynamic>;
                      final category =
                          (data['industry'] ?? data['Industry'] ?? '')
                              .toString();
                      return category == _selectedCategory;
                    }).toList();
              }

              if (isCreatedSort) {
                docs.sort((a, b) {
                  final da = (a.data() as Map<String, dynamic>);
                  final db = (b.data() as Map<String, dynamic>);
                  final ta = da['createdAt'];
                  final tb = db['createdAt'];
                  final ma = (ta is Timestamp) ? ta.millisecondsSinceEpoch : 0;
                  final mb = (tb is Timestamp) ? tb.millisecondsSinceEpoch : 0;
                  return createdDesc ? (mb - ma) : (ma - mb);
                });
              } else {
                final bool titleDesc = _sortKey.endsWith('desc');
                docs.sort((a, b) {
                  final da = (a.data() as Map<String, dynamic>);
                  final db = (b.data() as Map<String, dynamic>);
                  final ta = (da['title'] ?? da['Title'] ?? '').toString();
                  final tb = (db['title'] ?? db['Title'] ?? '').toString();
                  final cmp = ta.toLowerCase().compareTo(tb.toLowerCase());
                  return titleDesc ? -cmp : cmp;
                });
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final title =
                      (data['title'] ?? data['Title'] ?? '').toString();
                  final category =
                      (data['industry'] ?? data['Industry'] ?? '').toString();
                  final salary =
                      (data['salary_range'] ?? data['Salary_Range'] ?? '')
                          .toString();
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        title.isEmpty ? '(Untitled)' : title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        [
                          category,
                          salary,
                        ].where((e) => e.isNotEmpty).join(' • '),
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed:
                                () => CareersAdminPage._openCreateOrEditDialog(
                                  context,
                                  doc: doc,
                                ),
                            icon: const Icon(Icons.edit, color: Colors.white70),
                            tooltip: 'Edit',
                          ),
                          IconButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xFF1A1A2E),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    title: Text(
                                      'Delete Career',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete "$title"?',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (confirm == true) {
                                await FirebaseFirestore.instance
                                    .collection('careers')
                                    .doc(doc.id)
                                    .delete();
                              }
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Delete',
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
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: GoogleFonts.poppins(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search careers...',
              hintStyle: GoogleFonts.poppins(color: Colors.white70),
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.08),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Categories dropdown (filters careers)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('categories')
                    .orderBy('name')
                    .snapshots(),
            builder: (context, snapshot) {
              final items = <DropdownMenuItem<String>>[
                const DropdownMenuItem(value: 'All', child: Text('All')),
              ];
              if (snapshot.hasData) {
                for (final d in snapshot.data!.docs) {
                  final name = (d['name'] ?? '').toString();
                  if (name.isEmpty) continue;
                  items.add(DropdownMenuItem(value: name, child: Text(name)));
                }
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF1A1A2E),
                  iconEnabledColor: Colors.white,
                  style: GoogleFonts.poppins(color: Colors.white),
                  onChanged:
                      (v) => setState(() => _selectedCategory = v ?? 'All'),
                  items: items,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _sortKey,
              dropdownColor: const Color(0xFF1A1A2E),
              iconEnabledColor: Colors.white,
              style: GoogleFonts.poppins(color: Colors.white),
              onChanged: (v) => setState(() => _sortKey = v ?? 'created_desc'),
              items: const [
                DropdownMenuItem(value: 'created_desc', child: Text('Newest')),
                DropdownMenuItem(value: 'created_asc', child: Text('Oldest')),
                DropdownMenuItem(value: 'title_asc', child: Text('Title A–Z')),
                DropdownMenuItem(value: 'title_desc', child: Text('Title Z–A')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
