import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/screens/locations/add_location_screen.dart';
import 'package:co2fzs_admin/screens/locations/locations_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditBuildingScreen extends StatefulWidget {
  final SchoolBuilding schoolBuilding;
  EditBuildingScreen({Key? key, required this.schoolBuilding})
      : super(key: key);

  @override
  State<EditBuildingScreen> createState() => _EditBuildingScreenState();
}

class _EditBuildingScreenState extends State<EditBuildingScreen> {
  TextEditingController _buildingNameController = TextEditingController();
  TextEditingController _buildingLocationController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingDelete = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _buildingLocationController.text = widget.schoolBuilding.location;
    _buildingNameController.text = widget.schoolBuilding.buildingName;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _buildingNameController.dispose();
    _buildingLocationController.dispose();
  }

  void deleteBuilding() {}

  void updateBuilding() {}

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.schoolBuilding.buildingName + " bearbeiten",
        ),
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
                hintText: "Gebäude Name",
                textInputType: TextInputType.text,
                textEditingController: _buildingNameController,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hintText: "Adresse der Gebäudes",
                textInputType: TextInputType.number,
                textEditingController: _buildingLocationController,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => LocationsScreen(
                        buildingId: widget.schoolBuilding.id,
                        buildingName: widget.schoolBuilding.buildingName),
                  ),
                ),
                label: "Orte ansehen",
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              AuthButton(
                onTap: () => areYouSafeAlert(
                    context: context,
                    onTap: () => updateBuilding(),
                    text:
                        "Sind Sie sich wirklich sicher, dass Sie dieses Gebäude aktualisieren wollen?"),
                label: "Gebäude aktualisieren",
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
              user.operationLevel > 3
                  ? AuthButton(
                      onTap: () => areYouSafeAlert(
                          context: context,
                          onTap: () => deleteBuilding(),
                          text:
                              "Sind Sie sich sicher, dass Sie dieses Gebäude entfernen wollen. Jene Schüler welche sich noch in dem Gebäude befinden werden möglicherweise vom Wettbewerb ausgeschlossen."),
                      label: "Gebäude entfernen",
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
