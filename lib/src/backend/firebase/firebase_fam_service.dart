import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class FirebaseFamService {
  Ref ref;
  FirebaseFirestore db;
  FirebaseStorage firebaseStorage;
  FirebaseFamService({
    required this.ref,
    required this.db,
    required this.firebaseStorage,
  });

  // Add a new Fam
  Future<FZResult> addNewFam(Map<String, dynamic> famData) async {
    try {
      final docRef = await db.collection(Fam.collectionName).add(famData);
      await docRef.update({'id': docRef.id});
      return FZResult.success(docRef.id);
    } catch (e) {
      return FZResult.error(e.toString());
    }
  }

  // Fetch a Fam by ID
  Future<Fam> fetchFam(String famId) async {
    try {
      final doc = await db.collection(Fam.collectionName).doc(famId).get();
      if (doc.exists) {
        return Fam.fromDocSnapshot(doc.id, doc.data() as Map<String, dynamic>);
      } else {
        throw Exception('Fam not found');
      }
    } catch (e) {
      throw Exception('Error fetching Fam: $e');
    }
  }

  // Update a Fam
  Future<FZResult> updateFam(Fam updatedfam) async {
    try {
      await db.collection('fams').doc(updatedfam.id).update(updatedfam.updateObj());
      return FZResult.success('Fam updated successfully');
    } catch (e) {
      return FZResult.error(e.toString());
    }
  }

  Future<List<Fam>> getNearbyFams(double radius) async {
    try {
      final userLocation = GeoFirePoint(ref.read(userCurrentLocation));
      final querySnapshot = await GeoCollectionReference(db.collection(Fam.collectionName))
                .fetchWithin(
                  center: userLocation, 
                  radiusInKm: radius, 
                  field: "geo", 
                  geopointFrom: geopointFrom
                );
      if(querySnapshot.isNotEmpty) {
        return querySnapshot.map((e) => Fam.fromDocSnapshot(e.id, e.data())).toList();
      } else {
        return List.empty();
      }
    } catch(e) {
      throw FirebaseError(message: "Getting nearby fams: ${e.toString()}");
    }
  }

  Future<List<Fam>> getMyFams(String myId) async {
    try {
      final querySnapshot = await db.collection(Fam.collectionName)
        .where(Filter.or(
          Filter(Fam.adminsKey, arrayContains: myId),
          Filter(Fam.membersKey, arrayContains: myId)),
          ).get();

      if(querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((e) => Fam.fromDocSnapshot(e.id, e.data())).toList();
      } else {
        return List.empty();
      }
         
    } catch (e) {
      throw FirebaseError(message: "Getting my fams: ${e.toString()}");
    }
  }

  Future<List<Event>> getFamEvents(String famId) async {
    try {
      final querySnapshot = await db.collection(Fam.collectionName)
        .where(Event.byFamKey, isEqualTo: famId)
        .get();

      if(querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((e) => Event.fromDocSnapshot(e.id, e.data()))
        .toList();
      } else {
        return List.empty();
      }
    } catch (e) {
      throw FirebaseError(message: "Getting my fam events: ${e.toString()}");
    }
  }

  GeoPoint geopointFrom(Map<String, dynamic> data) =>
     (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;

}