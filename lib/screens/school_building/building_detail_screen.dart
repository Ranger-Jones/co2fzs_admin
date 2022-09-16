import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/class_info_screen.dart';
import 'package:co2fzs_admin/screens/school_building/edit_building_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/class_info.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingDetailScreen extends StatefulWidget {
  final SchoolBuilding schoolBuilding;
  const BuildingDetailScreen({Key? key, required this.schoolBuilding})
      : super(key: key);

  @override
  State<BuildingDetailScreen> createState() => _BuildingDetailScreenState();
}

class _BuildingDetailScreenState extends State<BuildingDetailScreen> {
  List<SchoolClass> classes = [];

  bool _classesLoaded = false;

  bool _isLoading = false;

  loadClasses(String schoolIdBlank) async {
    List<SchoolClass> _classes = [];
    setState(() {
      _isLoading = true;
    });
    print(widget.schoolBuilding.classes);
    try {
      _classes = await FirestoreMethods().catchClasses(
        schoolIdBlank: schoolIdBlank,
        classIds: widget.schoolBuilding.classes,
        context: context,
      );
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showSnackBar(context, e.toString());
      });
    }
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
      _classesLoaded = true;
      classes = _classes;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;

    if (!_classesLoaded || classes.isEmpty) {
      loadClasses(user.schoolIdBlank);
    }
    return Scaffold(
        appBar: AppBar(
            title: Text(
              "Info: ${widget.schoolBuilding.buildingName}",
            ),
            backgroundColor: primaryColor),
        floatingActionButton: user.operationLevel > 3
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditBuildingScreen(
                      schoolBuilding: widget.schoolBuilding,
                    ),
                  ),
                ),
                child: Icon(Icons.edit),
                backgroundColor: primaryColor,
              )
            : Container(),
        body: (!_isLoading ||
                classes.isEmpty ||
                classes.length < widget.schoolBuilding.classes.length)
            ? SingleChildScrollView(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      TableItem(
                        info: widget.schoolBuilding.buildingName,
                        label: "Name des Gebäudes",
                      ),
                      TableItem(
                        info: "${widget.schoolBuilding.users.length}",
                        label: "Schüler",
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Klassen",
                        style: Theme.of(context).textTheme.bodyText2!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 12),
                      ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: classes.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ClassInfoScreen(
                                snap: classes[index],
                              ),
                            ),
                          ),
                          child: ClassInfo(
                            snap: classes[index],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
