import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/notification.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flashzone_web/src/screens/subviews/notification_cell_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsListView extends ConsumerStatefulWidget {
  const NotificationsListView({super.key});

  static const routeName = 'notifications';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NotificationsListViewState();
}

class _NotificationsListViewState extends ConsumerState<NotificationsListView> {
  final List<FZNotification> _notifications = List.empty(growable: true);
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    
    loadNotifications();
  }

  loadNotifications() async {
    final user = ref.read(currentuser);
    if(user.email == null) return;

    setState(() {
      _loading = true;
    });

    _notifications.clear();
    _notifications.addAll(await ref.read(backend).fetchNotifications(user.email!));
    setState(() {
      _loading = false;
    });
  }

  fakesGenerate() {
    _notifications.add(FZNotification(text: "'Energy Healing Retreat' event was just added in Central Park, Manhattan", type: NotificationType.event));
    _notifications.add(FZNotification(text: "'Save Consciousness workshop' event was just added in Brooklyn", type: NotificationType.event));
    _notifications.add(FZNotification(text: "'Light workers evening happy hour' event was just added in Tribeca, Manhattan", type: NotificationType.event));
    _notifications.add(FZNotification(text: "We are changing the zone range from 5 mi to 30 mi", type: NotificationType.admin));
    _notifications.add(FZNotification(text: "'UFO Congress hearing discussion' event was just added in Jackson height, Queens", type: NotificationType.event));
  }

  @override
  Widget build(BuildContext context) {
    bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      onInitDone: () {
        Future(() => loadNotifications());
      },
      child: childView(mobileSize), 
      sideMenuIndex: 1);
  }

  childView(bool mobileSize) {
    if(_loading) return FZLoadingIndicator(text: "Loading new notifications..", mobileSize: mobileSize);
    if(_notifications.isEmpty) return const Center(child: FZText(text: "No Notifications", style: FZTextStyle.headline),);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //onTap: () => ,
                            child: NotificationCellView(
                                notif: _notifications[index],
                                mobileSize: mobileSize,
                                bgColor: index %2 ==0? Constants.lightColor(): Colors.grey,
                            ),
                          );
                        },
                      ),
      );
  }
}