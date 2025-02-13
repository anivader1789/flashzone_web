import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/model/auth_creds.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirebaseAuthService {
  late Ref ref;

  FirebaseAuthService({required this.ref});

  late PhoneAuthCredential creds;
  String? verification;
  bool isVerified = false;

  void signInWithCredential(AuthCreds creds) {
    ref.read(currentuser.notifier).update((state) => FZUser.interim());
    isVerified = creds.isVerified;
    FirebaseAuth.instance.signInWithCredential(creds.creds);
  }

  Future<FZResult> createEmailAccount(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      signInWithCredential(AuthCreds(creds: credential, isVerified: false));
      return FZResult(code: SuccessCode.successful);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        return FZResult(code: SuccessCode.failed, message: e.message);
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        
      } 
      return FZResult(code: SuccessCode.failed, message: e.message);
    } catch (e) {
      print(e);
       return FZResult(code: SuccessCode.failed, message: e.toString());
    }
  }

  Future<FZResult> signinEmail(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );
      signInWithCredential(AuthCreds(creds: credential, isVerified: false));
      return FZResult(code: SuccessCode.successful);
    } on FirebaseAuthException catch (e) {
      String msg = "Error with signin";
      if (e.code == 'user-not-found') {
        msg = 'No user found for that email.';
        print(msg);
      } else if (e.code == 'wrong-password') {
        msg = 'Wrong password';
        print(msg);
      }
      return FZResult(code: SuccessCode.failed, message: msg);
    } catch (e) {
      print(e);
      return FZResult(code: SuccessCode.failed, message: e.toString());
    }
  }

  Future<void> sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    final actionCodeSettings = ActionCodeSettings(
      url: "https://main.d1xky3fnzerbrr.amplifyapp.com/#verifyEmail/${user?.email}",
      //iOSBundleId: "com.example.ios",
      //androidPackageName: "com.example.android",
    );

    await user?.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    final actionCodeSettings = ActionCodeSettings(
      url: "https://main.d1xky3fnzerbrr.amplifyapp.com/#resetPw/${user?.email}",
      //iOSBundleId: "com.example.ios",
      //androidPackageName: "com.example.android",
    );

    await FirebaseAuth.instance
    .sendPasswordResetEmail(email: user!.email!);
  }

  Future<bool> isUserVerified() async { 
    if(isVerified) return true;

    await FirebaseAuth.instance.currentUser?.reload();
    return FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  Future<void> verifyPhoneNumber({required String phoneNumber, 
                      required Function (String) failureCallback, 
                      required Function successCallback, 
                      required Function instantVerificationCallback, 
                      required Function timeoutCallback}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      print("trying phone number: $phoneNumber and $auth");
      
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Instant verification or auto-retrieval: $credential");
          creds = credential;
          try {
            ref.read(backend).signInWithCredential(AuthCreds(creds: credential, isVerified: false));
            instantVerificationCallback();
          } catch (e) {
            failureCallback(e.toString());
          }
          
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification failed: $e");
          failureCallback(e.message ?? e.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          verification = verificationId;
          print("Code sent: $verificationId");
          successCallback();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("Code auto-retrieval timeout: $verificationId");
          timeoutCallback();
        },
      );
    } catch (e) {
      print("Error verifying phone number: $e");
      failureCallback(e.toString());
    }
  }

  Future<void> submitOTP({required String smsCode, 
                      required Function failureCallback, 
                      required Function successCallback}) async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verification!,
        smsCode: smsCode,
      );

      await auth.signInWithCredential(credential);
      successCallback();
      print("Phone number authentication successful");
    } catch (e) {
      print("Error submitting OTP: $e");
      failureCallback();
    }
  }

}