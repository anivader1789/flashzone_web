
import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/user.dart';

class Event {
  String title, description;
  String? id;
  DateTime time;
  FZUser? user;
  String pic;
  bool donation;
  double price;
  int duration;
  int eventRepeatOption;
  String? addressInstructions;
  String? addressArea;
  String? map;
  String? byFam;
  FZLocation? location;
  Event({this.id, 
  required this.title, 
  required this.description, 
  this.location,  
  this.eventRepeatOption = 0,
  required this.time, 
  this.byFam, this.user, this.addressInstructions, this.addressArea,
  this.pic = "assets/event_placeholder.jpeg", this.donation = false, this.price = 0, this.duration = 60, this.map});

  static dummy(DateTime when) => Event(
    id: "12345esefs", 
    title: "Event at FlashZone", 
    description: "This is a placeholder event to how the event will look in real. Users will be able to add any kind of description here including clickable links", 
    user: Fakes.generateFakeUserSync(),
    time: when);

    static String collectionName = "event";
    static String imageKey = "img", titleKey = "title", 
    descriptionKey = "description", userIdKey = "userId", 
    userhandleKey = "userhandle", nameKey = "username", 
    userPicKey = "userPic", donationKey = "donation", byFamKey = "byFam",
    dateKey = "date", durationKey = "duration", 
    priceKey = "price", eventRepeatOptionKey = "eventRepeatOption",
    geoKey = "geo", addressKey = "address", addressInstructionsKey = "addressInstructions", addressAreaKey = "addressArea", mapKey = "map";

    static Event fromDocSnapshot(String id, Map<String, dynamic>? data) {
      if(data == null) return dummy(DateTime.now());

      return Event(
        id: id,
        title: data[titleKey],
        description: data[descriptionKey],
        pic: data[imageKey],
        user: FZUser(id: data[userIdKey], name: data[nameKey], username: data[userhandleKey], avatar: data[userPicKey]),
        time: DateTime.parse(data[dateKey]),
        duration: data[durationKey] ?? 60,
        location: FZLocation(address: data[addressKey], geoData: data[geoKey]),
        price: data[priceKey],
        eventRepeatOption: data[eventRepeatOptionKey] ?? 0,
        addressInstructions: data[addressInstructionsKey],
        addressArea: data[addressAreaKey],
        map: data[mapKey],
        byFam: data[byFamKey],
        donation: data[donationKey]
        );
    }

    static List<String> repeatOptions = ["Do not repeat", "Repeat once a week", "Repeat once every 2 weeks", "Repeat once a month"];

    Map<String, dynamic> creationObj() {
      return {
        titleKey: title,
        descriptionKey: description,
        imageKey: pic,
        userIdKey: user!.id,
        nameKey: user!.name,
        userhandleKey: user!.username,
        userPicKey: user!.avatar,
        dateKey: time.toString(),
        durationKey: duration,
        addressKey: location?.address,
        addressInstructionsKey: addressInstructions,
        eventRepeatOptionKey: eventRepeatOption,
        addressAreaKey: addressArea,
        geoKey: location?.geoData,
        priceKey: price,
        mapKey: map,
        byFamKey: byFam,
        donationKey: donation
      };
    }

    Map<String, dynamic> updateObj() {
      return {
        titleKey: title,
        descriptionKey: description,
        imageKey: pic,
        dateKey: time.toString(),
        durationKey: duration,
        addressKey: location?.address,
        addressInstructionsKey: addressInstructions,
        eventRepeatOptionKey: eventRepeatOption,
        addressAreaKey: addressArea,
        geoKey: location?.geoData,
        priceKey: price,
        mapKey: map,
      };
    }
}