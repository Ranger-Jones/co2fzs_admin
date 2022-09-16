import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserChangeLocationScreen extends StatefulWidget {
  final User user;

  const UserChangeLocationScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  State<UserChangeLocationScreen> createState() =>
      _UserChangeLocationScreenState();
}

class _UserChangeLocationScreenState extends State<UserChangeLocationScreen> {
  bool _isLoading = false;
  bool _locationLoaded = false;
  bool _listLoading = true;
  bool _locationNotFound = false;
  bool _location2NotFound = false;
  bool _allLocationsLoaded = false;
  bool _updateUserLoading = false;
  bool _buildingsLoaded = false;

  Location location1 = Location.getEmptyLocation();
  Location location2 = Location.getEmptyLocation();

  int _locationLoadedAttempt = 0;
  int _location2LoadedAttempt = 0;

  List<Location> allSchoolLocations = [];
  List<Location> allSchoolLocationsWithNoSecondLivingPlace = [];

  SchoolBuilding? schoolBuilding;
  List<SchoolBuilding> schoolBuildings = [];

  String startAddress = "";
  String startAddress2 = "Kein zweiter Wohnort";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationLoadedAttempt = 0;
    _location2LoadedAttempt = 0;
  }

  void loadLocations() async {
    if (widget.user.role == "admin") {
      return;
    }

    var res = await FirestoreMethods().catchLocation(
      locationId: widget.user.homeAddress,
    );

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    print("LOCATIONRESULT: ${res}");

    if (_locationLoadedAttempt < 6) {
      if (res == "Undefined Error" || res is String) {
        // showSnackBar(context, res);
        _locationLoadedAttempt++;
        return loadLocations();
      } else {
        if (mounted) {
          setState(() {
            location1 = Location.fromSnap(res);
            startAddress = location1.id;
          });
        }
      }
    } else {
      setState(() {
        _locationNotFound = true;
        startAddress = "Kein zweiter Wohnort";
      });
    }

    if (_location2LoadedAttempt < 6) {
      if (widget.user.homeAddress2 != "") {
        var res = await FirestoreMethods().catchLocation(
          locationId: widget.user.homeAddress2,
        );
        if (res == "Undefined Error" || res is String) {
          showSnackBar(context, res);
          _location2LoadedAttempt++;
          return loadLocations();
        } else {
          if (mounted) {
            setState(() {
              location2 = Location.fromSnap(res);
              startAddress2 = location2.id;
            });
          }
        }
      }
    } else {
      setState(() {
        _location2NotFound = true;

        startAddress2 = "Kein zweiter Wohnort";
      });
    }
    if (mounted) {
      setState(() {
        _locationLoaded = true;
        _isLoading = false;
      });
    }
  }

  void loadAllLocations() async {
    List<Location> _allSchoolLocations = [];
    setState(() {
      _isLoading = true;
    });
    try {
      _allSchoolLocations = await FirestoreMethods().catchAllLocationsOfSchool(
          schoolID: schoolBuilding == null
              ? widget.user.schoolIdBlank
              : schoolBuilding!.id,
          context: context);
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    setState(() {
      allSchoolLocations = _allSchoolLocations;
      allSchoolLocationsWithNoSecondLivingPlace = _allSchoolLocations;
      allSchoolLocationsWithNoSecondLivingPlace
          .add(Location.noSecondLivingPlace());
      _isLoading = false;
      _allLocationsLoaded = true;
    });
  }

  void updateUserLocations() async {
    String res = "Undefined Error";

    setState(() {
      _updateUserLoading = true;
    });

    if (startAddress == "Kein zweiter Wohnort" || startAddress == "") {
      showSnackBar(
          context, "Wohnort 1 muss angegeben werden, Wohnort 2 ist optional");

      setState(() {
        _updateUserLoading = false;
      });
      return;
    }

    try {
      res = await FirestoreMethods().updateUserLocation(
        location1Id: startAddress,
        location2Id:
            startAddress2 == "Kein zweiter Wohnort" ? "" : startAddress2,
        uid: widget.user.uid,
      );
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      res = e.toString();
    }
    setState(() {
      _updateUserLoading = false;
    });
    showSnackBar(context, res);
  }

  loadSchoolBuildings(String schoolID, String classID) async {
    setState(() {
      _isLoading = true;
    });
    try {
      var res = await FirestoreMethods().catchBuildings(
        schoolIdBlank: schoolID,
      );

      if (res is String) {
        showSnackBar(context, res);
      } else {
        res.forEach(
          (element) => schoolBuildings.add(
            SchoolBuilding.fromSnap(element),
          ),
        );
        schoolBuildings.forEach((element) {
          if (element.classes.contains(classID)) {
            schoolBuilding = element;
          }
        });
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

  @override
  Widget build(BuildContext context) {
    User activeUser = Provider.of<UserProvider>(context).getUser;

    if (widget.user.role == "admin") {
      return Scaffold(
          appBar: AppBar(
        title: Text(
          "Admin Account",
        ),
        backgroundColor: primaryColor,
      ));
    }

    if (!_locationLoaded && (!_locationNotFound || !_location2NotFound)) {
      loadLocations();
    }

    if (!_allLocationsLoaded) {
      _isLoading = false;
    }

    if (!_buildingsLoaded) {
      loadSchoolBuildings(widget.user.schoolIdBlank, widget.user.classId);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Wohnort ändern von ${widget.user.firstname} ${widget.user.lastName[0] != "" ? widget.user.lastName[0] + "." : ""}",
        ),
        backgroundColor: primaryColor,
      ),
      body: !_isLoading
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Wohnort 1",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: startAddress,
                      icon:
                          const Icon(Icons.arrow_downward, color: primaryColor),
                      elevation: 16,
                      style: Theme.of(context).textTheme.bodyText2,
                      isExpanded: true,
                      alignment: Alignment.center,
                      underline: Container(
                        height: 2,
                        color: blueColor,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          startAddress = newValue!;
                        });
                      },
                      items: allSchoolLocations
                          .map<DropdownMenuItem<String>>((Location _location) {
                        return DropdownMenuItem<String>(
                          value: _location.id,
                          child: Text(_location.name),
                        );
                      }).toList(),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Divider(thickness: 2),
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Wohnort 2",
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<String>(
                      value: startAddress2,
                      icon:
                          const Icon(Icons.arrow_downward, color: primaryColor),
                      elevation: 16,
                      style: Theme.of(context).textTheme.bodyText2,
                      isExpanded: true,
                      alignment: Alignment.center,
                      underline: Container(
                        height: 2,
                        color: blueColor,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          startAddress2 = newValue!;
                        });
                      },
                      items: allSchoolLocationsWithNoSecondLivingPlace
                          .map<DropdownMenuItem<String>>((Location _location) {
                        return DropdownMenuItem<String>(
                          value: _location.id,
                          child: Text(_location.name),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    AuthButton(
                      onTap: updateUserLocations,
                      label: "Wohnorte aktualisieren",
                      isLoading: _updateUserLoading,
                    )
                  ]),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
