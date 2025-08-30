import 'package:flashzone_web/src/screens/event_detail_view.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
     return MasterView(
      sideMenuIndex: 3,
      child: Padding(
        padding: const EdgeInsets.all(16), 
        child: htmlContentView(htmlContent)),
      );
  }

  htmlContentView(String? data) {
    if(data == null) return Container();
    
    //print("Rendering html view");
    return SingleChildScrollView(//alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: HtmlWidget(
        '''
        $data
        ''',
          //"<iframe src=\"\" width=\"400\" height=\"300\" style=\"border:0;\" allowfullscreen=\"\" loading=\"lazy\" referrerpolicy=\"no-referrer-when-downgrade\"></iframe>",
      
          // all other parameters are optional, a few notable params:
      
          // specify custom styling for an element
          // see supported inline styling below
          customStylesBuilder: (element) {
            if (element.classes.contains('p')) {
              return {'color': 'red'};
            }
      
            return null;
          },
      
          customWidgetBuilder: (element) {
            if (element.attributes['foo'] == 'bar') {
              // render a custom block widget that takes the full width
              return Container();
            }
      
            if (element.attributes['fizz'] == 'buzz') {
              // render a custom widget inline with surrounding text
              return InlineCustomWidget(
                child: Container(),
              );
            }
      
            return null;
          },

          factoryBuilder: () => MyWidgetFactory(),
      
          // this callback will be triggered when user taps a link
          onTapUrl: (url) {
            return true;
          },
      
          // select the render mode for HTML body
          // by default, a simple `Column` is rendered
          // consider using `ListView` or `SliverList` for better performance
          renderMode: RenderMode.column,
      
          // set the default styling for text
          textStyle: const TextStyle(fontSize: 14),
        ),
    );
  }

  final String htmlContent = '''
<!DOCTYPE html>
<body>

  <h1>About FlashZone</h1>
  
  <p>Society today is more disconnected from communities and isolated than ever. It is desperate for more real life connections via local communities. We are building the future of hyperlocal digital communities, perfectly suited for the current times, to enable people to find their local communities.</p>
  
  <p>Our platform is a location-based social networking app where users can discover and engage with Twitter-style posts, events, and private groups—all geo-anchored within a 30-mile radius. Think of it as Twitter meets Nextdoor, but far more dynamic and localized. Users only see what's relevant in their 30-mile area, ensuring relevance, safety, and authenticity. Whether it’s a pop-up event, a missing pet, a community alert, or a niche local interest group—our app becomes the go-to place.</p>
  
  <h2>Core Features</h2>
  
  <ul>
    <li><b>Geo-Anchored Posts:</b> Share and view content only visible in your area.</li>
    <li><b>Local Event Listings:</b> Discover or host events specific to your location.</li>
    <li><b>Private Location-Based Groups called "fams":</b> Connect with neighbors or hyperlocal communities with shared interests.</li>
  </ul>
  
  <p>We hope you will enjoy your experience at FlashZone platform. If you have any questions, concern or suggestion, please go to the contact us button from side left-hand side menu option and drop us a message!</p>

</body>
</html>
''';
}