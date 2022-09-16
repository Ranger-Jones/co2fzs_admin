import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/locations/add_location_screen.dart';
import 'package:co2fzs_admin/screens/locations/location_detail_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationsScreen extends StatefulWidget {
  final String buildingId;
  final String buildingName;
  const LocationsScreen(
      {Key? key, this.buildingId = "", this.buildingName = ""})
      : super(key: key);

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  bool _isLoading = false;
  bool _schoolLoaded = false;

  School? school;

  void loadSchool() async {
    User user = Provider.of<UserProvider>(context, listen: false).getUser;
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
      return loadSchool();
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
    if (!_schoolLoaded) {
      loadSchool();
    }

    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Orte | ${widget.buildingName.isEmpty ? school!.schoolname : widget.buildingName}",
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: user.operationLevel > 3
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddLocationScreen(
                    buildingId: widget.buildingId,
                    buildingName: widget.buildingName,
                  ),
                ),
              ),
              child: Icon(Icons.add),
              backgroundColor: primaryColor,
            )
          : Container(),
      body: !_isLoading
          ? SafeArea(
              child: Container(
                child: StreamBuilder(
                  stream: widget.buildingId.isEmpty
                      ? FirebaseFirestore.instance
                          .collection("locations")
                          .where("schoolIdBlank", isEqualTo: school!.id)
                          .orderBy("name")
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection("locations")
                          .where("schoolIdBlank", isEqualTo: widget.buildingId)
                          .orderBy("name")
                          .snapshots(),
                  builder: (
                    context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == null ||
                        snapshot.data!.docs.length == 0) {
                      return Center(
                        child: Text("Keine Orte gefunden!"),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      primary: false,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LocationDetailScreen(
                              location: Location.fromSnap(
                                snapshot.data!.docs[index],
                              ),
                            ),
                          ),
                        ),
                        child: TableItem(
                          label: snapshot.data!.docs[index]["name"],
                          info:
                              "${snapshot.data!.docs[index]["distanceFromSchool"]} km",
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
