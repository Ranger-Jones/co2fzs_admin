import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/classes/add_classes_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/class_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassesScreen extends StatefulWidget {
  static String routeName = "/classes";
  const ClassesScreen({Key? key}) : super(key: key);

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  static String routeName = "/classes";
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
      // showSnackBar(context, res);
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
    User user = Provider.of<UserProvider>(context).getUser;
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
        title: Text("Klassen | ${school!.schoolname}"),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: user.operationLevel > 3
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddClassesScreen(),
                ),
              ),
              child: Icon(Icons.add),
              backgroundColor: primaryColor,
            )
          : Container(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("admin")
            .doc(school!.id)
            .collection("classes")
            .orderBy("name")
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
            itemBuilder: (context, index) => ClassInfo(
              snap: SchoolClass.fromSnap(snapshot.data!.docs[index]),
            ),
          );
        },
      ),
    );
  }
}
