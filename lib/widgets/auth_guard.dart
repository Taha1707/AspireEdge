import 'package:Aspire_Edge/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return child;
    }
  }
}
