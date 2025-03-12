import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailSignInModule extends ConsumerStatefulWidget {
  const EmailSignInModule({super.key, required this.ctx, required this.signupModeChanged, required this.signupMode});
  final BuildContext ctx;
  final Function (bool) signupModeChanged;
  final bool signupMode;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailSignInModuleState();
}

class _EmailSignInModuleState extends ConsumerState<EmailSignInModule> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final pwAgainController = TextEditingController();
  bool _loading = false;
  String? _error;



  @override
  Widget build(BuildContext context) {
    if(_loading) return const FZLoadingIndicator(text: "Please hold..", mobileSize: false);
    if(widget.signupMode) return signupView();
    return signinView();
  }

  signinView() {
    return Column(
      children: [
        label("Sign in with email"),
        vertical(),
        inputField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
        vertical(),
        inputField(controller: pwController, hint: "Password", keyboardType: TextInputType.text, passwordField: true),
        vertical(),
        if(_error != null) FZText(text: _error, style: FZTextStyle.smallsubheading, color: Colors.red,),
        FZButton(text: "Submit", onPressed: _signin,),
        vertical(2),
        FZText(text: "Forgot password", style: FZTextStyle.paragraph, onTap: () {
          // setState(() {
          //   _error = null;
          //   _emailSignupMode = true;
          // });
        },),
        FZText(text: "Create new email account", style: FZTextStyle.paragraph, onTap: () {
          // setState(() {
          //   _error = null;
          //   _emailSignupMode = true;
          // });
          widget.signupModeChanged(true);
        },),
      ],
    );
  }

  signupView() {
    return IntrinsicWidth(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          label("Create a new email account"),
          vertical(),
          inputField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
          vertical(),
          inputField(controller: pwController, hint: "Password", keyboardType: TextInputType.text, maxChars: 20, passwordField: true),
          vertical(),
          inputField(controller: pwAgainController, hint: "Repeat Password", keyboardType: TextInputType.text, maxChars: 20, passwordField: true),
          vertical(),
          if(_error != null) SizedBox(width: 240, child: FZText(text: _error, style: FZTextStyle.smallsubheading, color: Colors.red,)),
          FZButton(text: "Submit", onPressed: _signup,),
          vertical(2),
          FZText(text: "Switch to Sign in view", style: FZTextStyle.paragraph, onTap: () {
            // setState(() {
            //   _error = null;
            //   _emailSignupMode = false;
              
            // });
            widget.signupModeChanged(false);
          },),
          vertical(),
          pwInfoView()
        ],
      ),
    );
  }

  _signin() async {
    if(!emailValidate()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Email is invalid");
      return;
    }

    if(!pwValidate()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Password is invalid");
      return;
    }

    setState(() {
      _loading = true;
    });

    final res = await ref.read(backend).signinEmail(emailController.text, pwController.text);
    
    if(res.code == SuccessCode.failed) {
      _error = res.message;
    } else if(res.code == SuccessCode.successful) {
      _error = null;
    }

    setState(() {
      _loading = false;
    });

    
  }

  _pwForgot() async {
    if(!emailValidate()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Please enter a valid email");
      return;
    }

    setState(() {
      _loading = true;
    });

    final res = await ref.read(backend).signinEmail(emailController.text, pwController.text);
    
    setState(() {
      _loading = false;
    });
  }

  _signup() async {
    if(!emailValidate()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Please enter a valid email");
      return;
    }

    // if(!pwValidate()) {
    //   Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Password is invalid");
    //   return;
    // }

    if(!pwMatch()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Passwords don't match");
      return;
    }

    setState(() {
      _loading = true;
    });

    final res = await ref.read(backend).createEmailAccount(emailController.text, pwController.text);
    
    if(res.code == SuccessCode.failed) {
      _error = res.message;
    } else if(res.code == SuccessCode.successful) {
      _error = null;
    }

    setState(() {
      _loading = false;
    });
  }

  emailValidate() {
    String email = emailController.text;
    if(email.isEmpty) return false;

    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
      .hasMatch(email);
  }

  pwValidate() {
    String pw = pwController.text;
    var passwordvalid = RegExp(
                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(pw);
    return pw.length > 5 && passwordvalid;
  }

  pwMatch() => pwController.text == pwAgainController.text;

  pwInfoView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        vertical(),
        note("Password rules:"),
        vertical(2),
        note("1. Minimum 8 characters and maximum 20 characters"),
        vertical(),
        note("2. At least one uppercase letter and one lowercase letter"),
        vertical(),
        note("3. At least one number and one symbol"),
      ],
    );
  }

  inputField({required TextEditingController controller, required String hint, required TextInputType keyboardType, int? maxChars, bool passwordField = false}) {
    return SizedBox(width: 250,
      child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: passwordField,
                    maxLength: maxChars,
                    cursorColor: Constants.primaryColor(),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: hint,
                              
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                  ),
    );
  }

  note(String str) => FZText(text: str, style: FZTextStyle.smallsubheading, color: Colors.black,);
  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.black,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}