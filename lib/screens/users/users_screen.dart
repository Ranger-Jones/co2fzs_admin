import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/users/user_detail_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/user_info.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  final School school;

  const UsersScreen({Key? key, required this.school}) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool _isLoading = false;
  bool _classesLoaded = false;
  bool _buildingsLoaded = false;
  bool _allLocationsLoaded = false;

  List<String> allSchoolLocations = [];
  List<String> allSchoolClasses = [];
  List<String> allBuildingLocations = [];

  SchoolBuilding? schoolBuilding;
  List<SchoolBuilding> schoolBuildings = [];
  List<dynamic> buildingClasses = [];

  loadClasses() async {
    List<SchoolClass> _classes = [];
    setState(() {
      _isLoading = true;
    });

    try {
      _classes = await FirestoreMethods().catchClasses(
        schoolIdBlank: widget.school.id,
        classIds: widget.school.classes,
        context: context,
      );
    } catch (e) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showSnackBar(context, e.toString());
      });
    }
    await Future.delayed(Duration(milliseconds: 1500));
    List<String> _classIds =
        _classes.map((_schoolClass) => _schoolClass.id).toList();
    _classIds.removeWhere((_schoolClassId) => _schoolClassId == "");
    print("KLASSEN ${_classIds}");
    setState(() {
      _isLoading = false;
      _classesLoaded = true;
      allSchoolClasses = _classIds;
    });
  }

  loadSchoolBuildings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await FirestoreMethods().catchBuildings(
        schoolIdBlank: widget.school.id,
      );

      if (res is String) {
        showSnackBar(context, res);
      } else {
        res.forEach(
          (element) => schoolBuildings.add(
            SchoolBuilding.fromSnap(element),
          ),
        );
        schoolBuildings
            .forEach((_building) => buildingClasses.addAll(_building.classes));
        loadAllLocations();
      }
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    setState(() {
      _isLoading = false;
      _buildingsLoaded = true;
    });
  }

  void loadAllLocations() async {
    List<Location> _allSchoolLocations = [];
    List<Location> _allBuildingLocations = [];
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      schoolBuildings.forEach((_building) async {
        List<Location> _location = await FirestoreMethods()
            .catchAllLocationsOfSchool(
                schoolID: _building.id, context: context);

        _allBuildingLocations.addAll(_location);
      });
      _allSchoolLocations = await FirestoreMethods().catchAllLocationsOfSchool(
          schoolID: widget.school.id, context: context);
    } catch (e) {
      showSnackBar(context, e.toString());
      return;
    }

    List<String> _buildingLocationIds =
        _allBuildingLocations.map((_location) => _location.id).toList();
    List<String> _schoolLocationIds =
        _allSchoolLocations.map((_location) => _location.id).toList();

    setState(() {
      allSchoolLocations = _schoolLocationIds;
      allBuildingLocations = _buildingLocationIds;

      _isLoading = false;
      _allLocationsLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_classesLoaded) {
      loadClasses();
    }

    if (!_buildingsLoaded) {
      loadSchoolBuildings();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text("User der Schule ${widget.school.schoolname}"),
          backgroundColor: primaryColor,
        ),
        body: (!_isLoading || !_allLocationsLoaded)
            ? Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("users")
                      .where(
                        "schoolIdBlank",
                        isEqualTo: widget.school.id,
                      )
                      .orderBy("lastName")
                      .snapshots(),
                  builder: (
                    context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          User _userInList =
                              User.fromSnap(snapshot.data!.docs[index]);

                          bool _isInOtherBuilding =
                              buildingClasses.contains(_userInList.classId);

                          bool _locationError = _isInOtherBuilding
                              ? !allBuildingLocations
                                  .contains(_userInList.homeAddress)
                              : !allSchoolLocations
                                  .contains(_userInList.homeAddress);
                          print("${_userInList.firstname} | ${_locationError}");
                          bool _warning = !(widget.school.classes
                                  .contains(_userInList.classId)) ||
                              _locationError;
                          try {
                            return InkWell(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => UserDetailScreen(
                                    user: _userInList,
                                  ),
                                ),
                              ),
                              child: _userInList.role != "admin"
                                  ? UserInfo(
                                      user: _userInList,
                                      color: _userInList.disqualified
                                          ? lightRed
                                          : (_userInList.activated
                                              ? secondaryColor
                                              : yellow),
                                      warning: _warning,
                                    )
                                  : UserInfo(
                                      user: _userInList,
                                      color: darkPurple,
                                    ),
                            );
                          } catch (e) {
                            return Text("Fehler beim Laden des Accounts");
                          }
                        });
                  },
                ),
              )
            : Center(child: CircularProgressIndicator()));
  }
}
