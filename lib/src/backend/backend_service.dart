import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_auth_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_chat_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_fam_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_service.dart';
import 'package:flashzone_web/src/model/auth_creds.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/chat_message.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/invitation.dart';
import 'package:flashzone_web/src/model/notification.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/data/cached_data_manager.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backend = Provider((ref) => BackendService(ref));
final currentuser = StateProvider<FZUser>((ref) => FZUser.signedOut());
final flashes = StateProvider((ref) => List<Flash>.empty(growable: true));
final nearbyFams = StateProvider((ref) => List<Fam>.empty(growable: true));
final myFams = StateProvider((ref) => List<Fam>.empty(growable: true));
final messages = StateProvider<Map<FZUser,List<ChatMessage>>>((ref) => <FZUser,List<ChatMessage>>{});

final authLoaded = StateProvider<bool>((ref) => false);

final cachedRemoteUser = StateProvider<List<FZUser>>((ref) => List<FZUser>.empty(growable: true));

final routeInPipeline = StateProvider<String?>((ref) => null);

final invitationCode = StateProvider<String?>((ref) => null);
final invitationCodeError = StateProvider<String?>((ref) => null);
final userToVerify = StateProvider<FZUser?>((ref) => null);

final famInEdit = StateProvider<Fam?>((ref) => null);
final eventInEdit = StateProvider<Event?>((ref) => null);

class BackendService {
  final Ref ref;
  late AwsService aws;
  late FirebaseService firebase;
  late FirebaseAuthService firebaseAuth;
  late FirebaseChatService firebaseChat;
  late FirebaseFamService firebaseFam;
  BackendService(this.ref) {
    aws = AwsService(ref);
    firebase = FirebaseService(ref: ref);
    
  }

  Future<void> init() async {
    //await requestPermissions();
    //await LocationService.updateCurrentLocation(ref);
    await firebase.init();

    firebaseAuth = FirebaseAuthService(ref: ref);
    firebaseChat = FirebaseChatService(ref: ref, db: firebase.db, firebaseStorage: firebase.firebaseStorage);
    firebaseFam = FirebaseFamService(ref: ref, db: firebase.db, firebaseStorage: firebase.firebaseStorage);
    CachedDataManager().init(ref);
  }


  Future<Map<String, dynamic>?> fetchUserDetails(FZUser user) => firebase.fetchUserDetails(user);
  Future<FZResult> addNewUser(FZUser? fzUser) => firebase.addNewUser(fzUser);

  Future<FZResult> createEmailAccount(String email, String password) => firebaseAuth.createEmailAccount(email, password);
  Future<FZResult> signinEmail(String email, String password) => firebaseAuth.signinEmail(email, password);
  Future<void> sendVerificationEmail() => firebaseAuth.sendVerificationEmail();
  Future<void> sendPasswordResetEmail() => firebaseAuth.sendPasswordResetEmail();
  Future<bool> loadUserVerificationStatus() => firebaseAuth.isUserVerified();
  Future<void> resetSignIn() => firebase.resetSignIn();

  Future<void> verifyPhoneNumber({required String phoneNumber, 
                      required Function (String) failureCallback, 
                      required Function successCallback, 
                      required Function instantVerificationCallback, 
                      required Function timeoutCallback}) => firebaseAuth.verifyPhoneNumber(phoneNumber: phoneNumber, failureCallback: failureCallback, successCallback: successCallback, instantVerificationCallback: instantVerificationCallback, timeoutCallback: timeoutCallback);

  Future<void> submitOTP({required String smsCode, 
                      required Function failureCallback, 
                      required Function successCallback}) => firebaseAuth.submitOTP(smsCode: smsCode, failureCallback: failureCallback, successCallback: successCallback);

  Future<FZResult> deleteFlash(Flash flash) async {
    try {
      await firebase.deleteFlash(flash);
      flash.deleted = true;
      return FZResult(code: SuccessCode.successful);
    } catch (e) {
      return FZResult(code: SuccessCode.failed, message: e.toString());
    }

  }

  Future<FZResult> deleteComment(Flash flash, String fromUserId, String content) async { 
    final res = await firebase.deleteComment(flash, fromUserId, content);
    return res;
  }

  Future<FZResult> updateProfile(FZUser? fzUser) async {
    if(fzUser == null) return Future.value(FZResult(code: SuccessCode.failed, message: "While updating user, no user obj provided")) ;

    final res = await firebase.updateProfile(fzUser);
    if(res.code == SuccessCode.successful) {
      ref.read(currentuser.notifier).update((state) => fzUser);
    }
    return res;
  } 
  Future<FZUser?> fetchRemoteUser(String userId) async {
    final cachedUsers = ref.read(cachedRemoteUser);
    for(FZUser user in cachedUsers) {
      if(user.id == userId) {
        return user;
      }
    }
    
    FZUser? fetchedUser = await firebase.fetchRemoteUser(userId);
    if(fetchedUser != null) {
      cachedUsers.add(fetchedUser);
      ref.read(cachedRemoteUser.notifier).update((state) => cachedUsers);
    }
    return fetchedUser;
  }

  Future<void> requestPermissions() async {
    await LocationService.handleLocationPermission();
  } 

