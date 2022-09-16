import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/request_button.dart';
import 'package:co2fzs_admin/widgets/user_info.dart';
import 'package:flutter/material.dart';

class RequestScreen extends StatefulWidget {
  RequestScreen({Key? key}) : super(key: key);
  static String routeName = "/requests";

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  @override
  Widget build(BuildContext context) {
    final String classId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Anfragen"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .where("classId", isEqualTo: classId)
                  .where("activated", isEqualTo: false)
                  .where("disqualified", isEqualTo: false)
                  .snapshots(),
              builder: (
                context,
                AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
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
                  itemBuilder: (context, index) => RequestButton(
                    user: User.fromSnap(snapshot.data!.docs[index]),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
