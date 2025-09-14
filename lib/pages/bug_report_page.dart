import 'package:Aspire_Edge/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BugReportPage extends StatefulWidget {
  const BugReportPage({super.key});

  @override
  State<BugReportPage> createState() => _BugReportPageState();
}

class _BugReportPageState extends State<BugReportPage> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bugTitleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _priority = 'Medium';
  String _frequency = 'Sometimes';
  bool _submitting = false;
  bool _isLoading = false;
  DateTime _reportDateTime = DateTime.now();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Bug type checkboxes
  bool _textOverflow = false;
  bool _unresponsiveLayout = false;
  bool _buttonIconIssues = false;
  bool _navigationGlitches = false;
  bool _scrollProblems = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _prefillFromFirebase();
    _animationController.forward();
  }

  Future<void> _prefillFromFirebase() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = doc.data();

        _nameController.text = (data != null && (data['name'] ?? '').toString().trim().isNotEmpty)
            ? data['name'] as String
            : (user.displayName ?? '');
        _emailController.text = (data != null && (data['email'] ?? '').toString().trim().isNotEmpty)
            ? data['email'] as String
            : (user.email ?? '');
        _phoneController.text = (data != null && (data['phone'] ?? '').toString().trim().isNotEmpty)
            ? data['phone'] as String
            : (user.phoneNumber ?? '');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user data: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bugTitleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> _getSelectedBugTypes() {
    List<String> selectedTypes = [];
    if (_textOverflow) selectedTypes.add('Text Overflow');
    if (_unresponsiveLayout) selectedTypes.add('Unresponsive Layout');
    if (_buttonIconIssues) selectedTypes.add('Button/Icon Issues');
    if (_navigationGlitches) selectedTypes.add('Navigation Glitches');
    if (_scrollProblems) selectedTypes.add('Scroll Problems');
    return selectedTypes;
  }

  Future<void> _submitBugReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('bug_reports').add({
        'userId': user?.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'bugTitle': _bugTitleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'priority': _priority,
        'bugTypes': _getSelectedBugTypes(),
        'frequency': _frequency,
        'reportDateTime': _reportDateTime.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bug report submitted successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
      
      // Clear form
      _bugTitleController.clear();
      _descriptionController.clear();
      setState(() {
        _textOverflow = false;
        _unresponsiveLayout = false;
        _buttonIconIssues = false;
        _navigationGlitches = false;
        _scrollProblems = false;
        _priority = 'Medium';
        _frequency = 'Sometimes';
        _reportDateTime = DateTime.now();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            child: _isLoading
                ? _buildLoadingScreen()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            const SizedBox(height: 12),
                            _buildIntroCard(),
                            const SizedBox(height: 12),
                            _buildFormCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667EEA)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Loading Bug Report Form...',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bug Report',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Help us improve by reporting issues',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(Icons.bug_report, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  Widget _cardDecoration({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildIntroCard() {
    return _cardDecoration(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double titleSize = w >= 900
              ? 26
              : w >= 600
                  ? 22
                  : w >= 360
                      ? 18
                      : 16;
          final double bodySize = w >= 900
              ? 16
              : w >= 600
                  ? 15
                  : 14;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Report a Bug',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Found an issue? Help us fix it by providing detailed information about the bug.',
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: bodySize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return _cardDecoration(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _field(controller: _nameController, label: 'Name', icon: Icons.person_outline, readOnly: true),
            const SizedBox(height: 12),
            _field(controller: _emailController, label: 'Email', icon: Icons.email_outlined, readOnly: true, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            _field(controller: _phoneController, label: 'Contact Number', icon: Icons.phone_outlined, readOnly: true, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _field(
              controller: _bugTitleController,
              label: 'Bug Title',
              icon: Icons.title,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a bug title' : null,
            ),
            const SizedBox(height: 12),
            _field(
              controller: _descriptionController,
              label: 'Short Description',
              icon: Icons.description_outlined,
              maxLines: 3,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a description' : null,
            ),
            const SizedBox(height: 12),
            _prioritySelector(),
            const SizedBox(height: 12),
            _bugTypesSelector(),
            const SizedBox(height: 12),
            _frequencySelector(),
            const SizedBox(height: 12),
            _dateTimeDisplay(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submitBugReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text('Submit Bug Report', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prioritySelector() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Priority',
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF121212),
          value: _priority,
          items: const [
            DropdownMenuItem(value: 'Low', child: Text('Low')),
            DropdownMenuItem(value: 'Medium', child: Text('Medium')),
            DropdownMenuItem(value: 'High', child: Text('High')),
          ],
          onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _bugTypesSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bug Types (Select all that apply)',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildCheckbox('Text Overflow', _textOverflow, (value) => setState(() => _textOverflow = value!)),
          _buildCheckbox('Unresponsive Layout', _unresponsiveLayout, (value) => setState(() => _unresponsiveLayout = value!)),
          _buildCheckbox('Button/Icon Issues', _buttonIconIssues, (value) => setState(() => _buttonIconIssues = value!)),
          _buildCheckbox('Navigation Glitches', _navigationGlitches, (value) => setState(() => _navigationGlitches = value!)),
          _buildCheckbox('Scroll Problems', _scrollProblems, (value) => setState(() => _scrollProblems = value!)),
        ],
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF667EEA),
      checkColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _frequencySelector() {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Frequency',
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF121212),
          value: _frequency,
          items: const [
            DropdownMenuItem(value: 'Always', child: Text('Always')),
            DropdownMenuItem(value: 'Sometimes', child: Text('Sometimes')),
          ],
          onChanged: (v) => setState(() => _frequency = v ?? 'Sometimes'),
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
    );
  }

  Widget _dateTimeDisplay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Date & Time',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_reportDateTime.day}/${_reportDateTime.month}/${_reportDateTime.year} at ${_reportDateTime.hour.toString().padLeft(2, '0')}:${_reportDateTime.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _reportDateTime = DateTime.now();
              });
            },
            icon: Icon(Icons.refresh, color: Colors.white70, size: 20),
            tooltip: 'Update to current time',
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      style: GoogleFonts.poppins(color: readOnly ? Colors.white70 : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: readOnly ? const Icon(Icons.lock_outline, color: Colors.white54, size: 18) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF667EEA)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}
