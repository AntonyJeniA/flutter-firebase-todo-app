// lib/firebase_options.dart
// AUTO-GENERATED from google-services.json for project: taskflow-todo-31a9f

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── ANDROID (from google-services.json) ─────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAScPskgw2l1C63Ifi4IEcP8V9ZN1CvYWc',
    appId: '1:160665272025:android:ef2b1d04eb680daf1348c8',
    messagingSenderId: '160665272025',
    projectId: 'taskflow-todo-31a9f',
    databaseURL: 'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com',
    storageBucket: 'taskflow-todo-31a9f.firebasestorage.app',
  );

  // ─── iOS (use same project values — add iOS app in Firebase if needed) ───
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAScPskgw2l1C63Ifi4IEcP8V9ZN1CvYWc',
    appId: '1:160665272025:ios:ef2b1d04eb680daf1348c8',
    messagingSenderId: '160665272025',
    projectId: 'taskflow-todo-31a9f',
    databaseURL: 'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com',
    storageBucket: 'taskflow-todo-31a9f.firebasestorage.app',
    iosBundleId: 'com.todoapp.todoApp',
  );

  // ─── Web ──────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAScPskgw2l1C63Ifi4IEcP8V9ZN1CvYWc',
    appId: '1:160665272025:web:ef2b1d04eb680daf1348c8',
    messagingSenderId: '160665272025',
    projectId: 'taskflow-todo-31a9f',
    authDomain: 'taskflow-todo-31a9f.firebaseapp.com',
    databaseURL: 'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com',
    storageBucket: 'taskflow-todo-31a9f.firebasestorage.app',
  );

  // ─── macOS ────────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAScPskgw2l1C63Ifi4IEcP8V9ZN1CvYWc',
    appId: '1:160665272025:ios:ef2b1d04eb680daf1348c8',
    messagingSenderId: '160665272025',
    projectId: 'taskflow-todo-31a9f',
    databaseURL: 'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com',
    storageBucket: 'taskflow-todo-31a9f.firebasestorage.app',
    iosBundleId: 'com.todoapp.todo_app',
  );

  // ─── Windows ──────────────────────────────────────────────────
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAScPskgw2l1C63Ifi4IEcP8V9ZN1CvYWc',
    appId: '1:160665272025:web:ef2b1d04eb680daf1348c8',
    messagingSenderId: '160665272025',
    projectId: 'taskflow-todo-31a9f',
    authDomain: 'taskflow-todo-31a9f.firebaseapp.com',
    databaseURL: 'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com',
    storageBucket: 'taskflow-todo-31a9f.firebasestorage.app',
  );
}
