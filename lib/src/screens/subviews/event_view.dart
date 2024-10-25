import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventView extends ConsumerStatefulWidget {
  const EventView({super.key, required this.event});
  final Event event;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventViewState();
}

class _EventViewState extends ConsumerState<EventView> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Image.asset(widget.event.pic, height: 300, width: 300,),
          const SizedBox(height: 15,),
          FZText(text: widget.event.description, style: FZTextStyle.paragraph),
          const SizedBox(height: 15,),
          FZText(text: "Host: ${widget.event.by}", style: FZTextStyle.headline),
          FZText(text: "Price: \$${widget.event.price}", style: FZTextStyle.headline),
        ],
      ),
    );
  }
}