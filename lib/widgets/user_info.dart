import 'package:auto_size_text/auto_size_text.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final User user;
  final Color color;
  final bool warning;
  const UserInfo(
      {Key? key,
      required this.user,
      this.color = Colors.white,
      this.warning = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        width: double.infinity,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl != ""
                      ? user.photoUrl
                      : "https://cdn.pixabay.com/photo/2022/04/06/20/54/man-7116367_960_720.jpg"),
                ),
                SizedBox(width: 6),
                Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  child: AutoSizeText(
                    "${user.firstname} ${user.lastName}",
                    style: Theme.of(context).textTheme.headline3,
                    maxLines: 2,
                    minFontSize: 12,
                    textAlign: TextAlign.center,
                  ),
                ),
                warning
                    ? Icon(Icons.warning_amber, color: lightRed)
                    : Container(),
                color == Colors.white
                    ? Container(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: AutoSizeText(
                          "@${user.username}",
                          style: Theme.of(context).textTheme.bodyText1,
                          maxLines: 2,
                          minFontSize: 12,
                          textAlign: TextAlign.end,
                        ),
                      )
                    : CircleAvatar(backgroundColor: color, radius: 12)
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
