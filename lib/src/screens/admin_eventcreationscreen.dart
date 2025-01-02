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
  String? _error;

  final titleCont = TextEditingController(),
        descriptionCont = TextEditingController(),
        usernameCont = TextEditingController(),
        userhandleCont = TextEditingController(),
        userpicCont = TextEditingController(),
        imgCont = TextEditingController(),
        priceCont = TextEditingController(),
        donationCont = TextEditingController(),
        latCont = TextEditingController(),
        lonCont = TextEditingController(),
        addressCont = TextEditingController();

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
    child: Column(mainAxisSize: MainAxisSize.min,
      children: [
        stringRow("Title    ", titleCont),vertical(),
        stringRow("Description ", descriptionCont),vertical(),
        stringRow("Image    ", imgCont, TextInputType.url),vertical(),
        stringRow("User's Name ", usernameCont),vertical(),
        stringRow("Username ", userhandleCont),vertical(),
        stringRow("Avatar    ", userpicCont, TextInputType.url),vertical(),
        stringRow("Price    ", priceCont, TextInputType.number),vertical(),
        stringRow("Lat:    ", latCont, TextInputType.number),vertical(),
        stringRow("Lon:    ", lonCont, TextInputType.number),vertical(),
        stringRow("Address:    ", addressCont, TextInputType.text),vertical(),
        eventTimeRow(),
        vertical(2),
        if(_error != null) FZText(text: _error, style: FZTextStyle.headline, color: Colors.red,),
        if(_success) const FZText(text: "Success", style: FZTextStyle.headline, color: Colors.green,),
        _loading? const CircularProgressIndicator()
        : FZButton(onPressed: () => submit() , text: "Submit", bgColor: Constants.primaryColor(),)
      ],
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
        user: FZUser(name: usernameCont.text, username: userhandleCont.text, avatar: userpicCont.text),
        time: _eventTime!,
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
  field(TextEditingController cont, [TextInputType keyType = TextInputType.text]) {
    return SizedBox(width: 150,
      child: TextField(
                              //onChanged: _search,
                              controller: cont,
                              keyboardType: keyType,
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
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}