import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/main.dart';
import 'package:staccato/managers/language_manager.dart';
import 'package:staccato/music_analysing/music_note.dart';
import 'package:staccato/music_analysing/music_sheet.dart';

extension on Duration {
  String toStringInMinutes() {
    var buffer = StringBuffer();
    buffer.write(inMinutes.toString().padLeft(2, "0"));
    buffer.write(':');
    buffer.write((inSeconds % 60).toString().padLeft(2, "0"));

    return buffer.toString();
  }
}

extension AdvancedToString on DateTime {
  String toStringWithoutMilliseconds() {
    StringBuffer buffer = StringBuffer();
    if (LanguageManager.languageManager.languageAsLocal.languageCode == "de") {
      //German format
      buffer.write(day.toString().padLeft(2, "0"));
      buffer.write(".");
      buffer.write(month.toString().padLeft(2, "0"));
      buffer.write(".");
    } else {
      //english format
      buffer.write(month.toString().padLeft(2, "0"));
      buffer.write("/");
      buffer.write(day.toString().padLeft(2, "0"));
      buffer.write("/");
    }

    buffer.write(year);
    buffer.write(" - ");
    buffer.write(hour.toString().padLeft(2, "0"));
    buffer.write(":");
    buffer.write(minute.toString().padLeft(2, "0"));

    return buffer.toString();
  }
}

mixin AudioFile {
  late final DateTime date;
  late String _displayedName;
  late final String audioFilePath;

  String get getDisplayedName => _displayedName;
}

class MusicPiece with AudioFile {
  MusicPiece(String displayedName, String audioFilePath, DateTime date,
      MusicSheet sheet)
      : noteSheet = NoteSheet(sheet) {
    MyApp.logger.t('Creating new music piece...');
    this.date = date;
    this.audioFilePath = audioFilePath;
    _displayedName = displayedName;
    _musicPieces.add(this);
    MyApp.logger.d('Music piece: $this');
  }

  static final _musicPieces = List.empty(growable: true);

  final _instruments = LinkedList<InstrumentAudio>();
  final NoteSheet noteSheet;

  static List<MusicPiece> get musicPieces =>
      List.from(_musicPieces, growable: false);

  static int get musicPiecesCount => _musicPieces.length;

  LinkedList<InstrumentAudio> get instruments {
    var listOfInstruments = LinkedList<InstrumentAudio>();
    for (var instrument in _instruments) {
      listOfInstruments.add(instrument);
    }
    return listOfInstruments;
  }

  set displayedName(String newName) {
    MyApp.logger.t('Changing name of music piece to "$newName"...');
    if (newName.isEmpty) {
      MyApp.logger.e('New name is empty');
      return;
    }
    //TODO Change name in database
    _displayedName = newName;
    MyApp.logger.t('Named changed');
  }

  void addInstrument(Instrument instrument, String audioFilePath,
      DateTime date) {
    MyApp.logger
        .t('Adding instrument "${instrument.name}" to the list of music piece '
        '"$_displayedName"');
    _instruments.add(InstrumentAudio._(instrument, audioFilePath, date));
    MyApp.logger.t('Instrument added');
  }

  @override
  String toString() {
    return 'Music piece "$_displayedName"';
  }
}

enum Instrument { guitar, piano, drums }

final class InstrumentAudio extends LinkedListEntry<InstrumentAudio>
    with AudioFile {
  InstrumentAudio._(this.instrument, String audioFilePath, DateTime date) {
    MyApp.logger.t('Creating new instrument audio...');
    this.date = date;
    this.audioFilePath = audioFilePath;
    MyApp.logger.t('New instrument audio: $this');
  }

  final Instrument instrument;

  @override
  get getDisplayedName {
    switch (instrument) {
      case Instrument.drums:
        return "Drums";
      case Instrument.guitar:
        return "Guitar";
      case Instrument.piano:
        return "Piano";
      default:
        return "Unidentified instrument";
    }
  }

  @override
  String toString() {
    return getDisplayedName;
  }
}

class Audio extends StatefulWidget {
  Audio(this.audio, {super.key, bool isSynced = false})
      : isDummy = false,
        _isSynced = isSynced {
    MyApp.logger.t('Creating new audio widget...');
    MyApp.logger.t('New audio: ${audio._displayedName}');
  }

