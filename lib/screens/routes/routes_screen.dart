import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/route.dart' as model;
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/route_info.dart';
import 'package:co2fzs_admin/widgets/user_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({Key? key}) : super(key: key);

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  bool _routesLoaded = false;

  bool _isLoading = false;

  List<model.Route> allRoutesOfSchool = [];

  void loadAllRoutes(String schoolID) async {
    setState(() {
      _isLoading = true;
    });
    List<model.Route> _routes = [];
    try {
      _routes = await FirestoreMethods()
          .catchAllRoutesOfSchool(schoolID: schoolID, context: context);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
    await Future.delayed(Duration(milliseconds: 1500));
    _routes.sort((sc1, sc2) {
      var r = sc2.date.compareTo(sc1.date);
      if (r != 0) return r;
      return sc1.datePublished.compareTo(sc2.datePublished);
    });
    setState(() {
      _isLoading = false;
      _routesLoaded = true;
      allRoutesOfSchool = _routes;
    });
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    if (!_routesLoaded) {
      loadAllRoutes(user.schoolIdBlank);
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Alle Einträge"),
        backgroundColor: primaryColor,
      ),
      body: !_isLoading
          ? Container(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: allRoutesOfSchool.length,
                shrinkWrap: true,
                primary: false,
                itemBuilder: (context, index) => InkWell(
                  // onTap: () => Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (_) => UserDetailScreen(
                  //       user: User.fromSnap(snapshot.data!.docs[index]),
                  //     ),
                  //   ),
                  // ),
                  child: RouteInfo(
                    route: allRoutesOfSchool[index],
                  ),
                ),
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
