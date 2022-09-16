import 'package:auto_size_text/auto_size_text.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:flutter/material.dart';

class BuildingInfo extends StatelessWidget {
  final SchoolBuilding schoolBuilding;
  const BuildingInfo({Key? key, required this.schoolBuilding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: AutoSizeText(
              schoolBuilding.buildingName,
              style: Theme.of(context).textTheme.headline3,
              maxLines: 2,
            ),
          ),
          Text("${schoolBuilding.users.length}")
        ],
      ),
    );
  }
}
