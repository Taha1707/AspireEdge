import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/auth_guard.dart';

class LaunchingPage extends StatefulWidget {
  const LaunchingPage({super.key});
  static const String routeName = '/LaunchingPage';

  @override
  State<LaunchingPage> createState() => _LaunchingPageState();
}

class _LaunchingPageState extends State<LaunchingPage> {

  // agr dubara load karny k bd login page chaiye to ye code chalao

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      setState(() {
        Future.delayed(Duration.zero, () async{
          Navigator.pushReplacementNamed(context, "/HomePage");
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Mobile friendly check
    final isMobile = screenWidth < 650;

    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Welcome  to  Watch-Hub"),
          backgroundColor: Colors.grey[700],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 40, 20, 20),
          child: isMobile
              ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 220,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/launching_banner.jpg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 20),
      
              Text(
                "Welcome to Watch Hub — your gateway to timeless elegance and precision. Discover a curated selection of premium watches, from classic heritage designs to modern masterpieces, all in one place. Whether you're a collector or a first-time buyer, our platform is designed to give you the best experience in style and functionality. To begin your journey and unlock the full features of Watch Hub, please log in and explore what awaits you.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
      
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, "/LoginPage");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white54,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "LOGIN NOW",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 4,
                    ),
                  ),
                ),
              ),
            ],
          )
              : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 280,
                width: 400,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/launching_banner.jpg"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(width: 30),
      
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome to Watch Hub — your gateway to timeless elegance and precision. Discover a curated selection of premium watches, from classic heritage designs to modern masterpieces, all in one place. Whether you're a collector or a first-time buyer, our platform is designed to give you the best experience in style and functionality. To begin your journey and unlock the full features of Watch Hub, please log in and explore what awaits you.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(height: 20),
      
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, "/LoginPage");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white54,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          "LOGIN NOW",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
