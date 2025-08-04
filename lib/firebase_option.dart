import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: "AIzaSyCgkAs2Ay-rHE9lbVxi03UNwxfk9MZzk0w",
    authDomain: "weather-app-assignment-f6ae4.firebaseapp.com",
    projectId: "weather-app-assignment-f6ae4",
    storageBucket: "weather-app-assignment-f6ae4.firebasestorage.app",
    messagingSenderId: "181973317201",
    appId: "1:181973317201:web:ff8bdc6ed63f390e36aa70",
    measurementId: "G-2S4QTEQ4QB"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLmupasbj_tjcIQ5kRgQAmUSRwFu1jMLg',
    appId: '1:181973317201:android:84e5082c2919547936aa70',
    messagingSenderId: '181973317201',
    projectId: 'weather-app-assignment-f6ae4',
    storageBucket: 'weather-app-assignment-f6ae4.firebasestorage.app',
    measurementId: "G-2S4QTEQ4QB"
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA9K-VS2ByCGpccSGTnmsWciUlPmWIYVg4',
    appId: '1:1083843782028:ios:YOUR_IOS_APP_ID4822a9',
    messagingSenderId: '1083843782028',
    projectId: 'weather-44b8c',
    storageBucket: 'weather-44b8c.firebasestorage.app',
    iosBundleId: 'com.example.weatherApp2',
  );
}
