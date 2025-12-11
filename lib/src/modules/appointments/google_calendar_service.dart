import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:flutter/foundation.dart';

class GoogleCalendarService {
  static const String _baseUrl = 'https://www.googleapis.com/calendar/v3';
  static const String accessToken = '123'; // Replace with real token
  

  /// Create a 60-minute event after payment success
static Future<Map<String, dynamic>> createEvent({
  required String calendarId,
  required String accessToken,
  required DateTime startTime,
  required String customerName,
  required String customerEmail,
  required String famOwnerEmail,
  String? summary,
  String? description,
  bool createGoogleMeet = true,
}) async {
  final endTime = startTime.add(const Duration(minutes: 60));
  
  // Generate unique requestId for Google Meet
  final requestId = DateTime.now().millisecondsSinceEpoch.toString();
  
  final eventBody = {
    'summary': summary ?? 'Private Session - $customerName',
    'description': description ?? 'Booked via Flashzone fam. Payment confirmed.',
    'start': {
      'dateTime': startTime.toUtc().toIso8601String(),
      'timeZone': 'Asia/Kolkata', // IST
    },
    'end': {
      'dateTime': endTime.toUtc().toIso8601String(),
      'timeZone': 'Asia/Kolkata',
    },
    'attendees': [
      {'email': customerEmail, 'displayName': customerName},
      {'email': famOwnerEmail},
    ],
    if (createGoogleMeet) ...{
      'conferenceData': {
        'createRequest': {
          'requestId': requestId,
          'conferenceSolutionKey': {'type': 'hangoutsMeet'},
        }
      }
    },
    'reminders': {
      'useDefault': false,
      'overrides': [
        {'method': 'email', 'minutes': 30},
        {'method': 'popup', 'minutes': 10},
      ],
    },
    'source': 'Flashzone Booking',
  };
  
  final response = await http.post(
    Uri.parse('https://www.googleapis.com/calendar/v3/calendars/$calendarId/events?conferenceDataVersion=1'),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(eventBody),
  );
  
  if (response.statusCode != 200) {
    throw Exception('Event creation failed: ${response.body}');
  }
  
  final eventData = jsonDecode(response.body);
  return {
    'eventId': eventData['id'],
    'htmlLink': eventData['htmlLink'],
    'meetLink': eventData['conferenceData']?['entryPoints']?[0]?['uri'] ?? '',
    'iCalUID': eventData['iCalUID'],
  };
}


  /// Check free/busy for next 7 days, returns available slots
  static Future<List<DateTimeRange>> getAvailableSlots({
    required String calendarId,
    required DateTime startDate,
    required Duration sessionDuration,
    required Map<String, dynamic> workingHours, // e.g. {"mon": ["10:00", "18:00"]}
  }) async {
    final timeMin = startDate.toUtc().toIso8601String();
    final timeMax = startDate.add(Duration(days: 7)).toUtc().toIso8601String();
    
    // FreeBusy query
    final freeBusyResponse = await http.post(
      Uri.parse('$_baseUrl/freebusy'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'timeMin': timeMin,
        'timeMax': timeMax,
        'items': [{'id': calendarId}], // 'primary' or specific calendar ID
      }),
    );
    
    if (freeBusyResponse.statusCode != 200) {
      throw Exception('FreeBusy failed: ${freeBusyResponse.body}');
    }
    
    final freeBusyData = jsonDecode(freeBusyResponse.body);
    final busyIntervals = _parseBusyIntervals(freeBusyData['calendars']?[calendarId]?['busy'] ?? []);
    
    // Generate available slots based on working hours
    return _generateAvailableSlots(
      startDate: startDate,
      busyIntervals: busyIntervals,
      sessionDuration: sessionDuration,
      workingHours: workingHours,
    );
  }
  
  /// Parse busy intervals from FreeBusy response
  static List<DateTimeRange> _parseBusyIntervals(List<dynamic> busyJson) {
    return busyJson.map((busy) => DateTimeRange(
      start: DateTime.parse(busy['start']),
      end: DateTime.parse(busy['end']),
    )).toList();
  }
  
  /// Generate available slots respecting working hours and avoiding busy times
  static List<DateTimeRange> _generateAvailableSlots({
    required DateTime startDate,
    required List<DateTimeRange> busyIntervals,
    required Duration sessionDuration,
    required Map<String, dynamic> workingHours,
  }) {
    final availableSlots = <DateTimeRange>[];
    final endDate = startDate.add(Duration(days: 7));
    
    DateTime current = startDate;
    while (current.isBefore(endDate)) {
      final daySlots = _getDayWorkingSlots(current, workingHours);
      
      for (final daySlot in daySlots) {
        final potentialSlots = _splitIntoSessionSlots(daySlot, sessionDuration);
        final freeSlots = potentialSlots.where((slot) => 
          !_isOverlappingAnyBusy(slot, busyIntervals)
        ).toList();
        
        availableSlots.addAll(freeSlots);
      }
      
      current = current.add(Duration(days: 1));
    }
    
    return availableSlots.take(20).toList(); // Limit to top 20 slots
  }
  
  static List<DateTimeRange> _getDayWorkingSlots(DateTime day, Map<String, dynamic> workingHours) {
    final dayName = _dayName(day.weekday);
    final hours = workingHours[dayName] as List<dynamic>? ?? [];
    
    return hours.map((hourRange) {
      final times = hourRange.split('-');
      final startTime = _parseTime(times[0], day);
      final endTime = _parseTime(times[1], day);
      return DateTimeRange(start: startTime, end: endTime);
    }).toList();
  }
  
  static List<DateTimeRange> _splitIntoSessionSlots(DateTimeRange daySlot, Duration sessionDuration) {
    final slots = <DateTimeRange>[];
    DateTime slotStart = daySlot.start;
    
    while (slotStart.add(sessionDuration).isBefore(daySlot.end)) {
      slots.add(DateTimeRange(
        start: slotStart,
        end: slotStart.add(sessionDuration),
      ));
      slotStart = slotStart.add(Duration(minutes: 30)); // 30min buffer
    }
    
    return slots;
  }
  
  static bool _isOverlappingAnyBusy(DateTimeRange slot, List<DateTimeRange> busyIntervals) {
    for (final busy in busyIntervals) {
      //if (slot.overlaps(busy)) return true;
    }
    return false;
  }
  
  static String _dayName(int weekday) => 
      ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'][weekday - 1];
  
  static DateTime _parseTime(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    return DateTime(
      date.year, date.month, date.day,
      int.parse(parts[0]), int.parse(parts[1]),
    ).toLocal();
  }
}