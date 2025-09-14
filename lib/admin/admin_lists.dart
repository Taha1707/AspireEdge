import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'admin_home.dart';
import '../widgets/drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'bug_reports_page.dart';

class AdminTestimonialsListPage extends StatelessWidget {
  const AdminTestimonialsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('testimonials')
        .orderBy('createdAt', descending: true);
    return _AdminListScaffold(
      title: 'Testimonials',
      query: query,
      stream: query.snapshots(),
      itemBuilder: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? 'Anonymous').toString();
        final story = (data['story'] ?? '').toString();
        final imageRaw =
            (data['imageUrl'] ?? data['image'] ?? data['photo'] ?? '')
                .toString();
        final createdAt = data['createdAt'];
        final approved = (data['approved'] == true);
        return _AdminListTile(
          title: name,
          subtitle: story,
          leading: TestimonialAvatar(imageRaw: imageRaw, fallbackName: name),
          createdAt: createdAt,
          actions: [
            if (!approved)
              IconButton(
                tooltip: 'Approve',
                onPressed: () async {
                  await doc.reference.update({'approved': true});
                },
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.lightGreenAccent,
                ),
              ),
          ],
          onDelete: () async {
            await doc.reference.delete();
          },
        );
      },
    );
  }
}

Widget _avatar(String imageUrl, String name) {
  final String initial = (name.isNotEmpty ? name[0] : '?').toUpperCase();
  if (imageUrl.isNotEmpty) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF667EEA),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      ),
    );
  }
  return CircleAvatar(
    radius: 24,
    backgroundColor: const Color(0xFF667EEA),
    child: Text(
      initial,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  );
}

class TestimonialAvatar extends StatefulWidget {
  final String imageRaw;
  final String fallbackName;
  const TestimonialAvatar({
    super.key,
    required this.imageRaw,
    required this.fallbackName,
  });

  @override
  State<TestimonialAvatar> createState() => _TestimonialAvatarState();
}

class _TestimonialAvatarState extends State<TestimonialAvatar> {
  String? downloadUrl;
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  Future<void> _resolveUrl() async {
    final raw = widget.imageRaw;
    if (raw.isEmpty) return;
    try {
      if (raw.startsWith('data:image')) {
        final comma = raw.indexOf(',');
        final dataPart = comma != -1 ? raw.substring(comma + 1) : raw;
        final bytes = base64Decode(dataPart);
        if (mounted) setState(() => imageBytes = bytes);
      } else if (RegExp(r'^[A-Za-z0-9+/=\r\n]+$').hasMatch(raw) &&
          raw.length > 100) {
        final normalized = raw.replaceAll('\n', '').replaceAll('\r', '');
        final bytes = base64Decode(normalized);
        if (mounted) setState(() => imageBytes = bytes);
      } else if (raw.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(raw);
        final url = await ref.getDownloadURL();
        if (mounted) setState(() => downloadUrl = url);
      } else {
        if (mounted) setState(() => downloadUrl = raw);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          downloadUrl = null;
          imageBytes = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF667EEA),
        child: ClipOval(
          child: Image.memory(
            imageBytes!,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    if (downloadUrl == null) {
      return _avatar('', widget.fallbackName);
    }
    return _avatar(downloadUrl!, widget.fallbackName);
  }
}

class AdminFeedbackListPage extends StatelessWidget {
  const AdminFeedbackListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('feedback')
        .orderBy('createdAt', descending: true);
    return _AdminListScaffold(
      title: 'Feedback',
      query: query,
      stream: query.snapshots(),
      itemBuilder: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        final type = (data['type'] ?? '').toString();
        final message = (data['message'] ?? '').toString();
        final createdAt = data['createdAt'];
        final title = name.isNotEmpty ? '$name • $type' : type;
        final subtitle = email.isNotEmpty ? '$email • $message' : message;
        final resolved = (data['resolved'] == true);
        return _AdminListTile(
          title: title,
          subtitle: subtitle,
          createdAt: createdAt,
          actions: [
            if (!resolved)
              IconButton(
                tooltip: 'Mark resolved',
                onPressed: () async {
                  await doc.reference.update({'resolved': true});
                },
                icon: const Icon(Icons.done_all, color: Colors.cyanAccent),
              ),
          ],
          onDelete: () async {
            await doc.reference.delete();
          },
        );
      },
    );
  }
}

class AdminInquiriesListPage extends StatelessWidget {
  const AdminInquiriesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('inquiries')
        .orderBy('createdAt', descending: true);
    return _AdminListScaffold(
      title: 'Contact Inquiries',
      query: query,
      stream: query.snapshots(),
      itemBuilder: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        final phone = (data['phone'] ?? '').toString();
        final message = (data['message'] ?? '').toString();
        final createdAt = data['createdAt'];
        final title = name.isNotEmpty ? name : email;
        final subtitle = [email, phone].where((e) => e.isNotEmpty).join(' • ');
        final details = message;
        final handled = (data['handled'] == true);
        return _AdminListTile(
          title: title,
          subtitle: subtitle,
          extra: details,
          createdAt: createdAt,
          actions: [
            if (!handled)
              IconButton(
                tooltip: 'Mark handled',
                onPressed: () async {
                  await doc.reference.update({'handled': true});
                },
                icon: const Icon(
                  Icons.task_alt,
                  color: Colors.lightGreenAccent,
                ),
              ),
          ],
          onDelete: () async {
            await doc.reference.delete();
          },
        );
      },
    );
  }
}

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection('users')
        .orderBy('email');
    return _AdminListScaffold(
      title: 'Users',
      query: query,
      stream: query.snapshots(),
      itemBuilder: (doc) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['name'] ?? '').toString();
        final email = (data['email'] ?? '').toString();
        final active = (data['active'] == true);
        final role = (data['role'] ?? '').toString();
        final photoUrl = (data['photoUrl'] ?? '').toString();
        final title = name.isEmpty ? email : name;
        final subtitle = [email, role].where((e) => e.isNotEmpty).join(' • ');
        return _AdminListTile(
          title: title,
          subtitle: subtitle,
          leading: _avatar(photoUrl, title),
          createdAt: data['createdAt'],
          actions: [
            IconButton(
              tooltip: active ? 'Mark inactive' : 'Mark active',
              onPressed: () async {
                await doc.reference.update({'active': !active});
              },
              icon: Icon(
                active ? Icons.toggle_on : Icons.toggle_off,
                color: active ? Colors.lightGreenAccent : Colors.white70,
              ),
            ),
            if (role != 'admin')
              IconButton(
                tooltip: 'Make admin',
                onPressed: () async {
                  await doc.reference.update({'role': 'admin'});
                },
                icon: const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.cyanAccent,
                ),
              ),
          ],
          onDelete: () async {
            // Optionally also delete auth user if needed
            await doc.reference.delete();
          },
        );
      },
    );
  }
}

