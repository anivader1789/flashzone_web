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
      return label('Error occurred');
    } 
    
    if(_isAdmin) {
      return label('You are an admin');
    } else if (_isMember) {
      return label('You are a member of this fam');
    } else if (_isAdminRequested) {
      return label('Admin status requested');
    } else if (_isMemberRequested) {
      return label('Membership requested');
    } else {
      return FZText(
        text: "Request to Join", 
        style: FZTextStyle.headline, 
        color: Colors.blue,
        onTap: () {
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
              });
            }
          });
        });
    }
  }


  
  label(String text) => FZText(text: text, style: FZTextStyle.headline, color: Colors.grey,);
}