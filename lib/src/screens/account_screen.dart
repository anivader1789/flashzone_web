import 'dart:async';

import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/modules/google_auth/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AccountInputState {
  signup, username, bio, loading, finished, account
}
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key, required this.onDismiss});
  final Function () onDismiss;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late AccountInputState state;
  bool _loading = false, _finished = false;
  final usernameController = TextEditingController();
  final bioController = TextEditingController();

  late FZUser _user;

  @override
  void initState() {
    super.initState();

    
    
  }

  @override
  Widget build(BuildContext context) {
    _user = ref.watch(currentuser);
    
    if(_loading || _user.id == FZUser.interimUserId) {
      state = AccountInputState.loading;
    } else if(_finished) {
      state = AccountInputState.finished;
    } else if(_user.id == FZUser.signedOutUserId) {
      state = AccountInputState.signup;
    } else if(_user.username == null) {
      state = AccountInputState.username;
    } else if(_user.bio == null) {
      state = AccountInputState.bio;
    } else {
      //Profile complete
      bioController.text = _user.bio ?? "";
      state = AccountInputState.account;
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:  BorderRadius.all(Radius.circular(12)),
            ),
            child: switch (state) {
                AccountInputState.signup => signinForm(),
                AccountInputState.username => usernameField(),
                AccountInputState.bio => bioField(),
                AccountInputState.loading => const CircularProgressIndicator(),
                AccountInputState.finished => const Icon(Icons.check_circle, color: Colors.green, size: 32,),
                AccountInputState.account => accountEdit()
              },
            ) ,
        ),]
    );
  }

  signinForm() {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        label("Signin/Signup"),
        vertical(3),
        const GoogleSignInBtn()
      ],
    );
  }

  usernameField() {
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Let's pick a nice username"),
          vertical(3),
          Row(mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    prefix: FZText(text: "@", style: FZTextStyle.paragraph),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    hintText: 'Username',
                  ),
                  cursorColor: Constants.primaryColor(),
                ),
              ),
              const SizedBox(width: 5,),
              FZIconButton(
                    onPressed: () {
                      // Implement the logic to send the message
                      _usernameSubmitted(context);
                      //usernameController.clear();
                    },
                    tint: Constants.primaryColor(),
                    icon: Icons.send
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

  bioField() {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        label("A bio that other users will see on your profile"),
        vertical(3),
        Row(mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 250,
              child: TextField(
                controller: bioController,
                cursorColor: Constants.primaryColor(),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: const InputDecoration(
                          hintText: 'Bio',
                          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                        ),
              ),
            ),
            const SizedBox(width: 5,),
            FZIconButton(
                  onPressed: () {
                    // Implement the logic to send the message
                    _bioSubmitted();
                    //bioController.clear();
                  },
                  tint: Constants.primaryColor(),
                  icon: Icons.send
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
              IconButton(onPressed: () => ref.read(backend).signOut(), icon: const Icon(Icons.logout, color: Colors.black,)),
            ],
          ),
          const Divider(),
          vertical(3),
          const FZText(text: "Edit Bio", style: FZTextStyle.paragraph),
          Row(mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: bioController,
                  cursorColor: Constants.primaryColor(),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: 'Bio',
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                          ),
                ),
              ),
              const SizedBox(width: 5,),
              FZIconButton(
                    onPressed: () {
                      // Implement the logic to send the message
                      _bioSubmitted();
                      //bioController.clear();
                    },
                    tint: Constants.primaryColor(),
                    icon: Icons.send
                  ),
            ],
          ),
        ],
      ),
    );
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

  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.grey,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

}