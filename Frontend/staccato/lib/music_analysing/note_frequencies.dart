import 'music_sheet.dart';

class NoteFrequencies {
  // Octave 0
  static const double NOTE_FREQUENCY_A0 = 27.5;

  static const double NOTE_FREQUENCY_Hb0 = 29.1352;
  static const double NOTE_FREQUENCY_H0 = 30.8677;

  // Octave 1
  static const double NOTE_FREQUENCY_C1 = 32.7032;

  static const double NOTE_FREQUENCY_Db1 = 34.6478;
  static const double NOTE_FREQUENCY_D1 = 36.7081;

  static const double NOTE_FREQUENCY_Eb1 = 38.8909;
  static const double NOTE_FREQUENCY_E1 = 41.2034;

  static const double NOTE_FREQUENCY_F1 = 43.6535;

  static const double NOTE_FREQUENCY_Gb1 = 46.2493;
  static const double NOTE_FREQUENCY_G1 = 48.9994;

  static const double NOTE_FREQUENCY_Ab1 = 51.9131;
  static const double NOTE_FREQUENCY_A1 = 55;

  static const double NOTE_FREQUENCY_Hb1 = 58.2705;
  static const double NOTE_FREQUENCY_H1 = 61.7354;

  // Octave 2
  static const double NOTE_FREQUENCY_C2 = 65.4064;

  static const double NOTE_FREQUENCY_Db2 = 69.2957;
  static const double NOTE_FREQUENCY_D2 = 73.4162;

  static const double NOTE_FREQUENCY_Eb2 = 77.7817;
  static const double NOTE_FREQUENCY_E2 = 82.4069;

  static const double NOTE_FREQUENCY_F2 = 87.3071;

  static const double NOTE_FREQUENCY_Gb2 = 92.4986;
  static const double NOTE_FREQUENCY_G2 = 97.9989;

  static const double NOTE_FREQUENCY_Ab2 = 103.826;
  static const double NOTE_FREQUENCY_A2 = 110;

  static const double NOTE_FREQUENCY_Hb2 = 116.541;
  static const double NOTE_FREQUENCY_H2 = 123.471;

  // Octave 3
  static const double NOTE_FREQUENCY_C3 = 130.813;

  static const double NOTE_FREQUENCY_Db3 = 138.591;
  static const double NOTE_FREQUENCY_D3 = 146.832;

  static const double NOTE_FREQUENCY_Eb3 = 155.563;
  static const double NOTE_FREQUENCY_E3 = 164.814;

  static const double NOTE_FREQUENCY_F3 = 174.614;

  static const double NOTE_FREQUENCY_Gb3 = 184.997;
  static const double NOTE_FREQUENCY_G3 = 195.998;

  static const double NOTE_FREQUENCY_Ab3 = 207.652;
  static const double NOTE_FREQUENCY_A3 = 220;

  static const double NOTE_FREQUENCY_Hb3 = 233.082;
  static const double NOTE_FREQUENCY_H3 = 246.942;

  // Octave 4
  static const double NOTE_FREQUENCY_C4 = 261.626;

  static const double NOTE_FREQUENCY_Db4 = 277.183;
  static const double NOTE_FREQUENCY_D4 = 293.665;

  static const double NOTE_FREQUENCY_Eb4 = 311.127;
  static const double NOTE_FREQUENCY_E4 = 329.628;

  static const double NOTE_FREQUENCY_F4 = 349.228;

  static const double NOTE_FREQUENCY_Gb4 = 369.994;
  static const double NOTE_FREQUENCY_G4 = 391.995;

  static const double NOTE_FREQUENCY_Ab4 = 415.305;
  static const double NOTE_FREQUENCY_A4 = 440;

  static const double NOTE_FREQUENCY_Hb4 = 466.164;
  static const double NOTE_FREQUENCY_H4 = 493.883;

  // Octave 5
  static const double NOTE_FREQUENCY_C5 = 523.251;

  static const double NOTE_FREQUENCY_Db5 = 554.365;
  static const double NOTE_FREQUENCY_D5 = 587.33;

  static const double NOTE_FREQUENCY_Eb5 = 622.254;
  static const double NOTE_FREQUENCY_E5 = 659.255;

