import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/screens/classes/class_info_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class ClassInfo extends StatelessWidget {
  final SchoolClass snap;
  const ClassInfo({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ClassInfoScreen(snap: snap),
        ),
      ),
      child: Container(
      
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.1,
        
        child: Column(
          children: [
            Flexible(child: Container(), flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Text(
                    snap.name,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                Text(
                  "Schüler:  ${snap.users.length}/${snap.userCount}",
                  style: Theme.of(context).textTheme.headline2,
                ),
                
              ],
            ),
            Flexible(child: Container(), flex: 1),
            Divider(),
          ],
        ),
      ),
    );
  }
}
