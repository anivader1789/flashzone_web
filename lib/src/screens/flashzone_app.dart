
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/screens/contact_us_screen.dart';
import 'package:flashzone_web/src/screens/create_event_screen.dart';
import 'package:flashzone_web/src/screens/event_detail_view.dart';
import 'package:flashzone_web/src/screens/events_feed.dart';
import 'package:flashzone_web/src/screens/fam_chat_screen.dart';
import 'package:flashzone_web/src/screens/fam_edit_screen.dart';
import 'package:flashzone_web/src/screens/fam_list_screen.dart';
import 'package:flashzone_web/src/screens/fam_screen.dart';
import 'package:flashzone_web/src/screens/flash_detail_screen.dart';
import 'package:flashzone_web/src/screens/main_feed.dart';
import 'package:flashzone_web/src/screens/notifications_list_view.dart';
import 'package:flashzone_web/src/screens/profile_view.dart';
import 'package:flashzone_web/src/screens/route_error_screen.dart';
import 'package:flashzone_web/src/screens/write_flash.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.home,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.home,
      builder: (BuildContext context, GoRouterState state) {
        return const MainFeedListView();
      },
      routes: <RouteBase>[
        GoRoute(
          path: Routes.events,
          builder: (BuildContext context, GoRouterState state) {
            return const EventFeedView();
          },),
        GoRoute(
          path: Routes.post,
          builder: (BuildContext context, GoRouterState state) {
            return const WriteFlashView();
          },),
        GoRoute(
          path: Routes.eventCreate,
          builder: (BuildContext context, GoRouterState state) {
            return const CreateEventScreen();
          },),
        GoRoute(
          path: Routes.notifications,
          builder: (BuildContext context, GoRouterState state) {
            return const NotificationsListView();
          },),
        GoRoute(
          path: Routes.contactUs,
          builder: (BuildContext context, GoRouterState state) {
            return const ContactUsScreen();
          },),
        GoRoute(
          path: Routes.fams,
          builder: (BuildContext context, GoRouterState state) {
            return const FamListScreen();
          },),
        GoRoute(
          path: Routes.famNew,
          builder: (BuildContext context, GoRouterState state) {
            return const FamEditScreen();
          },),
        GoRoute(
          path: '${Routes.eventCreate}/:famid',
          builder: (context, state) {
            final famId = state.pathParameters['famid'];
            if(famId == null || famId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return CreateEventScreen(famId: famId);
          },),
        GoRoute(
          path: '${Routes.profile}/:userid',
          builder: (context, state) {
            final userId = state.pathParameters['userid'];
            if(userId == null || userId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return ProfileView(userId: userId);
          },),
        GoRoute(
          path: '${Routes.famChat}/:famid',
          builder: (context, state) {
            final famId = state.pathParameters['famid'];
            if(famId == null || famId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return FamChatScreen(famId: famId);
          },),
        GoRoute(
          path: '${Routes.famDetail}/:famid',
          builder: (context, state) {
            final famId = state.pathParameters['famid'];
            if(famId == null || famId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return FamHomeScreen(famId: famId);
          },),
        GoRoute(
          path: '${Routes.eventDetail}/:eventid',
          builder: (context, state) {
            final eventId = state.pathParameters['eventid'];
            if(eventId == null || eventId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return EventDetailsView(eventId: eventId);
          },),
        GoRoute(
          path: '${Routes.flashDetails}/:flashid',
          builder: (context, state) {
            final flashId = state.pathParameters['flashid'];
            if(flashId == null || flashId.isEmpty) {
              return RouteErrorScreen(fullUrl: state.fullPath?? "Unkown");
            }
            
            return FlashDetailScreen(flashId: flashId);
          },),
        
      ]
    )
  ],
  errorBuilder: (context, state) {
    
    return RouteErrorScreen(fullUrl: state.uri.path,);
  },

  );

class FZApp extends StatelessWidget {
  const FZApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlashZone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        // colorScheme: ColorScheme.fromSwatch().copyWith(
        //   primary: Colors.blue,
        //   secondary: Colors.blueAccent,
        // ),
      ),
      routerConfig: router,
    );
  }
}