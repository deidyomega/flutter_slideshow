import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:window_manager/window_manager.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'package:flutter/material.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  DartVLC.initialize();

  String data = await rootBundle.loadString("assets/settings.json");
  Config config = Config.fromJson(data);

  windowManager.waitUntilReadyToShow().then((_) async {
    // Set to frameless window
    await windowManager.setAsFrameless();
    await windowManager.setAlwaysOnTop(true);

    Future.delayed(const Duration(milliseconds: 500)).then((_) async {
      await windowManager.setSize(
        Size(config.width.toDouble(), config.height.toDouble()),
      );
      Future.delayed(const Duration(milliseconds: 500)).then((_) async {
        await windowManager.setPosition(Offset.zero);
      });
    });
    await windowManager.show();
  });

  runApp(MyApp(config: config));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key, required this.config}) : super(key: key);

  final Config config;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (config.fullscreen) {
          exit(0);
        }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: MyHomePage(config: config),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.config}) : super(key: key);

  final Config config;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int rows = 1;
  int columns = 1;
  int speed = 500;
  String directory = '';
  List<Player> player = [];

  List<FileSystemEntity> _files = [];
  List<FileSystemEntity> currentFiles = [];
  Timer? timer;
  int cFileindex = 0;
  int mainFileIndex = 0;

  @override
  initState() {
    super.initState();
    rows = widget.config.rows;
    columns = widget.config.columns;
    player = List.generate(rows * columns,
        (index) => Player(id: index, commandlineArguments: ['--no-video']));
    speed = widget.config.speed;
    directory = widget.config.directory;
    _getFiles().then((_) {
      currentFiles = List.generate(rows * columns, (index) {
        if (_files[index].path.endsWith('.mp4')) {
          playVideo(player[index], _files[index] as File);
        }
        return _files[index];
      });
      mainFileIndex = rows * columns;
      timer = Timer.periodic(
          Duration(milliseconds: speed), (Timer t) => _setFile());
    });
  }

  void _setFile() {
    setState(() {
      int cfileIndex = cFileindex % (rows * columns);
      if (currentFiles[cfileIndex].path.endsWith(".mp4")) {
        if (player[cfileIndex].playback.isPlaying) {
          cFileindex++;
          return;
        }
      }

      currentFiles[cfileIndex] = _files[mainFileIndex % _files.length];
      if (currentFiles[cfileIndex].path.endsWith(".mp4")) {
        playVideo(player[cfileIndex], currentFiles[cfileIndex] as File);
      }
      cFileindex++;
      mainFileIndex++;
    });
  }

  bool playVideo(Player player, File file) {
    player.open(Media.file(file));
    player.setVolume(0.0);
    player.setRate(1.0);
    player.play();
    return true;
  }

  Future<void> _getFiles() async {
    Directory dir = Directory(directory);
    List<FileSystemEntity> files = await dir.list(recursive: false).toList();

    files = files.where((f) => !f.path.endsWith(".py")).toList();
    files = files.where((f) => !f.path.endsWith(".hidden")).toList();
    files = files.where((f) => !f.path.endsWith(".NOMEDIA")).toList();
    files = files.where((f) => !f.path.endsWith(".mp4")).toList();

    files.shuffle();
    setState(() {
      _files = files;
      _files.shuffle();
      // print(_files);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: currentFiles.isEmpty
          ? Container()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(columns, (outerIndex) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(rows, (index) {
                    FileSystemEntity file =
                        currentFiles[outerIndex * rows + index];
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 100),
                      child: file.path.endsWith(".mp4")
                          ? Video(
                              player: player[outerIndex * rows + index],
                              height:
                                  (MediaQuery.of(context).size.height / rows) -
                                      20,
                              width: (MediaQuery.of(context).size.width /
                                      columns) -
                                  20,
                              showControls: false, // default
                              key: ValueKey(outerIndex * rows + index),
                            )
                          : ImageHandler(
                              key: ValueKey(outerIndex * rows + index),
                              file: file,
                              rows: rows,
                              columns: columns),
                    );
                  }),
                );
              }),
            ),
    );
  }
}

class ImageHandler extends StatelessWidget {
  const ImageHandler(
      {Key? key, required this.file, required this.rows, required this.columns})
      : super(key: key);

  final FileSystemEntity file;
  final int rows;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>(file.path),
      height: (MediaQuery.of(context).size.height / rows) - 20,
      width: (MediaQuery.of(context).size.width / columns) - 20,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.contain,
          image: FileImage(
            file as File,
          ),
        ),
      ),
    );
  }
}

class VideoHandler extends StatelessWidget {
  const VideoHandler({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
