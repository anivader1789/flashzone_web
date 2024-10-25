import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flashzone_web/src/settings/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainFeedListView extends ConsumerStatefulWidget {
  const MainFeedListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainFeedListViewState();
}

class _MainFeedListViewState extends ConsumerState<MainFeedListView> {

  final List<Flash> _flashes = List.empty(growable: true);
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
    for(int i=0; i<15; i++) {
      final flash = Flash(
        content: Fakes.generateFakeText(),
        user: await Fakes.generateFakeUser(),
        postDate: Fakes.generateFakeDate()
        );
      _flashes.add(flash);
    }
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 10,),
        Expanded(
        child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 5,),
                      itemCount: _flashes.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          //onTap: () => ,
                          child: FlashCellView(
                              flash: _flashes[index],
                          ),
                        );
                      },
                    ),
      ),
                  ]
    );
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
}