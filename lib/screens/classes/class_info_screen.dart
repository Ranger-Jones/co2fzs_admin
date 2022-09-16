import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/screens/classes/edit_class_screen.dart';
import 'package:co2fzs_admin/screens/classes/request_screen.dart';
import 'package:co2fzs_admin/screens/users/user_detail_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:co2fzs_admin/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClassInfoScreen extends StatelessWidget {
  final SchoolClass snap;
  const ClassInfoScreen({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${snap.name} Infos",
        ),
        backgroundColor: primaryColor,
      ),
      floatingActionButton: user.operationLevel > 3
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditClassScreen(
                    schoolClass: snap,
                  ),
                ),
              ),
              child: Icon(Icons.edit),
              backgroundColor: primaryColor,
            )
          : Container(),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24),
              TableItem(info: snap.name, label: "Klassenname"),
              TableItem(info: "${snap.totalPoints}", label: "Punkte"),
              TableItem(
                  info: "${snap.users.length} / ${snap.userCount}",
                  label: "Registrierte Nutzer"),
              SizedBox(height: 24),
              snap.users.isNotEmpty
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("classId", isEqualTo: snap.id)
                          .where("activated", isEqualTo: false)
                          .where("disqualified", isEqualTo: false)
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

                        int length = snapshot.data!.docs.length;

                        return length == 0
                            ? SizedBox(height: 0)
                            : BigButton(
                                iconData: Icons.people,
                                label: "$length Anfragen",
                                onPressed: () => Navigator.pushNamed(
                                    context, RequestScreen.routeName,
                                    arguments: snap.id),
                              );
                      },
                    )
                  : Text(""),
              SizedBox(height: 24),
              Text(
                "User",
                style: Theme.of(context).textTheme.headline2,
              ),
              SizedBox(height: 24),
              snap.users.isNotEmpty
                  ? StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("users")
                          .where("classId", isEqualTo: snap.id)
                          .where("activated", isEqualTo: true)
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
                          primary: false,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => UserDetailScreen(
                                  user:
                                      User.fromSnap(snapshot.data!.docs[index]),
                                ),
                              ),
                            ),
                            child: UserInfo(
                              user: User.fromSnap(snapshot.data!.docs[index]),
                            ),
                          ),
                        );
                      },
                    )
                  : Text("Keine registrierten Nutzer"),
            ],
          ),
        ),
      ),
    );
  }
}
