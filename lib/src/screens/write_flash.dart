
import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/modules/data/fz_data.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class WriteFlashView extends ConsumerStatefulWidget {
  const WriteFlashView({super.key});

  static const routeName = 'post';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WriteFlashViewState();
}

class _WriteFlashViewState extends ConsumerState<WriteFlashView> {
  final inputController = TextEditingController();
  bool _flashSubmitting = false;
  bool _errorSubmitting = false;
  String _selectedCommunity = "Spirituality";
  final detectableController = DetectableTextEditingController(
    detectedStyle:  TextStyle(fontSize: 18, color: Constants.fillColor()),
      regExp: hashTagAtSignRegExp,
    );
    
  bool _imageUploading = false;
  String? _imageUrl;
  final int kMaxChars = 200;

  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      child: childView(mobileSize), 
      sideMenuIndex: 0);

    
  }

  childView(bool mobileSize) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FZText(text: "Write Flash", style: FZTextStyle.largeHeadline),
              Expanded(child: Container()),
              // FZButton(
              //   onPressed: () {
              //     print("Draft clicked");
              //   }, 
              //   text: "Draft")
            ],
          ),
          const SizedBox(height: 15,),
          communitySelectorView(),
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
                  final route = ref.read(routeInPipeline);
                  context.go(route ?? Routes.routeNameHome());
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
      maxLength: kMaxChars,
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
        label("1. 200 max characters allowed"),
        vertical(),
        label("2. At least 1 flashtag is required"),
        vertical(),
        label("3. Be Kind. Do not post rude remarks"),
        vertical(),
        label("4. Adhere to one topic in each post"),
      ],
    );
  }

  communitySelectorView() {
    return Row(
      children: [
        const FZText(text: "Community: ", style: FZTextStyle.headline, color: Colors.grey,),
        const SizedBox(width: 10,),
        //Dropdown menu with options for community from FZData.communities
        DropdownButton<String>(
          value: _selectedCommunity,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          underline: Container(
            height: 2,
            color: Constants.primaryColor(),
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCommunity = newValue!;
            });
          },
          items: FZData.communities.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
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
    final postAddress = "";
    //await LocationService.getAddressFromLatLng(ref);

    print("posting address with: $postAddress");
    
    //Create a new flash object
    final flash = Flash(
      content: detectableController.text,
      imageUrl: _imageUrl,
      user: ref.read(currentuser),
      postDate: DateTime.now(),
      community: _selectedCommunity,
      postLocation: FZLocation(address: postAddress, geoData: geoFirePoint.data)
    );

    final res = await ref.read(backend).createNewFlash(flash);
    if(res.code == SuccessCode.successful) {
      setState(() {
        _errorSubmitting = false;
        _flashSubmitting = false;
        context.go(Routes.routeNameHome());
      });

      //ref.read(flashes).insert(0, res.returnedObject);
      
      //widget.onFinished();
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
      Helpers.showDialogWithMessage(ctx: context, msg: "Please write something to post");
      return false;
    } else if(detectableController.text.length > kMaxChars) {
      Helpers.showDialogWithMessage(ctx: context, msg: "Flash content cannot be more than $kMaxChars characters");
      return false;
    } else if(Helpers.allFlashTagsInText(detectableController.text).isEmpty) {
      Helpers.showDialogWithMessage(ctx: context, msg: "Please add at least one flashtag to your post");
      return false;
    }

    return true;
  }

  label(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.grey,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}