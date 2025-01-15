
import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_service.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/comment.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/flash.dart';
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

class BackendService {
  final Ref ref;
  late AwsService aws;
  late FirebaseService firebase;
  BackendService(this.ref) {
    aws = AwsService(ref);
    firebase = FirebaseService(ref: ref);
  }

  Future<void> init() async {
    await requestPermissions();
    await LocationService.updateCurrentLocation(ref);
    return firebase.init();
  }

  Future<FZResult?> sendMessage(ChatMessage chat) {
    return Future(() => null);
  }

  Future<Map<String, dynamic>?> fetchUserDetails(FZUser user) => firebase.fetchUserDetails(user);
  Future<FZResult> addNewUser(FZUser? fzUser) => firebase.addNewUser(fzUser);

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

  void signInWithCredential(dynamic creds) => firebase.signInWithCredential(creds);
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

  Future<CommentsList?> fetchFlashComments(String flashId) => firebase.fetchFlashComments(flashId);
  Future<FZResult> setFlashComments(CommentsList commentsList) => firebase.setFlashComments(commentsList);

  Future<FZResult> uploadImage(Uint8List data, String fileName) => firebase.uploadImage(data, fileName);

  Future<List<Event>> getEvents(double radius) => firebase.getEvents(radius);
  Future<Event?> fetchEvent(String eventId) => firebase.fetchEvent(eventId);
  Future<FZResult> createNewEvent(Event event) => firebase.createNewEvent(event);
}