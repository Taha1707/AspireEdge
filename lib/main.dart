import 'package:auth_reset_pass/pages/home_page.dart';
import 'package:auth_reset_pass/pages/launching_page.dart';
import 'package:auth_reset_pass/pages/login_page.dart';
import 'package:auth_reset_pass/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ecommerce App",
      home: LaunchingPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: TextTheme(
          // bodyLarge: TextStyle(fontFamily: "font-1"),
          // bodyMedium: TextStyle(fontFamily: "font-1"),
          // bodySmall: TextStyle(fontFamily: "font-1"),
        ),
        appBarTheme: AppBarTheme(
          titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 24),
          iconTheme: IconThemeData(color: Colors.white, weight: 20, size: 26)
        ),
      ),
      initialRoute: "/LoginPage",
      routes: {
        PageRoutes.userHome : (context) => HomePage(),
        PageRoutes.userLogin : (context) => LoginPage(),
        PageRoutes.userLaunch : (context) => LaunchingPage(),
      },
    );
  }
}

