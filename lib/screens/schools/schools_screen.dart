import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/add_classes_screen.dart';
import 'package:co2fzs_admin/screens/schools/add_schools_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/class_info.dart';
import 'package:co2fzs_admin/widgets/school_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SchoolsScreen extends StatefulWidget {
  static String routeName = "/classes";
  const SchoolsScreen({Key? key}) : super(key: key);

  @override
  State<SchoolsScreen> createState() => _SchoolsScreenState();
}

class _SchoolsScreenState extends State<SchoolsScreen> {
  bool _isLoading = false;

  bool _schoolLoaded = false;

  bool _contestLoaded = false;

  bool _routesLoaded = false;

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

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Alle Schulen"),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddSchoolsScreen(),
          ),
        ),
        child: Icon(Icons.add),
        backgroundColor: blueColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("admin").snapshots(),
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
            itemBuilder: (context, index) => SchoolInfo(
              snap: snapshot.data!.docs[index].data(),
            ),
          );
        },
      ),
    );
  }
}
