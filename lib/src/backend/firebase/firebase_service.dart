import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/firebase_options.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseService {
  late FirebaseApp _firebase;
  late FirebaseAuth _firebaseAuth;
  late FirebaseFirestore _db;
  late FirebaseStorage _firebaseStorage;
  late Ref ref;
  
  FirebaseService({required this.ref});

  Future<void> init() async {
    _firebase = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _db = FirebaseFirestore.instance;
    //_analytics = FirebaseAnalytics.instanceFor(app: _firebase);
    _firebaseAuth = FirebaseAuth.instanceFor(app: _firebase);
    //await _firebaseAuth.setPersistence(Persistence.INDEXED_DB);
    _firebaseStorage = FirebaseStorage.instance;
  } 

  Future<Map<String, dynamic>?> fetchUserDetails(FZUser user) async {
    try {
      final docRef = _db.collection(FZUser.collection).doc(user.id);
      final result = await docRef.get();
      if(result.data() == null) {
        print("doc fetched but is null");
        return null;
      } else {
        final data = result.data() as Map<String, dynamic>;
        //_analytics.logEvent(name: "login");
        return data;
        // ...
      }
    } catch(e) {
      throw FirebaseError(message: "Fetch user data: ${e.toString()}");
    }
  }

  // Future<FZUser?> fetchRemoteUser(String userId) async {
  //   try {
  //     final docRef = _db.collection(FZUser.collection).doc(userId);
  //     final result = await docRef.get();
  //     if(result.data() == null) {
  //       print("doc fetched but is null");
  //       return null;
  //     } else {
  //       final data = result.data() as Map<String, dynamic>;
  //       return FZUser.newSourceUserWithData(result.id, data);
  //     }
  //   } catch(e) {
  //     print("Error in Fetch user data: ${e.toString()}");
  //     throw FirebaseError(message: "Fetch user data: ${e.toString()}");
  //   }
  // }

  // Future<FZResult> addNewUser(FZUser? sourceUser) async {
  //   if(sourceUser == null) {
  //     return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
  //   }

  //   try {
  //     if(sourceUser.id == null) {
  //       print("WARNING!!! - tried to add user obj without id ---------");
  //       final result = await _db.collection(SourceUser.collectionName()).add(sourceUser.addNewUserObject());
  //       sourceUser.id = result.id;
  //       ref.read(userProvider.notifier).update((state) => sourceUser);
  //       _analytics.logEvent(name: "newUser");
  //       return SourceResult(code: SuccessCode.successful, message: "New user created with id: ${sourceUser.id}");
  //     } else {
  //       await _db.collection(SourceUser.collectionName()).doc(sourceUser.id).set(sourceUser.addNewUserObject(), SetOptions(merge: true));
  //       _analytics.logEvent(name: "newUser");
  //       return SourceResult(code: SuccessCode.successful, message: "User updated with id: ${sourceUser.id}");
  //     }

  //   } catch(e) {
  //     throw FirebaseError(message: "Thrown: ${e.toString()}");
  //   }
  // }

  // Future<List<Flash>> getFlashes() async {
  //   try {
  //     final currentUser = ref.read(userProvider);
  //     final querySnapshot = await _db.collection(Flash.collectionName).where(field);
  //     if(querySnapshot.docs.isNotEmpty) {
  //       print("Fetched source sessions");
  //       return querySnapshot.docs.map((e) => Session.newSessionWithData(e.id, e.data())).toList();
  //     } else {
  //       return List.empty();
  //     }
  //   } catch(e) {
  //     throw FirebaseError(message: "Getting source sessions: ${e.toString()}");
  //   }
  // }
}