import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/helpers/useful_functions.dart';
import 'package:flashzone_web/src/model/appointments.dart';
import 'package:flashzone_web/src/model/available_slots.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookSessionView extends ConsumerStatefulWidget {
  const BookSessionView({
    required this.providerUserId, 
    required this.providerFamId,
    required this.consumerCalendarId, 
    required this.consumerToken, 
    required this.providerName, 
    required this.bookingDuration, 
    super.key});
  final String providerUserId, providerFamId;
  final String consumerCalendarId;
  final String consumerToken;
  final String providerName;
  final String bookingDuration;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookSessionViewState();
}

class _BookSessionViewState extends ConsumerState<BookSessionView> {

  List<DateTime> availableSlots = [];
  late AvailableSlots availableSlotsList;
  List<List<bool>> slotStatus =List.empty();

  @override
  void initState() {
    super.initState();
    
    // Load available slots for the provider
    loadAvailableSlots();
  }

  Future<void> loadAvailableSlots() async {
    List<Appointment> bookings = await ref.read(backend).getBookingsForUser(widget.providerUserId);
    availableSlotsList = await ref.read(backend).getAvailableSlotsForProvider(widget.providerUserId, widget.providerFamId);
    

    // Process bookings to determine available slots
    setState(() {
      // Update availableSlots based on bookings
      slotStatus = UsefulFunctions.generateTimeSlotStatusMatrix(
        allowedSlots: availableSlotsList.slots,
        startDate: DateTime.now().add(const Duration(days: 1)),
        existingBookings: bookings,
      );

      
    });

  }

  loadSlotsStatus() {
    int daysCount = 7; // Assuming a week view
    int slotsPerDay = 24; // Assuming hourly slots

    slotStatus = List.generate(daysCount, (_) => List.filled(slotsPerDay, false));

    for (var slot in availableSlots) {
      int dayIndex = slot.weekday - 1; // Monday=0, Sunday=6
      int hourIndex = slot.hour; // Hour of the day

      if (dayIndex < daysCount && hourIndex < slotsPerDay) {
        slotStatus[dayIndex][hourIndex] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget availableSlotsView() {
    final List<Widget> dayRows = <Widget>[];
    for (var dayIndex = 1; dayIndex <= slotStatus.length; dayIndex++) {
      final List<Widget> slotButtons = [];
      for (var hour = 0; hour < slotStatus[dayIndex].length; hour++) {
        if (slotStatus[dayIndex][hour]) {
          slotButtons.add(horizontal());
          slotButtons.add(slotButton(dayIndex, hour));
        }
      }

      dayRows.add(vertical(2));
      dayRows.add(Row(
        children: slotButtons,
      ));

      
    }

    return Column(
      children: dayRows,
    );
  }

  Widget slotButton(int dayIndex, int hour) {
    return ElevatedButton(
      onPressed: () => bookSlot(dayIndex, hour),
      style: buttonStyle(false),
      child: label('$hour'),
    );
  }

  Future<void> bookSlot(int dayIndex, int slotIndex) async {
    
  }

  buttonStyle(bool isSelected) {
    return ElevatedButton.styleFrom(
      backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
      foregroundColor: isSelected ? Colors.white : Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  label(String text) {
    return FZText(text: text, style: FZTextStyle.paragraph);
  } 

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

}