import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flutter/material.dart';

class EventCellView extends StatelessWidget {
  const EventCellView({super.key, required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Card(elevation: 5,clipBehavior: Clip.hardEdge,
            //color: const Color.fromARGB(255, 255, 234, 212),
            // decoration: const BoxDecoration(
            //   color: Color.fromARGB(255, 225, 214, 173),
            //   borderRadius: BorderRadius.all(Radius.circular(8)),
            // ),
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, "events/${event.id}"),
              child: SizedBox(width: double.infinity,
                child: Stack(
                  children: [
                    Image(image: Helpers.loadImageProvider(event.pic), width: double.infinity, height: double.infinity, fit: BoxFit.fill,),
                    Align(alignment: Alignment.bottomLeft,
                    child: Container(padding: const EdgeInsets.all(8),width: double.infinity,
                      decoration: BoxDecoration(
                        color:  Constants.cardColor(),
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                          children: [
                            vertical(),
                            FZText(text: event.title, style: FZTextStyle.xlargeHeadline),
                            vertical(),
                            rowLabel(Helpers.getDisplayDate(event.time), Icons.timer),
                            vertical(),
                            rowLabel("White plains, NY", Icons.place),
                            vertical()
                          ],
                        ),
                    ),),
                    ]
                ),
              ),
            ),
      ),
    );
  }

  rowLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon),
        horizontal(),
        FZText(text: label, style: FZTextStyle.paragraph),
      ],
    );
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}