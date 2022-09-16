import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/add_classes_screen.dart';
import 'package:co2fzs_admin/screens/school_building/add_building_screen.dart';
import 'package:co2fzs_admin/screens/school_building/building_detail_screen.dart';
import 'package:co2fzs_admin/screens/schools/add_schools_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/building_info.dart';
import 'package:co2fzs_admin/widgets/class_info.dart';
import 'package:co2fzs_admin/widgets/school_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BuildingsScreen extends StatefulWidget {
  static String routeName = "/classes";
  const BuildingsScreen({Key? key}) : super(key: key);

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  bool _isLoading = false;

  bool _schoolLoaded = false;

  bool _contestLoaded = false;

  bool _routesLoaded = false;

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Alle Gebäude"),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddBuildingScreen(),
          ),
        ),
        child: Icon(Icons.add),
        backgroundColor: primaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("admin")
            .doc(user.schoolIdBlank)
            .collection("buildings")
            .snapshots(),
        builder: (
          context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == null) {
            return Center(child: Text("Keine Gebäude gefunden."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BuildingDetailScreen(
                    schoolBuilding:
                        SchoolBuilding.fromSnap(snapshot.data!.docs[index]),
                  ),
                ),
              ),
              child: BuildingInfo(
                schoolBuilding:
                    SchoolBuilding.fromSnap(snapshot.data!.docs[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}
