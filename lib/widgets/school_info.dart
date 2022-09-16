import 'package:co2fzs_admin/screens/classes/class_info_screen.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class SchoolInfo extends StatelessWidget {
  final snap;
  const SchoolInfo({Key? key, required this.snap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.075,
       
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Text(
                snap["schoolname"],
                style: Theme.of(context).textTheme.headline2,
              ),
            ),
            Text(
              "ID: ${snap["schoolId"]}",
              style: Theme.of(context).textTheme.headline2,
            ),
          ],
        ),
      ),
    );
  }
}
