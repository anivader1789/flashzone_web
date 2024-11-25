import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/model/chat.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backend = Provider((ref) => BackendService(ref));
final currentuser = Provider<FZUser>((ref) => FZUser.dummy());
final flashes = StateProvider((ref) => List<Flash>.empty(growable: true));
final messages = StateProvider<Map<FZUser,List<ChatMessage>>>((ref) => <FZUser,List<ChatMessage>>{});

class BackendService {
  final Ref ref;
  late AwsService aws;
  BackendService(this.ref) {
    aws = AwsService(ref);
  }

  Future<List<Flash>?>? getFlashes() {
    return null;
  }

  Future<FZResult?> sendMessage(ChatMessage chat) {
    return Future(() => null);
  }
}