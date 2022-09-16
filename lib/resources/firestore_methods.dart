import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/article.dart';
import 'package:co2fzs_admin/models/contest.dart';
import 'package:co2fzs_admin/models/post.dart';
import 'package:co2fzs_admin/models/route.dart' as model;
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/models/location.dart';
import 'package:co2fzs_admin/models/schoolClass.dart';
import 'package:co2fzs_admin/models/school_building.dart';
import 'package:co2fzs_admin/models/user.dart' as model;
import 'package:co2fzs_admin/resources/storage_methods.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> deleteClass(String schoolIdBlank, String classId) async {
    String res = "Undefined Error";

    try {
      await _firestore.collection("admin").doc(schoolIdBlank).update({
        "classes": FieldValue.arrayRemove([classId])
      });
      await _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("classes")
          .doc(classId)
          .delete();
      res = "Klasse erfolgreich entfernt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> deleteSchool(String schoolIdBlank) async {
    String res = "Undefined Error";

    try {
      await _firestore.collection("admin").doc(schoolIdBlank).delete();
      res = "Schule erfolgreich entfernt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> resetUser(String userId) async {
    String res = "Undefined Error";
    try {
      var snapshots = await _firestore
          .collection("users")
          .doc(userId)
          .collection("routes")
          .get();

      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }

      await _firestore
          .collection("users")
          .doc(userId)
          .update({"totalPoints": 0});
      res = "Nutzer erfolgreich zurückgesetzt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> oldDeleteLocation(
      String schoolIdBlank, String locationId) async {
    String res = "Undefined Error";

    try {
      await _firestore.collection("locations").doc(locationId).delete();
      res = "Ort erfolgreich entfernt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> updateClass(
    String name,
    String schoolIdBlank,
    String classId,
    int userCount,
  ) async {
    String res = "Undefined error occurred";

    try {
      _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("classes")
          .doc(classId)
          .update({"name": name, "userCount": userCount});

      await refreshClass(classID: classId, schoolID: schoolIdBlank);
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> resetAllUsers() async {
    String res = "Undefined Error";
    try {
      var users = await _firestore.collection("users").get();
      users.docs.forEach((element) async {
        model.User user = model.User.fromSnap(element);
        await resetUser(user.uid);
      });

      var schools = await _firestore.collection("admin").get();
      schools.docs.forEach((element) async {
        School school = School.fromSnap(element);
        await resetSchool(school.id);
      });
      res = "Alle User erfolgreich zurückgesetzt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> resetSchool(String schoolId) async {
    String res = "Undefined Error";
    try {
      await _firestore
          .collection("admin")
          .doc(schoolId)
          .update({"totalPoints": 0});

      var schoolClasses = await _firestore
          .collection("admin")
          .doc(schoolId)
          .collection("classes")
          .get();

      schoolClasses.docs.forEach((element) async {
        SchoolClass schoolClass = SchoolClass.fromSnap(element);
        await resetClass(schoolClass.id, schoolId);
      });

      res = "Schule erfolgreich zurückgesetzt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> resetClass(String classId, String schoolId) async {
    String res = "Undefined Error";
    try {
      await _firestore
          .collection("admin")
          .doc(schoolId)
          .collection("classes")
          .doc(classId)
          .update({"totalPoints": 0});
      res = "Klasse erfolgreich zurückgesetzt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> updateLocation(
      {required String name,
      required double distance,
      required String locationID}) async {
    String res = "Undefined Error";
    try {
      await _firestore.collection("locations").doc(locationID).update({
        "name": name,
        "distanceFromSchool": distance,
        "dateUpdated": DateTime.now(),
      });
      res = "Erfolgreich aktualisiert";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<dynamic> catchLocation({
    required String locationId,
  }) async {
    String res = "Undefined Error";
    try {
      DocumentSnapshot locationSnap =
          await _firestore.collection("locations").doc(locationId).get();

      return locationSnap;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> deleteLocation({required String locationID}) async {
    String res = "Undefined Error";
    try {
      var userWithH1 = await _firestore
          .collection("users")
          .where("homeAddress", isEqualTo: locationID)
          .get();

      var userWithH2 = await _firestore
          .collection("users")
          .where("homeAddress2", isEqualTo: locationID)
          .get();

      for (var doc in userWithH1.docs) {
        await doc.reference.update({"homeAddress": ""});
      }

      for (var doc in userWithH2.docs) {
        await doc.reference.update({"homeAddress2": ""});
      }

      await _firestore.collection("locations").doc(locationID).delete();
      res = "Wohnort erfolgreich entfernt";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<dynamic> catchClass(
      {required String schoolIdBlank, required String classId}) async {
    String res = "Undefined Error";
    try {
      var res = await _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("classes")
          .doc(classId)
          .get();

      return res;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<SchoolClass> catchClassPrototype(
      {required String schoolIdBlank,
      required String classId,
      required BuildContext context}) async {
    String res = "Undefined Error";
    SchoolClass schoolClass = SchoolClass.emptySchoolClass();
    try {
      var res = await _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("classes")
          .doc(classId)
          .get();

      schoolClass = SchoolClass.fromSnap(res);
    } catch (err) {
      res = err.toString();
      // showSnackBar(context, res);
    }
    return schoolClass;
  }

  Future<List<SchoolClass>> catchClasses(
      {required String schoolIdBlank,
      required List<dynamic> classIds,
      required BuildContext context}) async {
    List<SchoolClass> classes = [];

    try {
      classIds.forEach((e) async => classes.add(await catchClassPrototype(
          classId: e, context: context, schoolIdBlank: schoolIdBlank)));
      classes.removeWhere((element) => element.id == "");
    } catch (err) {
      showSnackBar(context, err.toString());
    }
    return classes;
  }

  Future<String> removeUser(model.User user) async {
    String res = "Undefined Error";

    try {
      await _firestore.collection("users").doc(user.uid).delete();
      await _firestore.collection("admin").doc(user.schoolIdBlank).update({
        "users": FieldValue.arrayRemove([user.uid]),
        "totalPoints": FieldValue.increment(-user.totalPoints)
      });
      await _firestore
          .collection("admin")
          .doc(user.schoolIdBlank)
          .collection("classes")
          .doc(user.classId)
          .update({
        "users": FieldValue.arrayRemove([user.uid]),
        "totalPoints": FieldValue.increment(-user.totalPoints)
      });

      res = "Success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<List<model.Route>> catchAllRoutesOfSchool(
      {required String schoolID, required BuildContext context}) async {
    String res = "Undefined Error";
    List<model.Route> allRoutesOfSchool = [];

    try {
      var userSnapshots = await _firestore
          .collection("users")
          .where("schoolIdBlank", isEqualTo: schoolID)
          .get();

      userSnapshots.docs.forEach((element) async {
        model.User _user = model.User.fromSnap(element);

        var userRoutes = await _firestore
            .collection("users")
            .doc(_user.uid)
            .collection("routes")
            .get();

        userRoutes.docs.forEach((element) {
          model.Route _route = model.Route.fromSnap(element);
          allRoutesOfSchool.add(_route);
        });
        res = "Einträge erfolgreich geladen";
      });
    } catch (e) {
      res = e.toString();
    }
    // showSnackBar(context, res);
    return allRoutesOfSchool;
  }

  Future<String> uploadClass(
    String name,
    String schoolIdBlank,
    int userCount,
  ) async {
    String res = "Undefined error occurred";

    try {
      String classId = const Uuid().v1();
      await _firestore.collection("admin").doc(schoolIdBlank).update({
        "classes": FieldValue.arrayUnion([classId])
      });
      SchoolClass schoolClass = SchoolClass(
        id: classId,
        schoolIdBlank: schoolIdBlank,
        name: name,
        userCount: userCount,
        totalPoints: 0,
        users: [],
      );
      _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("classes")
          .doc(classId)
          .set(
            schoolClass.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadBuilding({
    required String name,
    required String schoolIdBlank,
    required String location,
    required List<String> classIds,
  }) async {
    String res = "Undefined error occurred";

    try {
      String buildingId = const Uuid().v1();
      await _firestore.collection("admin").doc(schoolIdBlank).update({
        "classes": FieldValue.arrayUnion([buildingId])
      });
      SchoolBuilding schoolBuilding = SchoolBuilding(
        id: buildingId,
        buildingName: name,
        classes: classIds,
        location: location,
        photoUrl: "",
        totalPoints: 0,
        users: [],
      );
      _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("buildings")
          .doc(buildingId)
          .set(
            schoolBuilding.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadArticle({
    required String title,
    required String text,
    required String author,
    required String authorId,
    required Uint8List file,
  }) async {
    String res = "Undefined error occurred";

    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("posts", file, true);

      String articleId = const Uuid().v1();

      Article article = Article(
        id: articleId,
        author: author,
        title: title,
        text: text,
        authorId: authorId,
        photoUrl: photoUrl,
        tags: [],
        datePublished: DateTime.now(),
        dateUpdated: DateTime.now(),
      );
      _firestore.collection("articles").doc(articleId).set(
            article.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> deActivateUser(
    String userId,
  ) async {
    String res = "Unknown Error";
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"activated": false});
      res = "Erfolgreich deaktiviert";
    } catch (e) {
      e.toString();
    }
    return res;
  }

  Future<dynamic> catchBuildings({required String schoolIdBlank}) async {
    String res = "Undefined Error";
    try {
      QuerySnapshot buildingsSnapshots = await _firestore
          .collection("admin")
          .doc(schoolIdBlank)
          .collection("buildings")
          .get();

      if (buildingsSnapshots.docs.length < 1) {
        res = "Keine Gebäude gefunden.";
        return res;
      } else {
        return buildingsSnapshots.docs;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> refreshClass(
      {required String classID, required String schoolID}) async {
    String res = "Undefined Error";
    try {
      var classUser = await _firestore
          .collection("users")
          .where("classId", isEqualTo: classID)
          .get();

      List<String> userUids = classUser.docs.map((e) {
        model.User _user = model.User.fromSnap(e);
        return _user.uid;
      }).toList();
      print("USERLIST${userUids}");
      double newTotalPoints = 0;

      List<model.User> users = classUser.docs.map((e) {
        model.User _user = model.User.fromSnap(e);
        return _user;
      }).toList();

      users.forEach(
        (element) async {
          var _userRouteSnaps = await _firestore
              .collection("users")
              .doc(element.uid)
              .collection("routes")
              .get();
          List<model.Route> _userRoutes =
              _userRouteSnaps.docs.map((e) => model.Route.fromSnap(e)).toList();
          double userPoints = 0;
          _userRoutes.forEach((e) {
            newTotalPoints += e.points;
            userPoints += e.points;
            print("ROUTEPOINTS: ${e.points}");
            print("NEUE INSGESAMTPUNKTZAHL ${newTotalPoints}");
          });
          print("USERPOINTS: ${userPoints}");
          await _firestore.collection("users").doc(element.uid).update(
            {"totalPoints": userPoints},
          );
          await _firestore
              .collection("admin")
              .doc(schoolID)
              .collection("classes")
              .doc(classID)
              .update(
            {"users": userUids, "totalPoints": newTotalPoints},
          );
        },
      );

      res = "Klasse erfolgreich aktualisiert!";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<List<Location>> catchAllLocationsOfSchool(
      {required String schoolID, required BuildContext context}) async {
    List<Location> schoolLocations = [];

    try {
      var schoolLocationsSnapshots = await _firestore
          .collection("locations")
          .where("schoolIdBlank", isEqualTo: schoolID)
          .orderBy("name")
          .get();
      schoolLocations = schoolLocationsSnapshots.docs
          .map((e) => Location.fromSnap(e))
          .toList();
    } catch (e) {
      showSnackBar(context, e.toString());
    }

    return schoolLocations;
  }

  Future<String> updateUserLocation(
      {required String location1Id,
      required String location2Id,
      required String uid}) async {
    String res = "Undefined Error";

    try {
      await _firestore
          .collection("users")
          .doc(uid)
          .update({"homeAddress": location1Id, "homeAddress2": location2Id});
      res = "Wohnorte erfolgreich aktualisiert";
    } catch (e) {
      res = e.toString();
    }

    return res;
  }

  Future<String> refreshSchool({required String schoolID}) async {
    String res = "Undefined Error";
    try {
      var userInSchool = await _firestore
          .collection("users")
          .where("schoolIdBlank", isEqualTo: schoolID)
          .where("role", isEqualTo: "user")
          .get();

      List<dynamic> userIds =
          userInSchool.docs.map((element) => element["uid"]).toList();
      var classes = await _firestore
          .collection("admin")
          .doc(schoolID)
          .collection("classes")
          .get();
      double newTotalPoints = 0;
      List<String> classIds = [];
      int totalUsers = 0;
      classes.docs.forEach((element) async {
        SchoolClass _schoolClass = SchoolClass.fromSnap(element);
        newTotalPoints += _schoolClass.totalPoints;
        classIds.add(_schoolClass.id);
        totalUsers += _schoolClass.userCount;
        String res =
            await refreshClass(classID: _schoolClass.id, schoolID: schoolID);
      });
      print("SCHOOL NEW TOTALPOINTS ${newTotalPoints}");
      await _firestore.collection("admin").doc(schoolID).update({
        "totalPoints": newTotalPoints,
        "users": userIds,
        "totalUserCount": totalUsers,
        "classes": classIds,
      });
      res = "Schule erfolgreich aktualisiert!";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> disqualifyUser(
    String userId,
  ) async {
    String res = "Unknown Error";
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"disqualified": true});
      res = "Erfolgreich disqualifiziert";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> noDisqualifyUser(
    String userId,
  ) async {
    String res = "Unknown Error";
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"disqualified": false});
      res = "Erfolgreich entdisqualifiziert";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> activateUser(
    String userId,
  ) async {
    String res = "Unknown Error";
    try {
      FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .update({"activated": true});
      res = "Erfolgreich aktiviert";
    } catch (e) {
      e.toString();
    }
    return res;
  }

  Future<String> uploadLocation(
    String name,
    double distanceFromSchool,
    String schoolIdBlank,
  ) async {
    String res = "Undefined error occurred";

    try {
      String locationId = const Uuid().v1();

      Location location = Location(
        id: locationId,
        name: name,
        distanceFromSchool: distanceFromSchool,
        datePublished: DateTime.now(),
        dateUpdated: DateTime.now(),
        photoUrl: "",
        schoolIdBlank: schoolIdBlank,
      );
      _firestore.collection("locations").doc(locationId).set(
            location.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<dynamic> getMultipleSchoolsById(
      {required List<String> schoolIds}) async {
    String res = "Undefined Error";
    try {
      QuerySnapshot schools = await _firestore
          .collection("admin")
          .where("id", whereIn: schoolIds)
          .get();

      return schools.docs;
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<dynamic> catchConfig() async {
    String res = "Undefined Error";
    try {
      var config = await _firestore.collection("config").doc("STATIC").get();

      return config;
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<dynamic> catchSchool({required int schoolId}) async {
    String res = "Undefined Error";
    try {
      var schools = await _firestore
          .collection("admin")
          .where("schoolId", isEqualTo: schoolId)
          .get();
      var school;

      if (schools.size <= 0 || schools.size > 1) {
        res = "SchulID ist inkorrekt";
        return res;
      } else {
        school = schools.docs[0];
        return school;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> uploadContest(
    String title,
    DateTime startDate,
    DateTime endDate,
  ) async {
    String res = "Undefined error occurred";

    try {
      String contestId = const Uuid().v1();

      Contest schoolClass = Contest(
        id: contestId,
        title: title,
        startDate: startDate,
        endDate: endDate,
        schools: [],
      );
      _firestore.collection("contest").doc(contestId).set(
            schoolClass.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> joinContest(String schoolIdBlank, String contestId) async {
    await _firestore
        .collection("admin")
        .doc(schoolIdBlank)
        .update({"contestId": contestId});

    QuerySnapshot users = await _firestore
        .collection("users")
        .where("schoolIdBlank", isEqualTo: schoolIdBlank)
        .get();

    users.docs.forEach((user) async {
      await _firestore
          .collection("users")
          .doc(user["uid"])
          .update({"contestId": contestId});
    });

    await _firestore.collection("contest").doc(contestId).update({
      "schools": FieldValue.arrayUnion([schoolIdBlank])
    });
  }

  Future<String> uploadSchool(
    String schoolName,
    int schoolId,
    String location,
  ) async {
    String res = "Undefined error occurred";

    try {
      String schoolIdBlank = const Uuid().v1();
      School school = School(
        totalUserCount: 0,
        schoolId: schoolId,
        id: schoolIdBlank,
        schoolname: schoolName,
        location: location,
        classes: [],
        users: [],
        totalPoints: 0,
        contestId: "",
      );
      _firestore.collection("admin").doc(schoolIdBlank).set(
            school.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "some Error";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("posts", file, true);
      String postId = const Uuid().v1();
      Post post = Post(
        username: username,
        description: description,
        postId: postId,
        postUrl: photoUrl,
        uid: uid,
        datePublished: DateTime.now(),
        likes: [],
        profImage: profImage,
      );
      _firestore.collection("posts").doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection("posts").doc(postId).update({
          "likes": FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String text, String uid, String name,
      String profilePic) async {
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection("posts")
            .doc(postId)
            .collection("comments")
            .doc(commentId)
            .set({
          "profilePic": profilePic,
          "name": name,
          "uid": uid,
          "text": text,
          "commentId": commentId,
          "datePublished": DateTime.now(),
        });
      } else {
        print("Text is empty");
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection("posts").doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }
}
