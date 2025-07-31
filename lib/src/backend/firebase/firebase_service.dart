
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flashzone_web/firebase_options.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/invitation.dart';
import 'package:flashzone_web/src/model/notification.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class FirebaseService {
  late FirebaseApp _firebase;
  late FirebaseAuth _firebaseAuth;
  late FirebaseFirestore _db;
  late FirebaseStorage _firebaseStorage;
  late Ref ref;
  
  
  FirebaseService({required this.ref});

  FirebaseFirestore get db => _db;
  FirebaseStorage get firebaseStorage => _firebaseStorage;

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

  

  FirebaseAuth getAuthInstance() => _firebaseAuth;

  Future<void> signOut() {

    return _firebaseAuth.signOut();
  }

  void authStatusChanged(User? newUser) {
    if (newUser == null) {
      print('User is signed out!');
      ref.read(authLoaded.notifier).update((state) => true);
      ref.read(currentuser.notifier).update((state) => FZUser.signedOut());
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

    //FirebaseAu

    //await backendRef.requestPermissions();
    
    // if(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
    //   final userToken = await backendRef.getUserToken();
    //   print("Got user token: $userToken");
    //   fzUser.token = userToken;
    // }
    
    //ref.read(currentuser.notifier).update((state) => fzUser);
    
    //Fetch authenticated user details from server
    fetchUserDetails(fzUser)
    //If the above returned null,user does not exists in db. In that case, the following will return the user which we had with authentication
    //Else if above returned data map, the following returns null - means user is already there, no need to go further than the following call
      .then((value) => fzUser.updateWith(value, ref))
      //If this returned null that means user already exists in db, then the following call does nothing and code is withdrawn. 
      //Otherwise if sourceuser is returned, then a new user is added in the db

      //Bypassing user verification
      //.then((value) => newUserCheck(value))
      .then((value) => addNewUser(fzUser))
      .then((value) {
        // if(value.code ==  SuccessCode.successful) {
        //   //print("Invitation code fetched");
        //   ref.read(userToVerify.notifier).update((state) => fzUser);
        //   ref.read(invitationCode.notifier).update((state) => value.returnedObject);
          
        // } else if(value.code == SuccessCode.withdrawn) {
        //   //print("User already exists");
        //   ref.read(currentuser.notifier).update((state) => fzUser);

        // } else if(value.code == SuccessCode.failed) {
        //   //print("Invitation code could not be found on the server");
        //   ref.read(invitationCodeError.notifier).update((state) => "Your invitation code was not found. Please contact the admins");
        // }

        //Bypassing user verification
        ref.read(currentuser.notifier).update((state) => fzUser);
      })
      .catchError((e) {
        //print("Exception while updating user after auth: ${e.toString()}");
      } );
  }

  Future<void> resetSignIn() async {
    await signOut();
    ref.read(userToVerify.notifier).update((state) => null);
    ref.read(invitationCode.notifier).update((state) => null);
    ref.read(invitationCodeError.notifier).update((state) => null);
  }

  Future<Map<String, dynamic>?> fetchUserDetails(FZUser user) async {
    try {
      final docRef = _db.collection(FZUser.collection).doc(user.id);
      final result = await docRef.get();
      if(result.data() == null) {
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

  Future<FZResult> newUserCheck(FZUser? fzUser) async {
    if(fzUser == null) {
      return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
    }

    try {
      //Now checking if user has a valid invitation id
      final invitation = await fetchInvitationCode(fzUser.email);
      if(invitation == null) {
        return FZResult(code: SuccessCode.failed, message: "Invitation code does not exist");
      } else {
        return FZResult(code: SuccessCode.successful, message: "Invitation phase.", returnedObject: invitation.code);
      }

    } catch(e) {
      throw FirebaseError(message: "Thrown: ${e.toString()}");
    }
  }

  Future<FZResult> addNewUser(FZUser? fzUser) async {
    if(fzUser == null) {
      return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
    }

    try {
      if(fzUser.id == null) {
        final result = await _db.collection(FZUser.collection).add(fzUser.addNewUserObject());
        fzUser.id = result.id;
        //_analytics.logEvent(name: "newUser");
        return completeUserVerification(fzUser);
      } else {
        await _db.collection(FZUser.collection).doc(fzUser.id).set(fzUser.addNewUserObject(), SetOptions(merge: true));
        //_analytics.logEvent(name: "newUser");
        return completeUserVerification(fzUser);
      }

    } catch(e) {
      throw FirebaseError(message: "Thrown: ${e.toString()}");
    }
  }

  Future<FZResult> completeUserVerification(FZUser fzUser) async {
    try {
      await deleteInvitationCode(fzUser.email);
      ref.read(userToVerify.notifier).update((state) => null,);
      ref.read(currentuser.notifier).update((state) => fzUser,);
      ref.read(invitationCode.notifier).update((state) => null,);
      ref.read(invitationCodeError.notifier).update((state) => null,);

      return FZResult(code: SuccessCode.successful, message: "Verification complete. New user created with id: ${fzUser.id}");
    } catch (e) {
      throw FirebaseError(message: "Thrown: ${e.toString()}");
    }
  }

  Future<FZUser?> fetchRemoteUser(String userId) async {
    try {
      final docRef = _db.collection(FZUser.collection).doc(userId);
      final result = await docRef.get();
      if(result.data() == null) {
        return null;
      } else {
        final data = result.data() as Map<String, dynamic>;
        return FZUser.newSourceUserWithData(result.id, data);
      }
    } catch(e) {
      throw FirebaseError(message: "Fetch user data: ${e.toString()}");
    }
  }

  Future<InvitationCode?> fetchInvitationCode(String? email) async {
    print("fetching invitiation code: $email");
    if(email == null) return null;

    try {
      final docRef = _db.collection(InvitationCode.collection).where(InvitationCode.emailKey, isEqualTo: email);
      final result = await docRef.get();
      if(result.docs.isEmpty) {
        print("No invitation record found");
        return null;
      } else {
        final data = result.docs.first.data();
        print("invitation record found: ${data["email"]}");
        return InvitationCode.fromDocSnapshot(data);
      }
    } catch(e) {
      print("No invitation record found - exception thrown ${e.toString()}");
      return null;
    }
  }

  Future<bool> deleteInvitationCode(String? email) async {
    if(email == null) return true;

    try {
      final docRef = _db.collection(InvitationCode.collection).where(InvitationCode.emailKey, isEqualTo: email);
      final result = await docRef.get();
      if(result.docs.isEmpty) {
        return true;
      } else if(result.docs.length == 1) {
        final resDocs = result.docs;
        for(final doc in resDocs) {
          await _db.collection(InvitationCode.collection).doc(doc.id).delete();
        }
        
        return true;
      }
    } catch(e) {
      return false;
    } finally {
      return false;
    }
  }

  Future<FZResult> updateProfile(FZUser? fzUser) async {
    if(fzUser == null) {
      return FZResult(code: SuccessCode.withdrawn, message: "No user to update");
    }

    try {
      if(fzUser.id == null) {
        final result = await _db.collection(FZUser.collection).add(fzUser.profileUpdateObject());
        fzUser.id = result.id;
        ref.read(currentuser.notifier).update((state) => fzUser);
        return FZResult(code: SuccessCode.successful, message: "New user created with id: ${fzUser.id}", returnedObject: fzUser);
      } else {
        await _db.collection(FZUser.collection).doc(fzUser.id).update(fzUser.profileUpdateObject());
        ref.read(currentuser.notifier).update((state) => fzUser);
        return FZResult(code: SuccessCode.successful, message: "User updated with id: ${fzUser.id}", returnedObject: fzUser);
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

  Future<FZResult> deleteFlash(Flash flash) async {
    try {
      await deleteAllComments(flash.id!);
      await _db.collection(Flash.collectionName).doc(flash.id!).delete();
      return FZResult(code: SuccessCode.successful, message: "Delete flash");
    } catch (e) {
      return FZResult(code: SuccessCode.failed);
    }
  }

  Future<FZResult> deleteAllComments(String flashId) async {

    try {
      final res = await _db.collection(CommentsList.collection).where(CommentsList.flashKey, isEqualTo: flashId).get();
      if(res.docs.isNotEmpty) {
        await _db.collection(CommentsList.collection).doc(res.docs.first.id).delete();
        return FZResult(code: SuccessCode.successful, message: "Comment list deleted");
      } else {
        return FZResult(code: SuccessCode.withdrawn, message: "No delete records found to delete");
      }
    } catch (e) {
      return FZResult(code: SuccessCode.failed, message: e.toString());
    }
  }

  Future<FZResult> deleteComment(Flash flash, String fromUserId, String content) async {

    try {
      final res = await _db.collection(CommentsList.collection).where(CommentsList.flashKey, isEqualTo: flash.id).get();
      if(res.docs.isNotEmpty) {
        //await _db.collection(CommentsList.collection).doc(res.docs.first.id).delete();
        final commentList = CommentsList.fromDocSnapshot(res.docs.first.id, res.docs.first.data()) ;

        if(commentList == null) {
          print("Comment list was null");
          return FZResult(code: SuccessCode.withdrawn, message: "Comment List object null");
        }

        int numOfCommentsDeleted = 0;
        for(Comment cmt in commentList.comments) {
          if(cmt.userId == fromUserId && cmt.content == content) {
            commentList.comments.remove(cmt);
            numOfCommentsDeleted++;
          }
        }

        print("going to delete $numOfCommentsDeleted comments of content: $content");

        await _db.collection(CommentsList.collection).doc(commentList.id).update(commentList.updateObject());
        flash.comments -= numOfCommentsDeleted;
        await updateFlash(flash);

        return FZResult(code: SuccessCode.successful, message: "Comment deleted", returnedObject: numOfCommentsDeleted);
      } else {
        return FZResult(code: SuccessCode.withdrawn, message: "No delete records found to delete");
      }
    } catch (e) {
      return FZResult(code: SuccessCode.failed, message: e.toString());
    }
  }

  Future<FZResult> createNewEvent(Event event) async {
    try {
      final doc = await _db.collection(Event.collectionName).add(event.creationObj());
      event.id = doc.id;
      return FZResult(code: SuccessCode.successful, message: "Created a new event}", returnedObject: event.id);
    }  catch(e) {
      throw FirebaseError(message: "Adding new event: ${e.toString()}");
    }
  }

  Future<FZResult> updateEvent(Event event) async {
    try {
      await _db.collection(Event.collectionName).doc(event.id).update(event.updateObj());
      return FZResult(code: SuccessCode.successful, message: "Updated event}", returnedObject: event.id);
    }  catch(e) {
      throw FirebaseError(message: "Updating event: ${e.toString()}");
    }
  }

  Future<List<Event>> getEvents(double radius) async {
    try {
      final userLocation = GeoFirePoint(ref.read(userCurrentLocation));
      final querySnapshot = await GeoCollectionReference(_db.collection(Event.collectionName))
                .fetchWithin(
                  center: userLocation, 
                  radiusInKm: radius, 
                  field: "geo", 
                  geopointFrom: geopointFrom
                );
      if(querySnapshot.isNotEmpty) {
        return querySnapshot.map((e) => Event.fromDocSnapshot(e.id, e.data())).toList();
      } else {
        return List.empty();
      }
    } catch(e) {
      throw FirebaseError(message: "Getting flashes: ${e.toString()}");
    }
  }

  Future<Event?> fetchEvent(String eventId) async {
    try {
      final docRef = _db.collection(Event.collectionName).doc(eventId);
      final result = await docRef.get();
      if(result.data() == null) {
        return null;
      } else {
        final data = result.data() as Map<String, dynamic>;
        return Event.fromDocSnapshot(result.id, data);
      }
    } catch(e) {
      throw FirebaseError(message: "Fetch event data: ${e.toString()}");
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
        return null;
      } else {
        final data = result.data() as Map<String, dynamic>;
        return Flash.fromDocSnapshot(result.id, data);
      }
    } catch(e) {
      throw FirebaseError(message: "Fetch flash data: ${e.toString()}");
    }
  }

  Future<FZResult> updateFlash(Flash flash) async {
    try {
      await _db.collection(Flash.collectionName).doc(flash.id).update(flash.updateObj());
      return FZResult(code: SuccessCode.successful, returnedObject: flash);
    } catch(e) {
      throw FZResult(code: SuccessCode.failed, message: "Error with flash update: ${e.toString()}");
    }
  }

  Future<CommentsList?> fetchFlashComments(String flashId) async {
    try {
      final docRef = _db.collection(CommentsList.collection).where(CommentsList.flashKey, isEqualTo: flashId);
      final result = await docRef.get();
      if(result.docs.isEmpty) {
        return null;
      } else {
        final data = result.docs.first;
        return CommentsList.fromDocSnapshot(data.id, data.data());
      }
    } catch(e) {
      throw FirebaseError(message: "Fetch flash comments data: ${e.toString()}");
    }
  }

  Future<FZResult> setFlashComments(CommentsList commentsList) async {
    try {
      if(commentsList.id == null) {
        await _db.collection(CommentsList.collection).add(commentsList.creationObj());
      } else {
        await _db.collection(CommentsList.collection).doc(commentsList.id).update(commentsList.updateObject());
      }
      
      return FZResult(code: SuccessCode.successful, returnedObject: commentsList);
    } catch(e) {
      throw FZResult(code: SuccessCode.failed, message: "Fetch flash comments failed with error: ${e.toString()}");
    }
  }

  Future<List<FZNotification>> fetchNotifications(String email) async {
    try {
      final docSnapshot = await _db.collection(FZNotification.collection).where(
        Filter.or(
          Filter("email", isEqualTo: email),
          Filter("email", isEqualTo: "all") 
          )
      ).get();
      return docSnapshot.docs.map((e) => FZNotification.fromDocSnapshot(e.data()) ?? FZNotification(text: "Error", type: NotificationType.admin)).toList();
    } catch (e) {
      debugPrint(e.toString());
      return List.empty();
    }
  }

  Future<FZResult> createNewFlash(Flash flash) async {
    try {
      final doc = await _db.collection(Flash.collectionName).add(flash.creationObj());
      flash.id = doc.id;
      return FZResult(code: SuccessCode.successful, message: "Created a new flash}", returnedObject: flash);
    }  catch(e) {
      throw FirebaseError(message: "Adding new flash: ${e.toString()}");
    }
  }

  Future<FZResult> sendMessagetoDeveloper(String email, String message) async {
    try {
      final user = ref.read(currentuser);
      final data = {
        "email": email,
        "id": user.id,
        "message": message
      };

      await _db.collection("message_from_users").add(data);
      return FZResult(code: SuccessCode.successful, message: "Message sent successfully");
    }  catch(e) {
      throw FirebaseError(message: "Adding new flash: ${e.toString()}");
    }
  }

  Future<FZResult> uploadImage(Uint8List data, String fileName, String folderName) async {
    try {
      final storageRef = _firebaseStorage.ref().child("$folderName/$fileName");
      final uploadTask = storageRef.putData(data, SettableMetadata(contentType: "image/jpeg"));
      final TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      if(snapshot.state == TaskState.error) {
        return FZResult(code: SuccessCode.failed, message: "Firebase error while uploading $fileName");
      } else if(snapshot.state == TaskState.success) {
        return FZResult(code: SuccessCode.successful, message: "Upload complete", returnedObject: url);
      } else {
        return FZResult(code: SuccessCode.withdrawn, message: "Operation was cancelled while uploading $fileName");
      }
    } catch(e) {
      throw FirebaseError(message: "While uploading clip $fileName: ${e.toString()}");
    }
  }

  Future<FZResult> deleteImage(String url) async {
    try {
      final storageRef = _firebaseStorage.ref().child("img/$url");
      await storageRef.delete();
      return FZResult(code: SuccessCode.successful);
    } catch (e) {
      throw FirebaseError(message: "Exception while deleting image $url: ${e.toString()}");
    }


  }

  GeoPoint geopointFrom(Map<String, dynamic> data) =>
     (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint;
}