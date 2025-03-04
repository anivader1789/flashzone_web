import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class AdminEventCreation extends ConsumerStatefulWidget {
  const AdminEventCreation({super.key});

  static const routeName = 'admineventcreate';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AdminEventCreationState();
}

class _AdminEventCreationState extends ConsumerState<AdminEventCreation> {
  bool _loading = false, _success = false;
  bool _copyEventLoading = false;
  String? _error;
  int _eventDuration = 60;

  final copyEventIdCont = TextEditingController(), titleCont = TextEditingController(),
        descriptionCont = TextEditingController(),
        usernameCont = TextEditingController(),
        userhandleCont = TextEditingController(),
        userpicCont = TextEditingController(),
        imgCont = TextEditingController(),
        priceCont = TextEditingController(),
        donationCont = TextEditingController(),
        latCont = TextEditingController(),
        lonCont = TextEditingController(),
        addressCont = TextEditingController(),
        mapCont = TextEditingController();

  DateTime? _eventTime;

  setTime() {
    int year, month,day,hour,minute;
    showDatePicker(context: context, 
    firstDate: DateTime.now(), 
    lastDate: DateTime(2026))
    .then((date) {
      year = date!.year;
      month = date.month;
      day = date.day;
      showTimePicker(context: context, 
      initialTime: TimeOfDay.now())
      .then((time) {
        hour = time!.hour;
        minute = time.minute;

        
        setState(() {
          _eventTime =  DateTime(year, month, day, hour, minute);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(12),
    child: SingleChildScrollView(
      child: Column(mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              label("Copy from:  "),
              horizontal(),
              field(copyEventIdCont)
            ],
          ),
          vertical(),
          _copyEventLoading? const LinearProgressIndicator():  FZButton(onPressed: populateFromEvent, text: "Fetch data"),
          const Divider(),
          vertical(2),
          stringRow("Title    ", titleCont),vertical(),
          longStringRow("Description ", descriptionCont),vertical(),
          stringRow("Image    ", imgCont, TextInputType.url),vertical(),
          stringRow("User's Name ", usernameCont),vertical(),
          stringRow("Username ", userhandleCont),vertical(),
          stringRow("Avatar    ", userpicCont, TextInputType.url),vertical(),
          stringRow("Price    ", priceCont, TextInputType.number),vertical(),
          stringRow("Lat:    ", latCont, TextInputType.number),vertical(),
          stringRow("Lon:    ", lonCont, TextInputType.number),vertical(),
          stringRow("Address:    ", addressCont, TextInputType.text),vertical(),
          longStringRow("Map Embed ", mapCont),vertical(),
          eventTimeRow(),vertical(),
          durationRow(context),
          vertical(2),
          if(_error != null) FZText(text: _error, style: FZTextStyle.headline, color: Colors.red,),
          if(_success) const FZText(text: "Success", style: FZTextStyle.headline, color: Colors.green,),
          _loading? const CircularProgressIndicator()
          : FZButton(onPressed: () => submit() , text: "Submit", bgColor: Constants.primaryColor(),)
        ],
      ),
    ),);
  }

  submit() async {
    if(validate() == false) return;

    setState(() {
      _loading = true;
    });

    try {
      final GeoFirePoint geoFirePoint = GeoFirePoint(GeoPoint(double.parse(latCont.text), double.parse(lonCont.text)));
      final event = Event(
        title: titleCont.text, 
        description: descriptionCont.text, 
        price: double.parse(priceCont.text),
        pic: imgCont.text,
        user: FZUser(name: usernameCont.text, username: userhandleCont.text, avatar: userpicCont.text),
        time: _eventTime!,
        duration: _eventDuration,
        map: mapCont.text,
        location: FZLocation(address: addressCont.text, geoData: geoFirePoint.data)
      );

      final res = await ref.read(backend).createNewEvent(event);
      if(res.code == SuccessCode.successful) {
        setState(() {
          _loading = false;
          _success = true;
        });
      } else {
        setState(() {
          _loading = false;
          _error = "error with uploading document";
        });
      }
    } catch (e) {
      setState(() {
          _loading = false;
          _error = "exception thrown";
        });
    }
  }

  populateFromEvent() async {
    if(copyEventIdCont.text.isEmpty) return;

    setState(() {
      _copyEventLoading = true;
    });
    final event = await ref.read(backend).fetchEvent(copyEventIdCont.text);
    

    if(event != null) {
      titleCont.text = event.title;
      descriptionCont.text = event.description;
      usernameCont.text = event.user?.name ?? "";
      userhandleCont.text = event.user?.username ?? "";
      userpicCont.text = event.user?.avatar ?? "";
      imgCont.text = event.pic;
      mapCont.text = event.map ?? "";
      addressCont.text = event.location?.address ?? "";
      priceCont.text = event.price.toString();
      GeoPoint geoPoint = event.location?.geoData["geopoint"];

      latCont.text = geoPoint.latitude.toString();
      lonCont.text = geoPoint.longitude.toString();
    }
    setState(() {
      _copyEventLoading = false;
    });
  }

  validate() {
    if(titleCont.text.isEmpty || descriptionCont.text.isEmpty 
    || usernameCont.text.isEmpty || userhandleCont.text.isEmpty
     || latCont.text.isEmpty || lonCont.text.isEmpty || _eventTime == null) {
      return false;
     }

     return true;
  }

  stringRow(String text, TextEditingController controller, [TextInputType keyType = TextInputType.text]) {
    return Row(
      children: [
        label(text),
        horizontal(),
        field(controller, keyType),
      ],
    );
  }

  longStringRow(String text, TextEditingController controller, [TextInputType keyType = TextInputType.text]) {
    return Row(
      children: [
        label(text),
        horizontal(),
        field(controller, keyType, true),
      ],
    );
  }

  eventTimeRow() {
    return Row(
      children: [
        label("Date time: "),
        horizontal(),
        FZButton(onPressed: () => setTime(), text: "Set/Change", bgColor: Constants.primaryColor()),
        horizontal(),
        if(_eventTime != null) label(_eventTime.toString()),
      ],
    );
  }

  durationRow(BuildContext context) {
    return Row(
      children: [
        label("Duration: "),
        horizontal(),
        FZButton(onPressed: () {
          showTimePicker(context: context, initialTime: const TimeOfDay(hour: 1, minute: 0))
          .then((time) {
            if(time == null) return;
            setState(() {
              _eventDuration = (time.hour * 60) + time.minute;
            });
          });
        }, text: "Set/Change", bgColor: Constants.primaryColor()),
        horizontal(),
        label("$_eventDuration minutes"),
      ],
    );
  }

  field(TextEditingController cont, [TextInputType keyType = TextInputType.text, bool isLong = false]) {
    return SizedBox(width: 550,
      child: TextField(
                              //onChanged: _search,
                              controller: cont,
                              keyboardType: keyType,
                maxLines: isLong? 5: 1,
                              cursorColor: Constants.primaryColor(),
                              style: const TextStyle(fontSize: 12),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                                fillColor: Colors.white70,
                                filled: true,
                                
                              ),
                            ),
    );
  }
  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.grey,);
  vertical([double multiple = 1]) => SizedBox(height: 15 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}