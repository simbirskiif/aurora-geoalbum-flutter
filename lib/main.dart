import 'package:flutter/material.dart';
import 'package:geo_album/utils/image_location_utils.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/screens/gallery_screen.dart';
import 'package:geo_album/screens/map_screen.dart';
import 'package:provider/provider.dart';
import 'package:responsive_navigation_bar/responsive_navigation_bar.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => ImageManager(),
    child: const Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final GlobalKey<MapScreenState> mapKey = GlobalKey<MapScreenState>();

  int _selectedScreen = 0;
  List<Widget> get _screens {
    return <Widget>[
      KeepAliveWrapper(child: GalleryScreen(
        goToMap: (image) {
          mapKey.currentState?.goTo(image);
          setState(() {
            _selectedScreen = 1;
          });
        },
      )),
      KeepAliveWrapper(
          child: MapScreen(
        key: mapKey,
      ))
    ];
  }

  String t = "Поиск....";
  @override
  void initState() {
    super.initState();

    load();
  }

  Future<void> load() async {
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ImageManager>(context, listen: false)
            .findAndUpdateImages());
  }

  Future<void> printTest() async {
    List<String> imagePath = await findImagePathsRecursive();
    for (final s in imagePath) {
      debugPrint(s);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          floatingActionButtonTheme: FloatingActionButtonThemeData(),
          useMaterial3: true,
        ),
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: ResponsiveNavigationBar(
            textStyle: TextStyle(color: Colors.white),
            inactiveButtonsFlexFactor: 100,
            navigationBarButtons: const <NavigationBarButton>[
              NavigationBarButton(icon: Icons.image, text: "Списком"),
              NavigationBarButton(icon: Icons.map, text: "На карте")
            ],
            selectedIndex: _selectedScreen,
            onTabChange: (value) {
              setState(() {
                _selectedScreen = value;
              });
            },
          ),
          appBar: AppBar(
            title: Text("ГеоАльбом"),
            actions: [
              IconButton(
                  onPressed: () {
                    load();
                  },
                  icon: Icon(Icons.restart_alt))
            ],
          ),
          body: SafeArea(
              bottom: false,
              child: IndexedStack(
                index: _selectedScreen,
                children: _screens,
              )),
        ));
  }
}

class KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
