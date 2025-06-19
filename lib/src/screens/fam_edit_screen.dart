import 'package:detectable_text_field/detectable_text_field.dart';
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/modules/location/location_service.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class FamEditScreen extends ConsumerStatefulWidget {
  const FamEditScreen({super.key});

  static const routeName = 'famAddNew';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamEditScreenState();
}

class _FamEditScreenState extends ConsumerState<FamEditScreen> {
  final nameInputController = DetectableTextEditingController(
    detectedStyle:  TextStyle(fontSize: 18, color: Constants.fillColor()),
      regExp: hashTagRegExp,
    );

  final descriptionInputController = DetectableTextEditingController(
    detectedStyle:  TextStyle(fontSize: 18, color: Constants.fillColor()),
      regExp: urlRegex,
    );

  bool _imageUploading = false;
  String? _imageUrl;

    
  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      child: childView(mobileSize), 
      sideMenuIndex: 1);

      
    
  }

  childView(bool mobileSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FZText(text: "Creating a new Fam", style: FZTextStyle.headline),
          vertical(2),
          imageUploadField(context),
          vertical(2),
          nameInputField(),
          vertical(2),
          descInputField(),
          vertical(2),
          FZButton(
            onPressed: () {
             createFam(context);
            } ,
            text: "Create Fam",
          ),

        ],
      ),
    );
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
          image: _imageUrl != null ? DecorationImage(image: NetworkImage(_imageUrl!), fit: BoxFit.cover) : null,
        ),
        child: _imageUploading ? const Center(child: CircularProgressIndicator()) : const Icon(Icons.add_a_photo, size: 50, color: Colors.white,),
      ),
    );
  }

  nameInputField() {
    return DetectableTextField(
      maxLength: 60,
      controller: nameInputController,
      style: const TextStyle(fontSize: 18),
      maxLines: 1,
      cursorColor: Constants.secondaryColor(),
      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
                        hintText: 'name of your fam.. (Flashtag)',
                        fillColor: Colors.white70,
                        filled: true,
                        prefixText: "#",
                      ),
    );
  }

  descInputField() {
    return DetectableTextField(
      maxLength: 600,
      controller: descriptionInputController,
      style: const TextStyle(fontSize: 18),
      
      maxLines: 5,
      cursorColor: Constants.secondaryColor(),
      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18.0),),
                        hintText: 'description of your fam..',
                        fillColor: Colors.white70,
                        filled: true,
                        
                      ),
    );
  }

  createFam(BuildContext context) async {
    final GeoFirePoint geoFirePoint = GeoFirePoint(ref.read(userCurrentLocation));
    final postAddress = await LocationService.getAddressFromLatLng(ref);

    final fam = Fam(
      admins: [ref.read(currentuser).id!], 
      name: nameInputController.text,
      description: descriptionInputController.text,
      createdAt: DateTime.now(),
      location: FZLocation(address: postAddress, geoData: geoFirePoint.data), 
      members: [], memberRequests: [],
      adminRequests: [],
      imageUrl: _imageUrl,
      );

    final result = await ref.read(backend).addNewFam(fam);

    if(result.isSuccessful) {
      setState(() {
        context.go(Routes.routeNameFamDetail(result.returnedObject));
      });
    } else {
      Helpers.showDialogWithMessage(ctx: context, msg: "Error creating fam. Please try again..");
    }
  }

  uploadImage(BuildContext ctx) async {
    setState(() {
      _imageUploading = true;
    });
    final selectedImage = await ImagePicker().pickImage(source: ImageSource.gallery, maxHeight: 800);
    if(selectedImage == null) {
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
      if(res.isSuccessful) {
        setState(() {
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
        Helpers.showDialogWithMessage(ctx: ctx, msg: "Error uploading avatar image");
        _imageUploading = false;
      });
    }
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}