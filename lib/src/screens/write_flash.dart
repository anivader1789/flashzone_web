import 'dart:io';

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
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

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
    
  bool _imageUploading = false;
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
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
            //height: 200,
            child: inputField(),
          ),
          (_imageUrl != null)? 
                const FZText(text: "Image attachment success", style: FZTextStyle.headline, color: Colors.green,)
          : Row(
            children: [
              Icon(Icons.attachment, color: Constants.primaryColor(), size: 32,),
              const SizedBox(height: 2,),
              FZText(text: "Attach Image", style: FZTextStyle.headline, color: Constants.altPrimaryColor(), onTap: () => uploadImage(context),),
            ],
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
              const SizedBox(width: 10,),
              FZText(text: _imageUploading? "Uploading image..": "Posting Flash..", style: FZTextStyle.paragraph,),
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
                //bgColor: Constants.primaryColor(),
                text: "Cancel"),
              const SizedBox(width: 10,),
              FZButton(
                onPressed: () {
                  postFlash(context);
                }, 
                //bgColor: Constants.primaryColor(),
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

  void postFlash(BuildContext ctx) async {
    if(validate() == false) return;

    //final List<String> fts = Helpers.getAllFlashTags(detectableController.text);
   // detectableController.text = detectableController.text.replaceAll(RegExp(r'#'), fzSymbol);

    //await uploadImage(ctx);

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
      imageUrl: _imageUrl,
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

      //ref.read(flashes).insert(0, res.returnedObject);
      widget.onFinished();
    } else {
      setState(() {
        _flashSubmitting = false;
        _errorSubmitting = true;
      });
    }
  }

  uploadImage(BuildContext ctx) async {
    setState(() {
      _imageUploading = true;
      _flashSubmitting = true;
    });
    final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 800);
    if(selectedImage == null) {
      print("no image selected");
      setState(() {
        _imageUploading = false;
        _flashSubmitting = false;
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
    if(size > 2000000) {
      //Greater than 1 MB
      quality = 55;
    } else if(size > 1000000) {
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

    final compressed =
      img.encodeJpg(image!, quality: quality);


    print("size of image after compression ${compressed.length}");
    //imgFile.writeAsBytesSync(compressed);

    try {
      final res = await ref.read(backend).uploadImage(compressed, fileName);
      if(res.code == SuccessCode.successful) {
        setState(() {
          _imageUrl = res.returnedObject;
          _imageUploading = false;
          _flashSubmitting = false;
        });
      } else {
        
        setState(() {
          Helpers.showDialogWithMessage(ctx: ctx, msg: res.message!);
          _imageUploading = false;
          _flashSubmitting = false;
      });
      }
      
    } catch (e) {
      print(e.toString());
      setState(() {
        Helpers.showDialogWithMessage(ctx: ctx, msg: "Error uploading avatar image");
        _imageUploading = false;
        _flashSubmitting = false;
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