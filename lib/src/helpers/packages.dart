import 'package:context_menus/context_menus.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/modules/data/cached_data_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Helpers {
  static const _symbols = '·・ー_';

  static const _numbers = '0-9０-９';

  static const _englishLetters = 'a-zA-Zａ-ｚＡ-Ｚ';

  static const _japaneseLetters = 'ぁ-んァ-ン一-龠';

  static const _koreanLetters = '\u1100-\u11FF\uAC00-\uD7A3';

  static const _spanishLetters = 'áàãâéêíóôõúüçÁÀÃÂÉÊÍÓÔÕÚÜÇ';

  static const _arabicLetters = '\u0621-\u064A';

  static const _thaiLetters = '\u0E00-\u0E7F';

  static const detectionContentLetters = _symbols +
      _numbers +
      _englishLetters +
      _japaneseLetters +
      _koreanLetters +
      _spanishLetters +
      _arabicLetters +
      _thaiLetters;

  static const urlRegexContent = "((http|https)://)?(www.)?[-a-zA-Z0-9@:%._\\+~#?&//=]{1,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)";

  /// Regular expression to extract hashtag
  ///
  /// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
  static final hashTagRegExp = RegExp(
    "(?!\\n)(?:^|\\s)(#([$detectionContentLetters]+))",
    multiLine: true,
  );

  static final atSignRegExp = RegExp(
    "(?!\\n)(?:^|\\s)([@]([$detectionContentLetters]+))",
    multiLine: true,
  );

  static final urlRegex = RegExp(
    urlRegexContent,
    multiLine: true,
  );

  /// Regular expression when you select decorateAtSign
  static final hashTagAtSignRegExp = RegExp(
    "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))",
    multiLine: true,
  );

  static final hashTagUrlRegExp = RegExp(
    "(?!\\n)(?:^|\\s)([#]([$detectionContentLetters]+))|$urlRegexContent",
    multiLine: true,
  );

  static final hashTagAtSignUrlRegExp = RegExp(
    "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))|$urlRegexContent",
    multiLine: true,
  );

  static ImageProvider loadImageProvider(String? url) {
    if(url == null) {
      return const AssetImage('assets/profile_pic_placeholder.png');
    } else {
      return NetworkImage(url);
    }
  }

  static ImageProvider ftIcon() => const AssetImage('assets/logo.png');

  static List<String?> allFlashTagsInText(String text) {
    RegExp reg = Helpers.hashTagRegExp;
  
    return reg.allMatches(text).map((e) => e.group(0)).toList();
  }

  static Widget flashEngagementText(Flash flash, [Function ()? onTapped]) {
    if(flash.likes == 0 && flash.comments == 0) {
      return Container();
    } else {
      String text = "";
      final pluralLike = (flash.likes > 1)? "s": ""; 
      final pluralComment = (flash.comments > 1)? "s": "";
      if(flash.likes > 0 && flash.comments == 0) {
        text = "${flash.likes} like$pluralLike";
      } else if(flash.likes == 0 && flash.comments > 0){
        text = "${flash.comments} comment$pluralComment";
      } else {
        text = "${flash.likes} like$pluralLike   🔸   ${flash.comments} comment$pluralComment";
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(11, 7, 11, 7),
        decoration: BoxDecoration(
          border: Border.all(strokeAlign: BorderSide.strokeAlignCenter, color: Constants.primaryColor(), width: 2),
          borderRadius: const BorderRadius.all(Radius.circular(11))
        ),
        child: FZText(text: text, style: FZTextStyle.headline, onTap: onTapped,),
      );
    } 
  }

  static String getDisplayDate(DateTime dateTime) {
    String day = DateFormat('d MMM y').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return "$time on $day";
  }

  static String getDisplayTime(DateTime dateTime, [int? duration]) {
    if(duration != null) {
      DateTime endTime = dateTime.add(Duration(minutes: duration));
      final startText = DateFormat('h:mm a').format(dateTime);
      final endText = DateFormat('h:mm a').format(endTime);
      return "$startText - $endText";
    }
    return DateFormat('h:mm a').format(dateTime);
  }

  static String getDisplayDay(DateTime dateTime) {
    return DateFormat('MMM d y').format(dateTime);
  }

  static bool isDateToday(DateTime date) {
    final DateTime localDate = date.isUtc ? date.toLocal() : date;
    final now = DateTime.now();
    return now.day == localDate.day && now.month == localDate.month && now.year == localDate.year;
  }

  static bool isDateTomorrow(DateTime date) {
    final DateTime localDate = date.isUtc ? date.toLocal() : date;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return tomorrow.day == localDate.day && tomorrow.month == localDate.month && tomorrow.year == localDate.year;
  }

  static bool isDateNextWeek(DateTime date) {
    final DateTime localDate = date.isUtc ? date.toLocal() : date;
    
    // Get the current date
    DateTime now = DateTime.now();
    
    // Calculate the start and end of next week
    DateTime startOfNextWeek = now.add(Duration(days: 7 - now.weekday));
    DateTime endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));

    // Check if the input date is within the next week
    if (localDate.isAfter(startOfNextWeek) && localDate.isBefore(endOfNextWeek.add(const Duration(days: 1)))) {
      return true;
    }

    return false;
  }

  static showDialogWithMessage({required BuildContext ctx, required String msg, String title = "FlashZone"}) {
    showDialog(context: ctx, 
          builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            FZButton(
              text: "OK", 
              onPressed: () {
                ctx.pop();
              },
              bgColor: Constants.bgColor()
            ),
          ],
        ));
  }

  static List<String> getAllFlashTags(String str) {
    List<String> words = str.split(" ");
    for(String word in words) {
      if(word.contains(".")) {
        words.remove(word);
        words.addAll(word.split("."));
      }
    }

    List<String> fts = List.empty(growable: true);
    for(String word in words) {
      if(word[0] == "#") {
        fts.add(word);
      }
    }
    return fts;
  }

  static List<String> getAllUsername(String str) {
    List<String> words = str.split(" ");
    for(String word in words) {
      if(word.contains(".")) {
        words.remove(word);
        words.addAll(word.split("."));
      }
    }

    List<String> fts = List.empty(growable: true);
    for(String word in words) {
      if(word[0] == "@") {
        fts.add(word);
      }
    }
    return fts;
  }
}

