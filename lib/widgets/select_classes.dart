import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:flutter/material.dart';

class SelectClasses extends StatefulWidget {
  final String schoolId;
  SelectClasses({Key? key, required this.schoolId}) : super(key: key);

  @override
  State<SelectClasses> createState() => _SelectClassesState();
}

class _SelectClassesState extends State<SelectClasses> {
  List<SchoolClass> classes = [];
  List<String> classIds = [];

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return secondaryColor;
    }
    return blueColor;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 24,
        ),
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("admin")
                  .doc(widget.schoolId)
                  .collection("classes")
                  .orderBy("name", descending: false)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: snapshot.data!.docs.map((e) {
                    SchoolClass _schoolClass = SchoolClass.fromSnap(e);

                    return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_schoolClass.name),
                          Checkbox(
                            checkColor: Colors.white,
                            fillColor:
                                MaterialStateProperty.resolveWith(getColor),
                            value: classIds.contains(_schoolClass.id),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value!) {
                                  classIds.add(_schoolClass.id);
                                  classes.add(_schoolClass);
                                } else {
                                  classIds.remove(_schoolClass.id);
                                  classes.remove(_schoolClass);
                                }
                              });
                            },
                          )
                        ]);
                  }).toList(),
                );
              },
            ),
            AuthButton(
              onTap: () => Navigator.pop(context, classes),
              label: "Auswahl bestätigen",
            )
          ],
        ),
      ),
    );
  }
}
