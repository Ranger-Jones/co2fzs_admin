import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/main.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart' as model;
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/articles/articles_screen.dart';
import 'package:co2fzs_admin/screens/classes/classes_screen.dart';
import 'package:co2fzs_admin/screens/contest/contest_screen.dart';
import 'package:co2fzs_admin/screens/routes/routes_screen.dart';
import 'package:co2fzs_admin/screens/school_building/buildings_screen.dart';
import 'package:co2fzs_admin/screens/schools/edit_school_screen.dart';
import 'package:co2fzs_admin/screens/locations/locations_screen.dart';
import 'package:co2fzs_admin/screens/reports/reports_screen.dart';
import 'package:co2fzs_admin/screens/schools/schools_screen.dart';
import 'package:co2fzs_admin/screens/general/settings_screen.dart';
import 'package:co2fzs_admin/screens/users/users_screen.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:co2fzs_admin/widgets/iconInfo.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/post_card.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isLoading = false;
  bool _schoolLoaded = false;
  bool _contestLoaded = false;
  bool _routesLoaded = false;

  School? school;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void getSchool(String schoolId, School school) async {
    try {
      DocumentSnapshot snap = await FirebaseFirestore.instance
          .collection("admin")
          .doc(schoolId)
          .get();

      setState(() {
        school = School.fromSnap(snap);
        print(school.toJson());
      });
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void loadSchool() async {
    model.User user = Provider.of<UserProvider>(context, listen: false).getUser;
    setState(() {
      _isLoading = true;
    });
    var res = await FirestoreMethods().catchSchool(
      schoolId: user.schoolId,
    );
    if (res == "Undefined Error" ||
        res == "SchulID ist inkorrekt" ||
        res is String) {
      showSnackBar(context, res);
      loadSchool();
    } else {
      school = School.fromSnap(res);
      setState(() {
        _schoolLoaded = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    model.User user = Provider.of<UserProvider>(context).getUser;
    // if (schoolUpdated) {
    //   getSchool(school.id, school);
    //   setState(() {
    //     schoolUpdated = false;
    //   });
    // }
    // FirebaseAuth.instance.signOut();

    if (!_schoolLoaded) {
      loadSchool();
    }

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      floatingActionButton: user.operationLevel > 3
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditSchoolScreen(
                      school: school!,
                    ),
                  ),
                );
                loadSchool();
              },
              child: Icon(Icons.edit),
              backgroundColor: lightPurple,
            )
          : Container(),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 54,
              ),
              Text(
                school!.schoolname,
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              TableItem(
                  info: "${school!.users.length}",
                  label: "Registrierte Nutzer"),
              TableItem(
                  info: "${school!.classes.length}",
                  label: "Eingerichtete Klassen"),
              TableItem(
                  info: school!.totalPoints.toStringAsFixed(2),
                  label: "Punktzahl"),
              TableItem(
                  info: (school!.totalPoints / school!.users.length)
                      .toStringAsFixed(2),
                  label: "Durchschnittliche Punkte"),
              TableItem(info: school!.location, label: "Ort"),
              TableItem(info: "${school!.schoolId}", label: "Schul ID"),
              SizedBox(height: 24),
              BigButton(
                  label: "Klassen",
                  iconData: Icons.class_,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ClassesScreen(),
                      ),
                    );
                    print("pressed");
                  }),
              BigButton(
                  label: "Orte",
                  iconData: Icons.house,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LocationsScreen(),
                      ),
                    );
                  }),
              BigButton(
                  label: "User",
                  iconData: Icons.person,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UsersScreen(school: school!),
                      ),
                    );
                  }),
              BigButton(
                  label: "Einträge",
                  iconData: Icons.route,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoutesScreen(),
                      ),
                    );
                  }),
              BigButton(
                label: "Reports",
                iconData: Icons.report,
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ReportsScreen(),
                  ),
                ),
              ),
              (user.operationLevel == 3 || user.operationLevel == 5)
                  ? BigButton(
                      label: "Artikel",
                      iconData: Icons.article,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ArticlesScreen(),
                        ),
                      ),
                    )
                  : SizedBox(),
              user.operationLevel > 4
                  ? BigButton(
                      label: "Schulen",
                      iconData: Icons.school_sharp,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SchoolsScreen(),
                        ),
                      ),
                    )
                  : Container(),
              user.operationLevel > 3
                  ? BigButton(
                      label: "Gebäude",
                      iconData: Icons.house,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BuildingsScreen(),
                        ),
                      ),
                    )
                  : Container(),
              user.operationLevel > 4
                  ? BigButton(
                      label: "Wettbewerb Daten",
                      iconData: Icons.sports_martial_arts_sharp,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ContestScreen(),
                        ),
                      ),
                    )
                  : Container(),
              user.operationLevel > 4
                  ? BigButton(
                      label: "Einstellungen",
                      iconData: Icons.settings,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      ),
                    )
                  : Container(),
              BigButton(
                label: "Sign Out",
                iconData: Icons.logout,
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => MyApp()),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
