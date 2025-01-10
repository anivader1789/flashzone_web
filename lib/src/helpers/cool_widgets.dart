import 'package:flutter/material.dart';

class RoundedBadge extends StatelessWidget {
  final String title;
  final Widget icon;
  final Function () onClick;
  const RoundedBadge({required this.title, required this.icon, required this.onClick, super.key});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onClick,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.25),
              borderRadius: BorderRadius.circular(25.0)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(
                width: 5,
              ),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class RoundedSearchInput extends StatelessWidget {
  final TextEditingController textController;
  final String hintText;
  const RoundedSearchInput(
      {required this.textController, required this.hintText, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            offset: const Offset(12, 26),
            blurRadius: 50,
            spreadRadius: 0,
            color: Colors.grey.withOpacity(.1)),
      ]),
      child: TextField(
        controller: textController,
        onChanged: (value) {
          //Do something wi
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.travel_explore,
            color: Colors.grey[500]!,
          ),
          filled: true,
          fillColor: Colors.white,
          hintText: hintText,
          hintStyle:
              const TextStyle(color: Colors.grey, fontWeight: FontWeight.w300),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(45.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0),
            borderRadius: const BorderRadius.all(Radius.circular(45.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
            borderRadius: const BorderRadius.all(Radius.circular(45.0)),
          ),
        ),
      ),
    );
  }
}
