import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddLocationScreen extends StatefulWidget {
  final String buildingId;
  final String buildingName;

  AddLocationScreen({Key? key, this.buildingId = "", this.buildingName = ""})
      : super(key: key);
  static String routeName = "/add-location";

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  TextEditingController _locationController = TextEditingController();
  TextEditingController _distanceFromSchoolController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _locationController.dispose();
    _distanceFromSchoolController.dispose();
  }

  void uploadLocation(String schoolIdBlank) async {
    setState(() {
      _isLoading = true;
    });

    double distance = 0;

    try {
      distance = double.parse(_distanceFromSchoolController.text);
    } catch (e) {
      showSnackBar(context, e.toString());
      return;
    }

    String res = await FirestoreMethods().uploadLocation(
      _locationController.text,
      distance,
      widget.buildingId.isEmpty ? schoolIdBlank : widget.buildingId,
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
        title: Text("Ort/Stadt/Stadtteil hinzüfugen"),
        backgroundColor: primaryColor,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 64),
              widget.buildingName.isNotEmpty
                  ? Text(
                      "Dieser Ort wird zu '${widget.buildingName}' hinzugefügt",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    )
                  : Container(),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Name des Ortes/der Stadt/des Stadtteils",
                textInputType: TextInputType.text,
                textEditingController: _locationController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Distanz (5; 5.5)",
                textInputType: TextInputType.number,
                textEditingController: _distanceFromSchoolController,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => uploadLocation(user.schoolIdBlank),
                label: "Hochladen",
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
