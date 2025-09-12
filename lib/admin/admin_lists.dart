import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'admin_home.dart';
import '../widgets/drawer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminHomePage()),
            );
          },
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Export CSV',
            icon: const Icon(Icons.download_outlined),
            onPressed: () async {
              final snap = await query.get();
              final buffer = StringBuffer();
              if (title == 'Testimonials') {
                buffer.writeln('name,story,createdAt');
                for (final d in snap.docs) {
                  final m = d.data() as Map<String, dynamic>;
                  buffer.writeln(
                    '"${(m['name'] ?? '').toString().replaceAll('"', '""')}","${(m['story'] ?? '').toString().replaceAll('"', '""')}",${(m['createdAt'] is Timestamp) ? (m['createdAt'] as Timestamp).toDate().toIso8601String() : ''}',
                  );
                }
              } else if (title == 'Feedback') {
                buffer.writeln('name,email,type,message,createdAt');
                for (final d in snap.docs) {
                  final m = d.data() as Map<String, dynamic>;
                  buffer.writeln(
                    '"${(m['name'] ?? '').toString().replaceAll('"', '""')}","${(m['email'] ?? '').toString().replaceAll('"', '""')}","${(m['type'] ?? '').toString().replaceAll('"', '""')}","${(m['message'] ?? '').toString().replaceAll('"', '""')}",${(m['createdAt'] is Timestamp) ? (m['createdAt'] as Timestamp).toDate().toIso8601String() : ''}',
                  );
                }
              } else {
                buffer.writeln('name,email,phone,message,createdAt');
                for (final d in snap.docs) {
                  final m = d.data() as Map<String, dynamic>;
                  buffer.writeln(
                    '"${(m['name'] ?? '').toString().replaceAll('"', '""')}","${(m['email'] ?? '').toString().replaceAll('"', '""')}","${(m['phone'] ?? '').toString().replaceAll('"', '""')}","${(m['message'] ?? '').toString().replaceAll('"', '""')}",${(m['createdAt'] is Timestamp) ? (m['createdAt'] as Timestamp).toDate().toIso8601String() : ''}',
                  );
                }
              }
              final csv = buffer.toString();
              await showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: Text(
                        'CSV Preview',
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      content: SingleChildScrollView(
                        child: SelectableText(
                          csv,
                          style: GoogleFonts.robotoMono(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: csv));
                            if (Navigator.canPop(ctx)) Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('CSV copied to clipboard'),
                              ),
                            );
                          },
                          child: const Text('Copy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(
            tooltip: 'Export PDF',
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              final snap = await query.get();
              final doc = pw.Document();
              doc.addPage(
                pw.MultiPage(
                  build: (ctx) {
                    final rows = <pw.Widget>[];
                    rows.add(
                      pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    );
                    rows.add(pw.SizedBox(height: 8));
                    for (final d in snap.docs) {
                      final m = d.data() as Map<String, dynamic>;
                      if (title == 'Testimonials') {
                        rows.add(
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                (m['name'] ?? '').toString(),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text((m['story'] ?? '').toString()),
                              pw.Divider(),
                            ],
                          ),
                        );
                      } else if (title == 'Feedback') {
                        rows.add(
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                ((m['name'] ?? '').toString() +
                                        ' • ' +
                                        (m['email'] ?? '').toString())
                                    .trim(),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                ((m['type'] ?? '').toString() +
                                        ' • ' +
                                        (m['message'] ?? '').toString())
                                    .trim(),
                              ),
                              pw.Divider(),
                            ],
                          ),
                        );
                      } else {
                        rows.add(
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                ((m['name'] ?? '').toString() +
                                        ' • ' +
                                        (m['email'] ?? '').toString())
                                    .trim(),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text((m['message'] ?? '').toString()),
                              pw.Divider(),
                            ],
                          ),
                        );
                      }
                    }
                    return rows;
                  },
                ),
              );
              final bytes = await doc.save();
              await FileSaver.instance.saveFile(
                name: '${title.toLowerCase().replaceAll(' ', '_')}.pdf',
                bytes: Uint8List.fromList(bytes),
                ext: 'pdf',
                mimeType: MimeType.pdf,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('PDF exported')));
            },
          ),
          IconButton(
            tooltip: 'Export DOC',
            icon: const Icon(Icons.description_outlined),
            onPressed: () async {
              final snap = await query.get();
              final buffer = StringBuffer();
              buffer.writeln(title);
              buffer.writeln('');
              for (final d in snap.docs) {
                final m = d.data() as Map<String, dynamic>;
                if (title == 'Testimonials') {
                  buffer.writeln((m['name'] ?? '').toString());
                  buffer.writeln((m['story'] ?? '').toString());
                } else if (title == 'Feedback') {
                  buffer.writeln(
                    ((m['name'] ?? '').toString() +
                            ' • ' +
                            (m['email'] ?? '').toString())
                        .trim(),
                  );
                  buffer.writeln(
                    ((m['type'] ?? '').toString() +
                            ' • ' +
                            (m['message'] ?? '').toString())
                        .trim(),
                  );
                } else {
                  buffer.writeln(
                    ((m['name'] ?? '').toString() +
                            ' • ' +
                            (m['email'] ?? '').toString())
                        .trim(),
                  );
                  buffer.writeln((m['message'] ?? '').toString());
                }
                buffer.writeln('');
              }
              final bytes = Uint8List.fromList(buffer.toString().codeUnits);
              await FileSaver.instance.saveFile(
                name: '${title.toLowerCase().replaceAll(' ', '_')}.doc',
                bytes: bytes,
                ext: 'doc',
                mimeType: MimeType.microsoftWord,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('DOC exported')));
            },
          ),
        ],
      ),
      body: Container(
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
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF667EEA)),
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
              itemBuilder: (context, index) => itemBuilder(docs[index]),
            );
          },
        ),
      ),
      bottomNavigationBar: _AdminBottomNav(current: title),
      drawer: AdminDrawer(
        onMenuItemSelected: (t) {
          if (t == 'Feedback Forms') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminFeedbackListPage()),
            );
          } else if (t == 'Contact Us') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const AdminInquiriesListPage()),
            );
          } else if (t == 'Testimonials/Success Carousel') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminTestimonialsListPage(),
              ),
            );
          } else if (t == 'Resources Hub') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomePage(initialIndex: 3),
              ),
            );
          } else if (t == 'Multimedia Guidance') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminHomePage(initialIndex: 3),
              ),
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

class _AdminBottomNav extends StatelessWidget {
  final String current;
  const _AdminBottomNav({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            currentIndex: 0,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            selectedItemColor: Colors.cyanAccent.shade200,
            unselectedItemColor: Colors.white70,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminHomePage()),
                );
              } else if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminHomePage(initialIndex: 1),
                  ),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminHomePage(initialIndex: 2),
                  ),
                );
              } else if (index == 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminHomePage(initialIndex: 3),
                  ),
                );
              } else if (index == 4) {
                Scaffold.of(context).openDrawer();
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.business_center_outlined),
                activeIcon: Icon(Icons.business_center),
                label: 'Careers',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.quiz_outlined),
                activeIcon: Icon(Icons.quiz),
                label: 'Quizzes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Content',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
