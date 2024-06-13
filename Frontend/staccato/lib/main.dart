import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gap/gap.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:staccato/Classes/audiofile.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/login_page.dart';
import 'package:staccato/Pages/settings_page.dart';
import 'package:staccato/Pages/user_page.dart';
import 'package:staccato/Theme/themes.dart';
import 'package:staccato/l10n/l10n.dart';
import 'package:staccato/managers/language_manager.dart';
import 'package:staccato/managers/theme_manager.dart';
import 'package:staccato/music_analysing/music_sheet.dart';
import 'package:staccato/music_analysing/process_wav.dart';

import 'music_analysing/audio_edit.dart';

void main() {
  // Frequency Resolution = Samplerate / Values.Length
  // Gewünschte Frequenz ist nach der FFT mithilfe von (Frequency / Frequency Resolution) erhältlich

  //var result = AudioEdit.readWavFile("D:/SchuleD/Diplom-Arbeit/FourierTransform/WaveFiles/chordLeiter.wav");

  // var result = AudioEdit.readWavFile("D:/SchuleD/Diplom-Arbeit/FourierTransform/WaveFiles/The Beatles - Here Comes The Sun.wav");

  // ProcessWav worker = ProcessWav(result.item1, result.item2);

  // worker.startProcess().then((value)
  // {
  // MusicSheet tonleiter = worker.createMusicSheet();

  //     for (int i = 0; i < tonleiter.notes.length; i++)
  // {
  //   if(tonleiter.notes[i] != null) {
  //     for (var notes in tonleiter.notes[i]!)
  //     {
  //       print("${notes.note.name}, ${notes.noteType.name}, $i");
  //     }
  //   }
  // }

  //ChordAnalyser analyser = ChordAnalyser(tonleiter);

  //var chords = analyser.getChords();

  //print("--------------------__Chords__--------------------");
  //for(var chord in chords)
  //{
  //  print(chord);
  //}
  //});

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final logger = Logger(
    printer: PrettyPrinter(
        methodCount: 2,
        // Number of method calls to be displayed
        errorMethodCount: 8,
        // Number of method calls if stacktrace is provided
        lineLength: 120,
        // Width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: true // Should each log print contain a timestamp
        ),
  );

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    MyApp.logger.t("Staccato is starting...");
    ThemeManager.themeManager.addListener(onThemeChange);
    LanguageManager.languageManager.addListener(onLanguageChange);
    super.initState();
  }

  @override
  void dispose() {
    MyApp.logger.t("Staccato is shutting down...");
    ThemeManager.themeManager.removeListener(onThemeChange);
    LanguageManager.languageManager.removeListener(onLanguageChange);
    MyApp.logger.close();
    super.dispose();
  }

  onThemeChange() {
    MyApp.logger.t("The app theme mode has been changed to "
        "${ThemeManager.themeManager.themeMode}");
    setState(() {});
  }

  onLanguageChange() {
    MyApp.logger.t("The app language has been changed to "
        "${LanguageManager.languageManager.languageAsString}");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t("App is being build...");
    return MaterialApp(
      title: 'Staccato',
      theme: orangeLightTheme,
      darkTheme: blueGreyDarkTheme,
      themeMode: ThemeManager.themeManager.themeMode,
      supportedLocales: L10n.all,
      locale: LanguageManager.languageManager.languageAsLocal,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      home: const LoginPage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum _BottomNavigationBarState { normal, dragging, recording }

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  final double _splashRadius = 23;

  late final recorder;
  Stream? audioStream;

  var isMultipleInstrumentMode = false;

  var _bottomNavigationBarState = _BottomNavigationBarState.normal;

  var _buttonHorizontalPosition = 0.0;
  final _buttonTopPadding = 50.0;

  double _chooseFileOpacity = 1;
  double _recordAudioOpacity = 1;

  final _audios = List<Audio>.empty(growable: true);

  late AnimationController _animationController;

  List<Widget> _createBottomNavigationBarChildren() {
    if (_bottomNavigationBarState == _BottomNavigationBarState.dragging) {
      double padding = _buttonHorizontalPosition.abs();

      return [
        Padding(
          padding: EdgeInsets.fromLTRB(
              _buttonHorizontalPosition > 0 ? padding : 0, 0, 0, 0),
          child: Opacity(
              opacity: _chooseFileOpacity,
              child: Row(
                children: [
                  Text("Choose File",
                      style: Theme.of(context).textTheme.displayMedium),
                  const Gap(50),
                  //PositionedTransition(rect: _animationController, child: child),
                  const Icon(Icons.arrow_back_ios),
                  const Icon(Icons.arrow_back_ios),
                  const Icon(Icons.arrow_back_ios),
                ],
              )),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
              0, 0, _buttonHorizontalPosition < 0 ? padding : 0, 0),
          child: Opacity(
              opacity: _recordAudioOpacity,
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward_ios),
                  const Icon(Icons.arrow_forward_ios),
                  const Icon(Icons.arrow_forward_ios),
                  const Gap(50),
                  Text("Record audio",
                      style: Theme.of(context).textTheme.displayMedium),
                ],
              )),
        )
      ];
    }

    if (_bottomNavigationBarState == _BottomNavigationBarState.recording) {
      return [
        IconButton(onPressed: () {}, icon: const Icon(Icons.pause)),
        Row(
          children: [
            const Icon(Icons.fiber_manual_record),
            Text("00:00", style: Theme.of(context).textTheme.displayMedium),
          ],
        )
      ];
    }

    return [
      IconButton(
          onPressed: () {
            MyApp.logger.t('Settings button pressed');
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
          splashRadius: _splashRadius,
          icon: const Icon(Icons.settings)),
      IconButton(
          onPressed: () {
            MyApp.logger.t('Profile button pressed');
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => ProfilePage()));
          },
          splashRadius: _splashRadius,
          icon: const Icon(Icons.person)),
    ];
  }

  @override
  void initState() {
    MyApp.logger.t("Homepage is being build...");
    if (User.isLoggedIn) {
      MyApp.logger.d("The user is logged in as "
          "${User.getCurrentlyLoggedInUser!.username}");

      User.getCurrentlyLoggedInUser!.downloadAudioFiles().then((audios) {
        MyApp.logger.t('Loading audio files...');
        if (audios != null) {
          for (var audio in audios) {
            setState(() {
              _audios.add(audio);
            });
          }
        }
      });
    }
    if (kDebugMode) {
      _audios.add(Audio.dummy());
      _audios.add(Audio.dummy());
      _audios.add(Audio.dummy());
      _audios.add(Audio.dummy());
      _audios.add(Audio.dummy());
    }

    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat();

    recorder = AudioRecorder();

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    recorder.dispose();
    super.dispose();
  }

  void deleteFromCloud(int index, Icon icon) {
    _audios[index].removeFromCloud().then((hasWorked) {
      if (hasWorked) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Audio removed from cloud')));
        setState(() {
          icon = const Icon(Icons.cloud_upload_outlined);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Request failed')));
      }
      Navigator.of(context).pop();
    });
  }

  var fileDialogIsOpen = false;

  void startFileDialog() async {
    if (fileDialogIsOpen) return;

    _bottomNavigationBarState = _BottomNavigationBarState.normal;

    MyApp.logger.i('The user is picking a file');

    fileDialogIsOpen = true;
    var result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Choose audiofile',
        type: FileType.audio,
        allowedExtensions: ['.wav']);
    fileDialogIsOpen = false;

    if (result == null) {
      return;
    }

    var audioFile = result.files.first;

    if(isMultipleInstrumentMode) {
      //TODO split audio file
    }

    var audioResult = AudioEdit.readWavFile(audioFile.path!);
    var worker = ProcessWav(audioResult.item1, audioResult.item2);
    await worker.startProcess();
    var musicSheet = worker.createMusicSheet();

    _audios.add(Audio(MusicPiece(
        audioFile.name, audioFile.path!, DateTime.now(), musicSheet)));
  }

  void startRecording() async {
    _bottomNavigationBarState = _BottomNavigationBarState.recording;
    MyApp.logger.d('Starting recording...');
    if (await recorder.hasPermission()) {
      final appDirectory = await getApplicationDocumentsDirectory();
      final audioPath = Directory("${appDirectory.path}\\Staccato\\Audio");

      if (!await audioPath.exists()) {
        MyApp.logger.t('Audio directory does not exists. Creating it...');
        await audioPath.create(recursive: true);
        MyApp.logger.t('Audio directory created');
      } else {
        MyApp.logger.t('Audio directory does exists');
      }

      MyApp.logger.i('Path: ${audioPath.path}');

      var encoder = AudioEncoder.pcm16bits;

      if (!await recorder.isEncoderSupported(encoder)) {
        MyApp.logger.e("Could not start recording",
            error: "Encoder $encoder is not supported");
        stopRecording();
        return;
      }

      await recorder.start(const RecordConfig(), path: audioPath.path);
    } else {
      MyApp.logger.e('Could not start recording',
          error: 'No permission to use microphone');
    }
  }

  void stopRecording() {
    MyApp.logger.d("Stopping recording..");
    _bottomNavigationBarState = _BottomNavigationBarState.normal;
    recorder.stop().then((path) {
      MyApp.logger.d(path);
      setState(() => _audios.add(Audio(
          MusicPiece("Recording", path!, DateTime.now(), MusicSheet(10)))));
    });
  }

  void saveToCloud(int index, Icon icon) {
    _audios[index].uploadIntoCloud().then((hasWorked) {
      if (hasWorked) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Audio uploaded')));
        setState(() {
          icon = const Icon(Icons.cloud_done_outlined);
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Upload failed')));
      }
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t("Homepage is being build...");

    MyApp.logger.d('The list of audios consists of ${_audios.length}: '
        '\n$_audios');

    double? drawerSize;

    if (kIsWeb) {
      drawerSize = 300;
      MyApp.logger
          .d('App is being build on Web. Drawer size will be $drawerSize');
    } else if (Platform.isAndroid || Platform.isIOS) {
      drawerSize = 300;
      MyApp.logger
          .d('App is being build on mobile. Drawer size will be $drawerSize');
    } else {
      drawerSize = 500;
      MyApp.logger
          .d('App is being build on desktop. Drawer size will be $drawerSize');
    }

    double bottomNavigationBarHorizontalMargin;
    EdgeInsets buttonPadding;
    IconData buttonIcon;

    double dragMax = MediaQuery.of(context).size.width / 4;

    if (_bottomNavigationBarState == _BottomNavigationBarState.normal) {
      _chooseFileOpacity = 1;
      _recordAudioOpacity = 1;
      _buttonHorizontalPosition = 0;
      bottomNavigationBarHorizontalMargin = 10.0;
      buttonPadding = EdgeInsets.zero;
      buttonIcon = Icons.music_note;
    } else {
      if (_buttonHorizontalPosition < 0) {
        buttonPadding = EdgeInsets.fromLTRB(
            0, _buttonTopPadding, _buttonHorizontalPosition * -1, 0);
      } else {
        buttonPadding = EdgeInsets.fromLTRB(
            _buttonHorizontalPosition, _buttonTopPadding, 0, 0);
      }
      if (_bottomNavigationBarState == _BottomNavigationBarState.dragging) {
        bottomNavigationBarHorizontalMargin =
            MediaQuery.of(context).size.width / 8;
        buttonIcon = Icons.music_note;
      } else {
        bottomNavigationBarHorizontalMargin =
            MediaQuery.of(context).size.width / 4;
        buttonPadding = EdgeInsets.fromLTRB(0, _buttonTopPadding, 0, 0);
        buttonIcon = Icons.stop;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        width: drawerSize,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 195,
              child: DrawerHeader(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Single instrument',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Switch(
                              value: isMultipleInstrumentMode,
                              onChanged: (newValue) => setState(() =>
                                  isMultipleInstrumentMode =
                                      !isMultipleInstrumentMode)),
                          Text('Multiple instruments',
                              style: Theme.of(context).textTheme.bodySmall)
                        ],
                      ),
                      Text(AppLocalizations.of(context)!.audios_title),
                    ],
                  )),
            ),
            const Gap(15),
            Flexible(
              child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemBuilder: (context, index) {
                    MyApp.logger.t('Listview item $index is being build...');

                    var icon = _audios[index].isDummy
                        ? const Icon(Icons.cloud_off)
                        : _audios[index].isSynced
                            ? const Icon(Icons.cloud_done_outlined)
                            : const Icon(Icons.cloud_upload_outlined);

                    var onCloudButtonPressed = _audios[index].isDummy
                        ? null
                        : _audios[index].isSynced
                            ? () => deleteFromCloud(index, icon)
                            : () => saveToCloud(index, icon);

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      child: Ink(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).colorScheme.primary),
                        padding: const EdgeInsets.fromLTRB(17, 10, 0, 10),
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                _audios[index].audio.getDisplayedName,
                                style: Theme.of(context).textTheme.titleMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              ' | ',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              _audios[index]
                                  .audio
                                  .date
                                  .toStringWithoutMilliseconds(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const MaxGap(2000),
                            IconButton(
                              onPressed: onCloudButtonPressed,
                              icon: icon,
                              splashRadius: 25,
                            )
                          ],
                        ),
                      ),
                      onTap: () {
                        MyApp.logger.t('Changing selected audio...');
                        MyApp.logger.d('Audio: ${_audios[index]}');
                        setState(() {
                          _audios[index].selectAudio();
                          Navigator.pop(context);
                        });
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: _audios.length),
            ),
          ],
        ),
      ),
      body: Center(child: Audio.currentlySelectedAudio),
      bottomNavigationBar: AnimatedContainer(
          height: 55,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.primary),
          margin: EdgeInsets.fromLTRB(bottomNavigationBarHorizontalMargin, 0,
              bottomNavigationBarHorizontalMargin, 10),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _createBottomNavigationBarChildren(),
              ),
            ),
          )),
      floatingActionButton: AnimatedPadding(
          duration: const Duration(milliseconds: 125),
          padding: buttonPadding,
          child: GestureDetector(
            child: Container(
              height: 65,
              width: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(buttonIcon),
            ),
            onTapDown: (details) {
              if (_bottomNavigationBarState ==
                  _BottomNavigationBarState.recording) return;

              setState(() => _bottomNavigationBarState =
                  _BottomNavigationBarState.dragging);
            },
            onTapUp: (details) {
              if (_bottomNavigationBarState ==
                  _BottomNavigationBarState.recording) return;
              MyApp.logger.i("onTapUp");

              setState(() =>
                  _bottomNavigationBarState = _BottomNavigationBarState.normal);
            },
            //onTapCancel: () => MyApp.logger.i("onTapCancel"),
            onTap: () {
              if (_bottomNavigationBarState !=
                  _BottomNavigationBarState.recording) return;

              setState(() => stopRecording());
              MyApp.logger.i("onTap");
            },
            onHorizontalDragStart: (details) {
              if (_bottomNavigationBarState ==
                  _BottomNavigationBarState.recording) return;

              setState(() => _bottomNavigationBarState =
                  _BottomNavigationBarState.dragging);
            },
            onHorizontalDragCancel: () =>
                MyApp.logger.i("onHorizontalDragCancel"),
            onHorizontalDragDown: (details) =>
                MyApp.logger.i("onHorizontalDragDown"),
            onHorizontalDragEnd: (details) {
              if (_bottomNavigationBarState ==
                  _BottomNavigationBarState.recording) return;

              MyApp.logger.i("onHorizontalDragEnd");
              setState(() =>
                  _bottomNavigationBarState = _BottomNavigationBarState.normal);
            },
            onHorizontalDragUpdate: (details) {
              if (_bottomNavigationBarState ==
                  _BottomNavigationBarState.recording) return;

              var offset = details.localPosition.dx;
              setState(() {
                _buttonHorizontalPosition = offset * 1.8;

                if (offset > dragMax) {
                  startRecording();
                }

                if (offset < dragMax * -1) {
                  startFileDialog();
                }

                if (offset < 0) {
                  _recordAudioOpacity =
                      1 - min(1, (offset.abs() / dragMax) * 1.8);
                  _chooseFileOpacity = 1;
                } else if (offset > 0) {
                  _recordAudioOpacity = 1;
                  _chooseFileOpacity = 1 - min(1, (offset / dragMax) * 1.8);
                } else {
                  _recordAudioOpacity = 1;
                  _chooseFileOpacity = 1;
                }
              });
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
