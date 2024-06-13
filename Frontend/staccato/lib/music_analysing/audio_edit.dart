import 'dart:io';

import 'package:staccato/music_analysing/process_wav.dart';
import 'package:wav/wav.dart';
import 'dart:math';

class AudioEdit {
  static Tuple<List<double>, int> readWavFile(String filePath) {
    var file = File(filePath).readAsBytesSync();

    final wav = Wav.read(file);

    final sampleRate = wav.samplesPerSecond;

    var mono = wav.toMono();

    return Tuple(mono, sampleRate);
  }

  //static Tuple<List<double>, int> getMaxVolume(Tuple<List<double>, int> signal)  {
  //  double maxValue = signal.item1.reduce(max);
  //  double minValue = signal.item1.reduce(min).abs();
  //
  //  double largestValue = max(minValue, maxValue);
  //
  //  double relation = 1 / largestValue;
  //
  //  signal.item1 = signal.item1.map((value) => value * relation).toList();
  //  return signal;
  //}
}
