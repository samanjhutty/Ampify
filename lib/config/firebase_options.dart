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
class DefaultFBOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdssOYzAwW_t25V0TBgGylH0lOnXyZRnU',
    appId: '1:962828708485:android:bd7dfa5a4e9eb311e097ec',
    messagingSenderId: '962828708485',
    projectId: 'ampify-samtech',
    storageBucket: 'ampify-samtech.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAKCjfvFna8L9KiOS8aF38neUD9KfYYtgY',
    appId: '1:962828708485:ios:26b7dd048d0c96efe097ec',
    messagingSenderId: '962828708485',
    projectId: 'ampify-samtech',
    storageBucket: 'ampify-samtech.firebasestorage.app',
    androidClientId:
        '962828708485-4luos7db9sokjp48npuptl617g52aaq4.apps.googleusercontent.com',
    iosClientId:
        '962828708485-pu3uqbhm9r8dm65khtjb2dc92f14a4o0.apps.googleusercontent.com',
    iosBundleId: 'com.samtech.ampify',
  );
}
