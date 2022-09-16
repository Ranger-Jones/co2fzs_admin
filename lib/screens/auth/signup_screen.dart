import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/screens/schools/add_schools_screen.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:co2fzs_admin/resources/auth_methods.dart';
import 'package:co2fzs_admin/responsive/mobile_screen_layout.dart';
import 'package:co2fzs_admin/responsive/responsive_layout_screen.dart';
import 'package:co2fzs_admin/responsive/web_screen_layout.dart';
import 'package:co2fzs_admin/screens/auth/login_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';

class SignupScreen extends StatefulWidget {
  SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _schulIdController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _schulIdController.dispose();
    _usernameController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void openAddScool() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddSchoolsScreen(),
      ),
    );
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String schoolId = _schulIdController.text;
    int schoolIdNumber = 0;

    if (!schoolId.contains(RegExp(r"[A-Z]"))) {
      schoolIdNumber = int.parse(schoolId);
    }

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      schoolId: schoolIdNumber,
      operationLevel: 1,
    );
    setState(() {
      _isLoading = false;
    });
    if (res != "success") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    }
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64),
                TextFieldInput(
                  hintText: "Username",
                  textInputType: TextInputType.text,
                  textEditingController: _usernameController,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Email",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Passwort",
                  textInputType: TextInputType.text,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Schul ID",
                  textInputType: TextInputType.number,
                  textEditingController: _schulIdController,
                ),
                const SizedBox(height: 24),
                AuthButton(onTap: signUpUser, label: "Registrieren"),
                const SizedBox(height: 12),
                Flexible(child: Container(), flex: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: const Text("Already have an account? "),
                        padding: const EdgeInsets.symmetric(vertical: 8)),
                    GestureDetector(
                      onTap: navigateToLogin,
                      child: Container(
                          child: const Text("Log In!",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          padding: const EdgeInsets.symmetric(vertical: 8)),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