  Audio.dummy({super.key})
      : audio = MusicPiece("Dummy audio $_dummyCount",
      'audios/Tonleiter_c-dur.wav', DateTime.now(), MusicSheet(10)),
        isDummy = true,
        _isSynced = false {
    MyApp.logger.t('Creating new dummy audio widget...');
    _dummyCount++;
    (audio as MusicPiece).addInstrument(Instrument.piano, "", audio.date);
    (audio as MusicPiece).addInstrument(Instrument.guitar, "", audio.date);
    (audio as MusicPiece).addInstrument(Instrument.drums, "", audio.date);
    MyApp.logger.t('New audio: $this');
  }

  static int _dummyCount = 0;

  static Audio? _currentlySelectedAudio;

  final AudioFile audio;

  static Audio? get currentlySelectedAudio => _currentlySelectedAudio;

  final bool isDummy;

  bool _isSynced;

  bool get isSynced => _isSynced;

  bool get isSelected => this == _currentlySelectedAudio;

  bool get isInstrument => audio is InstrumentAudio;

  bool get isNotInstrument => audio is MusicPiece;

  void selectAudio() {
    MyApp.logger.t('Selecting audio ${audio._displayedName}');
    _currentlySelectedAudio = this;
  }

  Future<bool> uploadIntoCloud() async {
    MyApp.logger.t('User is trying to upload audio ${audio._displayedName}');

    if (isDummy) {
      MyApp.logger.f('This audio is a dummy audio and is not to be uploaded');
      return false;
    }

    MyApp.logger.t('Creating audio data...');
    var audioData = jsonEncode(<String, dynamic>{
      'audioFile': <String, dynamic>{
        'fileName': audio._displayedName
            .split('/')
            .last,
        'displayedName': audio._displayedName,
        'noteAnalysis': (audio as MusicPiece).noteSheet.sheetData.notes,
        'accordAnalysis': []
      }
    });
    MyApp.logger.d(audioData);

    var request = http.MultipartRequest(
        'POST', Uri.parse('http://fileserver.foxel.at:1220/audiofile'))
      ..headers['authorization'] =
          'Bearer ${User.getCurrentlyLoggedInUser!.authToken}'
      ..fields['data'] = audioData
      ..files.add(http.MultipartFile.fromBytes(
          'audio', File(audio.audioFilePath).readAsBytesSync(),
          filename: audio.audioFilePath
              .split('/')
              .last));

    MyApp.logger.t('Sending request...');
    var response = await request.send();

    MyApp.logger.d(response.statusCode);
    if (response.statusCode != 204) {
      MyApp.logger
          .e('Request failed', error: await response.stream.bytesToString());
      return false;
    }

    _isSynced = true;
    return true;
  }

  Future<bool> removeFromCloud() async {
    MyApp.logger.t(
        'User is trying to delete audio ${audio
            ._displayedName} from the cloud');

    if (!_isSynced) {
      MyApp.logger.f('This audio is not even in the cloud');
      return false;
    }

    MyApp.logger.t('Getting audio name...');
    var audioName = audio.audioFilePath
        .split('/')
        .last;
    MyApp.logger.d(audioName);

    MyApp.logger.t('Sending request...');
    var response = await http.delete(
        Uri.parse('http://fileserver.foxel.at:1220/audiofile'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Bearer ${User.getCurrentlyLoggedInUser!.authToken}'
        },
        body: jsonEncode(<String, String>{'name': audioName}));

    MyApp.logger.d(response.statusCode != 200);

    if (response.statusCode != 200) {
      MyApp.logger.e('Request failed', error: response.body);
      return false;
    }

    _isSynced = false;
    return true;
  }

  @override
  State<Audio> createState() => _AudioState();
}

class _AudioState extends State<Audio> {
  var _playerIcon = Icons.play_arrow;

  var sliderValue = 0.0;

  final player = AudioPlayer();

  Duration? duration;

  Duration position = Duration.zero;

  bool get isPlaying => player.state == PlayerState.playing;

  bool get isNotPlaying => player.state != PlayerState.playing;

  bool resumeAfterSeek = false;

