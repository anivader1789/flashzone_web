import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailSignInModule extends ConsumerStatefulWidget {
  const EmailSignInModule({super.key, required this.ctx});
  final BuildContext ctx;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailSignInModuleState();
}

class _EmailSignInModuleState extends ConsumerState<EmailSignInModule> {
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final pwAgainController = TextEditingController();
  bool _emailSignupMode = false, _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if(_loading) return const FZLoadingIndicator(text: "Please hold..", mobileSize: false);
    if(_emailSignupMode) return signupView();
    return signinView();
  }

  signinView() {
    return Column(
      children: [
        label("Signin"),
        vertical(),
        inputField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
        vertical(),
        inputField(controller: pwController, hint: "Password", keyboardType: TextInputType.visiblePassword),
        vertical(),
        if(_error != null) FZText(text: _error, style: FZTextStyle.smallsubheading, color: Colors.red,),
        FZButton(text: "Submit", onPressed: _signin,),
        vertical(2),
        FZText(text: "Forgot password", style: FZTextStyle.paragraph, onTap: () {
          setState(() {
            _error = null;
            _emailSignupMode = true;
          });
        },),
        FZText(text: "Create new account", style: FZTextStyle.paragraph, onTap: () {
          setState(() {
            _error = null;
            _emailSignupMode = true;
          });
        },),
      ],
    );
  }

  signupView() {
    return Column(
      children: [
        label("Signup"),
        vertical(),
        inputField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
        vertical(),
        inputField(controller: pwController, hint: "Password", keyboardType: TextInputType.visiblePassword),
        vertical(),
        inputField(controller: pwAgainController, hint: "Repeat Password", keyboardType: TextInputType.visiblePassword),
        vertical(),
        if(_error != null) FZText(text: _error, style: FZTextStyle.smallsubheading, color: Colors.red,),
        FZButton(text: "Submit", onPressed: _signup,),
        vertical(2),
        FZText(text: "Sign in", style: FZTextStyle.paragraph, onTap: () {
          setState(() {
            _error = null;
            _emailSignupMode = false;
          });
        },),
      ],
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

    if(!pwValidate()) {
      Helpers.showDialogWithMessage(ctx: widget.ctx, msg: "Password is invalid");
      return;
    }

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

  inputField({required TextEditingController controller, required String hint, required TextInputType keyboardType}) {
    return SizedBox(width: 250,
      child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    cursorColor: Constants.primaryColor(),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: hint,
                              
                              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                  ),
    );
  }
  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.grey,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}