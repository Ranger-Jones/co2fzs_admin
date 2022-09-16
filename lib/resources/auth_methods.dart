import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:co2fzs_admin/models/school.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:co2fzs_admin/models/user.dart' as model;
import 'package:co2fzs_admin/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection("users").doc(currentUser.uid).get();

    return model.User.fromSnap(snap);
  }

  Future<School> getSchoolDetails() async {
    User currentUser = _auth.currentUser!;
    DocumentSnapshot userSnap =
        await _firestore.collection("users").doc(currentUser.uid).get();

    model.User user = model.User.fromSnap(userSnap);

    DocumentSnapshot schoolSnap =
        await _firestore.collection("admin").doc(user.schoolIdBlank).get();
    print("SchulID: ${user.schoolIdBlank}");
    School school = School.fromSnap(schoolSnap);
    print("SchulID: ${school.classes.length}");
    return school;
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required int schoolId,
    required int operationLevel,
  }) async {
    String res = "Some error";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          schoolId > 1 ||
          !operationLevel.isNegative) {
        var schools = await _firestore
            .collection("admin")
            .where("schoolId", isEqualTo: schoolId)
            .get();

        var school;
        print("1Schule: ${school}");
        if (schools.size > 1) {
          res = "SchulID ist inkorrekt";
          print("2Schule: ${school}");
          return res;
        } else if (schools.size <= 0) {
          res = await FirestoreMethods()
              .uploadSchool("AdminSchool", 42187, "AdminLocation");
          if (res == "success") {
            schools = await _firestore
                .collection("admin")
                .where("schoolId", isEqualTo: schoolId)
                .get();
            school = schools.docs[0];
            print("3Schule: ${school}");
          } else {
            return "Error";
          }
        } else {
          school = schools.docs[0];
        }
        print("4Schule: ${school}");
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        model.User user = model.User(
          operationLevel: operationLevel,
          username: username,
          photoUrl: "",
          grade: "admin1",
          firstname: "Admin",
          lastName: "Admin",
          role: "admin",
          schoolId: schoolId,
          schoolIdBlank: school["id"],
          email: email,
          uid: cred.user!.uid,
          totalPoints: 0,
          classId: "",
          homeAddress: "",
          homeAddress2: "",
          contestId: "",
          disqualified: false,
          transport: "",
          activated: false,
          datePublished: DateTime.now(),
          dateUpdated: DateTime.now(),
          friends: [],
        );
        await _firestore
            .collection(
              "users",
            )
            .doc(
              cred.user!.uid,
            )
            .set(
              user.toJson(),
            );
        res = "success";
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == "invalid-email") {
        res = "The email is badly formatted.";
      } else if (err.code == "weak-password") {
        res = "Password should be better";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some Error";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the field!";
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        res = "This User isn't registered. Please check your email.";
      } else if (e.code == "wrong-password") {
        res = "Please check your password!";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
