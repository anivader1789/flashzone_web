import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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

  static String getDisplayDate(DateTime dateTime) {
    String day = DateFormat('d MMM y').format(dateTime);
    String time = DateFormat('h:mm a').format(dateTime);
    return "$time on $day";
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
                Navigator.of(ctx).pop();
              },
              bgColor: Constants.lightColor()
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
  headline, subheading, paragraph, largeHeadline, smallsubheading
}



class FZText extends StatelessWidget {
  const FZText({super.key, required this.text, required this.style, this.color = Colors.black, this.onTap, this.flashtagContent = false});
  final String? text;
  final FZTextStyle style;
  final Color color;
  final bool flashtagContent;
  final Function ()? onTap;

  @override
  Widget build(BuildContext context) {
    //TODO: Figure out how to enhance text for flashtag posts
    String enhancedText = text ?? "null";

    TextStyle textStyle = switch (style) {
      FZTextStyle.headline =>  TextStyle(color: color, fontWeight: FontWeight.bold),
      FZTextStyle.largeHeadline =>  TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
      FZTextStyle.subheading =>  TextStyle(color: color, fontWeight: FontWeight.w300),
      FZTextStyle.smallsubheading =>  TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w200),
      FZTextStyle.paragraph =>  TextStyle(color: color, fontWeight: FontWeight.normal),
    };

    if(onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: flashtagContent? flashtagContentView(enhancedText, textStyle): Text(enhancedText, style: textStyle,softWrap: true,),
        )
      );
    }



    return flashtagContent? flashtagContentView(enhancedText, textStyle): Text(enhancedText, style: textStyle,softWrap: true,);
  }
  
  flashtagContentView(String content, TextStyle style) {
    Color color = Constants.primaryColor();
    List<InlineSpan> spans = List.empty(growable: true);
    final chunks = highlightTexts(content);
    print(chunks);
    for(int i=0; i<chunks.length; i++) {
      final str = chunks[i];
      if(str == null || str.length < 3) continue;
      
      if(str[0] == "#" || (str[0] == " " && str[1] == "#")) {
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
        spans.add(WidgetSpan(alignment: PlaceholderAlignment.bottom,
          child: Image(image: Helpers.ftIcon(), color: color, width: 26,))
        );
        spans.add(TextSpan(text: str.substring(str[0] == " "?2: 1), style: TextStyle(color: color),));
      } else {
        spans.add(TextSpan(text: str, style: style,));
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
  this.textColor = Colors.black,
  this.bgColor = Colors.transparent, 
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
  location, time
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
        child: Column(
          children: [
            vertical(24),
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