  FirebaseAuth getAuthInstance() => firebase.getAuthInstance();
  void signInWithCredential(AuthCreds creds) => firebaseAuth.signInWithCredential(creds);
  Future<void> signOut() => firebase.signOut();


  Future<FZResult> createNewFlash(Flash flash) async {
    final flashesRef = ref.read(flashes);
    final res = await firebase.createNewFlash(flash);
    if(res.code == SuccessCode.successful) {
      print("Flash created successfully: ${res.returnedObject}");
      flashesRef.add(res.returnedObject);
      ref.read(flashes.notifier).update((state) => flashesRef);
      return res;
    } else  {
      print("Flash creation failed: ${res.message}");
      return FZResult(code: SuccessCode.failed, message: "Flash creation failed, returned object is null");
    }
    
  } 

  Future<List<Flash>> getFlashes(double radius, bool forceRemote) async {
    if(forceRemote) {
      final res = await firebase.getFlashes(radius);
      ref.read(flashes.notifier).update((state) => res);
      return res;
    } else {
      var res = ref.read(flashes);
      if(res.isEmpty) {
        res = await firebase.getFlashes(radius);
        ref.read(flashes.notifier).update((state) => res);
        return res;
      } else {
        return res;
      }
    }
    
  } 

  Future<List<Fam>> getNearbyFams(double radius, { bool forceRemote = false}) async {
    if(forceRemote) {
      final res = await firebaseFam.getNearbyFams(radius);
      ref.read(nearbyFams.notifier).update((state) => res);
      return res;
    } else {
      var res = ref.read(nearbyFams);

      if(res.isEmpty) {
        res = await firebaseFam.getNearbyFams(radius);
        ref.read(nearbyFams.notifier).update((state) => res);
        return res;
      } else {
        return res;
      }
    }
    
  } 

  Future<List<Fam>> getMyFams(String myId, { bool forceRemote = false}) async {
    if(forceRemote) {
      final res = await firebaseFam.getMyFams(myId);
      ref.read(myFams.notifier).update((state) => res);
      return res;
    } else {
      var res = ref.read(myFams);
      if(res.isEmpty) {
        res = await firebaseFam.getMyFams(myId);
        ref.read(myFams.notifier).update((state) => res);
        return res;
      } else {
        return res;
      }
    }
  }

  Future<List<Event>> getFamEvents(String famId) => firebaseFam.getFamEvents(famId);
  
  Future<Flash?> fetchFlash(String flashId) => firebase.fetchFlash(flashId);

  Future<FZResult> updateFlash(Flash flash) async {
    final res = await firebase.updateFlash(flash);
    var flashesRef = ref.read(flashes);
    flashesRef = flashesRef.map((f) {
      if(f.id == flash.id) {
        f = res.returnedObject;
      }
      return f;
    }).toList();

    ref.read(flashes.notifier).update((state) => flashesRef);

    return res;
  } 

  Future<InvitationCode?> fetchInvitationCode(String? email) => firebase.fetchInvitationCode(email);

  Future<CommentsList?> fetchFlashComments(String flashId) => firebase.fetchFlashComments(flashId);
  Future<FZResult> setFlashComments(CommentsList commentsList) => firebase.setFlashComments(commentsList);

  Future<FZResult> uploadImage(Uint8List data, String fileName, String folderName) => firebase.uploadImage(data, fileName, folderName);
  Future<FZResult> deleteImage(String url) => firebase.deleteImage(url);

  Future<String> sendMessage(FZChatMessage message, String groupId) => firebaseChat.sendMessage(message, groupId);

  Stream<List<FZChatMessage>> chatStream(String groupId, int limit) => firebaseChat.chatStream(groupId, limit: limit);
  Future<List<FZChatMessage>> getChats(String groupId, {
    int limit = 50,
    DocumentSnapshot? lastDocumentSnapshot,
  }) => firebaseChat.getChats(groupId, limit: limit, lastDocumentSnapshot: lastDocumentSnapshot);


  Future<String?> findPersonalChat({
    required FZUser sender,
    required FZUser receiver,
  }) => firebaseChat.findPersonalChat(sender: sender, receiver: receiver);
  
  Future<String> initiatePersonalChat({
    required FZUser sender,
    required FZUser receiver,
  }) => firebaseChat.initiatePersonalChat(sender: sender, receiver: receiver);

  Future<String> getOrCreateRefForFamChat({
    required String famId,
  }) => firebaseChat.getOrCreateRefForFamChat(famId: famId);

  

  Future<List<Event>> getEvents(double radius) => firebase.getEvents(radius);
  Future<Event?> fetchEvent(String eventId) => firebase.fetchEvent(eventId);
  Future<FZResult> createNewEvent(Event event) => firebase.createNewEvent(event);
  Future<FZResult> updateEvent(Event event) => firebase.updateEvent(event);
  Future<List<FZNotification>> fetchNotifications(String email) => firebase.fetchNotifications(email);

  Future<FZResult> sendMessagetoDeveloper(String email, String message) => firebase.sendMessagetoDeveloper(email, message);
  
  Future<FZResult> addNewFam(Fam fam) => firebaseFam.addNewFam(fam.creationObj());
  Future<FZResult> updateFam(Fam fam) => firebaseFam.updateFam(fam);
  Future<Fam?> fetchFam(String famId) => firebaseFam.fetchFam(famId);

  
}