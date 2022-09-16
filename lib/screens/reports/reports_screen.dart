import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reports"),
        backgroundColor: primaryColor,
      ),
      body: Text(
        "Reports stehen hier",
      ),
    );
  }
}
