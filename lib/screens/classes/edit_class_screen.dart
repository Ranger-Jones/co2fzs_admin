import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/locations/add_location_screen.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditClassScreen extends StatefulWidget {
  final SchoolClass schoolClass;
  EditClassScreen({Key? key, required this.schoolClass}) : super(key: key);

  @override
  State<EditClassScreen> createState() => _EditClassScreenState();
}

class _EditClassScreenState extends State<EditClassScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classSizeController = TextEditingController();
  bool _isLoading = false;
  bool _isLoadingDelete = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _classNameController.text = widget.schoolClass.name;
    _classSizeController.text = "${widget.schoolClass.userCount}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _classNameController.dispose();
    _classSizeController.dispose();
  }

  void updateClass(String schoolIdBlank, String classId) async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().updateClass(
      _classNameController.text,
      schoolIdBlank,
      classId,
      int.parse(_classSizeController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      showSnackBar(context, "Klasse erfolgreich aktualisiert");
    }
  }

  void deleteClass(String schoolIdBlank, String classId) async {
    setState(() {
      _isLoadingDelete = true;
    });

    String res = await FirestoreMethods().deleteClass(
      schoolIdBlank,
      classId,
    );

    setState(() {
      _isLoadingDelete = false;
    });
    if (res != "Klasse erfolgreich entfernt") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Klasse ${widget.schoolClass.name} bearbeiten"),
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
                hintText: "Klassen Name",
                textInputType: TextInputType.text,
                textEditingController: _classNameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Anzahl der Schüler",
                textInputType: TextInputType.number,
                textEditingController: _classSizeController,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => areYouSafeAlert(
                    context: context,
                    onTap: () => updateClass(
                          widget.schoolClass.schoolIdBlank,
                          widget.schoolClass.id,
                        ),
                    text:
                        "Sind Sie sich wirklich sicher, dass Sie diese Klasse aktualisieren wollen?"),
                label: "Klasse aktualisieren",
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              user.operationLevel > 3
                  ? AuthButton(
                      onTap: () => areYouSafeAlert(
                          context: context,
                          onTap: () => deleteClass(
                                widget.schoolClass.schoolIdBlank,
                                widget.schoolClass.id,
                              ),
                          text:
                              "Sind Sie sich sicher, dass Sie diese Klasse entfernen wollen. Jene Schüler welche sich noch in der Klasse befinden werden möglicherweise vom Wettbewerb ausgeschlossen."),
                      label: "Klasse entfernen",
                      delete: true,
                      isLoading: _isLoadingDelete,
                    )
                  : Container(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
