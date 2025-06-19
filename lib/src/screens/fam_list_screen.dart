import 'package:flashzone_web/src/backend/backend_service.dart';
import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flashzone_web/src/helpers/packages.dart';
import 'package:flashzone_web/src/model/fam.dart';
import 'package:flashzone_web/src/screens/master_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FamListScreen extends ConsumerStatefulWidget {
  const FamListScreen({super.key});

  static const routeName = 'fams';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FamListScreenState();
}

class _FamListScreenState extends ConsumerState<FamListScreen> with SingleTickerProviderStateMixin {
  List<Fam> myFams = List.empty(growable: true);
  List<Fam> memberFams = List.empty(growable: true);
  List<Fam> famsNearby = List.empty(growable: true);

  late TabController tabController;

  final String famShowcaseImg = "https://firebasestorage.googleapis.com/v0/b/zone-f-6e47c.firebasestorage.app/o/appimg%2Fbreakfast-club.jpeg?alt=media&token=b40b2257-4c2f-4e9a-b405-d8be3c7984cc";

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    
  }

  fetchAllFams() async {
    myFams.clear();
    memberFams.clear();
    famsNearby.clear();

    famsNearby.addAll(await ref.read(backend).getNearbyFams(70));

    String myId = ref.read(currentuser).id!;
    final fams = await ref.read(backend).getMyFams(myId);
    for(Fam fam in fams) {
      if(fam.admins.contains(myId)) {
        myFams.add(fam);
      } else if(fam.members.contains(myId)) {
        memberFams.add(fam);
      }
    }
    print("Nearby fams count: ${famsNearby.length} ; myfams: ${fams.length}");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    bool mobileSize = MediaQuery.of(context).size.width < 800;

    return MasterView(
      onInitDone: () {
        

        fetchAllFams();
      },
      child: childView(size, mobileSize), 
      sideMenuIndex: 2);

      
    
  }

  childView(Size size, bool mobileSize) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              FZNetworkImage(url: famShowcaseImg, maxWidth: mobileSize? size.width * 0.4: size.width * 0.2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       FZText(text: "Fams are like your family", style: mobileSize? FZTextStyle.largeHeadline: FZTextStyle.xlargeHeadline),
                      const FZText(text: "Its the people who live nearby that you bond with", style: FZTextStyle.headline),
                      vertical(),
                      FZText(text: "Click here to start your fam today!", style: FZTextStyle.headline, color: Colors.blue, onTap: () {
                        context.go(Routes.routeNameFamNew());
                      },),
                    ],
                  ),
                ),
              ),
              
            ],
          ),
          
          
          
          // FZButton(onPressed: () {
            
          // }, text: "Click here to start your own Fam!"),
          vertical(),
          const Divider(),
          vertical(),
          Expanded(child: famsListContainerView(mobileSize))
          
        ],
      ),
    );
  }

  famsListContainerView(bool mobileSize) {
    
    return Column(mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          indicatorColor: Constants.primaryColor(),
          controller: tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
          Tab(text: "Fams nearby",),
          Tab(text: "My Fams",)
        ]),
        vertical(3),
        Expanded(
          child: TabBarView(controller: tabController,
            children: [
            famsNearbyView(mobileSize),
            famListView(mobileSize),
          ]),
        )
      ],
    );
  }

  famsNearbyView(bool mobileSize) {
    if(famsNearby.isEmpty) {
      return const Center(child: FZText(text: "No fams in your area yet", style: FZTextStyle.headline, color: Colors.grey,),);
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        Fam fam = famsNearby[index];
        return famItemView(fam, mobileSize);
      }, 
      separatorBuilder: (context, index) {
        return const Divider(); // Regular divider between items
      }, 
      itemCount: famsNearby.length);
  }

  famListView(bool mobileSize) {
    if(myFams.isEmpty && memberFams.isEmpty) {
      return const Center(child: FZText(text: "No fams to show here. But you can create one!", style: FZTextStyle.headline, color: Colors.grey,),);
    }

    return ListView.separated(
      itemCount: myFams.length + memberFams.length + 2, // +2 for section headers
      itemBuilder: (context, index) {
        // First section header
        if (index == 0) {
          return const Text('Admin',
              style: TextStyle(fontWeight: FontWeight.bold));
        }
        // First list items
        else if (index <= myFams.length) {
          Fam fam = myFams[index - 1];
          return famItemView(fam, mobileSize);
        }
        // Second section header
        else if (index == myFams.length + 1) {
          return const Text('Member',
              style: TextStyle(fontWeight: FontWeight.bold));
        }
        // Second list items
        else {
          Fam fam = memberFams[index - myFams.length - 2];
          return famItemView(fam, mobileSize);
        }
      },
      separatorBuilder: (context, index) {
        // You can customize separators based on position if needed
        if (index == 0 || index == myFams.length + 1) {
          return const Divider(thickness: 2); // Thicker divider after headers
        }
        return const Divider(); // Regular divider between items
      },
    );
  }

  famItemView(Fam fam, bool mobileSize) {
    return Container(
      
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          context.go(Routes.routeNameFamDetail(fam.id!));
        },
        child: Card(
          surfaceTintColor: Constants.bgColor(),
          elevation: 5,
          margin: const EdgeInsets.all(8),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FZText(text: "#${fam.name}", style: mobileSize? FZTextStyle.headline: FZTextStyle.tooLargeHeadline),
                vertical(),
                FZText(text: fam.description, style: FZTextStyle.paragraph),
                vertical(),
                Row(
                  children: [
                    const Icon(Icons.group, size: 24,),
                    horizontal(),
                    FZText(text: fam.community, style: FZTextStyle.paragraph),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  } 


  vertical([double multiple = 1]) => SizedBox(height: 5 * multiple,);
  horizontal([double multiple = 1]) => SizedBox(width: 5 * multiple,);
}
