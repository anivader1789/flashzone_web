import 'package:flashzone_web/src/helpers/fakes_generator.dart';
import 'package:flashzone_web/src/model/flash.dart';
import 'package:flashzone_web/src/screens/subviews/flash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainFeedListView extends ConsumerStatefulWidget {
  const MainFeedListView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainFeedListViewState();
}

class _MainFeedListViewState extends ConsumerState<MainFeedListView> {

  final List<Flash> _flashes = List.empty(growable: true);
  //bool _loading = false;

  @override
  void initState() {
    super.initState();

    loadFakeData();
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
    return ListView.separated(
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
                );
  }
}