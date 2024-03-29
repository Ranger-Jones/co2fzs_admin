import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/models/user.dart';

class SchoolClass {
  final users;
  final String name;
  final double totalPoints;
  final String schoolIdBlank;
  final String id;
  final int userCount;
  final String photoUrl;

  SchoolClass({
    required this.name,
    required this.totalPoints,
    required this.schoolIdBlank,
    required this.users,
    required this.id,
    required this.userCount,
    this.photoUrl = "",
  });

  static SchoolClass emptySchoolClass() => SchoolClass(
      name: "",
      totalPoints: 0,
      schoolIdBlank: "",
      users: [],
      id: "",
      photoUrl: "",
      userCount: 0);

  Map<String, dynamic> toJson() => {
        "name": name,
        "totalPoints": totalPoints,
        "schoolIdBlank": schoolIdBlank,
        "users": users,
        "id": id,
        "userCount": userCount,
      };

  static SchoolClass fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return SchoolClass(
      name: snapshot["name"] ?? "Laden des Namens fehlgeschlagen",
      totalPoints: double.parse(snapshot["totalPoints"].toStringAsFixed(2)),
      schoolIdBlank: snapshot["schoolIdBlank"],
      users: snapshot["users"],
      id: snapshot["id"],
      userCount: snapshot["userCount"],
    );
  }
}
