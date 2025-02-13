import 'package:calendar_view/calendar_view.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/screens/subviews/event_cell_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class EventFeedView extends ConsumerStatefulWidget {
  const EventFeedView({super.key, required this.mobileSize});
  final bool mobileSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventFeedViewState();
}

class _EventFeedViewState extends ConsumerState<EventFeedView> {
  final List<Event> _upcomingEvents = List.empty(growable: true);
  final List<Event> _todayEvents = List.empty(growable: true);
  late String todayLabel;
  late TapGestureRecognizer _tapGestureForEventCreationForm;
  @override
  void initState() {
    super.initState();

    _tapGestureForEventCreationForm = TapGestureRecognizer()..onTap = eventCreationFormTapped;
    loadEvents();

  }

  eventCreationFormTapped() {
    launchUrl(Uri.parse('https://google.com'), webOnlyWindowName: '_blank');
  }

  loadEvents() async {
    final today = DateTime.now();
    todayLabel = "Events Today (${today.month}/${today.day})";

    final loadedEvents = await ref.read(backend).getEvents(7000000000);

    for(Event e in loadedEvents) {
      if(e.time.year == today.year && e.time.month == today.month && e.time.day == today.day) {
        _todayEvents.add(e);
      } else if(e.time.isBefore(DateTime.now())) {
        _upcomingEvents.add(e);
      }
    }
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12),
    child: ListView(//crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
        children: [
          vertical(),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: "To register your own event, please fill up this form: "),
              TextSpan(
                text: "'Event Registration Form'.", 
                style: const TextStyle(color: Colors.blue),
                recognizer: _tapGestureForEventCreationForm,
                mouseCursor: SystemMouseCursors.click)
          ])),
          vertical(),
          FZText(text: todayLabel, style: FZTextStyle.headline, color: Colors.grey,),
          const Divider(),
          vertical(),
          eventsGridView(_todayEvents),
          vertical(),
          const FZText(text: "Upcoming events", style: FZTextStyle.headline, color: Colors.grey,),
          const Divider(),
          vertical(),
          eventsGridView(_upcomingEvents),
        ],
      ),
    )  ;
  }

  eventsGridView(List<Event> events) {
    return GridView.count(shrinkWrap: true,
      crossAxisCount: widget.mobileSize? 1: 3,
      children: List.generate(events.length, (index) {
                    return EventCellView(event: events[index]);
                  },
    ));
  } 

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}

class AllEventFeedView extends ConsumerStatefulWidget {
  const AllEventFeedView({super.key, required this.mobileSize});
  final bool mobileSize;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AllEventFeedViewState();
}

class _AllEventFeedViewState extends ConsumerState<AllEventFeedView> {
  final List<Event> _events = List.empty(growable: true);
  final EventController _calendarController = EventController();
  Event? _eventViewing;
  
  @override
  void initState() {
    super.initState();
    
    // for(int i=0; i< 20; i++) {
    //   _events.add(Event.dummy(DateTime.now().add(Duration(hours: i*3))));
    // }
    loadEvents();
    
  }

  loadEvents() async {
    final loadedEvents = await ref.read(backend).getEvents(700000);

    _events.addAll(loadedEvents);
    setState(() {
      
    });
  }

  viewModeToggle(Event? e) {
    setState(() {
      _eventViewing = e;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: widget.mobileSize?
        eventsDisplayViews()
      : Row(
        children: [
          Expanded(
            flex: 2,
            child: eventsDisplayViews(),
          ),
          Expanded(
            flex: 1,
            child: buildCalendar()
          ),
        ],
      ),);
  }

  eventsDisplayViews() {
    if(_eventViewing != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontal(),
              FZIconButton(
                tint: Colors.grey, 
                icon: Icons.arrow_back, 
                onPressed: () {
                  setState(() {
                    _eventViewing = null;
                  });
                }
              ),
              horizontal(),
              const FZText(text: "Event List", style: FZTextStyle.paragraph)
            ],),
            vertical(),
            FZText(text: _eventViewing?.title, style: FZTextStyle.largeHeadline),
            vertical(),
            widget.mobileSize?
            Column(
              children: [
                Image(image: Helpers.loadImageProvider(_eventViewing?.pic)),
                vertical(),
                FZText(text: _eventViewing?.description, style: FZTextStyle.paragraph)
              ],
            )
            : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FZText(text: _eventViewing?.description, style: FZTextStyle.paragraph)
                ),
                Expanded(
                  flex: 1,
                  child: Image(image: Helpers.loadImageProvider(_eventViewing?.pic))
                )
              ],
            ),
            vertical(),
            FZText(text: "Price: ${_eventViewing?.price.toString()}", style: FZTextStyle.headline),
            vertical(),
            FZText(text: "Host: ${_eventViewing?.user?.name}", style: FZTextStyle.headline),
        ],
      );
    }


    return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _eventViewing = event;
                              });
                            },
                            child: SizedBox(
                              height: 120,
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  horizontal(),
                                  SizedBox(height: 90, child: Image(image: Helpers.loadImageProvider(event.pic)),),
                                  horizontal(),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FZText(text: Helpers.getDisplayDate(event.time), style: FZTextStyle.paragraph, color: Colors.grey,),
                                      vertical(),
                                      FZText(text: event.title, style: FZTextStyle.headline),
                                      vertical(),
                                      FZText(text: event.location?.address ?? event.user?.name, style: FZTextStyle.paragraph)
                                    ],
                                  )
                                ]
                                

                              ),),
                          );
                        },
        );
  }

  buildCalendar() {
    for(int i =0; i<_events.length; i++) {
      Event e = _events[i];
      _calendarController.add(CalendarEventData(title: e.title, date: e.time));
    }
    return Padding(padding: const EdgeInsets.all(11),
      child: MonthView(
          controller: _calendarController,
          initialMonth: DateTime.now(),
        )
      );
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}

