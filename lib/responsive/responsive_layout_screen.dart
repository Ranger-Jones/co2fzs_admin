import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/user.dart' as model;
import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/utils/dimensions.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({
    Key? key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addData();
  }

  addData() async {
    UserProvider _userProvider = Provider.of(context, listen: false);
    await _userProvider.refreshUser();

    // SchoolProvider _schoolProvider = Provider.of(context, listen: false);
    // await _schoolProvider.refreshSchool();
  }

  getConfig() async {}

  @override
  Widget build(BuildContext context) {
    // FirebaseAuth.instance.signOut();

    initializeDateFormatting();
    Intl.defaultLocale = 'de_DE';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > webScreenSize) {
          return widget.webScreenLayout;
        }

        return widget.mobileScreenLayout;
      },
    );
  }
}
