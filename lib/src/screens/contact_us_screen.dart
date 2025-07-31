import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactUsScreen extends ConsumerStatefulWidget {
  const ContactUsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ContactUsScreenState();
}

class _ContactUsScreenState extends ConsumerState<ContactUsScreen> {
  final emailCont = TextEditingController();
  final messageCont = TextEditingController();
  bool _sending = false;
  String? _sendStatusMessage;

  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(child: childView(mobileSize), sideMenuIndex: 5);
  }

  childView(bool mobileSize) {
    final user = ref.watch(currentuser);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FZText(text: "Contact us", style: FZTextStyle.largeHeadline),
          vertical(),
          const Divider(),
          if (user.isSignedOut) ...[
            vertical(),
            field(emailCont, label: "Your Email"),
          ],
          if(!user.isSignedOut) ...[
            vertical(),
            label("Hi, ${user.name}. Please enter your message below and we will get back to you as soon as we can."),
            label("You can use this form to request deletion of your account.")
          ],
          vertical(),
          field(messageCont, label: "Your message here..", isLong: true),
          vertical(2),
          if (_sendStatusMessage != null) label(_sendStatusMessage!),
          vertical(),
          _sending
              ? const CircularProgressIndicator()
              : FZButton(
                  onPressed: submit,
                  text: "Send",
                  bgColor: Constants.altPrimaryColor(),
                )
        ],
      ),
    );
  }

  submit() async {
    final user = ref.read(currentuser);
    String email = user.isSignedOut ? emailCont.text : user.email ?? "";

    if (email.isEmpty) {
      Helpers.showDialogWithMessage(
          ctx: context,
          msg:
              "Please enter your email address so we could follow up on your message");
      return;
    }

    if (messageCont.text.length < 5 || !messageCont.text.contains(" ")) {
      Helpers.showDialogWithMessage(
          ctx: context, msg: "Please enter a proper message");
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      final res = await ref
          .read(backend)
          .sendMessagetoDeveloper(email, messageCont.text);
      if (res.code == SuccessCode.successful) {
        setState(() {
          _sending = false;
          messageCont.clear();
          _sendStatusMessage = "Message successfully sent. We will get back to you soon.";
          Helpers.showDialogWithMessage(
          ctx: context, msg: "Message successfully sent. We will get back to you soon.");
        });
      }
    } on Exception catch (e) {
      setState(() {
        _sending = false;
        _sendStatusMessage = e.toString();
      });
    }
  }

  field(TextEditingController cont,
      {TextInputType keyType = TextInputType.text,
      required String label,
      bool isLong = false,
      double customWidth = 550,
      Icon? icon}) {
    return SizedBox(
      width: customWidth,
      child: TextField(
        //onChanged: _search,
        controller: cont,
        keyboardType: keyType,
        maxLines: isLong ? 5 : 1,
        cursorColor: Constants.primaryColor(),
        style: const TextStyle(fontSize: 19),
        decoration: InputDecoration(
          prefixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          fillColor: Colors.white70,
          filled: true,
          labelText: label,
        ),
      ),
    );
  }

  label(String str) => FZText(
        text: str,
        style: FZTextStyle.headline,
        color: Colors.grey,
      );
  vertical([double multiple = 1]) => SizedBox(
        height: 15 * multiple,
      );
  horizontal([double multiple = 1]) => SizedBox(
        width: 5 * multiple,
      );
}
