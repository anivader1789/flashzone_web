
import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/model/location.dart';
import 'package:flashzone_web/src/model/user.dart';

class Event {
  String id, title, description;
  DateTime time;
  FZUser? user;
  String pic;
  bool donation;
  double price;
  FZLocation? location;
  Event({required this.id, required this.title, required this.description, this.location, required this.time, this.user, this.pic = "assets/event_placeholder.jpeg", this.donation = false, this.price = 10});

  static dummy(DateTime when) => Event(
    id: "12345esefs", 
    title: "Event at FlashZone", 
    description: "This is a placeholder event to how the event will look in real. Users will be able to add any kind of description here including clickable links", 
    user: Fakes.generateFakeUserSync(),
    time: when);

    static String collectionName = "event";
    static String imageKey = "img", titleKey = "title", descriptionKey = "description", userIdKey = "userId", 
    userhandleKey = "userhandle", nameKey = "username", userPicKey = "userPic", donationKey = "donation",
    dateKey = "date", priceKey = "price", geoKey = "geo", addressKey = "address";

    static Event fromDocSnapshot(String id, Map<String, dynamic>? data) {
      if(data == null) return dummy(DateTime.now());

      return Event(
        id: id,
        title: data[titleKey],
        description: data[descriptionKey],
        pic: data[imageKey],
        user: FZUser(id: data[userIdKey], name: data[nameKey], username: data[userhandleKey], avatar: data[userPicKey]),
        time: DateTime.parse(data[dateKey]),
        location: FZLocation(address: data[addressKey], geoData: data[geoKey]),
        price: double.parse(data[priceKey]),
        donation: bool.parse(data[donationKey])
        );
    }
}