  @override
  void initState() {
    super.initState();
    if (widget.isDummy) {
      player
          .setSourceAsset(widget.audio.audioFilePath)
          .then((value) =>
          player.getDuration().then((duration) {
            setState(() {
              this.duration = duration;
            });
          }));
    } else {
      player
          .setSourceDeviceFile(widget.audio.audioFilePath)
          .then((value) =>
          player.getDuration().then((duration) {
            setState(() {
              this.duration = duration;
            });
          }));
    }

    player.onPlayerStateChanged.listen(onPlayerStateChanged);
    player.onPositionChanged.listen(onPositionChanged);
  }

  void startOrStopAudio() {
    if (isPlaying) {
      player.pause();
      return;
    }
    player.resume();
  }

  void onPlayerStateChanged(PlayerState state) {
    setState(() {
      if (state == PlayerState.playing) {
        _playerIcon = Icons.pause;
        return;
      }
      if (resumeAfterSeek) return;
      _playerIcon = Icons.play_arrow;
    });
  }

  void onPositionChanged(Duration position) {
    MyApp.logger.d('Position changed');
    setState(() {
      sliderValue = (position.inMilliseconds).toDouble() /
          (duration?.inMilliseconds ?? 1);
      this.position = position;
    });
  }

  void onStartSeeking(double value) {
    MyApp.logger.t('User started seeking audio ${widget.audio._displayedName}');
    if (isPlaying) {
      resumeAfterSeek = true;
      player.pause();
    }
  }

  void onStopSeeking(double newSliderValue) {
    MyApp.logger.t('User stopped seeking audio ${widget.audio._displayedName}');
    if (resumeAfterSeek) {
      player.seek(duration! * newSliderValue).then((value) => player.resume());
      resumeAfterSeek = false;
      return;
    }
    player.seek(duration! * newSliderValue);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    MyApp.logger
        .t('Audio widget "${widget.audio.getDisplayedName}" is being build...');

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            widget.audio.getDisplayedName,
            style: theme.textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            widget.audio.date.toStringWithoutMilliseconds(),
            style: theme.textTheme.bodySmall,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                IconButton(
                  onPressed: startOrStopAudio,
                  icon: Icon(_playerIcon),
                  splashRadius: 21,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  position.toStringInMinutes(),
                  style: theme.textTheme.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: sliderValue,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.onPrimary,
                    thumbColor: theme.colorScheme.primary,
                    onChangeStart: onStartSeeking,
                    onChanged: (value) =>
                        setState(() {
                          sliderValue = value;
                          if (duration == null) return;
                          position = duration! * sliderValue;
                        }),
                    onChangeEnd: onStopSeeking,
                  ),
                ),
                Text(
                  duration?.toStringInMinutes() ?? '??:??',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const Gap(30),
          Wrap(
            direction: Axis.horizontal,
            spacing: 20,
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 20,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: AspectRatio(
                  aspectRatio: 1 / sqrt(2),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ClipRRect(
                        borderRadius:
                        const BorderRadius.all(Radius.circular(25)),
                        child: (widget.audio as MusicPiece).noteSheet),
                  ),
                ),
              ),
              //Container(
              //  height: 300,
              //  padding: const EdgeInsets.all(10),
              //  decoration: BoxDecoration(
              //    color: theme.colorScheme.primary,
              //    borderRadius: BorderRadius.circular(25),
              //  ),
              //  child: ClipRRect(
              //      borderRadius: const BorderRadius.all(Radius.circular(25)),
              //      child: Image.asset(
              //          'assets/placeholder/spectogram_placeholder.png')),
              //)
            ],
          )
        ],
      ),
    );
  }
}

class NoteSheet extends StatelessWidget {
  NoteSheet._(this.name, this.lines, this.sheetData);

  factory NoteSheet(MusicSheet sheet) {
    var queue = Queue<List<MusicNote>?>.of(sheet.notes);

    var noteLines = List<NoteLine>.empty(growable: true);
    var notes = List<List<Note>>.empty(growable: true);

    var currentNotes = List<Note>.empty(growable: true);

    var previewsWasPause = false;

    //Removing first note if it is a pause
    if (queue.first?[0].note == ENote.pause) {
      queue.removeFirst();
    }

    while (queue.isNotEmpty) {
      for (int i = 0; i < 10; i++) {
        if (queue.isEmpty) break;

        var current = queue.removeFirst();

        if (current == null) continue; //TODO look if this is the way to go

        for (var note in current) {
          //Delete pause after pause
          if (current[0].note == ENote.pause) {
            if (previewsWasPause) {
              break;
            }
            previewsWasPause = true;
          } else {
            if (previewsWasPause) {
              previewsWasPause = false;
            }
          }

          currentNotes.add(Note(note));
        }
        if (currentNotes.isNotEmpty) notes.add(currentNotes);
        currentNotes = List<Note>.empty(growable: true);
      }
      noteLines.add(NoteLine(notes));
      notes = List<List<Note>>.empty(growable: true);
    }

    return NoteSheet._(sheet.musicSheetName, noteLines, sheet);
  }

