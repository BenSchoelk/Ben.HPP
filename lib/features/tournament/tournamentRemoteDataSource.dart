import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutterquiz/features/tournament/model/tournament.dart';
import 'package:flutterquiz/features/tournament/tournamentException.dart';
import 'package:flutterquiz/utils/constants.dart';
import 'package:flutterquiz/utils/errorMessageKeys.dart';
import 'package:flutterquiz/utils/internetConnectivity.dart';

//TODO : add error code for tournament

class TournamentRemoteDataSource {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<dynamic> getTournaments() async {}

  Future<List<DocumentSnapshot>> searchTournament({required String questionLanguageId, required String title}) async {
    try {
      QuerySnapshot querySnapshot;
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      querySnapshot = await _firebaseFirestore
          .collection(tournamentsCollection)
          .where("languageId", isEqualTo: questionLanguageId)
          .where("title", isEqualTo: title)
          .where(
            "totalPlayers",
            isNotEqualTo: numberOfPlayerForTournament,
          )
          .get();

      return querySnapshot.docs;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Stream<DocumentSnapshot> listenToTournamentUpdates(String tournamentId) {
    return _firebaseFirestore.collection(tournamentsCollection).doc(tournamentId).snapshots();
  }

  Future<void> updateTournament({
    required String tournamentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      await _firebaseFirestore.collection(tournamentsCollection).doc(tournamentId).update(data);
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  Future<String> createTournament({required Map<String, dynamic> data}) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      return (await _firebaseFirestore.collection(tournamentsCollection).add(data)).id;
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }

  //join tournament
  Future<bool> joinTournament({
    required String tournamentId,
    required String name,
    required String uid,
    required String profileUrl,
  }) async {
    try {
      if (await InternetConnectivity.isUserOffline()) {
        throw SocketException("");
      }

      return FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(tournamentsCollection).doc(tournamentId).get();
        Tournament tournament = Tournament.fromDocumentSnapshot(documentSnapshot);
        //if tournament not started and players is less than 8
        if (tournament.totalPlayers != numberOfPlayerForTournament) {
          transaction.update(documentSnapshot.reference, {
            "totalPlayers": tournament.totalPlayers + 1,
            "players": FieldValue.arrayUnion([
              {
                "name": name,
                "profileUrl": profileUrl,
                "uid": uid,
              }
            ]),
          });
          //do not search again for tournament
          return false;
        } else {
          //to search again for tournament or not
          return true;
        }
      });
    } on SocketException catch (_) {
      throw TournamentException(errorMessageCode: noInternetCode);
    } on PlatformException catch (_) {
      throw TournamentException(errorMessageCode: unableToFindRoomCode);
    } catch (_) {
      throw TournamentException(errorMessageCode: defaultErrorMessageCode);
    }
  }
}