import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfx/pdfx.dart';

final termsAcceptedProvider = StateProvider<bool>((ref) => false);

class TermsConditionView extends ConsumerStatefulWidget {
  const TermsConditionView( {super.key, required this.onDismiss});
  final Function () onDismiss;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TermsConditionViewState();
}

class _TermsConditionViewState extends ConsumerState<TermsConditionView> {

  late PdfControllerPinch _pdfController;
  bool _termsRead = false;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('terms.pdf'),
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final mobileSize = size.width <= 600;
    return Container(
      width: mobileSize? size.width * 0.95: size.width * 0.75,
      height: size.height * 0.7,
      child: containerView(mobileSize));

    
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

  Widget containerView(bool mobileSize) {
    return Column(
      children: [
        const FZText(text: "Terms & Conditions", style: FZTextStyle.headline,),
        const SizedBox(height: 5,),
        const FZText(text: "Please read all the pages to continue", style: FZTextStyle.smallsubheading),
        const SizedBox(height: 10,),
        FZButton(onPressed: () {
          if (!_termsRead) return; 
          ref.read(termsAcceptedProvider.notifier).state = true;
          widget.onDismiss();
        }, 
        bgColor: _termsRead ? Constants.primaryColor() : Colors.grey,
        text: "Accept & Continue"),
        const SizedBox(height: 10,),
        Expanded(
          child: PdfViewPinch(
            padding: 0,
            onDocumentLoaded: (document) {
              setState(() {
                _totalPages = document.pagesCount;
              });
            },
            onPageChanged: (page) {
              if (page == _totalPages - 1) {
                setState(() {
                  _termsRead = true;
                });
              }
            },
            controller: _pdfController,
          ),
        ),
      ],
    );
  }
}