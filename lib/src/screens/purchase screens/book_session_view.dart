import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/helpers/useful_functions.dart';
import 'package:flashzone_web/src/model/appointments.dart';
import 'package:flashzone_web/src/model/available_slots.dart';
import 'package:flashzone_web/src/model/purchased_item.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookSessionView extends ConsumerStatefulWidget {
  const BookSessionView({
    required this.onBookingComplete,
    required this.onCancel,
    required this.providerUserId, 
    required this.providerFamId,
    required this.providerName, 
    required this.bookingDuration, 
    required this.title,
    required this.description,
    required this.price,
    required this.currency,
    super.key});
  final Function(PurchasedItem)? onBookingComplete;
  final Function()? onCancel;
  final String providerUserId, providerFamId;
  final String providerName;
  final String bookingDuration;
  final String title, description;
  final int price;
  final String currency;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookSessionViewState();
}

class _BookSessionViewState extends ConsumerState<BookSessionView> {

  bool _paymentInProgress = false, 
      //_paymentDoneBookingInProgress = false,
      _paymentFailed = false,
      _paymentAndBookingDone = false;

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
    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            statusView(),
            if(!_paymentAndBookingDone && !_paymentInProgress) ...[
              vertical(2),
              label('Available Slots for ${widget.providerName}'),
              vertical(10),
              availableSlotsView(),
            ]
            
          ],
        )
      ],
    );
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.center,
    //   children: [
    //     label('Available Slots for ${widget.providerName}'),
    //     vertical(10),
    //     availableSlotsView(),
    //   ],
    // );
  }

  Widget statusView() {
    if (_paymentInProgress) {
      return label('Payment in progress...');
    } else if (_paymentFailed) {
      return label('Payment failed. Please try again.');
    } else if (_paymentAndBookingDone) {
      return label('Payment and booking successful!');
    } else {
      return Container();
    }
  }

  Widget availableSlotsView() {
    DateTime startDate = DateTime.now();
    final List<Widget> dayRows = <Widget>[];
    for (var dayIndex = 1; dayIndex <= slotStatus.length; dayIndex++) {
      final List<Widget> slotButtons = [];
      for (var hour = 0; hour < slotStatus[dayIndex].length; hour++) {
        if (slotStatus[dayIndex][hour]) {
          slotButtons.add(horizontal());
          slotButtons.add(slotButton(dayIndex, hour));
        }
      }

      dayRows.add(vertical());
      dayRows.add(label(UsefulFunctions.formatDateTime(startDate.add(Duration(days: dayIndex - 1)))));
      dayRows.add(vertical());
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

    

    DateTime today = DateTime.now();
    int hour = availableSlotsList.slots[dayIndex - 1][slotIndex];
    int hr = (hour / 100).floor();
    int minute = hour % 100;
    DateTime slotTime = DateTime(
      today.year,
      today.month,
      today.day + dayIndex,
      hr,
      minute,
    );

    Appointment newAppointment = Appointment(
      providerId: widget.providerUserId,
      consumerId: ref.read(currentuser).id!,
      startTime: slotTime,
      endTime: slotTime.add(Duration(
        minutes: int.parse(widget.bookingDuration),
      )),
      meetingLink: '',
      title: widget.title,
      description: widget.description,
    );

    

    PurchasedItem checkoutItem = PurchasedItem(
      itemTypeIndex: 0,
      title: widget.title,
      description: widget.description,
      buyerUserId: ref.read(currentuser).id!,
      sellerUserId: widget.providerUserId,
      sellerFamId: widget.providerFamId,
      //pic: ,
      price: widget.price.toDouble(),
      currency: widget.currency,
      appointmentId: newAppointment.id, 
    );

    ref.read(backend).attachCallbacksForPayment(
      (paymentSuccessResponse) async {
        ref.read(backend).addPurchasedItem(checkoutItem);
        ref.read(backend).makeBooking(newAppointment);
        setState(() {
          _paymentInProgress = false;
          _paymentAndBookingDone = true;
        });
      }, 
      (paymentFailureResponse) {
        setState(() {
          _paymentInProgress = false;
          _paymentFailed = true;
        });
      }, 
      (paymentChangeResponse) {

      });

    setState(() {
      _paymentInProgress = true;
    });

    ref.read(backend).initiatePayment(widget.price.toDouble(), widget.currency);

    //widget.onBookingComplete?.call(checkoutItem);


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