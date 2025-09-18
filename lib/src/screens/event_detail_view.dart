import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'dart:html' as html;

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_webview/fwfh_webview.dart';
import 'package:go_router/go_router.dart';

class EventDetailsView extends ConsumerStatefulWidget {
  const EventDetailsView({super.key, required this.eventId});
  final String? eventId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EventDetailsViewState();
}

class _EventDetailsViewState extends ConsumerState<EventDetailsView> {
  Event? _event;
  bool _loading = false, _error = false;

  @override
  void initState() {
    super.initState();
    loadEvent();
  }

  loadEvent() async {
    if(widget.eventId == null) {
      setState(() {
        _error = true;
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    _event = await ref.read(backend).fetchEvent(widget.eventId!);
    setState(() {
      _loading = false;
      if(_event == null) {
        _error = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      onInitDone: () {
        Future(() => loadEvent());
      },
      child: childView(mobileSize), 
      sideMenuIndex: 1);


    
  }

  childView(bool mobileSize) {
    if(_loading) {
      return FZLoadingIndicator(text: "Loading event", mobileSize: mobileSize);
    }
    
    if(_error) {
      return FZErrorIndicator(text: "Event not found", mobileSize: mobileSize);
    }

    if(_event == null) {
      return FZErrorIndicator(text: "Event not loaded. Try reloading the page", mobileSize: mobileSize);
    }

    return Padding(
      padding: const EdgeInsets.all(21),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min,
          children: [
            vertical(2),
            headlineView(),
            vertical(2),
            Row(children: [
              ThumbnailView(link: _event!.user?.avatar, mobileSize: mobileSize, radius: 42, mobileRadius: 32,),
              //CircleAvatar(foregroundImage: Helpers.loadImageProvider(_event!.user?.avatar), radius: widget.mobileSize? 32: 48,),
              horizontal(2),
              Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FZText(text: "Hosted by ", style: FZTextStyle.headline),
                  vertical(),
                  InkWell(
                    child: FZText(text: _event!.user!.name, style: FZTextStyle.paragraph, color: Colors.blue,),
                    onTap: () => context.go(Routes.routeNameProfile(_event!.user!.id!)),),
                  ],
                )
            ],),
            vertical(2),
            const Divider(),
            vertical(4),
            topSectionView(mobileSize),
            vertical(2),
          ],
        ),
      ),
    );
  }

  headlineView() {
    if(_event == null) return Container();

    if(_event!.user!.id == ref.read(currentuser).id) {
      return Row(
        children: [
          FZRichHeadline(text: _event!.title),
          horizontal(2),
          InkWell(
            child: const Icon(Icons.edit, color: Colors.grey,),
            onTap: () {
              ref.read(eventInEdit.notifier).update((state) => _event);
              context.go(Routes.routeNameEventCreate());
            }
          ),
        ],
      );
    } else {
      return FZRichHeadline(text: _event!.title);
    }
  }

  topSectionView(bool mobileSize) {
    if(mobileSize) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image(image: Helpers.loadImageProvider(_event?.pic), width: double.infinity, fit: BoxFit.fill,),
          vertical(),
          infoSection(),
          vertical(3),
          //hasHtmlContent(_event!.description)?
          htmlContentView(_event!.description)
          //: FZText(text: _event!.description, style: FZTextStyle.paragraph),
        ],
      );
    }

    return Row(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Expanded(
          flex: 6, 
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(image: Helpers.loadImageProvider(_event?.pic), width: double.infinity, fit: BoxFit.fill,),
              vertical(3),
              htmlContentView(_event!.description),
            ],
          )
          ),
        Expanded(flex: 1, child: Container()),
        Expanded(flex: 4, child: infoSection(), ),
      ],
    );
  }

  infoSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,mainAxisSize: MainAxisSize.min,
      children: [
        
        priceInfoBox(),
        vertical(3),
        timeInfoBox(),
        vertical(3),
        locationInfoBox(),
        //FZText(text: "Directions", style: FZTextStyle.headline, onTap: () => html.window.open('https://google.com', 'new tab'),)
      ],
    );
  }

  timeInfoBox() {
    return  infoBox(Column(
          children: [
            rowLabel(Helpers.getDisplayDay(_event!.time), Icons.calendar_month),
            vertical(2),
            rowLabel(Helpers.getDisplayTime(_event!.time, _event!.duration), Icons.schedule),
          ],
        ));
  }

  priceInfoBox() {
    String donationText = _event!.donation? " (Donation allowed)": "";
    return infoBox(
      Row(
          children: [
            const FZText(text: "Price: ", style: FZTextStyle.headline),
            horizontal(2),
            FZText(text: _event!.price == 0? "FREE$donationText": "\$${_event!.price}$donationText", style: FZTextStyle.largeHeadline)
          ],
        ) );
        
  }

  locationInfoBox() {
    //return htmlContentView(_event!.map);
    return infoBox(Column(mainAxisSize: MainAxisSize.min,
      children: [
        rowLabel(_event!.location?.address ?? "New York City, NY 11005", Icons.room),
        vertical(),
        htmlContentView(_event!.map)
      ],
    ));
  }

  infoBox(Widget child) {
    return Card(
      color: Constants.cardColor(),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 21, 26, 21),
        child: child
      ),
    );
  }

  rowLabel(String label, IconData icon) {
    return Row(mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          horizontal(),
          Expanded(child: FZText(text: label, style: FZTextStyle.headline)),
        ],
      );
  }

  htmlContentView(String? data) {
    if(data == null) return Container();
    
    print("Rendering html view");
    return SingleChildScrollView(//alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: HtmlWidget(
        '''
        $data
        ''',
          //"<iframe src=\"\" width=\"400\" height=\"300\" style=\"border:0;\" allowfullscreen=\"\" loading=\"lazy\" referrerpolicy=\"no-referrer-when-downgrade\"></iframe>",
      
          // all other parameters are optional, a few notable params:
      
          // specify custom styling for an element
          // see supported inline styling below
          customStylesBuilder: (element) {
            if (element.classes.contains('foo')) {
              return {'color': 'red'};
            }
      
            return null;
          },
      
          customWidgetBuilder: (element) {
            if (element.attributes['foo'] == 'bar') {
              // render a custom block widget that takes the full width
              return Container();
            }
      
            if (element.attributes['fizz'] == 'buzz') {
              // render a custom widget inline with surrounding text
              return InlineCustomWidget(
                child: Container(),
              );
            }
      
            return null;
          },

          factoryBuilder: () => MyWidgetFactory(),
      
          // this callback will be triggered when user taps a link
          onTapUrl: (url) {
            return true;
          },
      
          // select the render mode for HTML body
          // by default, a simple `Column` is rendered
          // consider using `ListView` or `SliverList` for better performance
          renderMode: RenderMode.column,
      
          // set the default styling for text
          textStyle: const TextStyle(fontSize: 14),
        ),
    );
  }

  bool hasHtmlContent(String str) => str.contains("<html>");

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

}

class MyWidgetFactory extends WidgetFactory with WebViewFactory {}