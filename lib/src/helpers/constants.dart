import 'package:flutter/material.dart';

class Constants {
  static Color primaryColor() => const Color.fromARGB(255, 251, 182, 43);
  static Color secondaryColor() => const Color.fromARGB(255, 45, 45, 45);
  static Color altPrimaryColor() => const Color.fromARGB(255, 182, 130, 27);
  static Color lightColor() => const Color.fromARGB(188, 242, 241, 188);
  static Color fillColor() => const Color.fromARGB(255, 112, 10, 130);
  static Color bgColor() => const Color.fromARGB(255, 88, 71, 53);
  static Color cardColor() => const Color.fromARGB(210, 255, 234, 212);


  static const List<String> flashtags = [
    "UFO", "Spirituality", "Paranormal" , "NDE"
  ];
}

class Routes {
  static const String authentication = 'authentication';
  static const String home = '/';
  static const String events = "events";
  static const String post = "post";
  static const String eventCreate = "eventCreate";
  static const String fams = "fams";
  static const String famDetail = "fam";
  static const String famNew = "addFam";
  static const String eventDetail = "event";
  static const String notifications = "notif";
  static const String flashDetails = "flash";
  static const String profile = "user";
  static const String contactUs = "contactus";
  static const String famChat = "famChat";
  static const String dm = "dm";
  static const String admin = "admin";

  static String routeNameAuthentication() => "$home$authentication";
  static String routeNameHome() => home;
  static String routeNameContactUs() => "$home$contactUs";
  static String routeNameEventsList() => "$home$events";
  static String routeNameEventCreate() => "$home$eventCreate";
  static String routeNameEventCreateFromFam(String famId) => "$home$eventCreate/$famId";
  static String routeNamePost() => "$home$post";
  static String routeNameFams() => "$home$fams";
  static String routeNameFamDetail(String famId) => "$home$famDetail/$famId";
  static String routeNameFamNew() => "$home$famNew";
  static String routeNameEventDetail(String eventId) => "$home$eventDetail/$eventId";
  static String routeNameNotifications() => "$home$notifications";
  static String routeNameFlashDetails(String flashId) => "$home$flashDetails/$flashId";
  static String routeNameProfile(String userId) => "$home$profile/$userId";
  static String routeNameFamChat(String famId) => "$home$famChat/$famId";
  static String routeNameDM(String? userId) => userId == null? "$home$dm": "$home$dm/$userId";
  static String routeNameAdmin() => "$home$admin";

}