

import 'dart:io';
import 'dart:isolate';

import '../fourier_transform/transforms.dart';
import 'music_note.dart';
import 'music_sheet.dart';
import 'dart:math';

import 'note_frequencies.dart';

class ProcessWav {

  late Map<double, List<Tuple<int, double>>> notePosition = {};
  late int recogniselimit;
  late List<double> wavValue;
  late int sampleRate;
  late List<List<double>> wavParts;
  late List<double> outputValue;
  late int windowStepSize;
  late double maxStepsPlayed = 0;

  ProcessWav(List<double> values, int sampleRate, {int recognizelimit = 1200})
      : recogniselimit = recognizelimit {
    Tuple<List<double>, int> signal = getMaxVolume(
        Tuple<List<double>, int>(values, sampleRate));

    wavValue = signal.item1;
    this.sampleRate = signal.item2;
    this.recogniselimit = recognizelimit;

    windowStepSize = (sampleRate ~/ 10) * 3;

    outputValue = List<double>.filled(wavValue.length, 0.0);
  }

  Future startProcess () async {
    wavParts = getParts(wavValue, getWindowSize(sampleRate), windowStepSize);
    await createListNotesPlayedAsync();
    getMaxNoteSteps();
  }

  MusicSheet createMusicSheet() {

    var musicSheetParts = wavValue.length / windowStepSize;

    MusicSheet musicSheet = MusicSheet(musicSheetParts.ceil());

    int lastElement;
    int firstPosition;
    int count;
    int noteLength;

    notePosition.forEach((elementKey, elementValue) {
      elementValue.sort((a,b)=> a.item1.compareTo(b.item1));

      ENoteType type = ENoteType.wholeNote;
      firstPosition = 0;
      lastElement = -1;
      count = 0;
      noteLength = 0;

      for (var pa in elementValue) {
        count++;
        noteLength++;

        if (elementValue.length == 1) {
          addValueMusicSheet(
              musicSheet, pa.item1 ~/ windowStepSize,
              NoteFrequencies.frequencyToNotes[elementKey]!,
              ENoteType.eigthNote);
          noteLength = 0;
          continue;
        }

        if (lastElement == -1) {
          lastElement = pa.item1;
          firstPosition = pa.item1;
          continue;
        }

        if (count == elementValue.length &&
            lastElement + windowStepSize == pa.item1) {
          lastElement = pa.item1;
        } else if (count == elementValue.length) {
          addValueMusicSheet(
              musicSheet, pa.item1 ~/ windowStepSize,
              NoteFrequencies.frequencyToNotes[elementKey]!,
              ENoteType.eigthNote);
          noteLength = 0;
          break;
        }

        if (lastElement + windowStepSize != pa.item1) {
          if (noteLength > (maxStepsPlayed / 2 + maxStepsPlayed / 4)) {
            type = ENoteType.wholeNote;
          } else if (noteLength > (maxStepsPlayed / 4 + maxStepsPlayed / 8)) {
            type = ENoteType.halfNote;
          } else if (noteLength > (maxStepsPlayed / 8 + maxStepsPlayed / 16)) {
            type = ENoteType.quarterNote;
          } else if (noteLength > (maxStepsPlayed / 16 + maxStepsPlayed / 32)) {
            type = ENoteType.eigthNote;
          } else {
            type = ENoteType.sixteenthNote;
          }
          addValueMusicSheet(musicSheet, firstPosition ~/ windowStepSize,
              NoteFrequencies.frequencyToNotes[elementKey]!, type);
          noteLength = 0;
          firstPosition = pa.item1;
        }

        lastElement = pa.item1;
      }
    });

    musicSheet.cutPauses(maxStepsPlayed);
    return musicSheet;
  }

  void getMaxNoteSteps() {
    int count;
    notePosition.forEach((noteKey, noteValue) {
      noteValue.sort((a,b)=> a.item1.compareTo(b.item1));
      count = 1;
      for (int i = 0; i < noteValue.length - 1; i++) {
        if (noteValue[i].item1 == noteValue[i + 1].item1 - windowStepSize) {
          count++;
        } else {
          count = 1;
        }

        if (maxStepsPlayed < count) {
          maxStepsPlayed = count.toDouble();
        }
      }

      if (maxStepsPlayed < count) {
        maxStepsPlayed = count.toDouble();
      }
    });
  }

