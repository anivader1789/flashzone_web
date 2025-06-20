import 'dart:async';

import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/email_auth/email_auth.dart';
import 'package:flashzone_web/src/modules/google_auth/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountInputState {
  signup, username, bio, loading, finished, account, code, verificationPending, name
}
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.onDismiss, required this.mobileSize});
  final Function () onDismiss;
  final bool mobileSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late AccountInputState state;
  bool _loading = false, _finished = false;
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final bioController = TextEditingController();
  bool _emailVerificationPending = false;
  bool _invitationCodeError = false;
  bool _showSignup = false;

  late FZUser _user;

  @override
  void initState() {
    super.initState();

  }

  loadEmailVerificationStatus() async {
    final res = await ref.read(backend).loadUserVerificationStatus();
    if(res == false) {
      setState(() {
        _emailVerificationPending = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _user = ref.watch(currentuser);
    final code = ref.watch(invitationCode);
    final codeError = ref.watch(invitationCodeError);

    if(code != null || codeError != null) {
        state = AccountInputState.code;
    } else {
      if(_loading || _user.id == FZUser.interimUserId) {
        state = AccountInputState.loading;
      } else if(_finished) {
        state = AccountInputState.finished;
      } else if(_user.id == FZUser.signedOutUserId) {
        state = AccountInputState.signup;
      } else if(_emailVerificationPending) {
        state = AccountInputState.verificationPending;
      } else if(_user.username == null) {
        state = AccountInputState.username;
      } else if(_user.name == null) {
        state = AccountInputState.name;
      } else if(_user.bio == null) {
        state = AccountInputState.bio;
      } else {
        //Profile complete
        bioController.text = _user.bio ?? "";
        state = AccountInputState.account;
      }
    }

    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.fromLTRB(25, 45, 25, 45),
            decoration: BoxDecoration(
              color: Constants.cardColor(),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/flashzoneR.png", height: 21,),
                vertical(9),
                containerView()
              ],),
            ),
            ) ,
        ),]
    );
  }

  containerView() {
    return switch (state) {
                AccountInputState.signup => signinForm(),
                AccountInputState.username => usernameField(),
                AccountInputState.name => nameField(),
                AccountInputState.bio => bioField(),
                AccountInputState.loading => const CircularProgressIndicator(),
                AccountInputState.finished => const Icon(Icons.check_circle, color: Colors.green, size: 32,),
                AccountInputState.account => accountEdit(),
                AccountInputState.verificationPending => emailVerificationPending(),
                AccountInputState.code => codeField()
              };
  }

  signinForm() {
    if(_showSignup) {
      return EmailSignInModule(ctx: context, signupMode: _showSignup, signupModeChanged: (val) {
            setState(() {
              _showSignup = val;
            });
          });
    }

    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Sign in or Sign up with Google"),
          vertical(),
          const GoogleSignInBtn(),
          vertical(2),
          //const Divider(thickness: 2,),
          vertical(),
          label("or"),
          vertical(3),
          EmailSignInModule(ctx: context, signupMode: _showSignup, signupModeChanged: (val) {
            setState(() {
              _showSignup = val;
            });
          })
        ],
      ),
    );
  }

  usernameField() {
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Let's pick a nice username"),
          vertical(3),
          Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: usernameController,
                  maxLength: 30,
                  decoration: const InputDecoration(
                    prefix: FZText(text: "@", style: FZTextStyle.paragraph),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: 'Username',
                  ),
                  cursorColor: Constants.primaryColor(),
                ),
              ),
              const SizedBox(width: 5,),
              button(
                    onPressed: () {
                      // Implement the logic to send the message
                      _usernameSubmitted(context);
                      //usernameController.clear();
                    },
                  ),
            ],
          ),
          vertical(2),
          const Divider(),
          const FZText(text: "Must be between 4 and 30 characters", style: FZTextStyle.smallsubheading, color: Colors.red,),
          const FZText(text: "Allowed characters: a-z, A-Z, 0-9 and _", style: FZTextStyle.smallsubheading, color: Colors.red,),
        ],
      ),
    );
  }

  nameField() {
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Your display name on the app"),
          vertical(3),
          Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: nameController,
                  maxLength: 15,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: 'Name',
                  ),
                  cursorColor: Constants.primaryColor(),
                ),
              ),
              const SizedBox(width: 5,),
              button(
                    onPressed: () {
                      // Implement the logic to send the message
                      _nameSubmitted(context);
                      //usernameController.clear();
                    },
                  ),
            ],
          ),
          vertical(2),
          const Divider(),
          const FZText(text: "Must be between 4 and 30 characters", style: FZTextStyle.smallsubheading, color: Colors.red,),
          const FZText(text: "Allowed characters: a-z, A-Z, 0-9 and _", style: FZTextStyle.smallsubheading, color: Colors.red,),
        ],
      ),
    );
  }

  bool _verificationLoading = false;

  codeField() {
    String? error = ref.read(invitationCodeError);
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Your invitation code"),
          vertical(3),
          _verificationLoading? const CircularProgressIndicator()
          : error != null? 
            FZText(text: error, style: FZTextStyle.paragraph, color: Colors.red,)
          : Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputField(controller: codeController, hint: "Invitation Code", maxChar: 6),
              const SizedBox(width: 5,),
              button(
                    onPressed: _beginVerification,
                  ),
            
            ],
          ),
          if(_invitationCodeError) const FZText(text: "Wrong code", style: FZTextStyle.smallsubheading, color: Colors.red,),
          vertical(7),
          FZText(text: "Sign in using another account", style: FZTextStyle.paragraph, onTap: () async {
              await ref.read(backend).resetSignIn();
              setState(() {
                
              });
            },)
        ],
      ),
    );
  }

  bioField() {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        label("A bio that other users will see on your profile"),
        vertical(3),
        Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            inputField(controller: bioController, hint: "Bio", maxChar: 400, largeInput: true),
            const SizedBox(width: 5,),
            button(
                    onPressed: _bioSubmitted,
                  ),
          ],
        ),
      ],
    );
  }

  accountEdit() {
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FZText(text: "Signed in as:", style: FZTextStyle.headline),
          vertical(),
          Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontal(),
              CircleAvatar(foregroundImage: Helpers.loadImageProvider(_user.avatar), radius: 32,),
              horizontal(3),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FZText(text: _user.name, style: FZTextStyle.headline),
                  FZText(text: "@${_user.username}", style: FZTextStyle.paragraph)
                ],
              ),
              const Expanded(child: SizedBox()),
              FZText(onTap: () => ref.read(backend).signOut(), text: "Sign Out", style: FZTextStyle.paragraph, color: Colors.red,),
            ],
          ),
          const Divider(),
          vertical(3),
          const FZText(text: "Edit Bio", style: FZTextStyle.paragraph),
          Row(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              inputField(controller: bioController, hint: "Bio", maxChar: 400, largeInput: true),
              const SizedBox(width: 5,),
              button(onPressed: _bioSubmitted),
            ],
          ),
        ],
      ),
    );
  }

  emailVerificationPending() {

    return const FZText(text: "Email verification is pending", style: FZTextStyle.paragraph);
  }

  _beginVerification() async {
    if(codeController.text == ref.read(invitationCode)) {
      //Code was correct
      setState(() {
        _verificationLoading = true;
        _invitationCodeError = false;
      });
      try {
        await ref.read(backend).addNewUser(ref.read(userToVerify));
        setState(() {
          _verificationLoading = false;
        });
      } catch (e) {
        setState(() {
          _verificationLoading = false;
        });
      }
      
    } else {
      setState(() {
        _invitationCodeError = true;
      });
    }
  }

  _usernameSubmitted(BuildContext ctx) async {
    final validate = validateUsername();
    if(validate != null) {
      Helpers.showDialogWithMessage(ctx: ctx, msg: validate);
      return;
    }

    setState(() {
      _loading = true;
    });

    final user = ref.read(currentuser);
    user.username = usernameController.text;

    final res = await ref.read(backend).updateProfile(user);

    if(res.code == SuccessCode.successful) {
      setState(() {
        _loading = false;
        if(_user.bio == null) {
          state = AccountInputState.bio;
        } else {
          _finished = true;
          Timer(const Duration(seconds: 1), () { widget.onDismiss(); });
        }
        
      });
    } else {

    }
    
  }

  _nameSubmitted(BuildContext ctx) async {
    setState(() {
      _loading = true;
    });

    final user = ref.read(currentuser);
    user.name = nameController.text;

    final res = await ref.read(backend).updateProfile(user);

    if(res.code == SuccessCode.successful) {
      setState(() {
        _loading = false;
        if(_user.bio == null) {
          state = AccountInputState.bio;
        } else {
          _finished = true;
          Timer(const Duration(seconds: 1), () { widget.onDismiss(); });
        }
        
      });
    } else {

    }
    
  }

  _bioSubmitted() async {
    setState(() {
      _loading = true;
    });

    final user = ref.read(currentuser);
    user.bio = bioController.text;

    final res = await ref.read(backend).updateProfile(user);

    if(res.code == SuccessCode.successful) {
      setState(() {
        _loading = false;
        _finished = true;
      });

      Timer(const Duration(seconds: 1), () { widget.onDismiss(); });
    } else {
      
    }
  }

  String? validateUsername() {
    final str = usernameController.text;
    if(str.length < 4 || str.length > 31) return "Username must be between 4 and 30 characters";
    
    for(int i=0; i<str.length; i++) {
      final ascii = str.codeUnitAt(i);
      if(ascii >= 0 && ascii <= 47) return "Invalid characters";
      if(ascii >= 58 && ascii <= 64) return "Invalid characters";
      if(ascii >= 91 && ascii <= 94) return "Invalid characters";
      if(ascii >= 123) return "Invalid characters";
      if(ascii == 96) return "Invalid characters";
    }

    return null;
  }

  button({
    required Function() onPressed,
    String text = "Save", IconData icon = Icons.save}) {
      if(widget.mobileSize) {
        return IconButton(onPressed: onPressed, icon: Icon(icon, color: Colors.black,));
      } else {
        return FZButton(
                    onPressed: onPressed,
                    text: text,
                  );
      }
    }

  inputField({required TextEditingController controller, required String hint, int maxChar = 100, bool largeInput = false}) {
    double width = widget.mobileSize? 280: largeInput? 450: 250;
    return SizedBox(width: width,
      height: largeInput? 150: null,
      child: TextField(
                    controller: controller,
                    maxLength: maxChar,
                    maxLines: largeInput? 3: 1,
                    cursorColor: Constants.primaryColor(),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: hint,
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                  ),
    );
  }
  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.black,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

}