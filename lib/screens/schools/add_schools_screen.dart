import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/screens/schools/schools_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddSchoolsScreen extends StatefulWidget {
  const AddSchoolsScreen({Key? key}) : super(key: key);

  @override
  State<AddSchoolsScreen> createState() => _AddSchoolsScreenState();
}

class _AddSchoolsScreenState extends State<AddSchoolsScreen> {
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _schoolIdController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _schoolNameController.dispose();
    _locationController.dispose();
    _schoolIdController.dispose();
  }

  void uploadSchool() async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().uploadSchool(
      _schoolNameController.text,
      int.parse(_schoolIdController.text),
      _locationController.text,
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
        title: Text("Schule hinzüfugen"),
    
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 64),
              TextFieldInput(
                hintText: "Name der Schule",
                textInputType: TextInputType.text,
                textEditingController: _schoolNameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Schul ID",
                textInputType: TextInputType.number,
                textEditingController: _schoolIdController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Adresse",
                textInputType: TextInputType.text,
                textEditingController: _locationController,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: uploadSchool,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text("Schule hinzufügen"),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                    color: blueColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
