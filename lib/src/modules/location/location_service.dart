import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocode/geocode.dart';

final userCurrentLocation = StateProvider<GeoPoint>((ref) => const GeoPoint(41.054514, -73.814637));

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

  static Future<void> updateCurrentLocation(dynamic ref) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble("lat");
    final lon = prefs.getDouble("lon");
    if(lat != null && lon != null) {
      ref.read(userCurrentLocation.notifier).update((state) => GeoPoint(lat, lon));
      pullCurrentLocationFromDevice(ref, prefs);
    } else {
      await pullCurrentLocationFromDevice(ref, prefs);
    }
  }

  static Future<void> pullCurrentLocationFromDevice(dynamic ref, SharedPreferences prefs) async {
    final hasPermission = await handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.lowest)
        .then((Position position) {
          print("Updated current location to: $position");
          ref.read(userCurrentLocation.notifier).update((state) => GeoPoint(position.latitude, position.longitude));
          prefs.setDouble("lat", position.latitude);
          prefs.setDouble("lon", position.longitude);
        }).catchError((e) {
          debugPrint(e);
        });
  }

  static Future<String?> getAddressFromLatLng(WidgetRef ref) async {
    try {
      
      GeoPoint coords = ref.read(userCurrentLocation);
      //print("Trying to get landmark from ${coords.latitude}, ${coords.longitude}");
      
      final address = await GeoCode().reverseGeocoding(
        latitude: coords.latitude,
        longitude: coords.longitude
      );

      print("Got placemarks: $address");



      return "${address.city}";
    } catch (e) {

      print("Caught error while getting lkandmark: $e");
      return null;
    }
  }

}