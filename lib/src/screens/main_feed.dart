import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/cool_widgets.dart';
import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/model/user.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flashzone_web/src/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainFeedListView extends ConsumerStatefulWidget {
  const MainFeedListView({super.key, required this.profileNavigate, required this.mobileSize});
  final Function (FZUser) profileNavigate;
  final bool mobileSize;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainFeedListViewState();
}

class _MainFeedListViewState extends ConsumerState<MainFeedListView> {
  bool _flashesLoading = false;
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
    
    loadData();
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

  loadData() async {
    setState(() {
      _flashesLoading = true;
    });

    _flashes.clear();
    if(ref.read(flashes).isNotEmpty) {
      
      setState(() {
        _filterFlashes.clear();
        
        _flashes.addAll(ref.read(flashes));
        _filterFlashes.addAll(_flashes);
        _filterFlashes.sort((Flash a, Flash b) => b.postDate.compareTo(a.postDate));
        _flashesLoading = false;
      });
      return;
    }
    
    _flashes.addAll(await ref.read(backend).getFlashes(30, false));
    

    //await populateFakeFlashes();

    ref.read(flashes.notifier).update((state) => _flashes,);
    //ref.read(flashes).addAll(_flashes);

    _filterFlashes.addAll(_flashes);
    _filterFlashes.sort((Flash a, Flash b) => b.postDate.compareTo(a.postDate));
    setState(() {
      _flashesLoading = false;
      
    });
  }

  

  @override
  Widget build(BuildContext context) {
    if(_flashesLoading) {
      return FZLoadingIndicator(text: "Loading flashes in your area", mobileSize: widget.mobileSize);
    }

    if(_flashes.isEmpty) {
      return Padding(padding: const EdgeInsets.all(8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          vertical(2),
          const FZText(text: "No one has posted in your area. It means you can be the first! So go ahead and post a flash.", style: FZTextStyle.headline, color: Colors.grey,),
          vertical(),
          const Divider(),
          vertical(),
          const FZText(text: "If you would like to check out what's happening in our home location, press below..", style: FZTextStyle.headline, color: Colors.grey,),

        ],
      ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // SizedBox(height: 40,
          //   child: Row( crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       const SizedBox(width: 5,),
          //       const FZText(text: "Filter by: ", style: FZTextStyle.headline),
          //       const SizedBox(width: 5,),
          //       _filterssDropDown(),
          //     ],
          //   ),
          //   ),
          const SizedBox(height: 10,),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                    //width: MediaQuery.of(context).size.width / 3,
                    height: 45,
                    child: RoundedSearchInput(
                      textController: searchController, 
                      hintText: "search Flashzone")
                    //  TextField(
                    //         //onChanged: _search,
                    //         controller: searchController,
                    //         cursorColor: Constants.primaryColor(),
                    //         style: const TextStyle(fontSize: 12),
                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),),
                    //           hintText: 'search FlashZone',
                    //           fillColor: Colors.white70,
                    //           filled: true,
                              
                    //         ),
                    //       ),
                  ),
              ),
                horizontal(),
                widget.mobileSize?
                IconButton(
                  icon: const Icon(Icons.search), 
                  onPressed:  () {
                      // Implement the logic to send the message
                      searchFlashes(searchController.text);
                      //usernameController.clear();
                    })
                : FZButton(
                    onPressed: () {
                      // Implement the logic to send the message
                      searchFlashes(searchController.text);
                      //usernameController.clear();
                    },
                    text: "Search",
                    textColor: Colors.white,
                    bgColor: Constants.altPrimaryColor(),
                  ),
                horizontal(),
                widget.mobileSize?
                IconButton(
                  icon: const Icon(Icons.cancel), 
                  onPressed: () {
                      // Implement the logic to send the message
                      searchController.text = "";
                      _filterFlashes.clear();
                      _filterFlashes.addAll(_flashes);
                      searchTerm = "";
                      setState(() { });
                      //usernameController.clear();
                    })
                : FZButton(
                    onPressed: () {
                      // Implement the logic to send the message
                      searchController.text = "";
                      _filterFlashes.clear();
                      _filterFlashes.addAll(_flashes);
                      searchTerm = "";
                      setState(() { });
                      //usernameController.clear();
                    },
                    text: "Clear",
                    textColor: Colors.white,
                    bgColor: Constants.bgColor(),
                  ),
            ],
          ),
          const SizedBox(height: 20,),
          if(searchTerm.isNotEmpty) FZText(text: "Showing search results for \"$searchTerm\"", style: FZTextStyle.smallsubheading, color: Colors.grey,),
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

  searchFlashes(String val) {
    
      _filterFlashes.clear();
      for(final flash in _flashes) {
        if(flash.content.toLowerCase().contains(val.toLowerCase())) {
          _filterFlashes.add(flash);
          continue;
        }
      }
      
    setState(() {
        searchTerm = val;
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

  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);

  String longchar() {
    return "FlashZone is an innovative platform focussed on #UFO that transforms the way communities create and attend events. It empowers users to submit and vote on requests for a wide range of physical events, from local concerts and sports matches to educational workshops and fitness classes. By allowing users to express their preferences and see which events are trending, FlashZone fosters a community-driven approach to event planning. Organizers can easily gauge interest, ensuring that each event resonates with what people genuinely want. FlashZone's voting system also builds excitement and encourages participation, as users can rally friends and share ideas to bring unique events to life. This platform creates a vibrant ecosystem where ideas are seamlessly transformed into real-life gatherings, turning collective interests into memorable experiences. With an easy-to-use interface and a focus on community engagement, FlashZone aims to make organizing and attending events more accessible, enjoyable, and impactful for everyone.";
  }

  String maxchar() {
    return "FlashZone is an innovative platform about #Paranormal where users can submit requests for physical events, making it easier to bring together communities and plan gatherings. Whether it's a local concert, fitness class, or a workshop, FlashZone provides a streamlined way for event organizers to gauge interest and ensure attendance. Users can request events they want to see in their area, vote on others’ suggestions, and even invite friends to join. With a mission to connect people through shared experiences, FlashZone turns ideas into real-life gatherings that resonate with community interests.";
  }

  String midchar() {
    return "FlashZone lets users request and vote on physical events on #Paranormal in their area, from concerts to classes. It connects communities by turning popular ideas into real gatherings, making event planning easy and engaging.";
  }

  String shortchar() {
    return "FlashZone turns event ideas into reality! It is all topics around #Spirituality";
  }

  Future<void> populateFakeFlashes() async {

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
  }
}