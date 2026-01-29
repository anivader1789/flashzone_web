import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/helpers/useful_functions.dart';
import 'package:flashzone_web/src/model/appointments.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FamCartScreen extends ConsumerStatefulWidget {
  const FamCartScreen({super.key, required this.onDismiss, required this.user});
  final Function () onDismiss;
  final FZUser? user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamCartScreenState();
}

class _FamCartScreenState extends ConsumerState<FamCartScreen> {
  List<Appointment> appointments = [];
  

  loadAppointments() async {

    appointments = await ref.read(backend).getMyBookings();

    if(appointments.isNotEmpty) {
      setState(() {});
    }
      
  }

  @override
  Widget build(BuildContext context) {
    FZUser user = ref.watch(currentuser);
    bool loading = false;

    if(!user.isSignedOut && appointments.isEmpty) {

      loadAppointments();
      loading = true;
      
    }

    bool isMobileScreen = MediaQuery.of(context).size.width <= 800;

    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
        loading? Center(child: FZLoadingIndicator(text: "Loading your appointments", mobileSize: isMobileScreen),)
        : containerView(isMobileScreen, user),
      ],
    );
  }

  containerView(bool isMobileScreen, FZUser user) {
    Size screenSize = MediaQuery.of(context).size;
    if(user.isSignedOut) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobileScreen ? screenSize.width * 0.1 : screenSize.width * 0.2, 
          vertical: isMobileScreen ? screenSize.height * 0.15 : screenSize.height * 0.25,),
          padding: const EdgeInsets.all(45),
          color: Colors.white,
        child: const Center(
          child: FZText(text: "Please login to view your cart.", style: FZTextStyle.headline,),
        ),
      );
    } else if(appointments.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobileScreen ? screenSize.width * 0.1 : screenSize.width * 0.2, 
          vertical: isMobileScreen ? screenSize.height * 0.15 : screenSize.height * 0.25,),
          padding: const EdgeInsets.all(45),
          color: Colors.white,
        child: const Center(
          child: FZText(text: "Your cart is empty.", style: FZTextStyle.headline,),
        ),
      );
    } else {
      return Container(
          margin: EdgeInsets.symmetric(
          horizontal: isMobileScreen ? screenSize.width * 0.1 : screenSize.width * 0.2, 
          vertical: isMobileScreen ? screenSize.height * 0.15 : screenSize.height * 0.25,),
          padding: const EdgeInsets.all(45),
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const FZText(text:"Your Appointments:", style: FZTextStyle.headline,),
                vertical(2),
                ...appointmentsListView(isMobileScreen),
                vertical(5),
                ElevatedButton(
                  onPressed: widget.onDismiss, 
                  child: const Text("Close Cart"))
              ],
            ),
          ),
        );
    }
  }

  appointmentsListView(bool isMobile) {
    final views = [];
    for(final appt in appointments) {
      views.add(appointmentDetailView(appt, isMobile));
      views.add(vertical(3));
    }

    return views;
  }

  
  appointmentDetailView(Appointment appointment, bool isMobileScreen) {
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          headline(appointment.title),
          vertical(),
          isMobileScreen ?
          Column(
            children: [
              FZNetworkImage(url: appointment.providerPictureUrl, maxWidth: 400,),
              vertical(),
              descriptionView(appointment),
            ],
          )
          :
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Expanded(flex: 1, child: FZNetworkImage(url: appointment.providerPictureUrl, maxWidth: 400,)),
              horizontal(10),
              Expanded(flex: 2, child: descriptionView(appointment)),
            ],
          ),
        ],
      ),
    );
  }

  descriptionView(Appointment appointment) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        label("At: ${UsefulFunctions.displayableDate(appointment.startTime)}"),
        vertical(),
        label("Duration: ${appointment.duration} minutes"),
        vertical(4),
        label(appointment.description),

      ],
    );
  }

  headline(String str) => FZText(text: str, style: FZTextStyle.headline, color: Colors.black,);
  label(String str) => FZText(text: str, style: FZTextStyle.paragraph, color: Colors.black,);
  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}