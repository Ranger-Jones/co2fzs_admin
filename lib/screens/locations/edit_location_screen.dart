import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/locations/locations_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditLocationScreen extends StatefulWidget {
  final Location location;
  EditLocationScreen({Key? key, required this.location}) : super(key: key);

  @override
  State<EditLocationScreen> createState() => _EditLocationScreenState();
}

class _EditLocationScreenState extends State<EditLocationScreen> {
  TextEditingController _locationNameController = TextEditingController();
  TextEditingController _locationDistanceController = TextEditingController();

  bool _isLoadingDelete = false;
  bool _isLoading = false;
  bool _isLoadingUpdate = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _locationNameController.text = widget.location.name;
    _locationDistanceController.text = "${widget.location.distanceFromSchool}";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _locationDistanceController.dispose();
    _locationNameController.dispose();
  }

  void deleteLocation(String locationId) async {
    String res = "Hoppala!";
    setState(() {
      _isLoadingDelete = true;
    });
    try {
      res = await FirestoreMethods().deleteLocation(
        locationID: locationId,
      );

      if (res == "Wohnort erfolgreich entfernt") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => LocationsScreen()),
            (route) => false);
      }
    } catch (e) {
      res = e.toString();
    }

    setState(() {
      _isLoadingDelete = false;
    });
    showSnackBar(context, res);
  }

  void updateLocation() async {
    String res = "Hoppala!";

    double distance = 0;

    try {
      distance = double.parse(_locationDistanceController.text);
    } catch (e) {
      showSnackBar(
          context, "Es sind nur Zahlen erlaubt im Format '5' oder '5.14'.");
      return;
    }
    setState(() {
      _isLoadingUpdate = true;
    });
    try {
      res = await FirestoreMethods().updateLocation(
        locationID: widget.location.id,
        distance: distance,
        name: _locationNameController.text,
      );

      if (res == "Erfolgreich aktualisiert") {
        Navigator.of(context).pop();
      }
    } catch (e) {
      res = e.toString();
    }

    setState(() {
      _isLoadingUpdate = false;
    });
    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
        appBar: AppBar(
          title: Text("Einstellungen zu ${widget.location.name}"),
          backgroundColor: primaryColor,
        ),
        body: SafeArea(
          child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFieldInput(
                    textEditingController: _locationNameController,
                    hintText: "Name des Wohnortes eingeben",
                    textInputType: TextInputType.text,
                  ),
                  SizedBox(height: 24),
                  TextFieldInput(
                    textEditingController: _locationDistanceController,
                    hintText: "Distanz zur Schule eingeben",
                    textInputType: TextInputType.number,
                  ),
                  SizedBox(height: 24),
                  user.operationLevel > 3
                      ? AuthButton(
                          onTap: updateLocation,
                          label: "Wohnort aktualisieren",
                          isLoading: _isLoading,
                        )
                      : Container(),
                  SizedBox(height: 24),
                  user.operationLevel > 3
                      ? AuthButton(
                          onTap: () => areYouSafeAlert(
                              context: context,
                              onTap: () => deleteLocation(widget.location.id),
                              text:
                                  'Sind Sie sich wirklich sicher, dass Sie diesen Wohnort löschen wollen? Dies könnte einige User vom Wettbewerb ausschließen.'),
                          label: "Wohnort löschen",
                          isLoading: _isLoading,
                          delete: true,
                        )
                      : Container(),
                ],
              )),
        ));
  }
}
