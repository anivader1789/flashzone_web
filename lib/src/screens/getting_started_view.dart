import 'package:flashzone_web/src/screens/event_detail_view.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class GettingStartedView extends StatelessWidget {
  const GettingStartedView({super.key});


  @override
  Widget build(BuildContext context) {
    //bool mobileSize = MediaQuery.of(context).size.width < 800;
    return MasterView(
      sideMenuIndex: 5,
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
<html>
<body>

<h1>Welcome and getting started on FlashZone</h1>

<p>We know many of you. We created this website for us and people like us. We want community, but community is hard to find in this digital world. The FlashZone website can play an important part in supporting all those who are searching for others who also want to build community by finding like-minded people. Stick with us as we grow and introduce new features. If you have suggestions, please let us know. We are listening: ed@flashzone.com</p>

<h2>Local Website</h2>

<p>This website is local. Users in other locations don't see what you're seeing. This is because our purpose is to build local communities made up of people who share one or more interests. When you change your location you will see the content in the new location, both posts and events. For this version "local" means 30 miles. We are focusing on many NY/CT localities first (everyone has to start some where), and we live here. You will see the distance from your location to events that are listed.</p>

<h2>We Use Flashtags</h2>

<p>When you post please tap the hashtag and place it in front of key words in your post. Doing so will change those words into links. They will appear as a geo-anchored hashtag symbol when your post is published. This symbol is called a flashtag:   and it looks like a hashtag with a circle around it. It geo-anchors the words that come immediately after it. As we introduce new features these flashtags will arrange your posts so that people with similar interests locally can find them all in one place. Clicking on a flashtag will show you all the other flashes (posts) which include the same flashtag.</p>

<p>Feel free to place flashtags in front of multiple keywords in your post. For, example, this post: </p>

<p>"I had an amazing #Reiki session. My Reiki practitioner used #MusicalTones and it amplified the experience. Thank you @angelD if you're reading this." </p>
<p>(The hashtag turns into a flashtag when it’s posted.)</p>

<hr>

<h2>Other features:</h2>

<p><b>Fams:</b> a free membership group you join (or create). A fam includes a private chat room for members. Please keep it wholesome.</p>

<p><b>Local events</b></p>

<p><b>Coming:</b> Direct messaging</p>

<p><b>Coming:</b> Users able to follow events that interest them and get notifications when the event date approaches. (A solution to the problem of forgetting events we really wanted to get to!)</p>

<p><b>Coming:</b> Users able to call in-person meet-up style meetings at no cost. (I’m personally really excited at the prospect of this.)</p>

<hr>

<p>=============================================</p>

<p>FlashZone is currently serving multiple communities. They are <b>Spirituality</b>, <b>Art</b>, <b>Experimental</b>, <b>Personal Development</b>, <b>Paranormal</b>, <b>Business</b>, <b>Beauty</b>, and <b>Others</b>.</p>

<p>Below are some suggested interests for the Spiritual Community. There are many more. You can put in your own interests too. You are not limited to this list! Please add a hashtag symbol before any keywords you use in your flash. You can use multiple ones.</p>

<ul>
<li>EnergyHealing</li>
<li>ShamanicJourneying</li>
<li>Astrology</li>
<li>EcstaticDance</li>
<li>Dreamwork</li>
<li>SpiritGuides</li>
<li>HigherMind</li>
<li>MoonRituals</li>
<li>Meditation</li>
<li>Metaphysics</li>
<li>Reiki</li>
<li>Awakening</li>
<li>Enlightenment</li>
<li>Consciousness</li>
<li>Mindfulness</li>
<li>Ascension</li>
<li>Manifestation</li>
<li>Intuition</li>
<li>Oneness</li>
<li>Unity</li>
<li>Karma</li>
<li>Dharma</li>
<li>Synchronicity</li>
<li>Clairvoyance</li>
<li>Tarot</li>
<li>HigherSelf</li>
</ul>

<p>Questions/comments? ed@flashzone.com</p>

</body>
</html>
''';

  //final String gettingStartedContent = "<!DOCTYPE html><html lang='en'><body><h1>Welcome and getting started on FlashZone</h1><p>We know many of you. We created this website for us and people like us. We want community, but community is hard to find in this digital world. The FlashZone website can play an important part in supporting all those who are searching for others who also want to build community by finding like-minded people. Stick with us as we grow and introduce new features. If you have suggestions, please let us know. We are listening: ed@flashzone.com</p><h2>Local Website </h2><p>This website is local. Users in other locations don't see what you're seeing. This is because our purpose is to build local communities made up of people who share one or more interests. When you change your location you will see the content in the new location, both posts and events. For this version 'local' means 30 miles. We are focusing on this NY/CT (parts of, and a touch of NJ) locality first (everyone has to start some where). We chose that because it was a maximum distance that many people would drive to to get to an event they would really like to participate in. You will see the distance from your location to events that are listed.</p><h2>We Use Flashtags </h2><p>When you post please tap the hashtag and place it in front of key words in your post. Doing so will change those words into links. They will appear as a geo-anchored hashtag symbol when your post is published. This symbol is called a flashtag:   It geo-anchors the words that come immediately after it. As we introduce new features these flashtags will arrange your posts so that people with similar interests locally can find them all in one place. Clicking on a flashtag will show you all the other flashes (posts) which include the same flashtag.</p><p>Feel free to place flashtags in front of multiple keywords in your post. For, example, this post: </p><p>'I had an amazing #Reiki session. My Reiki practitioner used #MusicalTones and it amplified the experience. Thank you @angelD if you're reading this.' </p><h2>Other features:</h2><p>Fams: a free membership group you join (or create). A fam includes a private chat room for members. Please keep it wholesome. </p><p>Local events</p><p>Coming: Direct messaging</p><p>Coming: Users able to follow events that interest them and get notifications when the event date approaches. (A solution to the problem of forgetting events we really wanted to get to!)</p><p>Coming: Users able to call in-person meet-up style meetings at no cost. (I’m personally really excited at the prospect of this.)</p><p>=============================================</p><p>FlashZone is currently serving multiple communities. They are Spirituality, Art, Experimental, Personal Development, Paranormal, Business, Experimental, Beauty, and Others.</p><p>Below are some suggested interests for the Spiritual Community. There are many more. You can put in your own interests. You are not limited to this list! Please add the hashtag symbol before any keywords you use in your flash. You can use multiple ones like this one in the following flash:</p><p>'I had an amazing #Reiki session. My Reiki practitioner used #MusicalTones and it amplified the experience. Thank you @angelD if you're reading this.”</p><ul><li>EnergyHealing</li><li>ShamanicJourneying</li><li>Astrology</li><li>EcstaticDance</li><li>Dreamwork</li><li>SpiritGuides</li><li>HigherMind</li><li>MoonRituals</li><li>Meditation</li><li>Metaphysics</li><li>Reiki</li><li>Awakening</li><li>Enlightenment</li><li>Consciousness</li><li>Mindfulness</li><li>Ascension</li><li>Manifestation</li><li>Intuition</li><li>Oneness</li><li>Unity</li><li>Karma</li><li>Dharma</li><li>Synchronicity</li><li>Clairvoyance </li><li>Tarot</li><li>HigherSelf</li></ul><p>Questions/comments? ed@flashzone.com</p></body></html>";
}