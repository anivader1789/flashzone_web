import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_auth_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_service.dart';
import 'package:flashzone_web/src/model/auth_creds.dart';
import 'package:flashzone_web/src/model/chat.dart';
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

final backend = Provider((ref) => BackendService(ref));
final currentuser = StateProvider<FZUser>((ref) => FZUser.signedOut());
final flashes = StateProvider((ref) => List<Flash>.empty(growable: true));
final messages = StateProvider<Map<FZUser,List<ChatMessage>>>((ref) => <FZUser,List<ChatMessage>>{});
final authLoaded = StateProvider<bool>((ref) => false);

final invitationCode = StateProvider<String?>((ref) => null);
final invitationCodeError = StateProvider<String?>((ref) => null);
final userToVerify = StateProvider<FZUser?>((ref) => null);

class BackendService {
  final Ref ref;
  late AwsService aws;
  late FirebaseService firebase;
  late FirebaseAuthService firebaseAuth;
  BackendService(this.ref) {
    aws = AwsService(ref);
    firebase = FirebaseService(ref: ref);
    firebaseAuth = FirebaseAuthService(ref: ref);
  }

  Future<void> init() async {
    //await requestPermissions();
    //await LocationService.updateCurrentLocation(ref);
    return firebase.init();
  }

  Future<FZResult?> sendMessage(ChatMessage chat) {
    return Future(() => null);
  }

  Future<Map<String, dynamic>?> fetchUserDetails(FZUser user) => firebase.fetchUserDetails(user);
  Future<FZResult> addNewUser(FZUser? fzUser) => firebase.addNewUser(fzUser);

  Future<FZResult> createEmailAccount(String email, String password) => firebaseAuth.createEmailAccount(email, password);
  Future<FZResult> signinEmail(String email, String password) => firebaseAuth.signinEmail(email, password);
  Future<void> sendVerificationEmail() => firebaseAuth.sendVerificationEmail();
  Future<void> sendPasswordResetEmail() => firebaseAuth.sendPasswordResetEmail();
  Future<bool> loadUserVerificationStatus() => firebaseAuth.isUserVerified();

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
  Future<FZUser?> fetchRemoteUser(String userId) => firebase.fetchRemoteUser(userId);

  Future<void> requestPermissions() async {
    await LocationService.handleLocationPermission();
  } 

  FirebaseAuth getAuthInstance() => firebase.getAuthInstance();
  void signInWithCredential(AuthCreds creds) => firebaseAuth.signInWithCredential(creds);
  Future<void> signOut() => firebase.signOut();


  Future<FZResult> createNewFlash(Flash flash) async {
    final flashesRef = ref.read(flashes);
    final res = await firebase.createNewFlash(flash);
    flashesRef.add(res.returnedObject);
    ref.read(flashes.notifier).update((state) => flashesRef);
    return res;
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

  Future<FZResult> uploadImage(Uint8List data, String fileName) => firebase.uploadImage(data, fileName);

  Future<List<Event>> getEvents(double radius) => firebase.getEvents(radius);
  Future<Event?> fetchEvent(String eventId) => firebase.fetchEvent(eventId);
  Future<FZResult> createNewEvent(Event event) => firebase.createNewEvent(event);
  Future<List<FZNotification>> fetchNotifications(String email) => firebase.fetchNotifications(email);
}