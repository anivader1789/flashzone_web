

import 'package:flashzone_web/src/model/appointments.dart';

class UsefulFunctions {
  static String formatDateTime(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"

        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  static List<DateTime> generateTimeSlots({
    required List<List<int>> allowedSlots,
    required DateTime startDate,
    List<Appointment>? existingBookings,
  }) {
    List<DateTime> slots = [];
    
    int startWeekday = startDate.weekday - 1; // DateTime.weekday: Monday=1, Sunday=7

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
    
    int startWeekday = startDate.weekday - 1; // DateTime.weekday: Monday=1, Sunday=7

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
          startDate.day + dayOffset,
          hr,
          minute,
        );

        bool isBooked = existingBookings != null && existingBookings.any((booking) {
          return slotTime.isAtSameMomentAs(booking.startTime);
        });

        if(!isBooked && slotTime.isAfter(DateTime.now())) {
          dayStatus.add(true);
        } else {
          dayStatus.add(false);
        }
      }

      statusMatrix.add(dayStatus);
    }

    return statusMatrix;
  }
}