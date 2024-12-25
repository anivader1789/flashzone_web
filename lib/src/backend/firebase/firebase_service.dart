import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/firebase_options.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

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

    _firebaseAuth.authStateChanges().listen((user) => authStatusChanged(user));
  } 

  void signInWithCredential(dynamic creds) {
    _firebaseAuth.signInWithCredential(creds);
  }

  Future<void> signOut() {
    
    return _firebaseAuth.signOut();
  }

  void authStatusChanged(User? newUser) {
    if (newUser == null) {
      print('User is signed out!');
      ref.read(authLoaded.notifier).update((state) => true);
      ref.read(currentuser.notifier).update((state) => FZUser.dummy());
    } else {
      print('User is signed in!');
      ref.read(authLoaded.notifier).update((state) => true);
      assert(newUser.runtimeType == User);
      final user = newUser;
      configureProfile(user);
    }
  
  }

  void configureProfile(User firebaseUser) async {
    FZUser fzUser = FZUser();
    fzUser.id = firebaseUser.uid;
    //sourceUser.phone = firebaseUser.phoneNumber;
    fzUser.email = firebaseUser.email;
    fzUser.name = firebaseUser.displayName;
    fzUser.avatar = firebaseUser.photoURL;

    //await backendRef.requestPermissions();
    
    // if(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    //   final userToken = await backendRef.getUserToken();
    //   print("Got user token: $userToken");
    //   fzUser.token = userToken;
    // }
    
    ref.read(currentuser.notifier).update((state) => fzUser);
    
    //Fetch authenticated user details from server
    fetchUserDetails(fzUser)
    //If the above returned null,user does not exists in db. In that case, the following will return the sourceuser which we had with authentication
    //Else if above returned data map, the following returns null - means user is already there, no need to go further than the following call
      .then((value) => fzUser.updateWith(value, ref))
      //If this returned null that means user already exists in db, then the following call does nothing and code is withdrawn. 
      //Otherwise if sourceuser is returned, then a new user is added in the db
      .then((value) => addNewUser(value))
      .then((value) {
        if(value.code ==  SuccessCode.withdrawn) {
          print("User already exists");
        } else if(value.code == SuccessCode.successful) {
          print("New User is created");
        }
      })
      .catchError((e) {
        print("Exception while updating user after auth: ${e.toString()}");
      } );
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

  Future<FZResult> addNewUser(FZUser? fzUser) async {
    if(fzUser == null) {
      return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
    }

    try {
      if(fzUser.id == null) {
        print("WARNING!!! - tried to add user obj without id ---------");
        final result = await _db.collection(FZUser.collection).add(fzUser.addNewUserObject());
        fzUser.id = result.id;
        ref.read(currentuser.notifier).update((state) => fzUser);
        //_analytics.logEvent(name: "newUser");
        return FZResult(code: SuccessCode.successful, message: "New user created with id: ${fzUser.id}");
      } else {
        await _db.collection(FZUser.collection).doc(fzUser.id).set(fzUser.addNewUserObject(), SetOptions(merge: true));
        //_analytics.logEvent(name: "newUser");
        return FZResult(code: SuccessCode.successful, message: "User updated with id: ${fzUser.id}");
      }

    } catch(e) {
      throw FirebaseError(message: "Thrown: ${e.toString()}");
    }
  }

  Future<FZUser?> fetchRemoteUser(String userId) async {
    try {
      final docRef = _db.collection(FZUser.collection).doc(userId);
      final result = await docRef.get();
      if(result.data() == null) {
        print("doc fetched but is null");
        return null;
      } else {
        final data = result.data() as Map<String, dynamic>;
        return FZUser.newSourceUserWithData(result.id, data);
      }
    } catch(e) {
      print("Error in Fetch user data: ${e.toString()}");
      throw FirebaseError(message: "Fetch user data: ${e.toString()}");
    }
  }

  Future<FZResult> updateProfile(FZUser? fzUser) async {
    if(fzUser == null) {
      return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
    }

    try {
      if(fzUser.id == null) {
        print("WARNING!!! - tried to add user obj without id ---------");
        final result = await _db.collection(FZUser.collection).add(fzUser.profileUpdateObject());
        fzUser.id = result.id;
        ref.read(currentuser.notifier).update((state) => fzUser);
        return FZResult(code: SuccessCode.successful, message: "New user created with id: ${fzUser.id}");
      } else {
        await _db.collection(FZUser.collection).doc(fzUser.id).update(fzUser.profileUpdateObject());
        return FZResult(code: SuccessCode.successful, message: "User updated with id: ${fzUser.id}");
      }

    } catch(e) {
      throw FirebaseError(message: "Thrown: ${e.toString()}");
    }
  }

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

  Future<List<Event>> getEvents(double radius) async {
    try {
      final userLocation = GeoFirePoint(ref.read(userCurrentLocation));
      final querySnapshot = await GeoCollectionReference(_db.collection(Flash.collectionName))
                .fetchWithin(
                  center: userLocation, 
                  radiusInKm: radius, 
                  field: "geo", 
                  geopointFrom: geopointFrom
                );
      if(querySnapshot.isNotEmpty) {
        print("Fetched event");
        return querySnapshot.map((e) => Event.fromDocSnapshot(e.id, e.data())).toList();
      } else {
        return List.empty();
      }
    } catch(e) {
      throw FirebaseError(message: "Getting flashes: ${e.toString()}");
    }
  }

  Future<List<Flash>> getFlashes(double radius) async {
    try {
      final userLocation = GeoFirePoint(ref.read(userCurrentLocation));
      final querySnapshot = await GeoCollectionReference(_db.collection(Flash.collectionName))
                .fetchWithin(
                  center: userLocation, 
                  radiusInKm: radius, 
                  field: "geo", 
                  geopointFrom: geopointFrom
                );
      if(querySnapshot.isNotEmpty) {
        print("Fetched flashes");
        return querySnapshot.map((e) => Flash.fromDocSnapshot(e.id, e.data())).toList();
      } else {
        return List.empty();
      }
    } catch(e) {
      throw FirebaseError(message: "Getting flashes: ${e.toString()}");
    }
  }

  Future<Flash?> fetchFlash(String flashId) async {
    try {
      final docRef = _db.collection(Flash.collectionName).doc(flashId);
      final result = await docRef.get();
      if(result.data() == null) {
        print("flash fetched but is null");
        return null;
      } else {
        print("flash fetched with id: ${result.id}");
        final data = result.data() as Map<String, dynamic>;
        return Flash.fromDocSnapshot(result.id, data);
      }
    } catch(e) {
      print("Error in Fetch flash data: ${e.toString()}");
      throw FirebaseError(message: "Fetch flash data: ${e.toString()}");
    }
  }

  Future<FZResult> createNewFlash(Flash flash) async {
    try {
      final doc = await _db.collection(Flash.collectionName).add(flash.creationObj());
      flash.id = doc.id;
      return FZResult(code: SuccessCode.successful, message: "Created a new session}", returnedObject: flash);
    }  catch(e) {
      throw FirebaseError(message: "Adding new session: ${e.toString()}");
    }
  }

  GeoPoint geopointFrom(Map<String, dynamic> data) =>
     (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
}