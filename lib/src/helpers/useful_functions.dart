

import 'package:flashzone_web/src/model/appointments.dart';

class UsefulFunctions {
  static String formatDateTime(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"

        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  static String displayableDate(DateTime dateTime) {
    return "${weekName(dateTime.weekday)} - "
        "${dateTime.day.toString().padLeft(2, '0')}/"
        "${dateTime.month.toString().padLeft(2, '0')}/"
        "${dateTime.year.toString().padLeft(4, '0')}";
  }

  static String displayableHourString(int hour) {
    int hr = (hour / 100).floor();
    String hrString = hr > 12 ? (hr - 12).toString() : hr.toString();
    String ampm = hr >= 12 ? "PM" : "AM";
    int minute = hour % 100;
    return "$hrString:"
        "${minute.toString().padLeft(2, '0')} $ampm";
  }

  static String weekName(int weekday) {
    switch (weekday) {
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
      case 7:
        return "Sunday";
      default:
        return "";
    }
  }

  static List<DateTime> generateTimeSlots({
    required List<List<int>> allowedSlots,
    required DateTime startDate,
    List<Appointment>? existingBookings,
  }) {
    List<DateTime> slots = [];
    
    int startWeekday = (startDate.weekday + 1) % 7; 

    for(int dayOffset = 0; dayOffset < allowedSlots.length; dayOffset++) {
      int currentDayIndex = (startWeekday + dayOffset) % 7;
      List<int> dailySlots = allowedSlots[currentDayIndex];

      for(int hour in dailySlots) {
        int hr = (hour/100).floor();
        int minute = hour % 100;


        DateTime slotTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day + dayOffset,
          hr,
          minute,
        );

        bool isBooked = existingBookings != null && existingBookings.any((booking) {
          return slotTime.isAtSameMomentAs(booking.startTime);
        });

        if(!isBooked && slotTime.isAfter(DateTime.now())) {
          slots.add(slotTime);
        }
      }
    }

    return slots;
  }

  static List<List<bool>> generateTimeSlotStatusMatrix({
    required List<List<int>> allowedSlots,
    required DateTime startDate,
    List<Appointment>? existingBookings,
  }) {
    List<List<bool>> statusMatrix = [];
    
    int startWeekday = (startDate.weekday - 1) % 7 + 2; 


    for(int dayOffset = 0; dayOffset < allowedSlots.length; dayOffset++) {
      int currentDayIndex = (startWeekday + dayOffset) % 7;
      List<int> dailySlots = allowedSlots[currentDayIndex];
      List<bool> dayStatus = [];

      for(int hour in dailySlots) {
        int hr = (hour/100).floor();
        int minute = hour % 100;


        DateTime slotTime = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          hr,
          minute,
        ).add(Duration(days: dayOffset));

        bool isBooked = existingBookings != null && existingBookings.any((booking) {
          return slotTime.isAtSameMomentAs(booking.startTime);
        });

        if(!isBooked && slotTime.isAfter(DateTime.now())) {
          dayStatus.add(true);
        } else {
          dayStatus.add(false);
        }
      }

      //print('Status list for dayOffset $dayOffset: $dayStatus');

      statusMatrix.add(dayStatus);
    }

    return statusMatrix;
  }
}