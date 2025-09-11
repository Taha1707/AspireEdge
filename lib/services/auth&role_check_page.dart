import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_home.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';


class Auth_Role_Check extends StatelessWidget {
  const Auth_Role_Check({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthRoleNavigator.navigateBasedOnRole(context, returnWidget: true),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data ?? const LoginPage(); // default fallback
      },
    );
  }
}


class AuthRoleNavigator {
  static Future<Widget?> navigateBasedOnRole(
      BuildContext context, {
        bool returnWidget = false,
      }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("🚫 No user found, navigating to LoginPage.");
      if (returnWidget) return const LoginPage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return null;
    }

    try {
      debugPrint("🔄 Fetching role for UID: ${user.uid}");

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      if (!doc.exists) {
        debugPrint("❌ No document found for UID: ${user.uid}");
      } else {
        debugPrint("✅ Document exists: ${doc.data()}");
      }

      final role = doc.data()?['role'];
      debugPrint("🎯 Final fetched role: $role");

      if (returnWidget) {
        return (role == 'admin')
            ? const AdminHomePage()
            : const HomePage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => (role == 'admin')
              ? const AdminHomePage()
              : const HomePage(),
        ),
      );

      return null;
    } catch (e, st) {
      debugPrint("🔥 Error fetching role: $e");
      debugPrint("Stack trace: $st");
      if (returnWidget) return const LoginPage();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return null;
    }
  }
}
