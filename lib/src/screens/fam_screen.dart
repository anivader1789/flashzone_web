
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/modules/fams/members_list_view.dart';
import 'package:flashzone_web/src/modules/fams/membership_status_views.dart';
import 'package:flashzone_web/src/modules/fams/pending_requests_list.dart';
import 'package:flashzone_web/src/screens/fam_chat_screen.dart';
import 'package:flashzone_web/src/screens/subviews/event_cell_view.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


//http://localhost:50000/#fams/H2xoT8GAAWd3tKGbeij3

class FamHomeScreen extends ConsumerStatefulWidget {
  const FamHomeScreen({super.key, required this.famId, required this.mobileSize});
  final String? famId;
  final bool mobileSize;

  static const routeName = 'fams';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamHomeScreenState();
}

class _FamHomeScreenState extends ConsumerState<FamHomeScreen> {
  List<Flash> _flashes = List.empty(growable: true);
  List<Event> _events = List.empty(growable: true);
  Fam? fam;
  final _adminsPopupController = OverlayPortalController();
  final _membersPopupController = OverlayPortalController();
  final _pendingsPopupController = OverlayPortalController();
  final String demoFam = "aOqZk8CWzsUz5wPGVKg3";

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    fetchDeatils();
  }

  void fetchDeatils() async {
    // Fetch the details of the fam from the database
    // and set the state with the fetched data
    // Example:
    setState(() {
      _loading = true;
    });
    _events.clear();
    fam = await ref.read(backend).fetchFam(widget.famId!);
    
    setState(() {
      _loading = false;
    });
    fetchFamEvents();
  }

  fetchFamEvents() async {
    _events.addAll(await ref.read(backend).getFamEvents(widget.famId!));
    if(_events.isNotEmpty) {
      setState(() {
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_loading) {
      return FZLoadingIndicator(text: "Loading Fam details..", mobileSize: widget.mobileSize);
    }

    if(fam == null) {
      return FZErrorIndicator(text: "Fam Error", mobileSize: widget.mobileSize);
    }

    return Padding(padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start , mainAxisSize: MainAxisSize.min,
          children: [
            famDetails(),
            vertical(2),
            FZText(text: "Be part of the discussion:", style: FZTextStyle.headline, color: Constants.secondaryColor(),),
            vertical(),
            ElevatedButton(
              
              onPressed: () {
                Navigator.pushNamed(context, "${FamChatScreen.routeName}/${widget.famId}");
              }, 
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(2),
                backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 182, 130, 27)),
                side: const MaterialStatePropertyAll(
                  BorderSide(
                    color: Colors.white,
                    width: 1,
                    style: BorderStyle.solid
                    )
                ),
                shape: const MaterialStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12)
                      ),
                  )
                )
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.chat, color: Colors.white,),
                    horizontal(),
                    const FZText(text: "Enter the chatroom", style: FZTextStyle.headline, color: Colors.white,),
                  ],
                ),
              )),
            vertical(6),
            FZText(text: "Events", style: FZTextStyle.headline, color: Constants.secondaryColor(),),
            const Divider(),
            vertical(2),
            eventsGridView(_events),
            vertical(),
            FZText(text: "Flashes", style: FZTextStyle.headline, color: Constants.secondaryColor(),),
            const Divider(),
            vertical(2),
            //buildFlashesView(),
          ],
        ),
      ),
    );
  }

  //A function that returns a column widget that displayes information about the fam. details are fam name, description, admn of the fam and members
  Widget famDetails() {
    if(widget.mobileSize) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThumbnailView(link: fam!.imageUrl, radius: 64, mobileRadius: 32, mobileSize: true,),
              horizontal(),
              FZText(text: "#${fam!.name}", style: FZTextStyle.headline, color: Colors.black,),
            ],
          ),
          vertical(2),
          FZText(text: fam!.description, style: FZTextStyle.paragraph),
          vertical(2),
          membershipButtonsView(),
          
        ],
        );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ThumbnailView(link: fam!.imageUrl, radius: 64, mobileRadius: 21, mobileSize: false,),
            horizontal(),
            FZText(text: "#${fam!.name}", style: FZTextStyle.tooLargeHeadline, color: Colors.black,),
            horizontal(),
            Expanded(child: Container()),
            membershipButtonsView(),
            horizontal(),
          ],
        ),
        vertical(2),
        FZText(text: fam!.description, style: FZTextStyle.paragraph),
        
      ],
    );
  } 

  membershipButtonsView() {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: _membersPopupController.toggle, 
                  child: OverlayPortal(
                          controller: _membersPopupController, 
                          overlayChildBuilder:  
                            (context) => MembersListView(
                              label: "Fam Members", 
                              memberIds: fam!.members,
                              onDismiss: () => _membersPopupController.hide(),
                              ),
                          child: FZText(text: "${fam!.members.length} Members", style: FZTextStyle.headline, color: Colors.blue,),
                          ),
                    ),
                TextButton(
                  onPressed: _adminsPopupController.toggle, 
                  child: OverlayPortal(
                          controller: _adminsPopupController, 
                          overlayChildBuilder:  
                            (context) => MembersListView(
                              label: "Fam Admins", 
                              memberIds: fam!.admins, 
                              onDismiss: () => _adminsPopupController.hide(),
                              ),
                            child: FZText(text: "${fam!.admins.length} Admin", style: FZTextStyle.headline, color: Colors.blue,),
                          ),
                    ),
                
                
                
                TextButton(
                  onPressed: _pendingsPopupController.toggle, 
                  child: OverlayPortal(
                          controller: _pendingsPopupController, 
                          overlayChildBuilder:  
                            (context) => PendingRequestsList(
                              fam: fam!, 
                              onDismiss: () => _pendingsPopupController.hide(),
                              ),
                          child: const FZText(text: "View Pending requests", style: FZTextStyle.headline, color: Colors.blue,),
                          ),
                    ),
                MembershipStatusView(fam: fam!, user: ref.read(currentuser)),
                
              ],
            );
  }

  buildFlashesView() {
    if(_flashes.isEmpty) {
      return FZText(text: "No Flashes yet", style: FZTextStyle.headline, color: Constants.secondaryColor(),);
    }
    return  ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _flashes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //onTap: () => ,
                            child: FlashCellView(
                                flash: _flashes[index],
                                profileClicked: (user) {},
                                compact: true,
                            ),
                          );
                        },
                      );
  }

  eventsGridView(List<Event> events) {
    if(events.isEmpty) {
      return FZText(text: "No events for now", style: FZTextStyle.headline, color: Constants.secondaryColor(),);
    }
    return GridView.count(shrinkWrap: true,
      crossAxisCount: widget.mobileSize? 1: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(events.length, (index) {
                    return EventCellView(event: events[index]);
                  },
    ));
  }

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);

}