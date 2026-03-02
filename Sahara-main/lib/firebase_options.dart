// This file is a placeholder for Firebase configuration
// To generate this file, run: flutterfire configure
// Follow the instructions at: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBALyqIvpmb0UM42RbKPIwmjcKON7RJBE4',
    appId: '1:953036067023:android:0f80e1fc44ec5919e6e7ba',
    messagingSenderId: '953036067023',
    projectId: 'sahara-a72',
    storageBucket: 'sahara-a72.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzJ8cOuNkrzAjuJcr6oWNpPZ0ELI3wyzU',
    appId: '1:953036067023:ios:6d30b833b86f4cc2e6e7ba',
    messagingSenderId: '953036067023',
    projectId: 'sahara-a72',
    storageBucket: 'sahara-a72.firebasestorage.app',
    iosBundleId: 'com.example.sahara',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpNvKNhWx_5LUQvlyWBhWOm4cIsleHqGY',
    appId: '1:953036067023:web:4a38e3d0949a0da9e6e7ba',
    messagingSenderId: '953036067023',
    projectId: 'sahara-a72',
    authDomain: 'sahara-a72.firebaseapp.com',
    storageBucket: 'sahara-a72.firebasestorage.app',
    measurementId: 'G-JK11PVGXV4',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzJ8cOuNkrzAjuJcr6oWNpPZ0ELI3wyzU',
    appId: '1:953036067023:ios:6d30b833b86f4cc2e6e7ba',
    messagingSenderId: '953036067023',
    projectId: 'sahara-a72',
    storageBucket: 'sahara-a72.firebasestorage.app',
    iosBundleId: 'com.example.sahara',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCpNvKNhWx_5LUQvlyWBhWOm4cIsleHqGY',
    appId: '1:953036067023:web:9cd804777c9a9eb1e6e7ba',
    messagingSenderId: '953036067023',
    projectId: 'sahara-a72',
    authDomain: 'sahara-a72.firebaseapp.com',
    storageBucket: 'sahara-a72.firebasestorage.app',
    measurementId: 'G-ZW8XHK57RK',
  );

}