const fzSymbol = "\u2021";

enum FZTextStyle {
  headline, subheading, paragraph, largeHeadline, xlargeHeadline, tooLargeHeadline, smallsubheading
}

class FZLocalImage extends StatelessWidget {
  const FZLocalImage({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Image.asset(path);
  }
}

enum FZImageSize {
    small, medium, large
  }

class FZNetworkImage extends StatelessWidget {
  const FZNetworkImage({super.key, required this.url, required this.maxWidth});
  final String? url;
  final double maxWidth;

  ImageProvider loadImageProvider(String? url) {
    if(url == null) {
      return const AssetImage('assets/profile_pic_placeholder.png');
    } else {
      return NetworkImage(url);
    }
  }

  Future<void> launch({bool isNewTab = true}) async {
    await launchUrl(
      Uri.parse(url!),
      webOnlyWindowName: isNewTab ? '_blank' : '_self',
    );
  }

  @override
  Widget build(BuildContext context) {
    if(url == null) {
      return Image(image: loadImageProvider(url), width: maxWidth,);
    }

    return ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth),
      child: Image(image: loadImageProvider(url)));

    // return ContextMenuRegion(
    //   contextMenu: GenericContextMenu(
    //     buttonConfigs: [
    //               ContextMenuButtonConfig(
    //                 "Open image in new tab",
    //                 onPressed: () {
    //                   // Implement your logic here
    //                   launch(isNewTab: true);
    //                 },
    //               ),
    //               ContextMenuButtonConfig(
    //                 "Open image",
    //                 onPressed: () {
    //                   // Implement your logic here
    //                   launch(isNewTab: false);
    //                 },
    //               ),
    //               ContextMenuButtonConfig(
    //                 "Copy image path",
    //                 onPressed: () {
    //                   // Implement your logic here
    //                   Clipboard.setData(ClipboardData(text: url!));
    //                 },
    //               ),
    //             ]),
    //     child: Image(image: loadImageProvider(url)), 
    //   );
  }
}

