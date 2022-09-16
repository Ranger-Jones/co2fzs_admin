import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/select_classes.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddBuildingScreen extends StatefulWidget {
  const AddBuildingScreen({Key? key}) : super(key: key);

  @override
  State<AddBuildingScreen> createState() => _AddBuildingScreenState();
}

class _AddBuildingScreenState extends State<AddBuildingScreen> {
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _buildingLocationController =
      TextEditingController();

  List<SchoolClass> classes = [];
  List<String> classIds = [];

  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _buildingNameController.dispose();
  }

  void uploadBuilding(String schoolIdBlank) async {
    setState(() {
      _isLoading = true;
    });

    String res = "Undefined Error";

    if (classes == null) {
      showSnackBar(context, "Bitte wähle mindestens eine Klasse aus!");
      return;
    }

    classIds = classes.map((e) => e.id).toList();

    if (_buildingNameController.text == "" ||
        _buildingLocationController.text == "") {
      showSnackBar(context, "Bitte fülle alle Felder aus!");
      return;
    }

    if (classIds.isEmpty) {
      showSnackBar(context, "Bitte wähle mindestens eine Klasse aus!");
      return;
    }

    print(classIds);
    // String res = "RES";
    try {
      res = await FirestoreMethods().uploadBuilding(
          name: _buildingNameController.text,
          schoolIdBlank: schoolIdBlank,
          classIds: classIds,
          location: _buildingLocationController.text);

      setState(() {
        _isLoading = false;
      });

      if (res == "success") {
        res = "Gebäude erfolgreich hinzugefügt";
        Navigator.of(context).pop();
      }
    } catch (e) {
      res != e.toString();
    }

    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Gebäude hinzüfugen"),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 64),
              TextFieldInput(
                hintText: "Name des Gebäudes",
                textInputType: TextInputType.text,
                textEditingController: _buildingNameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Adresse",
                textInputType: TextInputType.streetAddress,
                textEditingController: _buildingLocationController,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () async {
                  List<SchoolClass> _classes = await showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30)),
                    ),
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (_) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: SelectClasses(
                          schoolId: user.schoolIdBlank,
                        ),
                      );
                    },
                  );
                  print("KLASSEN AUSGEWÄHLT: ${_classes}");

                  setState(() {
                    classes = _classes;
                  });
                },
                label: "Klassen auswählen",
                color: secondaryColor,
              ),
              classes != null
                  ? (classes.isNotEmpty
                      ? Column(
                          children: [
                            Text(
                              "Ausgewählte Klassen",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Column(
                              children:
                                  classes.map((e) => Text(e.name)).toList(),
                            )
                          ],
                        )
                      : Text("Keine Klassen ausgewählt"))
                  : Text("Keine Klassen ausgewählt"),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => uploadBuilding(user.schoolIdBlank),
                label: "Gebäude hinzufügen",
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
