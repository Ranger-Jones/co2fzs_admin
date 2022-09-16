import 'package:co2fzs_admin/main.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/locations/add_location_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSchoolScreen extends StatefulWidget {
  final School school;
  EditSchoolScreen({Key? key, required this.school}) : super(key: key);

  @override
  State<EditSchoolScreen> createState() => _EditSchoolScreenState();
}

class _EditSchoolScreenState extends State<EditSchoolScreen> {
  bool _isLoading = false;
  bool _refreshisLoading = false;

  void deleteSchool(String schoolIdBlank) async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().deleteSchool(
      schoolIdBlank,
    );

    setState(() {
      _isLoading = false;
    });
    if (res != "success") {
      showSnackBar(context, res);
    } else {
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => MyApp()), (route) => false);
    }
  }

  void refreshSchool() async {
    String res = "Undefined Error";
    setState(() {
      _refreshisLoading = true;
    });
    Navigator.of(context).pop();
    try {
      res = await FirestoreMethods().refreshSchool(schoolID: widget.school.id);
      if (res == "Schule erfolgreich aktualisiert!") {
        Navigator.of(context).pop();
      }
    } catch (e) {
      res = e.toString();
    }
    setState(() {
      _refreshisLoading = false;
    });
    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Schule bearbeiten"),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 64),
              // TextFieldInput(
              //   hintText: "Klassen Name",
              //   textInputType: TextInputType.text,
              //   textEditingController: _classNameController,
              // ),
              // const SizedBox(height: 24),
              // TextFieldInput(
              //   hintText: "Anzahl der Schüler",
              //   textInputType: TextInputType.number,
              //   textEditingController: _classSizeController,
              // ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => areYouSafeAlert(
                    context: context,
                    onTap: refreshSchool,
                    text:
                        "Sind Sie sich wirklich sicher, dass Sie die Schule aktualisieren wollen. Die Punkte werden dadurch einmal neuberechnet. Achten Sie darauf, dass Sie vorher die Klassen aktualisiert haben um den vollen Effekt zu erzielen."),
                label: "Schule aktualisieren",
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => Navigator.pushNamed(
                    context, AddLocationScreen.routeName,
                    arguments: widget.school),
                label: "Orte hinzufügen",
              ),
              const SizedBox(height: 24),
              user.operationLevel == 4
                  ? AuthButton(
                      onTap: () {
                        deleteSchool(user.schoolIdBlank);
                      },
                      label: "Schule entfernen",
                      delete: true,
                    )
                  : SizedBox(height: 0),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
