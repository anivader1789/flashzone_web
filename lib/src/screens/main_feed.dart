import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flashzone_web/src/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainFeedListView extends ConsumerStatefulWidget {
  const MainFeedListView({super.key, required this.profileNavigate});
  final Function (FZUser) profileNavigate;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainFeedListViewState();
}

class _MainFeedListViewState extends ConsumerState<MainFeedListView> {

  final List<Flash> _flashes = List.empty(growable: true);
  final List<Flash> _filterFlashes = List.empty(growable: true);
  String searchTerm = "";
  final searchController = TextEditingController();
  //bool _loading = false;
  String filter = "all";
  List<DropdownMenuEntry<String>>? filters;

  @override
  void initState() {
    super.initState();
    
    loadFakeData();
    loadFilter();
  }

  
  loadFilter() async {
    filters = Settings.filters.map((e) => DropdownMenuEntry(value: e, label: e)).toList();
    filter = await Settings.getFlashFeedFilter();
    setState(() {
      
    });
  }

  setFilter(String? newFilter) async {
    if(newFilter == null) return;
    await Settings.setFlashFeedFilter(newFilter);
    setState(() {
      filter = newFilter;
    });
  }

  loadData() {

  }

  loadFakeData() async {
    _flashes.clear();
    if(ref.read(flashes).isNotEmpty) {
      
      setState(() {
        _flashes.addAll(ref.read(flashes));
      });
      return;
    }
    
    // for(int i=0; i<5; i++) {
    //   final flash = Flash(
    //     content: Fakes.generateFakeText(),
    //     user: await Fakes.generateFakeUser(),
    //     postDate: Fakes.generateFakeDate()
    //     );
    //   _flashes.add(flash);
    // }

      _flashes.add(Flash(
        content: shortchar(),
        user: await Fakes.generateFakeUser(),
        postDate: Fakes.generateFakeDate()
      ));
      _flashes.add(Flash(
        content: midchar(),
        user: await Fakes.generateFakeUser(),
        postDate: Fakes.generateFakeDate()
      ));
      _flashes.add(Flash(
        content: maxchar(),
        user: await Fakes.generateFakeUser(),
        postDate: Fakes.generateFakeDate()
      ));
      _flashes.add(Flash(
        content: longchar(),
        user: await Fakes.generateFakeUser(),
        postDate: Fakes.generateFakeDate()
      ));

    //ref.read(flashes.notifier).update((state) => _flashes,);
    ref.read(flashes).addAll(_flashes);
    _filterFlashes.addAll(_flashes);
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column( crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          
          SizedBox(height: 40,
            child: Row( crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 5,),
                const FZText(text: "Filter by: ", style: FZTextStyle.headline),
                const SizedBox(width: 5,),
                _filterssDropDown(),
              ],
            ),
            ),
          const SizedBox(height: 20,),
          SizedBox(
              width: MediaQuery.of(context).size.width / 3,height: 45,
              child: TextField(
                      onChanged: _searchTermChanged,
                      cursorColor: Constants.primaryColor(),
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                        hintText: 'search FlashZone',
                        fillColor: Colors.white70,
                        filled: true,
                        
                      ),
                    ),
            ),
          const SizedBox(height: 20,),
          Expanded(
          child: ListView.separated(
                  separatorBuilder: (context, index) => const SizedBox(height: 5,),
                        itemCount: _filterFlashes.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            //onTap: () => ,
                            child: FlashCellView(
                                flash: _filterFlashes[index],
                                profileClicked: widget.profileNavigate,
                            ),
                          );
                        },
                      ),
        ),
                    ]
      ),
    );
  }

  _searchTermChanged(String val) {
    if(val.isEmpty || !val.contains(" ")) {
      _filterFlashes.clear();
      _filterFlashes.addAll(_flashes);
      
    } else {
      _filterFlashes.clear();
      for(final flash in _flashes) {
        if(flash.content.toLowerCase().contains(val.toLowerCase())) {
          _filterFlashes.add(flash);
          continue;
        }
      }
      
    }
    setState(() {
        
      });
  }

  _filterssDropDown() {
    return DropdownMenu(width: 300,
        
        inputDecorationTheme: InputDecorationTheme(
            //isDense: true,
            //contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            constraints: BoxConstraints.tight(const 
             Size.fromHeight(40)),
            border: const UnderlineInputBorder(),
          ),
        dropdownMenuEntries: filters ?? List<DropdownMenuEntry<String>>.empty(),
        //label: FZText(text: filter, style: FZTextStyle.paragraph),
        onSelected: (value) { 
            setFilter(value); 
          },
        );
  }

  String longchar() {
    return "FlashZone is an innovative platform that transforms the way communities create and attend events. It empowers users to submit and vote on requests for a wide range of physical events, from local concerts and sports matches to educational workshops and fitness classes. By allowing users to express their preferences and see which events are trending, FlashZone fosters a community-driven approach to event planning. Organizers can easily gauge interest, ensuring that each event resonates with what people genuinely want. FlashZone's voting system also builds excitement and encourages participation, as users can rally friends and share ideas to bring unique events to life. This platform creates a vibrant ecosystem where ideas are seamlessly transformed into real-life gatherings, turning collective interests into memorable experiences. With an easy-to-use interface and a focus on community engagement, FlashZone aims to make organizing and attending events more accessible, enjoyable, and impactful for everyone.";
  }

  String maxchar() {
    return "FlashZone is an innovative platform where users can submit requests for physical events, making it easier to bring together communities and plan gatherings. Whether it's a local concert, fitness class, or a workshop, FlashZone provides a streamlined way for event organizers to gauge interest and ensure attendance. Users can request events they want to see in their area, vote on others’ suggestions, and even invite friends to join. With a mission to connect people through shared experiences, FlashZone turns ideas into real-life gatherings that resonate with community interests.";
  }

  String midchar() {
    return "FlashZone lets users request and vote on physical events in their area, from concerts to classes. It connects communities by turning popular ideas into real gatherings, making event planning easy and engaging.";
  }

  String shortchar() {
    return "FlashZone turns event ideas into reality!";
  }
}