import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/contest.dart';
import 'package:co2fzs_admin/screens/contest/add_contest_screen.dart';
import 'package:co2fzs_admin/screens/contest/edit_contest_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/widgets/big_button.dart';
import 'package:co2fzs_admin/widgets/contest_info.dart';
import 'package:flutter/material.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  int length = -1;
  Contest? contest;
  @override
  void initState() {
    super.initState();
    getContestsLength();
  }

  void getContestsLength() async {
    QuerySnapshot contest =
        await FirebaseFirestore.instance.collection("contest").get();
    setState(() {
      length = contest.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (length == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Wettbewerbe"),
          backgroundColor: primaryColor,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (length == 0) {
      return Scaffold(
          appBar: AppBar(
            title: const Text("Wettbewerbe"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Text("Keine Wettbewerbe erstellt",
                    style: Theme.of(context).textTheme.headline2),
                BigButton(
                  iconData: Icons.start_sharp,
                  label: "Wettbewerb einrichten",
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddContestScreen(
                        refreshContest: getContestsLength,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wettbewerbe"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditContestScreen(contest: contest!),
          ),
        ),
        child: Icon(Icons.edit),
        backgroundColor: primaryColor,
      ),
      body: Container(
        width: double.infinity,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("contest").snapshots(),
          builder: (
            context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            contest = Contest.fromSnap(snapshot.data!.docs[0]);

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => ContestInfo(
                contest: Contest.fromSnap(snapshot.data!.docs[index]),
                refreshContests: getContestsLength,
              ),
            );
          },
        ),
      ),
    );
  }
}
