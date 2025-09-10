import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/authentication.dart';
import '../services/validation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static const String routeName = '/LoginPage';

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
  bool isRegisterLoading = false;

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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Login - Page"),
        backgroundColor: Colors.grey[700],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/login_banner.jpeg"),
            fit: BoxFit.fill,
            opacity: 0.8,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 15,
                    margin: EdgeInsets.all(10),
                    color: Colors.white38,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: email_controller,
                            maxLength: 50,
                            decoration: const InputDecoration(
                              labelText: "Email",
                              hintText: "Enter Email",
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: validateEmail,
                            onSaved: (value) {
                              setState(() {
                                email = value;
                              });
                            },
                          ),

                          SizedBox(height: 10),

                          TextFormField(
                            obscureText: _isObscure,
                            controller: password_controller,
                            maxLength: 8,
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter Password",
                              prefixIcon: Icon(Icons.password_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                            ),
                            validator: validatePassword,
                            onSaved: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),

                          SizedBox(height: 20),

                          SizedBox(
                            child:
                                isLoginLoading
                                    ? Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    )
                                    : SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ElevatedButton(
                                        onPressed: _loginUser,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white54,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          "LOGIN",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 4,
                                          ),
                                        ),
                                      ),
                                    ),
                          ),

                          SizedBox(height: 10),

                          SizedBox(
                            child:
                            isRegisterLoading
                                ? Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                                : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                onPressed: _signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white54,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  "REGISTER",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
          context
        ).showSnackBar(SnackBar(content: Text("Login Successfully")));
        Navigator.pushReplacementNamed(context, "/HomePage");
      } else {
        ScaffoldMessenger.of(
          context
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    }
  }

  // y likna zaruri h h is k bd main function m wrna login nhi hoga

  // Future<void> main() async{
  //   WidgetsFlutterBinding.ensureInitialized();
  //   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //   runApp(MyApp());
  // }

  void _signupUser() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        isRegisterLoading = true;
      });

      var result = await AuthenticationHelper().signUp(
        email: email.toString(),
        password: password.toString(),
      );

      setState(() {
        isRegisterLoading = false;
      });

      if (result == null) {
        ScaffoldMessenger.of(
          context
        ).showSnackBar(SnackBar(content: Text("Registered Successfully")));
        clearData();
      } else {
        ScaffoldMessenger.of(
          context
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    }
  }


  void clearData(){
    email_controller.clear();
    password_controller.clear();
  }

}
