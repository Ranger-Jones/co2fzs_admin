import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/contest.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/school_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContestInfo extends StatefulWidget {
  final Contest contest;
  final VoidCallback refreshContests;
  const ContestInfo(
      {Key? key, required this.contest, required this.refreshContests})
      : super(key: key);

  @override
  State<ContestInfo> createState() => _ContestInfoState();
}

class _ContestInfoState extends State<ContestInfo> {
  var schools = null;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadSchools();
  }

  void loadSchools() async {
    var schoolSnap = await FirestoreMethods().getMultipleSchoolsById(
        schoolIds: widget.contest.schools.cast<String>());
    if (schoolSnap is String) {
      showSnackBar(context, "Keine Schulen verfügbar");
      setState(() {
        schools = null;
      });
    } else {
      setState(() {
        schools = schoolSnap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> schoolIds = widget.contest.schools.cast<String>();
    User user = Provider.of<UserProvider>(context).getUser;

    var contain = schoolIds.where((element) => element == user.schoolIdBlank);
    return Container(
        child: Column(
      children: [
        const SizedBox(height: 20),
        Text(
          "Title: ${widget.contest.title}",
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(height: 20),
        Text(
          "Start Datum: ${DateFormat.yMMMEd().format(widget.contest.startDate.toDate())}",
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(height: 20),
        Text(
          "End Datum: ${DateFormat.yMMMEd().format(widget.contest.endDate.toDate())}",
          style: Theme.of(context).textTheme.headline2,
        ),
        const SizedBox(height: 20),
        contain.isEmpty
            ? InkWell(
                onTap: () async {
                  await FirestoreMethods().joinContest(
                    user.schoolIdBlank,
                    widget.contest.id,
                  );
                  widget.refreshContests();
                  loadSchools();
                },
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text("Als Schule dem Event beitreten"),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                    color: blueColor,
                  ),
                ),
              )
            : Text("Bereits beigetreten"),
        const SizedBox(height: 20),
        Divider(height: 10, color: secondaryColor),
        const SizedBox(height: 20),
        Text(
          "Teilnehmende Schulen",
          style: Theme.of(context).textTheme.headline2,
        ),
        schools != null
            ? Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemBuilder: (context, index) => SchoolInfo(
                    snap: schools[index],
                  ),
                  itemCount: schools.length,
                ),
              )
            : CircularProgressIndicator(),
      ],
    ));
  }
}
