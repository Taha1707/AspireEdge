import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../widgets/auth_guard.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  String? uuid;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      setState(() {
        uuid = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
<<<<<<< HEAD
        drawer: UserDrawer(onMenuItemSelected: (String p1) {  },),
=======
>>>>>>> 446694636a11a3161c47114b46ce7a3f09d61dfe
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () async{
                await AuthenticationHelper().signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              icon: Icon(Icons.logout_outlined),
            )
          ],
          centerTitle: true,
          title: Text("Home - Page"),
          backgroundColor: Colors.grey[700],
        ),
        body: Container(
          color: Colors.grey[350],
          child: Center(
            child: Text("Coming Soon", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.grey[700]),),
          ),
        ),
      ),
    );
  }
}
