// GERADO PELO FLUTTERFIRE CLI
// Execute: flutterfire configure
// para gerar este arquivo automaticamente com os dados do seu projeto.
//
// INSTRUÇÕES:
// 1. Acesse https://console.firebase.google.com
// 2. Crie um projeto chamado "f1show"
// 3. Registre os apps Android e iOS
// 4. Substitua os valores abaixo pelos do seu projeto
// 5. Ou execute `flutterfire configure` para gerar automaticamente

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions não suportado para esta plataforma.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────────────────────
  // Obtenha em: Firebase Console → Seu projeto → Android → google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_ANDROID_API_KEY',
    appId: 'SUA_ANDROID_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_PROJECT_ID.appspot.com',
  );

  // ── iOS ───────────────────────────────────────────────────────────────────
  // Obtenha em: Firebase Console → Seu projeto → iOS → GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUA_IOS_API_KEY',
    appId: 'SUA_IOS_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_PROJECT_ID.appspot.com',
    iosBundleId: 'com.f1show.f1showMobile',
  );

  // ── Web ───────────────────────────────────────────────────────────────────
  // Obtenha em: Firebase Console → Seu projeto → Web → Configurações
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'SUA_WEB_API_KEY',
    appId: 'SUA_WEB_APP_ID',
    messagingSenderId: 'SEU_MESSAGING_SENDER_ID',
    projectId: 'SEU_PROJECT_ID',
    storageBucket: 'SEU_PROJECT_ID.appspot.com',
    authDomain: 'SEU_PROJECT_ID.firebaseapp.com',
  );
}