  void addValueMusicSheet(MusicSheet musicSheet, int position, ENote note,
      ENoteType noteType) {

    if (musicSheet.notes[position] == null) {
      musicSheet.notes[position] = [];
    }

    musicSheet.notes[position]!.add(MusicNote(note, noteType));
  }


  Future createListNotesPlayedAsync() async
  {
    // Create a new Stopwatch
    Stopwatch stopwatch = Stopwatch()..start();

    List<Future> isolates = List<Future>.empty(growable: true);

    //If part length < isolates it does not work
    int partLength = (wavParts.length/Platform.numberOfProcessors).floor(); //Round down

    int start = 0;
    int end = partLength;

    //Schleife geht 1en Durchlauf kürzer, damit danach noch extra ein Isolate gestartet werden kann
    for(int i = 0; i < Platform.numberOfProcessors -1; i++){

      var range = wavParts.getRange(start, end).toList(growable: false);

      isolates.add(startIsolate(range,i,partLength));

      start += partLength;
      end += partLength;
    }

    isolates.add(startIsolate(wavParts.getRange(start, wavParts.length).toList(growable: false),Platform.numberOfProcessors-1,partLength));

    var results = await Future.wait(isolates);

    stopwatch.stop();
    print("Time in s: " + (stopwatch.elapsedMilliseconds/1000).toString());

    for (var result in results){
      for(var rootres in result){
        notePosition.update(rootres.$1, (value) => value..add(Tuple<int, double>(rootres.$2, rootres.$3)),
        ifAbsent: () => [Tuple<int, double>(rootres.$2, rootres.$3)]);
      }
    }
  }

  Future startIsolate(List<List<double>> fftValues, int position, int stepSize){

    return Isolate.run(() async {

      List<(double key, int value, double amplitude)> resultList = List<(double, int, double)>.empty(growable: true);

      for(int i = 0; i < fftValues.length; i++) {

        int currentValue = (position * stepSize + i) * windowStepSize;

        List<double> fftResultsParsed = Transforms.FFT(fftValues[i]);

        var frequencyResolution = sampleRate / (fftResultsParsed.length * 2);

        for (var freq in NoteFrequencies.notesToFrequency.entries) {
          if (checkFrequencies(fftResultsParsed, freq.value, frequencyResolution)) {
            resultList.add((freq.value, currentValue, fftResultsParsed[(freq.value / frequencyResolution).round()]));
          }
        }
      }
      return resultList;
    });
  }

  bool checkFrequencies(List<double> fftResultsParsed, double frequency,
      double frequencyResolution) {

    return fftResultsParsed[(frequency - 2) ~/ frequencyResolution] >
        recogniselimit ||
        fftResultsParsed[(frequency - 1) ~/ frequencyResolution] >
            recogniselimit ||
        fftResultsParsed[(frequency) ~/ frequencyResolution] > recogniselimit ||
        fftResultsParsed[(frequency + 1) ~/ frequencyResolution] >
            recogniselimit ||
        fftResultsParsed[(frequency + 2) ~/ frequencyResolution] >
            recogniselimit;
  }

  void addValueDictionary(Map<double, List<Tuple<int, double>>> notePos,
      double key, int value, double amplitude) {
    if (notePos.containsKey(key)) {
      notePos[key]!.add(Tuple<int, double>(value, amplitude));
    } else {
      notePos[key] = [Tuple<int, double>(value, amplitude)];
    }
  }

  List<List<double>> getParts(List<double> wavValue, int windowSize,
      int windowStepSize) {
    List<List<double>> parts = [];

    int start = 0;
    int end = windowSize;

    while (start < wavValue.length) {
      if (end > wavValue.length) {
        end = wavValue.length - 1;
      }

      parts.add(wavValue.sublist(start, end));

      start += windowStepSize;
      end += windowStepSize;
    }

    return parts;
  }

  Tuple<List<double>, int> getMaxVolume(Tuple<List<double>, int> signal) {
    double minValue = signal.item1.reduce(min).abs();
    double maxValue = signal.item1.reduce(max);

    double largestValue = max(minValue, maxValue);

    double relation = 1 / largestValue;

    for (int i = 0; i < signal.item1.length; i++) {
      signal.item1[i] *= relation;
    }

    return signal;
  }

  int getWindowSize(int sampleRate) {
    var values500ms = sampleRate ~/ 2;

    var exponent = (log(values500ms) / log(2)).ceil();

    return pow(2, exponent).toInt();
  }
}

class Tuple<T1, T2> {
  T1 item1;
  T2 item2;

  Tuple(this.item1, this.item2);
}