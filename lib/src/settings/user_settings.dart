import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static final List<String> filters = [
    "Spirituality", "Healing", "TarrotCards", "NDE"
  ];

  static const String feedFilterKey = "feedfilter";

  static Future<String> getFlashFeedFilter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(feedFilterKey) ?? "all";
  }

  static Future<void> setFlashFeedFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(feedFilterKey, filter);
  }
}