  static const double NOTE_FREQUENCY_F5 = 698.456;

  static const double NOTE_FREQUENCY_Gb5 = 739.989;
  static const double NOTE_FREQUENCY_G5 = 783.991;

  static const double NOTE_FREQUENCY_Ab5 = 830.609;
  static const double NOTE_FREQUENCY_A5 = 880;

  static const double NOTE_FREQUENCY_Hb5 = 932.328;
  static const double NOTE_FREQUENCY_H5 = 987.767;

  // Octave 6
  static const double NOTE_FREQUENCY_C6 = 1046.5;

  static const double NOTE_FREQUENCY_Db6 = 1108.73;
  static const double NOTE_FREQUENCY_D6 = 1174.66;

  static const double NOTE_FREQUENCY_Eb6 = 1244.51;
  static const double NOTE_FREQUENCY_E6 = 1318.51;

  static const double NOTE_FREQUENCY_F6 = 1396.91;

  static const double NOTE_FREQUENCY_Gb6 = 1479.98;
  static const double NOTE_FREQUENCY_G6 = 1567.98;

  static const double NOTE_FREQUENCY_Ab6 = 1661.22;
  static const double NOTE_FREQUENCY_A6 = 1760;

  static const double NOTE_FREQUENCY_Hb6 = 1864.66;
  static const double NOTE_FREQUENCY_H6 = 1975.53;

  // Octave 7
  static const double NOTE_FREQUENCY_C7 = 2093;

  static const double NOTE_FREQUENCY_Db7 = 2217.46;
  static const double NOTE_FREQUENCY_D7 = 2349.32;

  static const double NOTE_FREQUENCY_Eb7 = 2489.02;
  static const double NOTE_FREQUENCY_E7 = 2637.02;

  static const double NOTE_FREQUENCY_F7 = 2793.83;

  static const double NOTE_FREQUENCY_Gb7 = 2959.96;
  static const double NOTE_FREQUENCY_G7 = 3135.96;

  static const double NOTE_FREQUENCY_Ab7 = 3322.44;
  static const double NOTE_FREQUENCY_A7 = 3520;

  static const double NOTE_FREQUENCY_Hb7 = 3729.31;
  static const double NOTE_FREQUENCY_H7 = 3951.07;

  // Octave 8
  static const double NOTE_FREQUENCY_C8 = 4186.01;

