import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/model/op_results.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MembershipStatusView extends ConsumerStatefulWidget {
  const MembershipStatusView({super.key, 
    required this.fam,
    required this.user,
  });
  final Fam fam;
  final FZUser user;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MembershipStatusViewState();
}

class _MembershipStatusViewState extends ConsumerState<MembershipStatusView> {
  bool _isAdmin = false, _isMember = false, _isAdminRequested = false, _isMemberRequested = false;
  bool _isLoading = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    
    _isAdmin = widget.fam.admins.contains(widget.user.id);
    _isMember = widget.fam.members.contains(widget.user.id);
    _isAdminRequested = widget.fam.adminRequests.contains(widget.user.id);
    _isMemberRequested = widget.fam.memberRequests.contains(widget.user.id);


  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: Constants.primaryColor(),));
    } else if (_isError) {
      return statusView('Error occurred', Icons.error);
    } 
    
    if(_isAdmin) {
      return statusView('You are an admin', Icons.check_circle);
    } else if (_isMember) {
      return statusView('You are a member', Icons.check);
    } else if (_isAdminRequested) {
      return statusView('Admin status requested', Icons.check);
    } else if (_isMemberRequested) {
      return statusView(
        'Membership requested', 
        Icons.check,
        onTapped: () {
          Helpers.showDialogWithMessage(ctx: context, msg: "You have already requested to be a member. Admin has not reveiwed your request yet. Please check back later for status update.");
        },);
    } else {
      return FZButton(
        onPressed: () {
           widget.fam.requestMembership(widget.user.id!);
          setState(() {
            _isLoading = true;
          });
          ref.read(backend).updateFam(widget.fam).then((result) {
            if (result.code != SuccessCode.successful) {
              setState(() {
                _isError = true;
              });
            } else {
              setState(() {
                _isMemberRequested = true;
                _isLoading = false;
                Helpers.showDialogWithMessage(ctx: context, msg: "You have requested to become a member of this Fam. The admins have been sent your request. Please wait for them to review and respond to your request. You can see the status of your request on this page.");
              });
            }
          });
        }, 
      text: "Request to Join!");
      
    }
  }

  
  statusView(String text, IconData icon, {Function()? onTapped}) { 
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey,
            width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(16))
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey,),
            const SizedBox(width: 8,),
            FZText(text: text, style: FZTextStyle.headline, color: Colors.grey,),
          ],
        ),
      ),
    );
  }
}