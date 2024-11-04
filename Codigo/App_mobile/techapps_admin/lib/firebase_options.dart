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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyBt2VyvBXDuCGHG0c5S70_Aek-G-ycfi6c',
    appId: '1:519385187996:web:dfa1b495640743244acf59',
    messagingSenderId: '519385187996',
    projectId: 'servicio-scav',
    authDomain: 'servicio-scav.firebaseapp.com',
    storageBucket: 'servicio-scav.appspot.com',
    measurementId: 'G-7S0FH4XVE3',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAE7kq4t-iDdv3uUuQ6scDv4YvSKGkdh34',
    appId: '1:519385187996:android:a7e242192798b57c4acf59',
    messagingSenderId: '519385187996',
    projectId: 'servicio-scav',
    storageBucket: 'servicio-scav.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1CqLw7n4I13YDTjbD5vWwbtIwYJ80utY',
    appId: '1:519385187996:ios:517cc4596e26987c4acf59',
    messagingSenderId: '519385187996',
    projectId: 'servicio-scav',
    storageBucket: 'servicio-scav.appspot.com',
    iosBundleId: 'com.duoctechapps.admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1CqLw7n4I13YDTjbD5vWwbtIwYJ80utY',
    appId: '1:519385187996:ios:1e01cc08af07ab664acf59',
    messagingSenderId: '519385187996',
    projectId: 'servicio-scav',
    storageBucket: 'servicio-scav.appspot.com',
    iosBundleId: 'com.example.techappsAdmin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBt2VyvBXDuCGHG0c5S70_Aek-G-ycfi6c',
    appId: '1:519385187996:web:e375424a7ff232044acf59',
    messagingSenderId: '519385187996',
    projectId: 'servicio-scav',
    authDomain: 'servicio-scav.firebaseapp.com',
    storageBucket: 'servicio-scav.appspot.com',
    measurementId: 'G-4JZWP5JPRM',
  );
}