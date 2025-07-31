import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/thumbnail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MembersListView extends ConsumerStatefulWidget {
  const MembersListView({super.key, required this.label, required this.memberIds, required this.adminIds, required this.onDismiss});
  final String label;
  final List<String> memberIds;
  final List<String> adminIds;
  final Function () onDismiss;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MembersListViewState();
}

class _MembersListViewState extends ConsumerState<MembersListView> {
  List<String> membersIds = [];

  @override
  void initState() {
    super.initState();
    membersIds.addAll(widget.memberIds);
    membersIds.addAll(widget.adminIds);

    
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
            width: mobileSize? size.width * 0.6: size.width * 0.3,
            height: size.height * 0.7,
            padding: const EdgeInsets.fromLTRB(25, 45, 25, 45),
              decoration: BoxDecoration(
                color: Constants.cardColor(),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
            child: containerView(mobileSize),
          ),
        )
      ],
    );
  }

  containerView(bool mobileSize) {
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        FZText(text: widget.label, style: FZTextStyle.headline,),
        const Divider(color: Colors.grey, thickness: 2,),
        const SizedBox(height: 10,),
        Expanded(
          child: ListView.separated(
            itemBuilder: (context, index) {
              return MemberListItemView(
                memberId: membersIds[index], 
                isAdmin: widget.adminIds.contains(membersIds[index]),
                mobileSize: mobileSize,);
            }, 
            separatorBuilder: (context, index) {
                  return const Divider(color: Colors.grey); // Regular divider between items
                }, 
            itemCount: membersIds.length),
        )
      ],
    );
  }


}

class MemberListItemView extends ConsumerStatefulWidget {
  const MemberListItemView({super.key, required this.memberId, required this.isAdmin, required this.mobileSize});
  final String memberId;
  final bool isAdmin;
  final bool mobileSize;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemberListItemViewState();
}

class _MemberListItemViewState extends ConsumerState<MemberListItemView> {
  FZUser? user;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loading = true;
    fetchMember();
  }

  fetchMember() async {
    user = await ref.read(backend).fetchRemoteUser(widget.memberId);
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(loading) {
      return Center(child: CircularProgressIndicator(color: Constants.primaryColor(),));
    }

    if(user == null) {
      return const Center(
        child: FZText(
          text: "User could not be loaded", 
          style: FZTextStyle.headline,
          color: Colors.grey,
          ),
          );
    }

    return Row(
                children: [
                  ThumbnailView(
                    link: user?.avatar,
                    mobileSize: widget.mobileSize,
                  ),
                  const SizedBox(width: 10,),
                  FZText(
                    text: user?.name,
                    style: FZTextStyle.headline,
                    onTap: () {
                      context.go(Routes.routeNameProfile(user!.id!));
                    },
                  ),
                  if(widget.isAdmin) ...[
                    const SizedBox(width: 5,),
                    FZText(
                      text: "(Admin)",
                      color: Colors.red,
                      style: FZTextStyle.headline,
                      onTap: () {
                        context.go(Routes.routeNameProfile(user!.id!));
                      },
                    ),
                  ]
                ],
              );
  }
}