import 'package:flutter/material.dart';

import 'stub.dart';

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    child: Row(
      children: [
        Image.asset("assets/google-icon.png", width: 50, height: 50,),
        const Text('SIGN IN'),
      ],
    ),
  );
}