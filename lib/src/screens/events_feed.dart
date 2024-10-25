import 'package:calendar_view/calendar_view.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/screens/subviews/event_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventFeedView extends ConsumerStatefulWidget {
  const EventFeedView({super.key, required this.today});
  final bool today;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventFeedViewState();
}

class _EventFeedViewState extends ConsumerState<EventFeedView> {
  final List<Event> _events = List.empty(growable: true);
  final EventController _calendarController = EventController();
  
  @override
  void initState() {
    super.initState();
    
    final total = widget.today? 3: 20;
    for(int i=0; i< total; i++) {
      _events.add(Event.dummy(DateTime.now().add(Duration(hours: i*3))));
    }

    
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: listViews(),
            )
          ),
          Expanded(
            flex: 1,
            child: buildCalendar()
          ),
        ],
      ),);
  }

  listViews() {
    List<ExpansionTile> tiles = List.empty(growable: true);
    for(int i =0; i<_events.length; i++) {
      Event e = _events[i];
      tiles.add(
        ExpansionTile(
          title: FZText(text: e.title, style: FZTextStyle.largeHeadline),
          subtitle: FZText(text: Helpers.getDisplayDate(e.time), style: FZTextStyle.paragraph),
          children: [EventView(event: e)],),
        );
    }
    return tiles;
  }

  buildCalendar() {
    for(int i =0; i<_events.length; i++) {
      Event e = _events[i];
      _calendarController.add(CalendarEventData(title: e.title, date: e.time));
    }
    return Padding(padding: const EdgeInsets.all(11),
      child: widget.today? DayView(
          controller: _calendarController,
          initialDay: DateTime.now(),
        )
        : MonthView(
          controller: _calendarController,
          initialMonth: DateTime.now(),
        )
      );
  }
}