class FZText extends StatelessWidget {
  const FZText({super.key, 
  required this.text, 
  required this.style, 
  this.color = Colors.black, 
  this.onTap, 
  this.context,
  this.flashtagContent = false});
  final String? text;
  final FZTextStyle style;
  final Color color;
  final bool flashtagContent;
  final BuildContext? context;
  final Function ()? onTap;

  @override
  Widget build(BuildContext context) {
    //TODO: Figure out how to enhance text for flashtag posts
    String enhancedText = text ?? "null";

    TextStyle textStyle = switch (style) {
      FZTextStyle.headline =>  TextStyle(color: color, fontWeight: FontWeight.bold),
      FZTextStyle.largeHeadline =>  TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      FZTextStyle.xlargeHeadline =>  TextStyle(color: color, fontSize: 19, fontWeight: FontWeight.bold),
      FZTextStyle.tooLargeHeadline =>  TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold),
      FZTextStyle.subheading =>  TextStyle(color: color, fontWeight: FontWeight.w300),
      FZTextStyle.smallsubheading =>  TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w200),
      FZTextStyle.paragraph =>  TextStyle(color: color, fontWeight: FontWeight.normal),
    };

    if(onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: flashtagContent? flashtagContentView(enhancedText, context, textStyle): Text(enhancedText, style: textStyle, overflow: TextOverflow.visible,softWrap: true),
        )
      );
    }



    return flashtagContent? flashtagContentView(enhancedText, context, textStyle): Text(enhancedText, style: textStyle, overflow: TextOverflow.visible,softWrap: true);
  }
  
  flashtagContentView(String content, BuildContext? context, TextStyle style) {
    
    
    List<InlineSpan> spans = List.empty(growable: true);
    final chunks = highlightTexts(content);
    //print(chunks);
    for(int i=0; i<chunks.length; i++) {
      final str = chunks[i];
      if(str == null || str.length < 3) continue;
      
      if(str[0] == "#" || (str[0] == " " && str[1] == "#")) {
        final tagName = str.substring(str[0] == " "?2: 1);
        String? famId = CachedDataManager().getFamId(tagName);
        final clr = famId==null? Constants.altPrimaryColor(): Constants.fillColor();
        final highlightedStyle = TextStyle(fontSize: 24, color: clr, textBaseline: TextBaseline.alphabetic, height: 1);

        //is a flashtag
        // spans.add(WidgetSpan(alignment: PlaceholderAlignment.bottom,
        //   child: Row(
        //     mainAxisSize: MainAxisSize.min, 
        //     crossAxisAlignment: CrossAxisAlignment.end,
        //     textBaseline: TextBaseline.alphabetic,
        //     children: [
        //     const SizedBox(width: 4,),
        //     Image(image: Helpers.ftIcon(), color: color, width: 26,),
        //     Text(str.substring(str[0] == " "?2: 1), style: TextStyle(color: color),),
              
        //   ],)
        //   )
        // );
        spans.add(const TextSpan(text: " "));
        spans.add(WidgetSpan(//alignment: PlaceholderAlignment.baseline,
          child: 
          //Image(image: Helpers.ftIcon(), color: clr, width: 32,)
          MouseRegion(cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                if(famId != null && context != null) {
                  context.go(Routes.routeNameFamDetail(famId));
                }
              },
              child: Row(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Image(image: Helpers.ftIcon(), color: clr, width: 32,),
                Text(tagName,textAlign: TextAlign.end, style: highlightedStyle)
              ],),
            ),
          )
          )
        );
        //spans.add(TextSpan(text: str.substring(str[0] == " "?2: 1), style: highlightedStyle,));
      } else {
        spans.add(TextSpan(text: str, style: const TextStyle(fontSize: 24,),));
      }
    }

    return SelectableText.rich(
      TextSpan(
        children: spans,
      ),
    );
  }



  List<String?> highlightTexts(String str) {
    RegExp reg = Helpers.hashTagRegExp;
  
    //final fts = reg.allMatches(str).map((z) => z.group(0)).toList();
    final fts = reg.allMatches(str);
    
    List<String?> res = List.empty(growable: true);
    
    int x=0;
    for(int i=0; i<fts.length; i++) {
      res.add(str.substring(x, fts.elementAt(i).start));
      x = fts.elementAt(i).end;
      res.add(fts.elementAt(i).group(0));
    }
    res.add(str.substring(x));

    return res;
  }

  List<String?> extractFlashTags(String str) {
    final reg = RegExp(r'#[a-zA-z]+\b');
    final matches = reg.allMatches(str).first;

    return reg.allMatches(str).map((z) => z.group(0)).toList();
  }
}

