import 'package:flashzone_web/src/backend/aws/aws_service.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final backend = Provider((ref) => BackendService(ref));

class BackendService {
  final Ref ref;
  late AwsService aws;
  BackendService(this.ref) {
    aws = AwsService(ref);
  }

  Future<List<Flash>?>? getFlashes() {
    return null;
  }
}