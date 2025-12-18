
import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/event.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/modules/fams/members_list_view.dart';
import 'package:flashzone_web/src/modules/fams/membership_status_views.dart';
import 'package:flashzone_web/src/modules/fams/pending_requests_list.dart';
import 'package:flashzone_web/src/modules/views/loading_fam_view.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flashzone_web/src/screens/subviews/event_cell_view.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flashzone_web/src/screens/themed_screen.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';


//http://localhost:50000/#fams/H2xoT8GAAWd3tKGbeij3

class FamHomeScreen extends ConsumerStatefulWidget {
  const FamHomeScreen({super.key, required this.famId, required this.hasCustomPage});
  final String? famId;
  final bool hasCustomPage;
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
  late TapGestureRecognizer _tapGestureForEventCreationForm;
  final String demoFam = "aOqZk8CWzsUz5wPGVKg3";

  bool _loading = false;
  bool _isPreview = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();

    _tapGestureForEventCreationForm = TapGestureRecognizer()..onTap = eventCreationFormTapped;

    //fetchDeatils();
    if(widget.famId == "0") {
      fam = ref.read(famInEdit);
      _isPreview = fam != null;
    }
  }

  eventCreationFormTapped() {
    if(widget.famId == null) return;
    
    context.go(Routes.routeNameEventCreateFromFam(widget.famId!));
    //launchUrl(Uri.parse('https://docs.google.com/forms/d/1BNL_2lR26mvI2KdAZMWKv5Oshf3Ykrmk-ExMZpGgwi4'), webOnlyWindowName: '_blank');
  }

  void fetchDetails() async {
    // Fetch the details of the fam from the database
    // and set the state with the fetched data
    // Example:

    if(widget.famId == "0") {
      
    } else {
       setState(() {
        _loading = true;
      });
      _events.clear();
      fam = await ref.read(backend).fetchFam(widget.famId!);
      
      setState(() {
        if(fam != null) {
          _isAdmin = fam!.admins.contains(ref.read(currentuser).id);
          fetchFamEvents();
        }
        _loading = false;
      });
    }
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
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    print("Testing custom domain for fam detail page: ${widget.hasCustomPage}");
    return MasterView(
      onInitDone: () {
        Future(() => fetchDetails());
      },
      child: childView(mobileSize), 
      showMenu: widget.hasCustomPage == false,
      sideMenuIndex: 2);
      
  }

  childView(bool mobileSize) {
    if(ref.read(famInEdit) == null && widget.famId == "0") {
      return FZErrorIndicator(text: "Nothing to preview..", mobileSize: mobileSize);
    }

    if(widget.hasCustomPage) {
      if(_loading || fam == null) {
        return const LoadingWidget();
      } else {
        return ThemedPage(fam!);
      }
        
      }

    if(_loading) {
      
      return FZLoadingIndicator(text: "Please wait..", mobileSize: mobileSize);
    }

    if(fam == null) {
      return FZErrorIndicator(text: "Fam Error", mobileSize: mobileSize);
    }

    if(fam!.pageContent != null) {
      return ThemedPage(fam!);
    }

    return Padding(padding: const EdgeInsets.all(10),
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start , 
          mainAxisSize: MainAxisSize.min,
          children: [
            famDetails(mobileSize),
            vertical(2),
            FZText(text: "Be part of the discussion:", style: FZTextStyle.headline, color: Constants.secondaryColor(),),
            vertical(),
            ElevatedButton(
              
              onPressed: () {
                context.go(Routes.routeNameFamChat(widget.famId!));
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
            if(_isAdmin) Text.rich(
              TextSpan(children: [
                const TextSpan(text: "To create events for your fam, please fill up this form: "),
                TextSpan(
                  text: "'Event Registration Form'.", 
                  style: const TextStyle(color: Colors.blue),
                  recognizer: _tapGestureForEventCreationForm,
                  mouseCursor: SystemMouseCursors.click)
            ])),
            vertical(2),
            eventsGridView(_events, mobileSize),
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
  Widget famDetails(bool mobileSize) {
    if(mobileSize) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          adminView(mobileSize),
          if(_isPreview) previewBar(mobileSize),
          vertical(),
          Row(
            children: [
              ThumbnailView(link: fam!.imageUrl, radius: 64, mobileRadius: 32, mobileSize: true,),
              horizontal(),
              Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headlineView(mobileSize),
                  vertical(),
                  viewMembersLink()
                ],
              ),
            ],
          ),
          vertical(),
          MembershipStatusView(fam: fam!, user: ref.read(currentuser)),
          vertical(2),
          FZText(text: fam!.description, style: FZTextStyle.paragraph),
          vertical(2),
          //membershipButtonsView(),
          
        ],
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        adminView(mobileSize),
        if(_isPreview) previewBar(mobileSize),
        vertical(),
        Row(
          children: [
            ThumbnailView(link: fam!.imageUrl, radius: 64, mobileRadius: 21, mobileSize: false,),
            horizontal(),
            Column(mainAxisSize: MainAxisSize.min,crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headlineView(mobileSize),
                  vertical(),
                  viewMembersLink()
                ],
              ),
            horizontal(),
            Expanded(child: Container()),
            MembershipStatusView(fam: fam!, user: ref.read(currentuser)),
            horizontal(),
          ],
        ),
        vertical(2),
        FZText(text: fam!.description, style: FZTextStyle.paragraph),
        
      ],
    );
  } 

  headlineView(bool mobileSize) {
    if(fam == null) return Container();

    if(_isAdmin) {
      return Row(
        children: [
          FZText(text: fam!.name, style: mobileSize? FZTextStyle.headline: FZTextStyle.largeHeadline, color: Colors.black,),
          horizontal(2),
          InkWell(
            onTap: editFam,
            child: const Icon(Icons.edit, color: Colors.grey,),
          ),
        ],
      );
    } else {
      return FZText(text: fam!.name, style: mobileSize? FZTextStyle.headline: FZTextStyle.largeHeadline, color: Colors.black,);
    }
  }

  adminView(bool mobileSize) {
    if(!_isAdmin) return const SizedBox.shrink();

    return Container( width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Constants.secondaryColor(),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: mobileSize?
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            const FZText(text: "You are an admin", style: FZTextStyle.smallsubheading, color: Colors.white,),
            vertical(),
            OverlayPortal(
                            controller: _pendingsPopupController, 
                            overlayChildBuilder:  
                              (context) => PendingRequestsList(
                                fam: fam!, 
                                onDismiss: () => _pendingsPopupController.hide(),
                                ),
                            child: FZText(text: "View all pending requests", style: FZTextStyle.smallsubheading, color: Colors.white, onTap: _pendingsPopupController.toggle,),
                            ),
            vertical(),
          ],
        )
       : Row(
        children: [
          horizontal(3),
          const FZText(text: "You are an admin", style: FZTextStyle.subheading, color: Colors.white,),
          const Expanded(child: SizedBox()),
           OverlayPortal(
                          controller: _pendingsPopupController, 
                          overlayChildBuilder:  
                            (context) => PendingRequestsList(
                              fam: fam!, 
                              onDismiss: () => _pendingsPopupController.hide(),
                              ),
                          child: FZText(text: "View all pending requests", style: FZTextStyle.subheading, color: Colors.white, onTap: _pendingsPopupController.toggle,),
                          ),
          horizontal(),
          horizontal(3),
        ],
      ),
    );
  }

  previewBar(bool mobileSize) {
    return Container( width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Constants.secondaryColor(),
        borderRadius: const BorderRadius.all(Radius.circular(18)),
      ),
      child: mobileSize?
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
          children: [
            const FZText(text: "Preview Mode", style: FZTextStyle.smallsubheading, color: Colors.white,),
            vertical(),
            Row(
              children: [
                FZButton(onPressed: publishFam, text: "Publish"),
                horizontal(),
                FZButton(onPressed: editFam, text: "Cancel"),
              ],
            )
          ],
        )
       : Row(
        children: [
          horizontal(3),
          const FZText(text: "Preview mode", style: FZTextStyle.subheading, color: Colors.white,),
          const Expanded(child: SizedBox()),
          FZButton(onPressed: () => publishFam(), text: "Publish"),
          horizontal(),
          FZButton(onPressed: editFam, text: "Cancel"),
          horizontal(3),
        ],
      ),
    );
  }

  publishFam() async {
    if(fam == null) return;

    setState(() {
      _loading = true;
    });

    final result = await ref.read(backend).addNewFam(fam!);

    if(result.isSuccessful) {
      setState(() {
        ref.read(famInEdit.notifier).update((state) => null);
        _loading = false;
        context.go(Routes.routeNameFamDetail(result.returnedObject));
      });
    } else {
      setState(() {
        _loading = false;
        Helpers.showDialogWithMessage(ctx: context, msg: "Error publishing fam. Please try again..");

      });
    }
  }

  editFam() {
    ref.read(famInEdit.notifier).update((state) => fam);
    context.go(Routes.routeNameFamNew());
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
                              adminIds: fam!.admins,
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
                              adminIds: fam!.admins,
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

  viewMembersLink() {
    return Row(
      children: [
        const Icon(Icons.person, color: Colors.black,),
        horizontal(),
        OverlayPortal(
                          controller: _membersPopupController, 
                          overlayChildBuilder:  
                            (context) => MembersListView(
                              label: "Fam Members", 
                              memberIds: fam!.members,
                              adminIds: fam!.admins,
                              onDismiss: () => _membersPopupController.hide(),
                              ),
                          child: FZText(text: "${fam!.members.length + fam!.admins.length} Members", style: FZTextStyle.headline, color: Colors.black, onTap: _membersPopupController.toggle,),
                          )
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
                                compact: true,
                            ),
                          );
                        },
                      );
  }

  eventsGridView(List<Event> events, bool mobileSize) {
    if(events.isEmpty) {
      return FZText(text: "No events for now", style: FZTextStyle.headline, color: Constants.secondaryColor(),);
    }
    return GridView.count(shrinkWrap: true,
      crossAxisCount: mobileSize? 1: 3,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(events.length, (index) {
                    return EventCellView(event: events[index]);
                  },
    ));
  }

  Widget vertical([int multiplier = 1]) => SizedBox(height: 5 * multiplier.toDouble(),);
  Widget horizontal([int multiplier = 1]) => SizedBox(width: 5 * multiplier.toDouble(),);

}