class TodayEventFeedView extends ConsumerStatefulWidget {
  const TodayEventFeedView({super.key, required this.mobileSize});
  final mobileSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TodayEventFeedViewState();
}

class _TodayEventFeedViewState extends ConsumerState<TodayEventFeedView> {
  final List<Event> _events = List.empty(growable: true);
  Event? _eventViewing;
  late String todayLabel;
  
  @override
  void initState() {
    super.initState();
    
    
    
    // for(int i=0; i< 20; i++) {
    //   _events.add(Event.dummy(DateTime.now().add(Duration(hours: i*3))));
    // }
    loadEvents();
    
  }

  loadEvents() async {
    final today = DateTime.now();
    todayLabel = "Events Today (${today.month}/${today.day})";

    final loadedEvents = await ref.read(backend).getEvents(700000);

    for(Event e in loadedEvents) {
      if(e.time.year == today.year && e.time.month == today.month && e.time.day == today.day) {
        _events.add(e);
      }
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        vertical(),
        FZText(text: todayLabel, style: FZTextStyle.headline, color: Colors.grey,),
        const Divider(),
        vertical(),
        Expanded(child: eventsDisplayViews()),
      ],
    ) ) ;
  }

  eventsDisplayViews() {
    if(_eventViewing != null) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              horizontal(),
              FZIconButton(
                tint: Colors.grey, 
                icon: Icons.arrow_back, 
                onPressed: () {
                  setState(() {
                    _eventViewing = null;
                  });
                }
              ),
              horizontal(),
              const FZText(text: "Event List", style: FZTextStyle.paragraph)
            ],),
            vertical(),
            FZText(text: _eventViewing?.title, style: FZTextStyle.largeHeadline),
            vertical(),
            widget.mobileSize?
            Column(
              children: [
                Image(image: Helpers.loadImageProvider(_eventViewing?.pic)),
                vertical(),
                FZText(text: _eventViewing?.description, style: FZTextStyle.paragraph)
              ],
            )
            : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: FZText(text: _eventViewing?.description, style: FZTextStyle.paragraph)
                ),
                Expanded(
                  flex: 1,
                  child: Image(image: Helpers.loadImageProvider(_eventViewing?.pic))
                )
              ],
            ),
            vertical(),
            FZText(text: "Price: ${_eventViewing?.price.toString()}", style: FZTextStyle.headline),
            vertical(),
            FZText(text: "Host: ${_eventViewing?.user?.name}", style: FZTextStyle.headline),
        ],
      );
    }

    
    return ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _eventViewing = event;
                              });
                            },
                            child: SizedBox(
                              height: 120,
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  horizontal(),
                                  SizedBox(height: 90, child: Image(image: Helpers.loadImageProvider(event.pic)),),
                                  horizontal(),
                                  Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      FZText(text: Helpers.getDisplayDate(event.time), style: FZTextStyle.paragraph, color: Colors.grey,),
                                      vertical(),
                                      FZText(text: event.title, style: FZTextStyle.headline),
                                      vertical(),
                                      FZText(text: event.location?.address ?? event.user?.name, style: FZTextStyle.paragraph)
                                    ],
                                  )
                                ]
                                

                              ),),
                          );
                        },
        );
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}

// eventsDisplayViews() {
  //   List<ExpansionTile> tiles = List.empty(growable: true);
  //   for(int i =0; i<_events.length; i++) {
  //     Event e = _events[i];
  //     tiles.add(
  //       ExpansionTile(
  //         title: FZText(text: e.title, style: FZTextStyle.largeHeadline),
  //         subtitle: FZText(text: Helpers.getDisplayDate(e.time), style: FZTextStyle.paragraph),
  //         children: [EventView(event: e)],),
  //       );
  //   }
  //   return tiles;
  // }