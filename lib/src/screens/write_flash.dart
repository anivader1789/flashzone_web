import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WriteFlashView extends ConsumerStatefulWidget {
  const WriteFlashView({super.key, required this.onFinished});
  final Function () onFinished;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WriteFlashViewState();
}

class _WriteFlashViewState extends ConsumerState<WriteFlashView> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              const FZText(text: "Write Flash", style: FZTextStyle.largeHeadline),
              Expanded(child: Container()),
              FZButton(
                onPressed: () {
                  print("Draft clicked");
                }, 
                text: "Draft")
            ],
          ),
          const SizedBox(height: 15,),
          SizedBox(
            height: 200,
            child: TextField(
                      maxLines: 5,
                      cursorColor: Constants.secondaryColor(),
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
                        hintText: 'post a flash',
                        fillColor: Colors.white70,
                        filled: true,
                        
                      ),
            ),
          ),
          const SizedBox(height: 15,),
          Row(
            children: [
              Expanded(child: Container()),
              FZButton(
                onPressed: () {
                  widget.onFinished();
                }, 
                bgColor: Constants.primaryColor(),
                text: "Cancel"),
              const SizedBox(width: 10,),
              FZButton(
                onPressed: () {
                  widget.onFinished();
                }, 
                bgColor: Constants.primaryColor(),
                text: "Flash")
            ],
          ),
        ],
      ),);
  }
}