  static final Map<ENote, double> notesToFrequency = {
    ENote.a0: NOTE_FREQUENCY_A0,
    ENote.hb0: NOTE_FREQUENCY_Hb0,
    ENote.h0: NOTE_FREQUENCY_H0,
    // Octave 1
    ENote.c1: NOTE_FREQUENCY_C1,
    ENote.db1: NOTE_FREQUENCY_Db1,
    ENote.d1: NOTE_FREQUENCY_D1,
    ENote.eb1: NOTE_FREQUENCY_Eb1,
    ENote.e1: NOTE_FREQUENCY_E1,
    ENote.f1: NOTE_FREQUENCY_F1,
    ENote.gb1: NOTE_FREQUENCY_Gb1,
    ENote.g1: NOTE_FREQUENCY_G1,
    ENote.ab1: NOTE_FREQUENCY_Ab1,
    ENote.a1: NOTE_FREQUENCY_A1,
    ENote.bb1: NOTE_FREQUENCY_Hb1,
    ENote.b1: NOTE_FREQUENCY_H1,
    // Octave 2
    ENote.c2: NOTE_FREQUENCY_C2,
    ENote.db2: NOTE_FREQUENCY_Db2,
    ENote.d2: NOTE_FREQUENCY_D2,
    ENote.eb2: NOTE_FREQUENCY_Eb2,
    ENote.e2: NOTE_FREQUENCY_E2,
    ENote.f2: NOTE_FREQUENCY_F2,
    ENote.gb2: NOTE_FREQUENCY_Gb2,
    ENote.g2: NOTE_FREQUENCY_G2,
    ENote.ab2: NOTE_FREQUENCY_Ab2,
    ENote.a2: NOTE_FREQUENCY_A2,
    ENote.bb2: NOTE_FREQUENCY_Hb2,
    ENote.b2: NOTE_FREQUENCY_H2,
    // Octave 3
    ENote.c3: NOTE_FREQUENCY_C3,
    ENote.db3: NOTE_FREQUENCY_Db3,
    ENote.d3: NOTE_FREQUENCY_D3,
    ENote.eb3: NOTE_FREQUENCY_Eb3,
    ENote.e3: NOTE_FREQUENCY_E3,
    ENote.f3: NOTE_FREQUENCY_F3,
    ENote.gb3: NOTE_FREQUENCY_Gb3,
    ENote.g3: NOTE_FREQUENCY_G3,
    ENote.ab3: NOTE_FREQUENCY_Ab3,
    ENote.a3: NOTE_FREQUENCY_A3,
    ENote.bb3: NOTE_FREQUENCY_Hb3,
    ENote.b3: NOTE_FREQUENCY_H3,
    // Octave 4
    ENote.c4: NOTE_FREQUENCY_C4,
    ENote.db4: NOTE_FREQUENCY_Db4,
    ENote.d4: NOTE_FREQUENCY_D4,
    ENote.eb4: NOTE_FREQUENCY_Eb4,
    ENote.e4: NOTE_FREQUENCY_E4,
    ENote.f4: NOTE_FREQUENCY_F4,
    ENote.gb4: NOTE_FREQUENCY_Gb4,
    ENote.g4: NOTE_FREQUENCY_G4,
    ENote.ab4: NOTE_FREQUENCY_Ab4,
    ENote.a4: NOTE_FREQUENCY_A4,
    ENote.bb4: NOTE_FREQUENCY_Hb4,
    ENote.b4: NOTE_FREQUENCY_H4,
    // Octave 5
    ENote.c5: NOTE_FREQUENCY_C5,
    ENote.db5: NOTE_FREQUENCY_Db5,
    ENote.d5: NOTE_FREQUENCY_D5,
    ENote.eb5: NOTE_FREQUENCY_Eb5,
    ENote.e5: NOTE_FREQUENCY_E5,
    ENote.f5: NOTE_FREQUENCY_F5,
    ENote.gb5: NOTE_FREQUENCY_Gb5,
    ENote.g5: NOTE_FREQUENCY_G5,
    ENote.ab5: NOTE_FREQUENCY_Ab5,
    ENote.a5: NOTE_FREQUENCY_A5,
    ENote.bb5: NOTE_FREQUENCY_Hb5,
    ENote.b5: NOTE_FREQUENCY_H5,
    // Octve 6
    ENote.c6: NOTE_FREQUENCY_C6,
    ENote.db6: NOTE_FREQUENCY_Db6,
    ENote.d6: NOTE_FREQUENCY_D6,
    ENote.eb6: NOTE_FREQUENCY_Eb6,
    ENote.e6: NOTE_FREQUENCY_E6,
    ENote.f6: NOTE_FREQUENCY_F6,
    ENote.gb6: NOTE_FREQUENCY_Gb6,
    ENote.g6: NOTE_FREQUENCY_G6,
    ENote.ab6: NOTE_FREQUENCY_Ab6,
    ENote.a6: NOTE_FREQUENCY_A6,
    ENote.bb6: NOTE_FREQUENCY_Hb6,
    ENote.b6: NOTE_FREQUENCY_H6,
    // Octave 7
    ENote.c7: NOTE_FREQUENCY_C7,
    ENote.db7: NOTE_FREQUENCY_Db7,
    ENote.d7: NOTE_FREQUENCY_D7,
    ENote.eb7: NOTE_FREQUENCY_Eb7,
    ENote.e7: NOTE_FREQUENCY_E7,
    ENote.f7: NOTE_FREQUENCY_F7,
    ENote.gb7: NOTE_FREQUENCY_Gb7,
    ENote.g7: NOTE_FREQUENCY_G7,
    ENote.ab7: NOTE_FREQUENCY_Ab7,
    ENote.a7: NOTE_FREQUENCY_A7,
    ENote.bb7: NOTE_FREQUENCY_Hb7,
    ENote.b7: NOTE_FREQUENCY_H7,
    // Octave 8
    ENote.c8: NOTE_FREQUENCY_C8
  };

  static final Map<double, ENote> frequencyToNotes =
  notesToFrequency.map((key, value) => MapEntry(value, key));
}