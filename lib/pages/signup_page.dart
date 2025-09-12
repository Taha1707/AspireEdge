import 'package:auth_reset_pass/pages/login_page.dart';
import 'package:auth_reset_pass/services/auth&role_check_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../services/validation.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final name_controller = TextEditingController();
  final email_controller = TextEditingController();
  final phone_controller = TextEditingController();


  String? name = "";
  String? email = "";
  String? password = "";
  String? phone = "";
  String? role = "user";
  String? tier;

  bool _isObscure = true;
  bool isRegisterLoading = false;

  final List<String> tierOptions = [
    "Class 8",
    "Matric",
    "Intermediate",
    "Professional"
  ];

  final password_controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4C1D95), Color(0xFF0EA5E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Foreground form
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 26,
                                letterSpacing: 2,
                              ),
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              "Create your account",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 25),



                            // Name
                            _buildTextField(
                              controller: name_controller,
                              label: "Name",
                              hint: "Enter Name",
                              validator: validateName,
                              icon: Icons.person_outline,
                              onSaved: (val) => name = val,
                            ),

                            const SizedBox(height: 15),

                            // Email
                            _buildTextField(
                              controller: email_controller,
                              label: "Email",
                              hint: "Enter Email",
                              icon: Icons.email_outlined,
                              validator: validateEmail,
                              onSaved: (val) => email = val,
                            ),


                            const SizedBox(height: 15),

                            // Phone
                            _buildTextField(
                              controller: phone_controller,
                              label: "Phone",
                              hint: "Enter Phone Number",
                              validator: validatePhoneNumber,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              onSaved: (val) => phone = val,
                            ),

                            const SizedBox(height: 15),

                            // Tier dropdown
                            DropdownButtonFormField<String>(
                              initialValue: tier,
                              dropdownColor: Colors.black87,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Tier",
                                prefixIcon: Icon(Icons.school_outlined),
                                prefixIconColor: Colors.white,
                                labelStyle:
                                const TextStyle(color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.white70),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: tierOptions.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style:
                                      const TextStyle(color: Colors.white, fontSize: 16)),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  tier = val;
                                });
                              },
                              validator: (val) =>
                              val == null ? "Please select tier" : null,
                            ),


                            const SizedBox(height: 10),




                            // Password
                            TextFormField(
                              controller: password_controller,
                              obscureText: _isObscure,
                              validator: validatePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: "Password",
                                hintText: "Enter Password",
                                hintStyle: const TextStyle(color: Colors.white70),
                                labelStyle: const TextStyle(color: Colors.white),
                                prefixIcon: const Icon(
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
                                  borderSide:
                                  const BorderSide(color: Colors.white70),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                  const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onSaved: (val) => password = val,
                            ),


                            const SizedBox(height: 10),


                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Already have an account? ",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                  },
                                  child: const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 25),

                            isRegisterLoading
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
                                onPressed: _signupUser,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "REGISTER",
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white),
        hintStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

// ...

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
        // ✅ Get current user
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          // ✅ Add user info into Firestore
          await FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .set({
            "userId": user.uid,
            "name": name,
            "email": email,
            "phone": phone,
            "tier": tier,
            "role": role,
            "createdAt": FieldValue.serverTimestamp(),
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registered Successfully")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Auth_Role_Check()),
        );

        clearData();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(result.toString())));
      }
    }
  }


  void clearData() {
    name_controller.clear();
    email_controller.clear();
    password_controller.clear();
    phone_controller.clear();
    tier = null;
  }
}
