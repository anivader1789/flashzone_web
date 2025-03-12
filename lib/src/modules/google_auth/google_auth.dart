import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/auth_creds.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './google_signin_btn.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';



class GoogleSignInBtn extends ConsumerStatefulWidget {
  const GoogleSignInBtn({super.key});
  

  @override
  ConsumerState<GoogleSignInBtn> createState() => _GoogleSignInBtnState();
}

class _GoogleSignInBtnState extends ConsumerState<GoogleSignInBtn> {

  final List<String> scopes = <String>[
    //'email',
    //'https://www.googleapis.com/auth/contacts.readonly',
  ];

  late GoogleSignIn _googleSignIn;

  @override
  void initState() {
    super.initState();

    _googleSignIn = GoogleSignIn(
      // Optional clientId
      clientId: "26609542744-io0414qpi557bgot80stmmlg8egug868.apps.googleusercontent.com",
      scopes: scopes,
    );

    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
          
      bool isAuthorized = account != null;
      print("Google auth state changed with status: $isAuthorized");

      if(isAuthorized) {
        print("After calling google signin with guser: ${account.displayName}");

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await account.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        

        ref.read(backend).signInWithCredential(AuthCreds(creds: credential, isVerified: true));
      }

      
      // However, on web...
      // if (kIsWeb && account != null) {
      //   isAuthorized = await _googleSignIn.canAccessScopes(scopes);
      // }
// #enddocregion CanAccessScopes

      // setState(() {
      //   _currentUser = account;
      //   _isAuthorized = isAuthorized;
      // });

      // Now that we know that the user can access the required scopes, the app
      // can call the REST API.
      // if (isAuthorized) {
      //   unawaited(_handleGetContact(account!));
      // }
      // if (isAuthorized) {
      //   ref.read(userProvider.notifier).update((state) => SourceUser(account));
      // }
    });

    //_googleSignIn.signInSilently();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          color: Constants.bgColor(),
          width: 2)
      ),
      child: buildSignInButton(onPressed: _handleSignIn));
    // return ElevatedButton(
    //   onPressed: signInWithGoogle,
    //   child: FittedBox(
    //               fit: BoxFit.contain,
    //               child: Row(
    //                 children: [
    //                   Image.asset("assets/google-icon.png", width: 20, height: 20,),
    //                   const SizedBox(width: 10,),
    //                   const FZText(text: "Login with Google", style: FZTextStyle.paragraph,),
    //                 ],
    //               ),
    //           ),
    //   );
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();

      

    } catch (error) {
      print("Error during google signin: $error");
    }
  }

   Future<void> signOut() => _googleSignIn.signOut();

  void signInWithGoogle() async {
    // ref.read(seekerSessionsProvider.notifier).update((state) => List.empty(growable: true));
    // ref.read(sourceSessionsProvider.notifier).update((state) => List.empty(growable: true));
        //const oauthClientId = "200609542744-io0414qpi557bgot80stmmlg8egug868.apps.googleusercontent.com";

    const oauthClientId = "26609542744-io0414qpi557bgot80stmmlg8egug868.apps.googleusercontent.com";
    //final firebaseClientId = "26609542744-kavlofsqfska8fagcpg57fer9r6parrd.apps.googleusercontent.com";
    
    try {
      late GoogleSignInAccount? googleUser;
      // Trigger the authentication flow
      if(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
        googleUser = await GoogleSignIn(scopes: scopes).signIn();
      } else {
        googleUser = await GoogleSignIn(scopes: scopes,clientId: oauthClientId).signIn();
      }

      print("After calling google signin");

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      ref.read(backend).signInWithCredential(AuthCreds(creds: credential, isVerified: false));
    } catch (e) {
      print("Error with google signin: $e");
    }
    
    //Do something with creds if necessary
  }
}