  final MusicSheet sheetData;

  final String name;

  final List<NoteLine> lines;

  final controller = PageController(keepPage: false);

  @override
  Widget build(BuildContext context) {

    int pages;

    if(lines.length <= 3) {
      pages = 1;
    }else {
      pages = lines.length ~/ 3;
    }

    List<Column> childrenOfChildren = List.generate(
        pages, (i) {
      List<Widget> children = List.generate(min(3, lines.length - (3 * i)) + 2, (index) {
        if (index == 0) {
          return const Flexible(
            flex: 4,
            child: FittedBox(
              child: Text(
                'Test',
                style: TextStyle(color: Colors.black, fontSize: 60),
              ),
            ),
          );
        }

        if (index > min(3, lines.length - (3 * i))) {
          return const Flexible(
            flex: 1,
            child: FittedBox(child: Text('Generated by STACCATO')),
          );
        }

        return lines[(index + (3 * i)) - 1];
      });

      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      );
    });


    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
      color: Colors.white,
      child: PageView(
          controller: controller,
          children: childrenOfChildren
      ),
    );
  }
}

class NoteLine extends StatelessWidget {
  const NoteLine._(this.noteRows);

  factory NoteLine(List<List<Note>> noteColumnList) {
    var noteColumns = List<Stack>.generate(noteColumnList.length, (index) {
      return Stack(
        children: noteColumnList[index],
      );
    });

    return NoteLine._(noteColumns);
  }

  final List<Stack> noteRows;

  @override
  Widget build(BuildContext context) {
    var stackChildren = List<Widget>.empty(growable: true);

    for (var noteColumn in noteRows) {
      stackChildren.add(noteColumn);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        var noteLinesHeight = constraints.maxWidth / 10;
        var noteHeight = constraints.maxWidth / 2.5;

        return Stack(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(0, noteHeight / 2, 0, 0),
            child: Image.asset(
                'assets/notes/note_clef.png', height: noteLinesHeight),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, noteHeight / 2, 0, 0),
            child: SizedBox(
              height: noteLinesHeight,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: VerticalDivider(
                        indent: constraints.maxHeight / 7,
                        endIndent: constraints.maxHeight / 6,
                        color: Colors.black,
                        width: 0,
                      ),
                    );
                  }),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, noteHeight / 2, 0, 0),
            child: SizedBox(
              height: noteLinesHeight,
              child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: VerticalDivider(
                        indent: constraints.maxHeight / 7,
                        endIndent: constraints.maxHeight / 6,
                        color: Colors.black,
                        width: 0,
                      ),
                    );
                  }),
            ),
          ),
          SizedBox(
            height: noteHeight,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Padding(
                  padding:
                  EdgeInsets.fromLTRB(constraints.maxWidth / 20, 0, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: noteRows,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, noteHeight / 2, 0, 0),
            child: SizedBox(
              height: noteLinesHeight,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Divider(
                    height: 0,
                    color: Colors.transparent,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.black,
                    thickness: 1,
                  ),
                  Divider(
                    height: 0,
                    color: Colors.transparent,
                    thickness: 1,
                  ),
                ],
              ),
            ),
          )
        ]);
      },
    );
  }
}

class Note extends StatelessWidget {
  const Note(this.note, {super.key});

  final MusicNote? note;

  final wholeNote = 'assets/notes/whole-note.png';

  final wholePause = 'assets/notes/whole-pause.png';

  @override
  Widget build(BuildContext context) {
    int position = note!.note.sheetPosition;

    String image;

    if (note?.note == ENote.pause) {
      image = wholePause;
    } else {
      image = wholeNote;
    }

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Padding(
              padding: EdgeInsets.fromLTRB(
                  0, (constraints.maxHeight / 48.3) * position, 0, 0),
              child: Image.asset(
                image,
                height: constraints.maxHeight / 24,
              ));
        });
  }
}
