import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

final userCurrentLocation = StateProvider<GeoPoint>((ref) => const GeoPoint(41.014412, 73.752798));

class LocationService {

  static Future<bool> handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {   
        //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  static Future<void> updateCurrentLocation(WidgetRef ref) async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
          print("Updated current location to: $position");
          ref.read(userCurrentLocation.notifier).update((state) => GeoPoint(position.latitude, position.longitude));
        }).catchError((e) {
          debugPrint(e);
        });
  }

  static Future<String?> getAddressFromLatLng(WidgetRef ref) async {
    try {
      GeoPoint coords = ref.read(userCurrentLocation);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coords.latitude,
        coords.longitude
      );

      Placemark place = placemarks[0];

      print("Got landmark: $place from $coords");

      return "${place.locality}, ${place.country}";
    } catch (e) {

      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

}