import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:co2fzs_admin/resources/auth_methods.dart';
import 'package:co2fzs_admin/responsive/mobile_screen_layout.dart';
import 'package:co2fzs_admin/responsive/responsive_layout_screen.dart';
import 'package:co2fzs_admin/responsive/web_screen_layout.dart';
import 'package:co2fzs_admin/screens/auth/signup_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void loginUser() async {
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().loginUser(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (res == "success") {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const ResponsiveLayout(
            webScreenLayout: WebScreenLayout(),
            mobileScreenLayout: MobileScreenLayout(),
          ),
        ),
      );
    } else {
      showSnackBar(context, res);
    }
  }

  void navigateToSignup() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SignupScreen(),
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
                Flexible(child: Container(), flex: 2),
                Image.asset(
                  "assets/images/logo.png",
                  height: 180,
                ),
                const SizedBox(height: 64),
                TextFieldInput(
                  hintText: "Nutzername",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _emailController,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Passwort",
                  textInputType: TextInputType.emailAddress,
                  textEditingController: _passwordController,
                  isPass: true,
                ),
                const SizedBox(height: 24),
                AuthButton(
                    onTap: loginUser,
                    label: "Einloggen",
                    isLoading: _isLoading),
                const SizedBox(height: 12),
                Flexible(child: Container(), flex: 2),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Container(
                //         child: const Text("Don't have an account? "),
                //         padding: const EdgeInsets.symmetric(vertical: 8)),
                //     GestureDetector(
                //       onTap: navigateToSignup,
                //       child: Container(
                //           child: const Text("Sign Up!",
                //               style: TextStyle(fontWeight: FontWeight.bold)),
                //           padding: const EdgeInsets.symmetric(vertical: 8)),
                //     )
                //   ],
                // )
              ],
            )),
      ),
    );
  }
}
