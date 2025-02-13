import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flutter/material.dart';

class ThumbnailView extends StatefulWidget {
  const ThumbnailView({super.key, required this.link, required this.mobileSize});
  final String? link;
  final bool mobileSize;

  @override
  State<ThumbnailView> createState() => _ThumbnailViewState();
}

class _ThumbnailViewState extends State<ThumbnailView> {
  final _popupController = OverlayPortalController();

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: _popupController.toggle, 
            child: CircleAvatar(
              backgroundImage: Helpers.loadImageProvider(widget.link), 
              radius: widget.mobileSize? 24: 30,
              child: OverlayPortal(
                          controller: _popupController, 
                          overlayChildBuilder:  (context) => overlayView(),),)
          ),
        );
  }

  overlayView() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Positioned.fill(
            child: GestureDetector(
              onTap: () => _popupController.hide(),
              child: Container(
                color: const Color.fromARGB(200, 0, 0, 0),
              ),
            )
        ),
        Center(
          child: CircleAvatar(
              backgroundImage: Helpers.loadImageProvider(widget.link), 
              radius: width<height? 0.4 * width: 0.4 * height,),
        ),]
    );
  }
}