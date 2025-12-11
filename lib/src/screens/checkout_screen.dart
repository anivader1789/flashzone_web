import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.onDismiss, required this.user});
  final Function () onDismiss;
  final FZUser user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamCartScreenState();
}

class _FamCartScreenState extends ConsumerState<CheckoutScreen> {


  @override
  Widget build(BuildContext context) {
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
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const FZText(text:"Your Purchases:", style: FZTextStyle.headline,),
                ElevatedButton(
                  onPressed: widget.onDismiss, 
                  child: const Text("Close Cart"))
              ],
            ),
          ),
        )
      ],
    );
  }

  

  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.black,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}