import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/models/route.dart' as model;
import 'package:co2fzs_admin/screens/users/user_options_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:co2fzs_admin/widgets/class_info.dart';
import 'package:co2fzs_admin/widgets/route_info.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  UserDetailScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = false;

  bool _classLoaded = false;
  bool _locationLoaded = false;

  bool _locationNotFound = false;
  bool _location2NotFound = false;

  bool _schoolClassNotFound = false;

  SchoolClass? schoolClass;

  Location location1 = Location.getEmptyLocation();
  Location location2 = Location.getEmptyLocation();

  int _locationLoadedAttempt = 0;
  int _location2LoadedAttempt = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _locationLoadedAttempt = 0;
    _location2LoadedAttempt = 0;
  }

  void loadClass(BuildContext context) async {
    if (widget.user.role == "admin") {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      var res = await FirestoreMethods().catchClass(
        schoolIdBlank: widget.user.schoolIdBlank,
        classId: widget.user.classId,
      );
      if (res is String) {
        showSnackBar(context, res);
        return loadClass(context);
      } else {
        if (res != null) {
          schoolClass = SchoolClass.fromSnap(res);
        } else {
          if (mounted) {
            setState(() {
              _schoolClassNotFound = true;
            });
          }
        }
      }
    } catch (e) {
      showSnackBar(context, "Fehler beim laden der Klasse");
      if (mounted) {
        setState(() {
          _schoolClassNotFound = true;
          _classLoaded = true;
          _isLoading = false;
        });
      }
    }

    if (mounted) {
      setState(() {
        _classLoaded = true;
        _isLoading = false;
      });
    }
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
          });
        }
      }
    } else {
      setState(() {
        _locationNotFound = true;
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
            });
          }
        }
      }
    } else {
      setState(() {
        _location2NotFound = true;
      });
    }
    if (mounted) {
      setState(() {
        _locationLoaded = true;
        _isLoading = false;
      });
    }
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

    if (!_classLoaded && !_schoolClassNotFound) {
      loadClass(context);
    }

    if (!_locationLoaded && (!_locationNotFound || !_location2NotFound)) {
      loadLocations();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Informationen über ${widget.user.firstname} ${widget.user.lastName[0] != "" ? widget.user.lastName[0] + "." : ""}",
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: activeUser.operationLevel > 3
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => UserOptionsScreen(user: widget.user)),
              ),
              child: Icon(Icons.edit),
              backgroundColor: primaryColor,
            )
          : Container(),
      body: !_isLoading
          ? SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    TableItem(
                        info:
                            "${widget.user.firstname} ${widget.user.lastName}",
                        label: "Name"),
                    TableItem(info: widget.user.email, label: "Email"),
                    TableItem(
                        info: !_schoolClassNotFound
                            ? schoolClass!.name
                            : "Klasse nicht gefunden",
                        label: "Klasse"),
                    TableItem(
                      info: !widget.user.disqualified
                          ? (widget.user.activated
                              ? "Account aktiviert"
                              : "Account nicht aktiviert ")
                          : "Account disqualifiziert",
                      label: "Status",
                    ),
                    TableItem(
                        info: "${widget.user.totalPoints}", label: "Punkte"),
                    TableItem(info: widget.user.username, label: "Username"),
                    TableItem(
                        info: location1.name != ""
                            ? location1.name
                            : "Wohnort nicht vorhanden",
                        label: "Wohnort 1"),
                    TableItem(
                        info: location2.name != ""
                            ? location2.name
                            : "Wohnort nicht vorhanden",
                        label: "Wohnort 2"),
                    SizedBox(height: 24),
                    Text("Einträge",
                        style: Theme.of(context).textTheme.headline3),
                    SizedBox(height: 24),
                    StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .doc(widget.user.uid)
                          .collection("routes")
                          .orderBy("date")
                          .snapshots(),
                      builder: (
                        context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          itemCount: snapshot.data!.docs.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => RouteInfo(
                            route: model.Route.fromSnap(
                                snapshot.data!.docs[index]),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