class FZButton extends StatelessWidget {
  const FZButton({super.key, 
  required this.onPressed,
  required this.text, 
  this.textColor = Colors.white,
  this.bgColor = const Color.fromARGB(255, 182, 130, 27), 
  this.compact = false});
  final String text;
  final Color bgColor;
  final Color textColor;
  final bool compact;
  final Function ()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, 
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(bgColor),
              side: MaterialStatePropertyAll(
                BorderSide(
                  color: bgColor,
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
              padding: EdgeInsets.symmetric(vertical: compact? 4: 12, horizontal: 12),
              child: FZText(text: text, style: FZTextStyle.paragraph, color: textColor,),
            ),
          );
  }
}

class FZIconButton extends StatelessWidget {
  const FZIconButton({super.key, required this.tint, required this.icon, required this.onPressed});
  final Color tint;
  final IconData icon;
  final Function ()? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, 
    child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Icon(icon, size: 21,),
            ),
    );
  }
}

enum FZSymbolType {
  location, time, community
}

class FZSymbol extends StatelessWidget {
  const FZSymbol({super.key, required this.type, this.compact = false});
  final FZSymbolType type;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    IconData icon = switch (type) {
      FZSymbolType.location => Icons.pin_drop,
      FZSymbolType.time => Icons.watch_later,
      FZSymbolType.community => Icons.group,
    };
    
    return Icon(icon, size: compact? 16: 22,);
  }

  
}

class FZLoadingIndicator extends StatelessWidget {
    const FZLoadingIndicator({super.key, required this.text, required this.mobileSize});
    final bool mobileSize; 
    final String text;
  
    @override
    Widget build(BuildContext context) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 70, height: 70, child: CircularProgressIndicator(color: Constants.primaryColor(),)),
            vertical(),
            FZText(text: text, style: FZTextStyle.paragraph, color: Colors.grey,),
          ],
        ),
      );
    }

    vertical([double multiple = 1]) {
    return SizedBox(height: (mobileSize? 5: 15) * multiple,);
  }
}

class FZErrorIndicator extends StatelessWidget {
    const FZErrorIndicator({super.key, required this.text, required this.mobileSize});
    final bool mobileSize; 
    final String text;
  
    @override
    Widget build(BuildContext context) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 70, color: Colors.grey,),
            vertical(),
            FZText(text: text, style: FZTextStyle.largeHeadline, color: Colors.grey,),
          ],
        ),
      );
    }

    vertical([double multiple = 1]) {
      return SizedBox(height: (mobileSize? 5: 15) * multiple,);
    }
}

class FZRichHeadline extends StatelessWidget {
  const FZRichHeadline({super.key, required this.text, this.smaller = false});
  final String text;
  final bool smaller;

  @override
  Widget build(BuildContext context) {
    print(text);
    if(text.contains("%lb%")) {
      final chunks = text.split("%lb%");
      
      return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(chunks[0], 
        style: TextStyle(color: Colors.black, fontSize: smaller? 21: 24, fontWeight: FontWeight.bold), 
        overflow: TextOverflow.visible,
        softWrap: true),
        Text(chunks[1], 
        style: TextStyle(color: Colors.black, fontSize: smaller? 16: 19, fontWeight: FontWeight.w200, fontStyle: FontStyle.italic), 
        overflow: TextOverflow.visible,
        softWrap: true)
      ],);
    } 

    return Text(text, 
    style: TextStyle(color: Colors.black, fontSize: smaller? 21: 24, fontWeight: FontWeight.bold), 
    overflow: TextOverflow.visible,
    softWrap: true);
  }
}