import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key, this.famId});
  final String? famId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  bool _loading = false;
  String? _error;
  int _eventDuration = 60;
  bool _imageUploading = false;
  String? _imageUrl, _oldImageUrl;
  int _eventRepeatOptionSelected = 0;

  final copyEventIdCont = TextEditingController(),
      titleCont = TextEditingController(),
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
      addressCityCont = TextEditingController(),
      addressStateCont = TextEditingController(),
      addressCountryCont = TextEditingController(),
      addressInstructionCont = TextEditingController(),
      addressAreaCont = TextEditingController(),
      mapCont = TextEditingController();

  late DateTime _eventDateTime;
  Event? editingEvent;

  @override
  void initState() {
    super.initState();

    editingEvent = ref.read(eventInEdit);
    if (editingEvent != null) {
      _eventDateTime = editingEvent!.time;
    } else {
      _eventDateTime = DateTime.now();
    }

    populateFields();
  }

  populateFields() {
    priceCont.text = "0";

    if (editingEvent == null) return;

    titleCont.text = editingEvent!.title;
    descriptionCont.text = editingEvent!.description;
    _imageUrl = editingEvent!.pic;
    _eventDateTime = editingEvent!.time;
    _eventDuration = editingEvent!.duration;
    priceCont.text = editingEvent!.price.toString();
    addressCont.text = editingEvent!.location?.address ?? "";
    latCont.text = editingEvent!.location?.geoData['geopoint']?.latitude
            .toString() ??
        "";
    lonCont.text = editingEvent!.location?.geoData['geopoint']?.longitude
            .toString() ?? "";
    addressAreaCont.text = editingEvent!.addressArea ?? "";
    _eventRepeatOptionSelected = editingEvent!.eventRepeatOption;
    addressInstructionCont.text = editingEvent!.addressInstructions ?? "";
    mapCont.text = editingEvent!.map ?? "";
  }

  setTime(BuildContext context) {
    int year, month, day, hour, minute;
    showDatePicker(
            context: context,
            firstDate: DateTime.now(),
            lastDate: DateTime(2026))
        .then((date) {
      year = date!.year;
      month = date.month;
      day = date.day;
      showTimePicker(context: context, initialTime: TimeOfDay.now())
          .then((time) {
        hour = time!.hour;
        minute = time.minute;

        setState(() {
          _eventDateTime = DateTime(year, month, day, hour, minute);
        });

        return _eventDateTime;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(child: childView(mobileSize), sideMenuIndex: 1);
  }

  childView(bool mobileSize) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FZText(
                text: editingEvent != null
                    ? "Edit Event"
                    : widget.famId == null? "Event Registration form": "Event registration for your fam",
                style: mobileSize
                    ? FZTextStyle.headline
                    : FZTextStyle.largeHeadline),
            const Divider(),
            vertical(),
            basicInfoInput(mobileSize),
            vertical(2),
            dateTimeInput(mobileSize),
            vertical(2),
            durationInput(),
            vertical(2),
            repeatOptionInput(mobileSize),
            vertical(2),
            priceInput(mobileSize),
            vertical(2),
            locationInput(mobileSize),
            vertical(2),
            mapEmbedInput(mobileSize),
            vertical(2),
            if (_error != null)
              FZText(
                text: _error,
                style: FZTextStyle.headline,
                color: Colors.red,
              ),
            _loading
                ? const CircularProgressIndicator()
                : FZButton(
                    onPressed: submit,
                    text: editingEvent == null ? "Submit" : "Save",
                    bgColor: Constants.altPrimaryColor(),
                  ),

            vertical(),
            const Divider(),
            instructionsView(mobileSize),
          ],
        ),
      ),
    );
  }

  basicInfoInput(bool mobileSize) {
    if (!mobileSize) {
      return Row(
        children: [
          horizontal(),
          imageUploadField(context),
          horizontal(5),
          Column(
            children: [
              field(titleCont, label: "Name of the event"),
              vertical(),
              field(descriptionCont, label: "Description", isLong: true)
            ],
          )
        ],
      );
    } else {
      return Column(
        children: [
          imageUploadField(context),
          vertical(),
          field(titleCont, label: "Name of the event"),
          vertical(),
          field(descriptionCont, label: "Description", isLong: true),
        ],
      );
    }
  }

  repeatOptionInput(bool mobileSize) {
    final listItems = [
      for (int i = 0; i < Event.repeatOptions.length; i++)
        DropdownMenuEntry(value: i, label: Event.repeatOptions[i])
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(text: "Repeat Option", style: FZTextStyle.headline),
        DropdownMenu(
          width: 300,
          initialSelection: 0,
          inputDecorationTheme: InputDecorationTheme(
            //isDense: true,
            //contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints.tight(const Size.fromHeight(40)),
            border: const UnderlineInputBorder(),
          ),
          dropdownMenuEntries: listItems,
          //label: FZText(text: Event.repeatOptions[_eventRepeatOptionSelected], style: FZTextStyle.paragraph),
          onSelected: (value) {
            setState(() {
              _eventRepeatOptionSelected = value ?? 0;
            });
          },
        ),
      ],
    );
  }

  mapEmbedInput(bool mobileSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(
            text: "Embed a map: (Optional)", style: FZTextStyle.headline),
        const FZText(
            text: "See instructions for details",
            style: FZTextStyle.subheading),
        vertical(),
        field(mapCont, label: "Map Embed code", isLong: true),
      ],
    );
  }

  locationInput(bool mobileSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(text: "Event Venue Location", style: FZTextStyle.headline),
        vertical(),
        
        const FZText(
            text: "Latitude and Longitude (See below the form for instructions)",
            style: FZTextStyle.paragraph),
        mobileSize?
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field(latCont,
                label: "Latitude",
                keyType: TextInputType.number,
                customWidth: 150,
                icon: const Icon(Icons.location_on)),
            field(lonCont,
                label: "Longitude",
                keyType: TextInputType.number,
                customWidth: 150,
                icon: const Icon(Icons.location_on)),
            ],
          )
        : Row(
          children: [
            field(latCont,
                label: "Latitude",
                keyType: TextInputType.number,
                customWidth: 150,
                icon: const Icon(Icons.location_on)),
            horizontal(4),
            field(lonCont,
                label: "Longitude",
                keyType: TextInputType.number,
                customWidth: 150,
                icon: const Icon(Icons.location_on)),
          ],
        ),
        vertical(),
        const FZText(
            text: "Street address", style: FZTextStyle.paragraph),
        field(addressCont, label: "eg: 1234 Main St, Apt 101"),
        
        vertical(),
        const FZText(
            text: "Borough, County (Optional)",
            style: FZTextStyle.paragraph),
        field(addressAreaCont, label: "eg: Brooklyn"),
        vertical(),
        const FZText(
            text: "City",
            style: FZTextStyle.paragraph),
        field(addressCityCont, label: "eg: New York City"),
        vertical(),
        const FZText(
            text: "State",
            style: FZTextStyle.paragraph),
        field(addressStateCont, label: "eg: New York"),
        vertical(),
        const FZText(
            text: "Country",
            style: FZTextStyle.paragraph),
        field(addressCountryCont, label: "eg: USA"),
        vertical(),
        const FZText(
            text: "Any instructions, landmark, parking info, etc",
            style: FZTextStyle.paragraph),
        field(addressInstructionCont, label: "eg: Next to the subway station. Parking available"),
      ],
    );
  }

  priceInput(bool mobileSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(
            text: "Event Price (Keep 0 for free)", style: FZTextStyle.headline),
        vertical(),
        field(priceCont,
            label: "0",
            keyType: TextInputType.number,
            customWidth: 90,
            icon: const Icon(Icons.attach_money)),
      ],
    );
  }

  submit() async {
    if (validate(context) == false) return;

    setState(() {
      _loading = true;
    });


    final fullAddress = "${addressCont.text}, ${addressCityCont.text}, "
        "${addressStateCont.text}, ${addressCountryCont.text}";

    try {
      if (editingEvent != null) {
        final GeoFirePoint geoFirePoint = GeoFirePoint(
            GeoPoint(double.parse(latCont.text), double.parse(lonCont.text)));

        editingEvent!.title = titleCont.text;
        editingEvent!.description = descriptionCont.text;
        editingEvent!.pic = _imageUrl!;
        editingEvent!.time = _eventDateTime;
        editingEvent!.duration = _eventDuration;
        editingEvent!.eventRepeatOption = _eventRepeatOptionSelected;
        editingEvent!.addressInstructions = addressInstructionCont.text;
        editingEvent!.addressArea = addressAreaCont.text;
        editingEvent!.map = mapCont.text;
        editingEvent!.location = FZLocation(
                address: fullAddress, geoData: geoFirePoint.data);
        editingEvent!.price = double.parse(priceCont.text);

        final res = await ref.read(backend).updateEvent(editingEvent!);
        if (res.code == SuccessCode.successful) {
          if (_oldImageUrl != null && _oldImageUrl != _imageUrl) {
            deleteImage(_oldImageUrl);
          }
          ref.read(eventInEdit.notifier).state = null; // Clear the editing state
          setState(() {
            _loading = false;
            context.go(Routes.routeNameEventDetail(res.returnedObject));
          });
        } else {
          setState(() {
            _loading = false;
            _error = "error creating this event";
          });
        }
      } else {
        final GeoFirePoint geoFirePoint = GeoFirePoint(
            GeoPoint(double.parse(latCont.text), double.parse(lonCont.text)));
        final event = Event(
            title: titleCont.text,
            description: descriptionCont.text,
            price: double.parse(priceCont.text),
            pic: _imageUrl!,
            user: ref.read(currentuser),
            addressArea: addressAreaCont.text,
            addressInstructions: addressInstructionCont.text,
            eventRepeatOption: _eventRepeatOptionSelected,
            byFam: widget.famId,
            time: _eventDateTime,
            duration: _eventDuration,
            map: mapCont.text,
            location: FZLocation(
                address: fullAddress, geoData: geoFirePoint.data));

        final res = await ref.read(backend).createNewEvent(event);
        if (res.code == SuccessCode.successful) {
          setState(() {
            _loading = false;
            context.go(Routes.routeNameEventDetail(res.returnedObject));
          });
        } else {
          setState(() {
            _loading = false;
            _error = "error creating this event";
          });
        }
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        _loading = false;
        _error = "exception thrown";
      });
    }
  }

  imageUploadField(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        uploadImage(ctx);
      },
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          color: Constants.bgColor(),
          borderRadius: BorderRadius.circular(18),
          image: _imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_imageUrl!), fit: BoxFit.cover)
              : null,
        ),
        child: _imageUploading
            ? const Center(child: CircularProgressIndicator())
            : _imageUrl != null? null: const Icon(
                Icons.add_a_photo,
                size: 50,
                color: Colors.white,
              ),
      ),
    );
  }

  uploadImage(BuildContext ctx) async {
    setState(() {
      _imageUploading = true;
    });
    final selectedImage = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxHeight: 800);
    if (selectedImage == null) {
      print("no image selected");
      setState(() {
        _imageUploading = false;
      });
      return;
    }

    //final bytes = await selectedImage.readAsBytes();
    //final docPath = await getApplicationDocumentsDirectory();
    final id = DateTime.now().toString();
    final fileName = "flashimg${ref.read(currentuser).id}$id.jpg";
    //File imgFile = File("${docPath.path}/$fileName");
    //File imgFile = File(fileName);

    //final fileName = selectedImage.path.split("/").last;
    //final fileExt = fileName.split(".").last;
    //print("File path: ${imgFile.path}  ");

    int size = await selectedImage.length();
    print("size of image $size");

    var quality = 90;
    if (size > 2000000) {
      //Greater than 1 MB
      quality = 55;
    } else if (size > 1000000) {
      //Greater than 1 MB
      quality = 70;
    }

    img.Image? image = img.decodeImage(await selectedImage.readAsBytes());
    // Resize the image to have the longer side be 800 pixels
    // int width;
    // int height;

    // if (image!.width > image.height) {
    //   width = 800;
    //   height = (image.height / image.width * 800).round();
    // } else {
    //   height = 800;
    //   width = (image.width / image.height * 800).round();
    // }

    // img.Image resizedImage = img.copyResize(image, width: width, height: height);

    final compressed = img.encodeJpg(image!, quality: quality);

    print("size of image after compression ${compressed.length}");
    //imgFile.writeAsBytesSync(compressed);

    final folder = "event/${ref.read(currentuser).id}";

    try {
      final res = await ref.read(backend).uploadImage(compressed, fileName, folder);
      if (res.isSuccessful) {
        setState(() {
          _oldImageUrl = _imageUrl;
          _imageUrl = res.returnedObject;
          _imageUploading = false;
        });
      } else {
        setState(() {
          Helpers.showDialogWithMessage(ctx: ctx, msg: res.message!);
          _imageUploading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        Helpers.showDialogWithMessage(
            ctx: ctx, msg: "Error uploading avatar image");
        _imageUploading = false;
      });
    }
  }

  deleteImage(String? url) async {
    if (url == null) return;
    await ref.read(backend).deleteImage(url);
  }

  bool validate(BuildContext ctx) {
    if (ref.read(currentuser).isSignedOut) {
      Helpers.showDialogWithMessage(
          ctx: context, msg: "You have to be signed in to submit a new event");
      return false;
    }

    if (titleCont.text.isEmpty) {
      Helpers.showDialogWithMessage(
          ctx: ctx, msg: "Please enter an event name");
      return false;
    }

    if (descriptionCont.text.isEmpty) {
      Helpers.showDialogWithMessage(
          ctx: ctx, msg: "Please enter a description");
      return false;
    }

    if (_imageUrl == null) {
      Helpers.showDialogWithMessage(
          ctx: ctx, msg: "Event must have a display image");
      return false;
    }

    if(latCont.text.isEmpty || lonCont.text.isEmpty) {
      Helpers.showDialogWithMessage(
          ctx: ctx, msg: "Please enter latitude and longitude");
      return false;
    }

    if (addressCont.text.isEmpty || addressCityCont.text.isEmpty ||
        addressStateCont.text.isEmpty || addressCountryCont.text.isEmpty) {
      Helpers.showDialogWithMessage(
          ctx: ctx, msg: "Please enter the full address of the event. Including street address, city, state and country");
      return false;
    }

    

    return true;
  }

  dateTimeInput(bool mobileSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(
            text: "Select a date and time", style: FZTextStyle.headline),
        vertical(),
        if(mobileSize) ...[
          dateField(),
          vertical(),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if(!mobileSize) ...[
              dateField(),
              horizontal(4),
            ],
            const FZText(text: "at", style: FZTextStyle.headline),
            horizontal(4),
            timeField()
          ],
        )
      ],
    );
  }

  durationInput() {
    //Generate durations (minutes) from 30 minutes to 6 hours in 15 minutes increments
    final durations = List.generate(24, (index) => (index + 1) * 15); // 15, 30, ..., 360 minutes
    // final durations = List.generate(
    //     12, (index) => (index + 1) * 30); // 30, 60, 90, ..., 360 minutes

    //Generate DropdownMenuEntries for each duration
    List<DropdownMenuEntry> items = [];
    for (int i = 0; i < durations.length; i++) {
      int duration = durations[i];
      int hours = duration ~/ 60;
      int minutes = duration % 60;
      String hoursStr = hours > 0
          ? hours == 1
              ? "$hours hour "
              : "$hours hours "
          : "";
      String minutesStr = minutes > 0
          ? minutes == 1
              ? "$minutes minute"
              : "$minutes minutes"
          : "";
      String label = "$hoursStr$minutesStr".trim();
      items.add(DropdownMenuEntry(value: duration, label: label));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(text: "Event Duration", style: FZTextStyle.headline),
        vertical(),
        Row(
          children: [
            const Icon(Icons.timer),
            horizontal(),
            DropdownMenu(
              width: 200,
              initialSelection: _eventDuration,
              inputDecorationTheme: InputDecorationTheme(
                //isDense: true,
                //contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                border: const UnderlineInputBorder(),
              ),
              dropdownMenuEntries: items,
              //label: FZText(text: "$_eventDuration minutes", style: FZTextStyle.paragraph),
              onSelected: (value) {
                setState(() {
                  _eventDuration = value ?? 60; // Default to 60 minutes
                });
              },
            ),
          ],
        )
      ],
    );
  }

  dateField() {
    final format = DateFormat("yyyy-MM-dd");
    return SizedBox(
      width: 200,
      child: DateTimeField(
          decoration: const InputDecoration(icon: Icon(Icons.today)),
          initialValue: _eventDateTime,
          format: format,
          onChanged: (value) {
            setState(() {
              _eventDateTime = DateTime(
                  value?.year ?? _eventDateTime.year,
                  value?.month ?? _eventDateTime.month,
                  value?.day ?? _eventDateTime.day,
                  _eventDateTime.hour,
                  _eventDateTime.second);
            });
          },
          onShowPicker: (context, currentVal) {
            return showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(2026));
          }),
    );
  }

  timeField() {
    final format = DateFormat("HH:mm");
    return SizedBox(
      width: 150,
      child: DateTimeField(
        decoration: const InputDecoration(icon: Icon(Icons.timer)),
        format: format,
        initialValue: _eventDateTime,
        onChanged: (value) {
          setState(() {
            _eventDateTime = DateTime(
                _eventDateTime.year,
                _eventDateTime.month,
                _eventDateTime.day,
                value?.hour ?? _eventDateTime.hour,
                value?.second ?? _eventDateTime.second);
          });
        },
        onShowPicker: (context, currentValue) async {
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
          );
          return DateTimeField.convert(time);
        },
      ),
    );
  }

  field(TextEditingController cont,
      {TextInputType keyType = TextInputType.text,
      required String label,
      bool isLong = false,
      double customWidth = 550,
      Icon? icon}) {
    return SizedBox(
      width: customWidth,
      child: TextField(
        //onChanged: _search,
        controller: cont,
        keyboardType: keyType,
        maxLines: isLong ? 5 : 1,
        cursorColor: Constants.primaryColor(),
        style: const TextStyle(fontSize: 19),
        decoration: InputDecoration(
          prefixIcon: icon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          fillColor: Colors.white70,
          filled: true,
          labelText: label,
        ),
      ),
    );
  }

  instructionsView(bool mobileSize) {
    String itemsPrefix = mobileSize? "": " - ";

    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FZText(text: "Instructions:", style: FZTextStyle.largeHeadline),
        vertical(),
        label("${itemsPrefix}Please upload a clear image to make a good impression"),
        label("${itemsPrefix}Provide very clear details on the event in the description"),
        label("${itemsPrefix}The city, borough, county field is there so that users could easily find your event when they search with the search term that includes borough."),
        label("${itemsPrefix}Latitude and Longitude fields are mandatory and you can find them when you find your event location on Google map as the red pin, right click on the pin and click what's here. These are two decimal numbers."),
        label("${itemsPrefix}You can optionally put in your map html code by going to your location on google map, click share, then click embed a map, select small size and then copy the code. Paste the code as is in the map embed field"),
        label("${itemsPrefix}For any questions, please contact us from the contact us menu button on the left side."),
        vertical(),
      ],
    );
  }

  label(String str) => FZText(
        text: str,
        style: FZTextStyle.headline,
        color: Colors.grey,
      );
  vertical([double multiple = 1]) => SizedBox(
        height: 15 * multiple,
      );
  horizontal([double multiple = 1]) => SizedBox(
        width: 5 * multiple,
      );
}
