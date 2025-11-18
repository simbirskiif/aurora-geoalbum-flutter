import 'package:flutter/material.dart';
import 'package:geo_album/image_location.dart';
import 'package:geo_album/image_store.dart';
import 'package:geo_album/screens/gallery_screen.dart';
import 'package:geo_album/screens/map_screen.dart';
import 'package:provider/provider.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ImageManager>(context, listen: false)
            .findAndUpdateImages());
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
            primarySwatch: Colors.deepOrange,
            primaryColor: Colors.deepOrange),
        home: Scaffold(
          bottomNavigationBar: NavigationBar(
            destinations: const <Widget>[
              NavigationDestination(icon: Icon(Icons.image), label: "Списком"),
              NavigationDestination(icon: Icon(Icons.map), label: "На карте")
            ],
            selectedIndex: _selectedScreen,
            onDestinationSelected: (value) {
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
          body: IndexedStack(
            index: _selectedScreen,
            children: _screens,
          ),
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
