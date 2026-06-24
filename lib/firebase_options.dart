import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('klinika_ai is configured for Android and iOS.');
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      _ => throw UnsupportedError(
          'klinika_ai supports Android and iOS for this workshop demo.',
        ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDioUD2GjoWHbx5LdxrjBe_Mj3ddXKkpCg',
    appId: '1:545160429547:android:8b2a9d7af62439b891a3ae',
    messagingSenderId: '545160429547',
    projectId: 'klinika-ai',
    storageBucket: 'klinika-ai.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANEXFItmv2UUb6VO4o2WElErM2rCDWYVM',
    appId: '1:545160429547:ios:740ffc65053bd54591a3ae',
    messagingSenderId: '545160429547',
    projectId: 'klinika-ai',
    storageBucket: 'klinika-ai.firebasestorage.app',
    iosBundleId: 'dev.buildwithai.yaounde.klinikaAi',
  );
}