class _AdminListScaffold extends StatelessWidget {
  final String title;
  final Query query;
  final Stream<QuerySnapshot> stream;
  final Widget Function(QueryDocumentSnapshot doc) itemBuilder;

  const _AdminListScaffold({
    required this.title,
    required this.query,
    required this.stream,
    required this.itemBuilder,
  });

  String _getSubtitle(String title) {
    switch (title) {
      case 'Testimonials':
        return 'Manage user success stories and testimonials';
      case 'Feedback':
        return 'Review and respond to user feedback';
      case 'Contact Inquiries':
        return 'Handle contact form submissions';
      case 'Users':
        return 'Manage user accounts and permissions';
      default:
        return 'Admin management panel';
    }
  }

  IconData _getIcon(String title) {
    switch (title) {
      case 'Testimonials':
        return Icons.people;
      case 'Feedback':
        return Icons.feedback;
      case 'Contact Inquiries':
        return Icons.contact_mail;
      case 'Users':
        return Icons.group;
      default:
        return Icons.admin_panel_settings;
    }
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
          IconButton(
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHomePage()),
                ),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  _getSubtitle(title),
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
            child: Icon(_getIcon(title), color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

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
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF667EEA),
                          ),
                        );
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No records found',
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                        );
                      }
                      final docs = snapshot.data!.docs;
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder:
                            (context, index) => itemBuilder(docs[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: AdminDrawer(
        onMenuItemSelected: (t) {
          if (t == 'Careers') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomePage(initialIndex: 1),
              ),
            );
          } else if (t == 'Quizzes') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomePage(initialIndex: 2),
              ),
            );
          } else if (t == 'Testimonials/Success Carousel') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminTestimonialsListPage(),
              ),
            );
          } else if (t == 'Feedback Forms') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminFeedbackListPage()),
            );
          } else if (t == 'Contact Us') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminInquiriesListPage()),
            );
          } else if (t == 'Bug Reports') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BugReportsPage()),
            );
          }
        },
      ),
    );
  }
}

class _AdminListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? extra;
  final dynamic createdAt;
  final VoidCallback onDelete;
  final List<Widget>? actions;
  final Widget? leading;

  const _AdminListTile({
    required this.title,
    required this.subtitle,
    this.extra,
    required this.createdAt,
    required this.onDelete,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? ts;
    if (createdAt is Timestamp) ts = (createdAt as Timestamp).toDate();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
            ),
            if (extra != null && extra!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                extra!,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
              ),
            ],
            if (ts != null) ...[
              const SizedBox(height: 6),
              Text(
                ts.toLocal().toString(),
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (actions != null) ...actions!,
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
          ],
        ),
      ),
    );
  }
}
