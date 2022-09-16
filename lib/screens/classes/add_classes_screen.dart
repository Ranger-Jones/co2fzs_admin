import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddClassesScreen extends StatefulWidget {
  const AddClassesScreen({Key? key}) : super(key: key);

  @override
  State<AddClassesScreen> createState() => _AddClassesScreenState();
}

class _AddClassesScreenState extends State<AddClassesScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classSizeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _classNameController.dispose();
    _classSizeController.dispose();
  }

  void uploadClass(String schoolIdBlank) async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().uploadClass(
      _classNameController.text,
      schoolIdBlank,
      int.parse(_classSizeController.text),
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Klasse hinzüfugen"),
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
                onTap: () => uploadClass(user.schoolIdBlank),
                label: "Klasse hinzufügen",
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
