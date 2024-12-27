import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';

class WriteFlashView extends ConsumerStatefulWidget {
  const WriteFlashView({super.key, required this.onFinished});
  final Function () onFinished;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WriteFlashViewState();
}

class _WriteFlashViewState extends ConsumerState<WriteFlashView> {
  final inputController = TextEditingController();
  bool _flashSubmitting = false;
  bool _errorSubmitting = false;
  final detectableController = DetectableTextEditingController(
    detectedStyle:  TextStyle(fontSize: 18, color: Constants.fillColor()),
      regExp: hashTagAtSignRegExp,
    );

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
            child: inputField(),
          ),
          const SizedBox(height: 15,),
          if(_errorSubmitting) Row(
                    children: [
                      Expanded(child: Container()),
                      const FZText(text: "Error posting flash", style: FZTextStyle.subheading, color: Colors.red,),
                      const SizedBox(width: 15,),
                    ],
                  ),
          _flashSubmitting?
          Row(
            children: [
              Expanded(child: Container()),
              const CircularProgressIndicator(),
              const SizedBox(width: 15,),
            ],
          )
          : Row(
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
                  postFlash();
                }, 
                bgColor: Constants.primaryColor(),
                text: "Flash")
            ],
          ),
          vertical(10),
          infoView(),
        ],
      ),);
  }

  inputField() {
    return DetectableTextField(
      controller: detectableController,
      style: const TextStyle(fontSize: 18),
      
      maxLines: 5,
      cursorColor: Constants.secondaryColor(),
      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
                        hintText: 'post a flash',
                        fillColor: Colors.white70,
                        filled: true,
                        
                      ),
    );
  }

  normalInputField() {
    return TextField(
              controller: inputController,
                      maxLines: 5,
                      cursorColor: Constants.secondaryColor(),
                      style: const TextStyle(fontSize: 18),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
                        hintText: 'post a flash',
                        fillColor: Colors.white70,
                        filled: true,
                        
                      ),
            );
  }

  infoView() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        vertical(),
        label("Rules of posting:"),
        vertical(2),
        label("1. Be Kind. Do not post rude remarks"),
        vertical(),
        label("2. Adhere to one topic in each post"),
      ],
    );
  }

  void postFlash() async {
    if(validate() == false) return;

    //final List<String> fts = Helpers.getAllFlashTags(detectableController.text);
   // detectableController.text = detectableController.text.replaceAll(RegExp(r'#'), fzSymbol);


    setState(() {
      _flashSubmitting = true;

    });

    print("Posting a flash: ${detectableController.text}");
    final GeoFirePoint geoFirePoint = GeoFirePoint(ref.read(userCurrentLocation));
    final postAddress = await LocationService.getAddressFromLatLng(ref);

    print("posting address with: $postAddress");
    //Create a new flash object
    final flash = Flash(
      content: detectableController.text,
      user: ref.read(currentuser),
      postDate: DateTime.now(),
      postLocation: FZLocation(address: postAddress, geoData: geoFirePoint.data)
    );

    final res = await ref.read(backend).createNewFlash(flash);
    if(res.code == SuccessCode.successful) {
      setState(() {
        _errorSubmitting = false;
        _flashSubmitting = false;
      });

      ref.read(flashes).insert(0, res.returnedObject);
      widget.onFinished();
    } else {
      setState(() {
        _flashSubmitting = false;
        _errorSubmitting = true;
      });
    }
  }

  bool validate() {
    if(detectableController.text.isEmpty) {
      return false;
    }

    return true;
  }

  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.grey,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}