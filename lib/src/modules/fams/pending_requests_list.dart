import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PendingRequestsList extends ConsumerStatefulWidget {
  const PendingRequestsList({super.key, 
    required this.fam,
    required this.onDismiss
  });
  final Fam fam;
  final Function () onDismiss;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PendingRequestsListState();
}

class _PendingRequestsListState extends ConsumerState<PendingRequestsList> {
  List<String> requestsMembers = [], requestsAdmins = [];

  @override
  void initState() {
    super.initState();

    requestsAdmins.addAll(widget.fam.adminRequests);
    requestsMembers.addAll(widget.fam.memberRequests);
    
  }
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mobileSize = size.width <= 600;
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
        Center(
          child: Container(
            width: mobileSize? size.width * 0.8: size.width * 0.5,
            height: size.height * 0.7,
            padding: const EdgeInsets.fromLTRB(25, 45, 25, 45),
              decoration: BoxDecoration(
                color: Constants.cardColor(),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
            child: containerView(),
          ),
        )
      ],
    );
  }

  containerView() {
    if (requestsAdmins.isEmpty && requestsMembers.isEmpty) {
      return const Center(
        child: FZText(text: "No pending requests", style: FZTextStyle.headline,),
      );
    }

    
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
          const FZText(text: "Pending Requests", style: FZTextStyle.headline,),
          const Divider(),
          const SizedBox(height: 10,),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
            
                // First section header
                if (index == 0) {
                  return const FZText(text: 'Admin requests', style: FZTextStyle.paragraph);
                }
                // First list items
                else if (index <= requestsAdmins.length) {
                  final userId = requestsAdmins[index - 1];
                  return RequestItemView(
                    userId: userId,
                    fam: widget.fam,
                    isAdminRequest: true,
                    requestAccepted: () {
                      setState(() {
                        requestsAdmins.removeAt(index - 1);
                      });
                    },
                    requestRejected: () {
                      setState(() {
                        requestsAdmins.removeAt(index - 1);
                      });
                    },
                  );
                }
                // Second section header
                else if (index == requestsAdmins.length + 1) {
                  return const FZText(text: 'Member requests', style: FZTextStyle.paragraph);
                }
                // Second list items
                else {
                  final userId = requestsMembers[index - requestsAdmins.length - 2];
            
                  return RequestItemView(
                    userId: userId,
                    fam: widget.fam,
                    isAdminRequest: false,
                    requestAccepted: () {
                      setState(() {
                        requestsMembers.removeAt(index - 1);
                      });
                    },
                    requestRejected: () {
                      setState(() {
                        requestsMembers.removeAt(index - 1);
                      });
                    },
                  );
                }
              },
              separatorBuilder:  (context, index) {
                  // You can customize separators based on position if needed
                  if (index == 0 || index == requestsAdmins.length + 1) {
                    return const Divider(thickness: 2, color: Colors.grey,); // Thicker divider after headers
                  }
                  return const Divider(color: Colors.grey); // Regular divider between items
                }, 
              itemCount: requestsAdmins.length + requestsMembers.length + 2),
          )
      ],);
  }
}

class RequestItemView extends ConsumerStatefulWidget {
  const RequestItemView({super.key, 
    required this.userId,
    required this.fam,
    this.isAdminRequest = false,
    required this.requestAccepted,
    required this.requestRejected,
  });
  final String userId;
  final Fam fam;
  final bool isAdminRequest;
  final Function () requestAccepted, requestRejected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RequestItemViewState();
}

class _RequestItemViewState extends ConsumerState<RequestItemView> {
  FZUser? user;
  bool isLoading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    setState(() {
      isLoading = true;
    });
    final fetchedUser = await ref.read(backend).fetchRemoteUser(widget.userId);
    setState(() {
      isLoading = false;
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (user == null) {
      return const Center(
        child: Text("User not found"),
      );
    }

    if (error) {
      return const Center(
        child: FZText(text: "Error", style: FZTextStyle.headline, color: Colors.red,),
      );
    }

    return Row(
      children: [
        ThumbnailView(
                    link: user?.avatar,
                    mobileSize: false,
                  ),
        const SizedBox(width: 10,),
        FZText(
          text: user?.name,
          style: FZTextStyle.headline,
          onTap: () {
            context.go(Routes.routeNameProfile(user!.id!));
          },
        ),
        Expanded(child: Container()),
        Column(
          children: [
            Padding(padding: const EdgeInsets.only(top: 4),
                child: FZButton(
                  onPressed: () async {
                    if(widget.isAdminRequest) {
                      widget.fam.acceptAdminStatus(user!.id!);
                    } else {
                      widget.fam.acceptMembership(user!.id!);
                    }
                    final res = await ref.read(backend).updateFam(widget.fam);
                    if(res.code == SuccessCode.successful) {
                      widget.requestAccepted();
                    } else {
                      setState(() {
                        error = true;
                      });
                    }
                  }, 
                  text: "Accept"),),
                Padding(padding: const EdgeInsets.only(top: 4),
                child: FZButton(
                  onPressed: () async {
                    if(widget.isAdminRequest) {
                      widget.fam.rejectAdminStatus(user!.id!);
                    } else {
                      widget.fam.rejectMembership(user!.id!);
                    }
                    final res = await ref.read(backend).updateFam(widget.fam);
                    if(res.code == SuccessCode.successful) {
                      widget.requestAccepted();
                    } else {
                      setState(() {
                        error = true;
                      });
                    }
                  }, 
                  text: "Reject"),),
          ],
        ),
        const SizedBox(width: 10,),
        
      ],
    );
  }
}