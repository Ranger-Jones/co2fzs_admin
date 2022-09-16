import 'package:co2fzs_admin/models/contest.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditContestScreen extends StatefulWidget {
  final Contest contest;
  EditContestScreen({Key? key, required this.contest}) : super(key: key);

  @override
  State<EditContestScreen> createState() => _EditContestScreenState();
}

class _EditContestScreenState extends State<EditContestScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _classSizeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _classNameController.text = widget.schoolClass.name;
    // _classSizeController.text = "${widget.schoolClass.userCount}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _classNameController.dispose();
    _classSizeController.dispose();
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
                hintText: "Contest Name",
                textInputType: TextInputType.text,
                textEditingController: _classNameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Contest",
                textInputType: TextInputType.number,
                textEditingController: _classSizeController,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () {},
                label: "Contest aktualisieren",
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
