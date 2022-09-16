import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/users/user_detail_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:flutter/material.dart';

class RequestButton extends StatelessWidget {
  final User user;
  SchoolClass? schoolClass;
  RequestButton({Key? key, required this.user}) : super(key: key);

  activateUser(BuildContext context) async {
    String res = await FirestoreMethods().activateUser(user.uid);
    showSnackBar(context, res);
  }

  deactivateUser(BuildContext context) async {
    String res = await FirestoreMethods().disqualifyUser(user.uid);
    showSnackBar(context, res);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UserDetailScreen(user: user))),
      child: Container(
          child: Column(
        children: [
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: AutoSizeText(
                  "${user.firstname} ${user.lastName}",
                  style: Theme.of(context).textTheme.headline3,
                  maxLines: 2,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.45,
                child: AutoSizeText(
                  user.email,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: IconButton(
                  onPressed: () => activateUser(context),
                  icon: const Icon(
                    Icons.check_outlined,
                    color: primaryColor,
                    size: 50,
                  ),
                ),
              ),
              Center(
                child: IconButton(
                  onPressed: () => deactivateUser(context),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: primaryColor,
                    size: 50,
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 6),
          Divider(),
        ],
      )),
    );
  }
}
