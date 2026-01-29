import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/model/appointments.dart';
import 'package:flashzone_web/src/model/available_slots.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/purchased_item.dart';
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
      final querySnapshot = await db.collection(Event.collectionName)
        .where(Event.byFamKey, isEqualTo: famId)
        .get();
      print("Fetching fam events: got ${querySnapshot.docs.length} events byFamId = $famId");
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

  Future<FZResult> addPurchasedItem(PurchasedItem purchasedItem) async {
    try {
      final docRef = await db.collection(PurchasedItem.collectionName).add(purchasedItem.toMap());
      await docRef.update({'id': docRef.id});
      return FZResult.success(docRef.id);
    } catch (e) {
      return FZResult.error(e.toString());
    }
  }

  Future<PurchasedItem> getPurchasedItemsForUser(String buyerUserId) async {
    try {
      final querySnapshot = await db.collection(PurchasedItem.collectionName)
        .where(PurchasedItem.fieldBuyerUserId, isEqualTo: buyerUserId)
        .get();
      //print("Fetching purchased items: got ${querySnapshot.docs.length} items for buyerUserId = $buyerUserId");
      if(querySnapshot.docs.isNotEmpty) {
        return PurchasedItem.fromMap(querySnapshot.docs[0].data(), querySnapshot.docs[0].id);
      } else {
        throw FirebaseError(message: "No purchased items found for buyerUserId = $buyerUserId");
      }
    } catch (e) {
      throw FirebaseError(message: "Getting purchased items for user: ${e.toString()}");
    }
  }

  Future<PurchasedItem> getPurchasedItemsForFam(String sellerFamId) async {
    try {
      final querySnapshot = await db.collection(PurchasedItem.collectionName)
        .where(PurchasedItem.fieldSellerFamId, isEqualTo: sellerFamId)
        .get();
      //print("Fetching purchased items: got ${querySnapshot.docs.length} items for sellerFamId = $sellerFamId");
      if(querySnapshot.docs.isNotEmpty) {
        return PurchasedItem.fromMap(querySnapshot.docs[0].data(), querySnapshot.docs[0].id);
      } else {
        throw FirebaseError(message: "No purchased items found for sellerFamId = $sellerFamId");
      }
    } catch (e) {
      throw FirebaseError(message: "Getting purchased items for fam: ${e.toString()}");
    }
  }

  

  Future<AvailableSlots> getAvailableSlotsForProvider(String providerUserId, String providerFamId) async {
    try {
      final querySnapshot = await db.collection(AvailableSlots.collectionName)
        .where(AvailableSlots.fieldProviderUserId, isEqualTo: providerUserId)
        .where(AvailableSlots.fieldProviderFamId, isEqualTo: providerFamId)
        .get();
      //print("Fetching fam available slots: got ${querySnapshot.docs.length} slots for providerUserId = $providerUserId");
      if(querySnapshot.docs.isNotEmpty) {
        return AvailableSlots.fromMap(querySnapshot.docs[0].data(), querySnapshot.docs[0].id);
      } else {
        throw FirebaseError(message: "No available slots found for providerUserId = $providerUserId");
      }
    } catch (e) {
      throw FirebaseError(message: "Getting provider available slots: ${e.toString()}");
    }
  }

  Future<List<Appointment>> getBookingsForUser(String userId) async {
    try {
      final querySnapshot = await db.collection(Appointment.collectionName)
        .where(Appointment.fieldProviderId, isEqualTo: userId)
        .get();
      //print("Fetching fam appointments: got ${querySnapshot.docs.length} appointments byFamId = $famId");
      if(querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((e) => Appointment.fromMap(e.data(), e.id))
        .toList();
      } else {
        return List.empty();
      }
    } catch (e) {
      throw FirebaseError(message: "Getting user appointments: ${e.toString()}");
    }
  }

  Future<List<Appointment>> getMyBookings() async {
    try {
      final querySnapshot = await db.collection(Appointment.collectionName)
        .where(Appointment.fieldConsumerId, isEqualTo: ref.read(currentuser).id)
        .get();
      //print("Fetching fam appointments: got ${querySnapshot.docs.length} appointments byFamId = $famId");
      if(querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((e) => Appointment.fromMap(e.data(), e.id))
        .toList();
      } else {
        return List.empty();
      }
    } catch (e) {
      throw FirebaseError(message: "Getting my appointments: ${e.toString()}");
    }
  }

  Future<Appointment> makeBooking(Appointment appointment) async {
    try {
      final docRef = await db.collection(Appointment.collectionName).add(appointment.toMap());
      await docRef.update({'id': docRef.id});
      final doc = await docRef.get();
      return Appointment.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw FirebaseError(message: "Making booking: ${e.toString()}");
    }
  }

  Future<FZResult> deleteBooking(String appointmentId) async {
    try {
      await db.collection(Appointment.collectionName).doc(appointmentId).delete();
      return FZResult.success('Appointment deleted successfully');
    } catch (e) {
      return FZResult.error(e.toString());
    }
  }


  GeoPoint geopointFrom(Map<String, dynamic> data) =>
     (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;

}