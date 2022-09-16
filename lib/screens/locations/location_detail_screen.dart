import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/screens/locations/edit_location_screen.dart';
import 'package:co2fzs_admin/screens/classes/request_screen.dart';
import 'package:co2fzs_admin/screens/users/user_detail_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:co2fzs_admin/widgets/table_item.dart';
import 'package:co2fzs_admin/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class LocationDetailScreen extends StatelessWidget {
  final Location location;
  const LocationDetailScreen({Key? key, required this.location})
      : super(key: key);

  Stream<QuerySnapshot<Map<String, dynamic>>> searchResult() {
    var stream1 = FirebaseFirestore.instance
        .collection("users")
        .where("homeAddress", isEqualTo: location.id)
        .snapshots();
    var stream2 = FirebaseFirestore.instance
        .collection("users")
        .where("homeAddress", isEqualTo: location.id)
        .snapshots();
    return MergeStream([stream1, stream2]);
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
        appBar: AppBar(
          title: Text("Details von ${location.name}"),
          backgroundColor: primaryColor,
        ),
        floatingActionButton: user.operationLevel > 3
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditLocationScreen(
                      location: location,
                    ),
                  ),
                ),
                child: Icon(Icons.edit),
                backgroundColor: primaryColor,
              )
            : Container(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: 12),
                  TableItem(info: location.name, label: "Name"),
                  TableItem(
                    info: "${location.distanceFromSchool} km",
                    label: "Distanz zur Schule",
                  ),
                  TableItem(
                    info: DateFormat.yMMMEd()
                        .format(
                          location.dateUpdated.toDate(),
                        )
                        .toString(),
                    label: "Zuletzt aktualisiert",
                  ),
                  SizedBox(height: 12),
                  Text(
                    "User die sich auf diesen Wohnort registriert haben",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  SizedBox(height: 12),
                  StreamBuilder(
                    stream: searchResult(),
                    builder: (
                      context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      int length = snapshot.data!.docs.length;

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        primary: false,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => UserDetailScreen(
                                user: User.fromSnap(snapshot.data!.docs[index]),
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
                ],
              ),
            ),
          ),
        ));
  }
}
