//A singleton class that manages the cached data for the app. 

import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedDataManager {
  CachedDataManager._privateConstructor();
  static final CachedDataManager _instance = CachedDataManager._privateConstructor();
  factory CachedDataManager() => _instance;

  late Ref _ref; // Field to hold the Ref instance

  void init(Ref ref) {
    _ref = ref; // Initialize the Ref instance
  }

  Ref get ref => _ref; // Getter for the Ref instance

  String? getFamId(String name) {
    final famsRef = ref.read(nearbyFams);
    if(famsRef.isEmpty) return null;
    if(famsRef.any((f) => f.name == name)) {
      return famsRef.firstWhere((f) => f.name == name).id;
    } else {
      return null;
    }
  }
}


