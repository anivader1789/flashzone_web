// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlu97bk9nWEZ-G9DuwltTN0MWbQ0GQS4I',
    appId: '1:26609542744:web:f849cac2f437ec08708c2d',
    messagingSenderId: '26609542744',
    projectId: 'zone-f-6e47c',
    authDomain: 'zone-f-6e47c.firebaseapp.com',
    databaseURL: 'https://zone-f-6e47c.firebaseio.com',
    storageBucket: 'zone-f-6e47c.firebasestorage.app',
    measurementId: 'G-WK7XW2W3HZ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA73wlbXyV7dXXmb7NgWsB7Wy18WiRD4n4',
    appId: '1:26609542744:android:75823fdbd70eb21f708c2d',
    messagingSenderId: '26609542744',
    projectId: 'zone-f-6e47c',
    databaseURL: 'https://zone-f-6e47c.firebaseio.com',
    storageBucket: 'zone-f-6e47c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDRhfLCv2Uuq7n448idHaoa2nNXhLuRBuM',
    appId: '1:26609542744:ios:0a6a174361e3782e708c2d',
    messagingSenderId: '26609542744',
    projectId: 'zone-f-6e47c',
    databaseURL: 'https://zone-f-6e47c.firebaseio.com',
    storageBucket: 'zone-f-6e47c.firebasestorage.app',
    iosBundleId: 'com.example.flashzoneWeb',
  );
}