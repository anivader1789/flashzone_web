import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/helpers/useful_functions.dart';
import 'package:flashzone_web/src/model/appointments.dart';
import 'package:flashzone_web/src/model/available_slots.dart';
import 'package:flashzone_web/src/model/purchased_item.dart';
import 'package:flashzone_web/src/model/user.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookSessionView extends ConsumerStatefulWidget {
  const BookSessionView({
    required this.onBookingComplete,
    required this.onCancel,
    required this.providerUser, 
    
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
  final FZUser providerUser;
  final String providerFamId;
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
      _bookingInProgress = false,
      _loadingSlots = true,
      //_paymentDoneBookingInProgress = false,
      _paymentFailed = false,
      _paymentAndBookingDone = false;

  DateTime? bookedDateTime;

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
    List<Appointment> bookings = await ref.read(backend).getBookingsForUser(widget.providerUser.id!);
    availableSlotsList = await ref.read(backend).getAvailableSlotsForProvider(widget.providerUser.id!, widget.providerFamId);
    
    //print('Available Slots: ${availableSlotsList.slots}');
    // Process bookings to determine available slots
    setState(() {
      // Update availableSlots based on bookings
      slotStatus = UsefulFunctions.generateTimeSlotStatusMatrix(
        allowedSlots: availableSlotsList.slots,
        startDate: DateTime.now().add(const Duration(days: 1)),
        existingBookings: bookings,
      );

      _loadingSlots = false;
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
    Size size = MediaQuery.of(context).size;
    bool isMobile = size.width <= 600;
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
        Container(
          margin:  EdgeInsets.symmetric(
            horizontal: isMobile ? size.width * 0.05 : size.width * 0.2,
            vertical: size.height * 0.1,
          ),
          padding: const EdgeInsets.only(left: 45),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              statusView(),
              if(!_paymentAndBookingDone && !_paymentInProgress) ...[
                vertical(2),
                headline('Available Slots for next 7 days'),
                vertical(10),
                availableSlotsView(isMobile),
              ]
              
            ],
          ),
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

  Widget availableSlotsView(bool isMobile) {
    if(_bookingInProgress) {
      return Wrap(alignment: WrapAlignment.center,
        children: [
          const CircularProgressIndicator(),
          vertical(),
          headline('Booking in progress...'),
        ],
      );
    }

    if(_paymentInProgress) {
      return Wrap(alignment: WrapAlignment.center,
        children: [
          const CircularProgressIndicator(),
          vertical(),
          headline('Payment in progress...'),
        ],
      );
    }

    if(bookedDateTime != null) {
      return Wrap(alignment: WrapAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48,),
          vertical(),
          headline('You are now booked for ${UsefulFunctions.displayableDate(bookedDateTime!)}. '),
          vertical(),
          label('You will see this booking in your cart session.'),
        ],
      );
    }

    if(_loadingSlots) {
      return Wrap(alignment: WrapAlignment.center,
        children: [
          const CircularProgressIndicator(),
          vertical(),
          headline('Loading available slots...'),
        ],
      );
    }


    DateTime startDate = DateTime.now();
    final List<Widget> columnWidgets = <Widget>[];

    if(isMobile) {
      for (var dayIndex = 0; dayIndex < slotStatus.length; dayIndex++) {
        final List<Widget> dayWidgets = [];
        dayWidgets.add(label(UsefulFunctions.displayableDate(startDate.add(Duration(days: dayIndex + 1)))));
        dayWidgets.add(horizontal(2));

        final List<Widget> slotButtonsRowWidgets1 = [];
        for (var hour = 0; hour < 4; hour++) {
            int hourToDisplay = availableSlotsList.slots[dayIndex][hour];
            
            slotButtonsRowWidgets1.add(slotButton(
              dayIndex: dayIndex, 
              hourIndex: hour, 
              hour: hourToDisplay, 
              isAvailable: slotStatus[dayIndex][hour],
              isMobile: isMobile,));
            slotButtonsRowWidgets1.add(horizontal());
        }

        dayWidgets.add(Row(mainAxisAlignment: MainAxisAlignment.start,
          children: slotButtonsRowWidgets1,
        ));
        dayWidgets.add(horizontal());

        final List<Widget> slotButtonsRowWidgets = [];
        for (var hour = 4; hour < slotStatus[dayIndex].length; hour++) {
            int hourToDisplay = availableSlotsList.slots[dayIndex][hour];
            
            slotButtonsRowWidgets.add(slotButton(
              dayIndex: dayIndex, 
              hourIndex: hour, 
              hour: hourToDisplay, 
              isAvailable: slotStatus[dayIndex][hour],
              isMobile: isMobile,));
            slotButtonsRowWidgets.add(horizontal());
        }

        dayWidgets.add(Row(mainAxisAlignment: MainAxisAlignment.start,
          children: slotButtonsRowWidgets,
        ));

        columnWidgets.add(vertical(2));
        columnWidgets.add(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: dayWidgets,
        ));
      }
    } else {
      for (var dayIndex = 0; dayIndex < slotStatus.length; dayIndex++) {
        final List<Widget> slotButtonsRowWidgets = [];
        slotButtonsRowWidgets.add(label(UsefulFunctions.displayableDate(startDate.add(Duration(days: dayIndex + 1)))));
        slotButtonsRowWidgets.add(horizontal(2));
        for (var hour = 0; hour < slotStatus[dayIndex].length; hour++) {
            int hourToDisplay = availableSlotsList.slots[dayIndex][hour];
            slotButtonsRowWidgets.add(horizontal());
            slotButtonsRowWidgets.add(slotButton(
              dayIndex: dayIndex, 
              hourIndex: hour, 
              hour: hourToDisplay, 
              isAvailable: slotStatus[dayIndex][hour],
              isMobile: isMobile,));
        }

        columnWidgets.add(vertical(2));
        columnWidgets.add(Row(mainAxisAlignment: MainAxisAlignment.start,
          children: slotButtonsRowWidgets,
        ));
      }
    }
    

    return Column(
      children: columnWidgets,
    );
  }


  Widget slotButton({
    required int dayIndex, 
    required int hourIndex, 
    required int hour, 
    required bool isAvailable,
    required bool isMobile}) {
      String labelText = UsefulFunctions.displayableHourString(hour);
    return ElevatedButton(
      onPressed: () => bookSlotClicked(dayIndex, hourIndex, isAvailable),
      style: buttonStyle(isAvailable, isMobile),
      child: isMobile ? mobileLabel(labelText) : label(labelText),
    );
  }

  Future<void> bookSlotClicked(int dayIndex, int slotIndex, bool isAvailable) async {
    if(ref.read(currentuser).isSignedOut) {
      Helpers.showDialogWithMessage(ctx: context, msg: "You need to be signed in to book a session");
      return;
    }

    final bookingDate = DateTime.now().add(Duration(days: dayIndex + 1));
    final hour = availableSlotsList.slots[dayIndex][slotIndex] ~/ 100;
    final minute = availableSlotsList.slots[dayIndex][slotIndex] % 100;
    final slotDateTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      hour,
      minute,
    );

    print('Attempting to book slot on $slotDateTime');


    if(isAvailable == false) {
      Helpers.showDialogWithMessage(ctx: context, msg: "This slot is already booked");
      return;
    }

    //Helpers.showDialogWithMessage(ctx: context, msg: "Making a new booking..");
      
    //Show confirmation dialog
    Helpers.showConfirmationDialogue(
      ctx: context, 
      title: 'Confirm Booking', 
      msg: 'Do you want to book the session on ${UsefulFunctions.displayableDate(slotDateTime)}?', 
      onConfirm: ()  {
        initiateBooking(slotDateTime);

      },
    );

    //widget.onBookingComplete?.call(checkoutItem);
  }

  Future<void> initiateBooking(DateTime slotDateTime) async {
    setState(() {
          _bookingInProgress = true;
        });

        Appointment newAppointment = Appointment(
          providerId: widget.providerUser.id!,
          providerPictureUrl: widget.providerUser.avatar ?? '',
          providerName: widget.providerName,
          duration: int.parse(widget.bookingDuration),
          price: widget.price.toDouble(),
          consumerId: ref.read(currentuser).id!,
          startTime: slotDateTime,
          endTime: slotDateTime.add(Duration(
            minutes: int.parse(widget.bookingDuration),
          )),
          meetingLink: '',
          title: widget.title,
          description: widget.description,
        );

        newAppointment = await ref.read(backend).makeBooking(newAppointment);

        setState(() {
          _bookingInProgress = false;
          _paymentInProgress = true;
        });

        PurchasedItem checkoutItem = PurchasedItem(
          itemTypeIndex: 0,
          title: widget.title,
          description: widget.description,
          buyerUserId: ref.read(currentuser).id!,
          sellerUserId: widget.providerUser.id!,
          sellerFamId: widget.providerFamId,
          //pic: ,
          price: 2,// widget.price.toDouble(),
          currency: widget.currency,
          appointmentId: newAppointment.id, 
        );

        ref.read(backend).attachCallbacksForPayment(
          (paymentSuccessResponse) async {
            print('Payment successful: ${paymentSuccessResponse.paymentId}');
            await ref.read(backend).addPurchasedItem(checkoutItem);
            setState(() {
              _paymentInProgress = false;
              _paymentAndBookingDone = true;
              bookedDateTime = slotDateTime;
              _bookingInProgress = false;
            });
          }, 
          (paymentFailureResponse) {
            print('Payment failed: ${paymentFailureResponse.message}');
            setState(() {
              _paymentInProgress = false;
              _paymentFailed = true;
            });
          }, 
          (paymentChangeResponse) {
            print('Payment method changed: ${paymentChangeResponse.walletName}');
          });

        

        ref.read(backend).initiatePayment(
          2,//widget.price.toDouble(), 
          widget.currency);


  }



  buttonStyle(bool isAvailable, bool isMobile) {
    return ElevatedButton.styleFrom(
      backgroundColor: isAvailable ? Colors.white : Colors.grey[500],
      foregroundColor: isAvailable ? Colors.white : Colors.black,
      padding: isMobile ? const EdgeInsets.symmetric(vertical: 8, horizontal: 12) : const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isAvailable == false ? Colors.red : Colors.blue,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  label(String text) {
    return FZText(text: text, style: FZTextStyle.paragraph);
  } 

  mobileLabel(String text) {
    return FZText(text: text, style: FZTextStyle.subheading);
  }

  headline(String text) {
    return FZText(text: text, style: FZTextStyle.largeHeadline);
  }

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

}