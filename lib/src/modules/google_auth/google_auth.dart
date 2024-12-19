import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './google_signin_btn.dart';

const List<String> scopes = <String>[
  'email',
  //'https://www.googleapis.com/auth/contacts.readonly',
];

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
   //clientId: '237702719268-00frn8m256kcje31le5jak7qei41e19n.apps.googleusercontent.com',
  scopes: scopes,
);

class GoogleSignInBtn extends ConsumerStatefulWidget {
  const GoogleSignInBtn({super.key});

  @override
  ConsumerState<GoogleSignInBtn> createState() => _GoogleSignInBtnState();
}

class _GoogleSignInBtnState extends ConsumerState<GoogleSignInBtn> {

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {

      bool isAuthorized = account != null;

      // if (isAuthorized) {
      //   ref.read(userProvider.notifier).update((state) => SourceUser(account));
      // }
    });

    
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: signInWithGoogle,
      child: FittedBox(
                  fit: BoxFit.contain,
                  child: Row(
                    children: [
                      Image.asset("assets/google-icon.png", width: 20, height: 20,),
                      const SizedBox(width: 10,),
                      const FZText(text: "Login with Google", style: FZTextStyle.paragraph,),
                    ],
                  ),
              ),
      );
  }

  void signInWithGoogle() async {
    // ref.read(seekerSessionsProvider.notifier).update((state) => List.empty(growable: true));
    // ref.read(sourceSessionsProvider.notifier).update((state) => List.empty(growable: true));
    
    const oauthClientId = "26609542744-io0414qpi557bgot80stmmlg8egug868.apps.googleusercontent.com";
    //final firebaseClientId = "26609542744-kavlofsqfska8fagcpg57fer9r6parrd.apps.googleusercontent.com";
    
    late GoogleSignInAccount? googleUser;
    // Trigger the authentication flow
    if(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      googleUser = await GoogleSignIn(scopes: scopes).signIn();
    } else {
      googleUser = await GoogleSignIn(scopes: scopes,clientId: oauthClientId).signIn();
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    ref.read(backend).signInWithCredential(credential);
    //Do something with creds if necessary
  }
}



