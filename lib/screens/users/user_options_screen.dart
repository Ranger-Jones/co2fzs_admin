import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/screens/users/user_change_location_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserOptionsScreen extends StatefulWidget {
  final User user;
  const UserOptionsScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<UserOptionsScreen> createState() => _UserOptionsScreenState();
}

class _UserOptionsScreenState extends State<UserOptionsScreen> {
  bool _isLoadingRemove = false;
  bool _isLoadingReset = false;
  bool _isLoadingDisqualified = false;

  void resetUser(BuildContext context) async {
    String res = "Undefined Error";
    setState(() {
      _isLoadingReset = true;
    });
    try {
      res = await FirestoreMethods().resetUser(widget.user.uid);
    } catch (e) {
      res = e.toString();
    }
    setState(() {
      _isLoadingReset = false;
    });
    showSnackBar(context, res);
  }

  void removeUser(BuildContext context) async {
    String res = "Undefined Error";
    setState(() {
      _isLoadingRemove = true;
    });
    try {
      res = await FirestoreMethods().removeUser(widget.user);
      if (res == "Success") {
        refresh();
        showSnackBar(context, "User erfolgreich entfernt");
      } else {
        showSnackBar(context, res);
      }
    } catch (e) {
      res = e.toString();
    }
    setState(() {
      _isLoadingRemove = false;
    });
  }

  void disqualifyUser(BuildContext context) async {
    String res = "Undefined Error";
    setState(() {
      _isLoadingDisqualified = true;
    });
    try {
      res = await FirestoreMethods().disqualifyUser(widget.user.uid);
      if (res == "Erfolgreich disqualifiziert") {
        refresh();
      }
    } catch (e) {
      res = e.toString();
    }
    showSnackBar(context, res);
    setState(() {
      _isLoadingDisqualified = false;
    });
  }

  activateUser(BuildContext context) async {
    String res = await FirestoreMethods().activateUser(widget.user.uid);
    showSnackBar(context, res);
    refresh();
  }

  deactivateUser(BuildContext context) async {
    String res = await FirestoreMethods().deActivateUser(widget.user.uid);
    showSnackBar(context, res);
    refresh();
  }

  noDisqualify(BuildContext context) async {
    String res = await FirestoreMethods().noDisqualifyUser(widget.user.uid);
    showSnackBar(context, res);
    refresh();
  }

  void refresh() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    User activeUser = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Verfügbare Optionen zu ${widget.user.firstname} ${widget.user.lastName[0] != "" ? widget.user.lastName[0] + "." : ""}",
        ),
        backgroundColor: primaryColor,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            activeUser.operationLevel > 3
                ? (widget.user.activated
                    ? AuthButton(
                        label: "User deaktivieren",
                        isLoading: _isLoadingDisqualified,
                        onTap: () => areYouSafeAlert(
                            context: context,
                            onTap: () => deactivateUser(context),
                            text:
                                "Sind Sie sich wirklich sicher, dass Sie diesen User deaktivieren wollen. Er verliert damit die Möglichkeit am Wettbewerb teilzunehmen."),
                      )
                    : AuthButton(
                        label: "User aktivieren",
                        isLoading: _isLoadingDisqualified,
                        onTap: () => areYouSafeAlert(
                            context: context,
                            onTap: () => activateUser(context),
                            text:
                                "Sind Sie sich wirklich sicher, dass Sie diesen User aktivieren wollen. Er bekommt damit die Möglichkeit am Wettbewerb teilzunehmen."),
                      ))
                : Container(),
            SizedBox(height: 24),
            activeUser.operationLevel > 3
                ? (widget.user.disqualified
                    ? AuthButton(
                        label: "User entdisqualifizieren",
                        color: lightPurple,
                        isLoading: _isLoadingDisqualified,
                        onTap: () => areYouSafeAlert(
                            context: context,
                            onTap: () => noDisqualify(context),
                            text:
                                "Sind Sie sich wirklich sicher, dass Sie diesen User entdisqualifzieren wollen. Er bekommt damit die Möglichkeit wieder am Wettbewerb teilzunehmen."),
                      )
                    : AuthButton(
                        label: "User disqualifizieren",
                        color: lightPurple,
                        isLoading: _isLoadingDisqualified,
                        onTap: () => areYouSafeAlert(
                            context: context,
                            onTap: () => disqualifyUser(context),
                            text:
                                "Sind Sie sich wirklich sicher, dass Sie diesen User disqualifzieren wollen. Er verliert damit die Möglichkeit am Wettbewerb teilzunehmen."),
                      ))
                : Container(),
            SizedBox(height: 24),
            activeUser.operationLevel > 3
                ? AuthButton(
                    label: "Wohnort(e) ändern",
                    color: secondaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UserChangeLocationScreen(
                          user: widget.user,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(height: 24),
            activeUser.operationLevel > 3
                ? AuthButton(
                    label: "User zurücksetzen",
                    color: yellow,
                    isLoading: _isLoadingReset,
                    onTap: () => areYouSafeAlert(
                        context: context,
                        onTap: () => resetUser(context),
                        text:
                            "Sind Sie sich wirklich sicher, dass Sie diesen User zurücksetzen wollen. Er verliert damit alle Punkte, sowie alle von ihm eingetrgenen 'Routen'."),
                  )
                : Container(),
            SizedBox(height: 24),
            activeUser.operationLevel > 3
                ? AuthButton(
                    color: lightRed,
                    isLoading: _isLoadingRemove,
                    label: "User komplett entfernen",
                    onTap: () => areYouSafeAlert(
                        context: context,
                        onTap: () => removeUser(context),
                        text:
                            "Sind Sie sich wirklich sicher, dass Sie diesen User komplett entfernen wollen? Möglicherweise verliert er damit die Möglichkeit generell am Wettbewerb teilzunehmen."),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
