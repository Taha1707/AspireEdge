import 'package:auth_reset_pass/pages/home_page.dart';
import 'package:auth_reset_pass/pages/signup_page.dart';
import 'package:auth_reset_pass/services/auth&role_check_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';
import '../services/validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final email_controller = TextEditingController();
  final password_controller = TextEditingController();

  String? email = "";
  String? password = "";
  bool _isObscure = true;
  bool isLoginLoading = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        Future.delayed(Duration.zero, () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: SafeArea(
              child: Center(
                child: Form(
                  key: _formKey,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 26,
                              letterSpacing: 2,
                            ),
                          ),

                          SizedBox(height: 10),

                          Text(
                            "Please login to continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 25),

                          TextFormField(
                            controller: email_controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Email",
                              hintText: "Enter Email",
                              hintStyle: TextStyle(color: Colors.white70),
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.white,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            onSaved: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),

                          const SizedBox(height: 15),

                          TextFormField(
                            obscureText: _isObscure,
                            controller: password_controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter Password",
                              hintStyle: TextStyle(color: Colors.white70),
                              labelStyle: TextStyle(color: Colors.white),
                              prefixIcon: Icon(
                                Icons.password_outlined,
                                color: Colors.white,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white70),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: validatePassword,
                            onSaved: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 36,
                              child: TextButton(
                                onPressed: _forgotPassword,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Forgot password?",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.white70),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUpPage(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          isLoginLoading
                              ? const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              )
                              : Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2196F3),
                                      Color(0xFF0D47A1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                  onPressed: _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isLoginLoading = true;
      });

      var result = await AuthenticationHelper().signIn(
        email: email.toString(),
        password: password.toString(),
      );

      setState(() {
        isLoginLoading = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login Successfully")));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Auth_Role_Check()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(
      text: email_controller.text.trim(),
    );
    await showDialog(
      context: context,
      builder: (ctx) {
        bool sending = false;
        bool sent = false;
        String sentMessage = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE0E3EB),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Reset password",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),
                          sent
                              ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  sentMessage,
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                              )
                              : TextField(
                                controller: controller,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.black87),
                                decoration: InputDecoration(
                                  hintText: "Enter your email or user ID",
                                  hintStyle: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                  filled: true,
                                  fillColor: Color(0xFFF5F6FA),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                      color: Color(0xFFE0E3EB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF667EEA),
                                      width: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (!sent)
                                OutlinedButton(
                                  onPressed:
                                      sending ? null : () => Navigator.pop(ctx),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFFE0E3EB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    foregroundColor: Colors.black87,
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              if (!sent) const SizedBox(width: 8),
                              if (!sent)
                                ElevatedButton(
                                  onPressed:
                                      sending
                                          ? null
                                          : () async {
                                            final email =
                                                controller.text.trim();
                                            if (email.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Please enter email',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            setState(() => sending = true);
                                            try {
                                              // 1) Resolve email from input: allow either email or userId
                                              String? userId;
                                              String resolvedEmail = email;
                                              if (!resolvedEmail.contains(
                                                '@',
                                              )) {
                                                // treat input as userId and look up email in Firestore
                                                try {
                                                  final doc =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(resolvedEmail)
                                                          .get();
                                                  if (doc.exists) {
                                                    final data =
                                                        doc.data()
                                                            as Map<
                                                              String,
                                                              dynamic
                                                            >;
                                                    final mail =
                                                        (data['email'] ?? '')
                                                            .toString();
                                                    if (mail.isNotEmpty) {
                                                      resolvedEmail = mail;
                                                      userId = doc.id;
                                                    }
                                                  } else {
                                                    // fallback: search by "uid" field == input
                                                    final qs =
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .where(
                                                              'uid',
                                                              isEqualTo:
                                                                  resolvedEmail,
                                                            )
                                                            .limit(1)
                                                            .get();
                                                    if (qs.docs.isNotEmpty) {
                                                      final data =
                                                          qs.docs.first.data()
                                                              as Map<
                                                                String,
                                                                dynamic
                                                              >;
                                                      final mail =
                                                          (data['email'] ?? '')
                                                              .toString();
                                                      if (mail.isNotEmpty) {
                                                        resolvedEmail = mail;
                                                        userId =
                                                            qs.docs.first.id;
                                                      }
                                                    }
                                                  }
                                                } catch (_) {}
                                              } else {
                                                // input was an email; try to fetch userId (optional)
                                                try {
                                                  final qs =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .where(
                                                            'email',
                                                            isEqualTo:
                                                                resolvedEmail,
                                                          )
                                                          .limit(1)
                                                          .get();
                                                  if (qs.docs.isNotEmpty)
                                                    userId = qs.docs.first.id;
                                                } catch (_) {}
                                              }

                                              // 2) Send reset email (will throw if user not found)
                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(
                                                    email: resolvedEmail,
                                                  );

                                              if (!mounted) return;
                                              // 3) Show confirmation inside the dialog instead of closing
                                              final ref =
                                                  (100000 +
                                                          (DateTime.now()
                                                                  .millisecondsSinceEpoch %
                                                              899999))
                                                      .toString();
                                              final msg = StringBuffer(
                                                'Password reset email sent to ',
                                              );
                                              msg.write(resolvedEmail);
                                              if (userId != null) {
                                                msg.write(
                                                  ' (User ID: $userId)',
                                                );
                                              }
                                              msg.write(' • Ref: $ref');
                                              setState(() {
                                                sent = true;
                                                sentMessage = msg.toString();
                                              });
                                            } on FirebaseAuthException catch (
                                              e
                                            ) {
                                              if (e.code == 'user-not-found') {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'No account found for this email',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    e.message ??
                                                        'Failed to send reset email',
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              if (mounted)
                                                setState(() => sending = false);
                                            }
                                          },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667EEA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "Send",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              if (sent)
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667EEA),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Close',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
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
}
