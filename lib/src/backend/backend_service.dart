import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/backend/firebase/firebase_service.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backend = Provider((ref) => BackendService(ref));
final currentuser = StateProvider<FZUser>((ref) => FZUser.dummy());
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
  Future<FZResult> updateProfile(FZUser? fzUser) => firebase.updateProfile(fzUser);
  Future<FZUser?> fetchRemoteUser(String userId) => firebase.fetchRemoteUser(userId);

  Future<void> requestPermissions() async {
    await LocationService.handleLocationPermission();
  } 

  void signInWithCredential(dynamic creds) => firebase.signInWithCredential(creds);
  Future<void> signOut() => firebase.signOut();

  Future<FZResult> createNewFlash(Flash flash) => firebase.createNewFlash(flash);
  Future<List<Flash>> getFlashes(double radius) => firebase.getFlashes(radius);
  Future<Flash?> fetchFlash(String flashId) => firebase.fetchFlash(flashId);

  Future<FZResult> uploadImage(String filePath, String fileName) => firebase.uploadImage(filePath, fileName);

  Future<List<Event>> getEvents(double radius) => firebase.getEvents(radius);
  Future<FZResult> createNewEvent(Event event) => firebase.createNewEvent(event);
}