import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void resetAllUsers(BuildContext context) async {
    String res = "Undefined Error";
    try {
      await FirestoreMethods().resetAllUsers();
    } catch (e) {
      res = e.toString();
    }

    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen"),
          backgroundColor: primaryColor,
        ),
        body: SingleChildScrollView(
            child: Column(
          children: [
            BigButton(
              label: "Alle Nutzer und Schulen zurücksetzen",
              iconData: Icons.sports_martial_arts_sharp,
              onPressed: () => resetAllUsers(context),
            )
          ],
        )));
  }
}
