

import 'package:staccato/main.dart';
import 'package:staccato/music_analysing/music_note.dart';

enum ENote {
  pause,
  //Octave 0
  a0, //58 1
  hb0, //57 2
  h0, //57 3

  //Octave 1
  c1, //56 4
  db1, //55 5
  d1, //55 6
  eb1, //54 7
  e1, //54 8
  f1, //53 9
  gb1, //52 10
  g1, //52 11
  ab1, //51 12
  a1, //51 13
  bb1, //50 14
  b1, //50 15

  //Octave 2
  c2, //49 16
  db2, //48 17
  d2, //48 18
  eb2, //47 19
  e2, //47 20
  f2, //46 21
  gb2, //45 22
  g2, //45 23
  ab2, //44 24
  a2, //44 25
  bb2, //43 26
  b2, //43 27

  //Octave 3:

  c3, //42 28
  db3, //41 29
  d3, //41 30
  eb3, //40 31
  e3,//40 32
  f3, //39 33
  gb3, //38 34
  g3, //38 35
  ab3, //37 36
  a3, //37 37
  bb3, //36 38
  b3, //36 39

  //Octave 4:

  c4, // 35 40
  db4, //34 41
  d4, //34 42
  eb4, //33 43
  e4, //33 44
  f4, //32 45
  gb4, //31 46
  g4, //31 47
  ab4, //30 48
  a4, //30 49
  bb4, //29 50
  b4, //29 51

  //Octave 5:
  c5, //28 52
  db5, //27 53
  d5, //27 54
  eb5, //26 55
  e5, //26 56
  f5, //25 57
  gb5, //24 58
  g5, //24 59
  ab5, //23 60
  a5, //23 61
  bb5, //22 62
  b5, //22 63

  //Octave 6:
  c6, //21 64
  db6, //20 65
  d6, //20 66
  eb6, //19 67
  e6, //19 68
  f6, //18 69
  gb6, //17 70
  g6, //17 71
  ab6, //16 72
  a6, //16 73
  bb6, //15 74
  b6, //15 75

  //Octave 7:
  c7, //14 76
  db7, //13 77
  d7, //13 78
  eb7, //12 79
  e7, //12 80
  f7, //11 81
  gb7, //10 82
  g7, //10 83
  ab7, //9 84
  a7, //9 85
  bb7, //8 86
  b7, //8 87

  //Octave 8:
  c8; //7 88

  int get intIndex => index - 4;
  int get sheetPosition {
    if(index == 0) return 29;

    int highestNote = 58;

    switch(index) {
      case 1:
        return 58;
      case 2:
        return 57;
      case 3:
        return 57;
      case 4:
        return 56;
      case 5:
        return 55;
      case 6:
        return 55;
      case 7:
        return 54;
      case 8:
        return 54;
      case 9:
        return 53;
      case 10:
        return 52;
      case 11:
        return 52;
      case 12:
        return 51;
      case 13:
        return 51;
      case 14:
        return 50;
      case 15:
        return 50;
      case 16:
        return 49;
      case 17:
        return 48;
      case 18:
        return 48;
      case 19:
        return 47;
      case 20:
        return 47;
      case 21:
        return 46;
      case 22:
        return 45;
      case 23:
        return 45;
      case 24:
        return 44;
      case 25:
        return 44;
      case 26:
        return 43;
      case 27:
        return 43;
      case 28:
        return 42;
      case 29:
        return 41;
      case 30:
        return 41;
      case 31:
        return 40;
      case 32:
        return 40;
      case 33:
        return 39;
      case 34:
        return 38;
      case 35:
        return 38;
      case 36:
        return 37;
      case 37:
        return 37;
      case 38:
        return 36;
      case 39:
        return 36;
      case 40:
        return 35;
      case 41:
        return 34;
      case 42:
        return 34;
      case 43:
        return 33;
      case 44:
        return 33;
      case 45:
        return 32;
      case 46:
        return 31;
      case 47:
        return 31;
      case 48:
        return 30;
      case 49:
        return 30;
      case 50:
        return 29;
      case 51:
        return 29;
      case 52:
        return 28;
      case 53:
        return 27;
      case 54:
        return 27;
      case 55:
        return 26;
      case 56:
        return 26;
      case 57:
        return 25;
      case 58:
        return 24;
      case 59:
        return 24;
      case 60:
        return 23;
      case 61:
        return 23;
      case 62:
        return 22;
      case 63:
        return 22;
      case 64:
        return 21;
      case 65:
        return 20;
      case 66:
        return 20;
      case 67:
        return 19;
      case 68:
        return 19;
      case 69:
        return 18;
      case 70:
        return 17;
      case 71:
        return 17;
      case 72:
        return 16;
      case 73:
        return 16;
      case 74:
        return 15;
      case 75:
        return 15;
      case 76:
        return 14;
      case 77:
        return 13;
      case 78:
        return 13;
      case 79:
        return 12;
      case 80:
        return 12;
      case 81:
        return 11;
      case 82:
        return 10;
      case 83:
        return 10;
      case 84:
        return 9;
      case 85:
        return 9;
      case 86:
        return 8;
      case 87:
        return 8;
      case 88:
        return 7;
      case 89:
        return 7;
      case 90:
        return 6;
    }

    if(index == 1) return 35;
    if(index == 2) return 34;
    if(index == 3) return 33;

    if(index < 9) {
      return highestNote - (index - (index ~/ 2));
    } else if(index < 16) {
      return highestNote - (index - (index ~/ 2) - 0.5).toInt();
    } else if(index < 21) {
      return highestNote - (index - (index ~/ 2) - 1);
    }else if(index < 28) {
      return highestNote - (index - (index ~/ 2) - 1.5).toInt();
    }else if(index < 33) {
      return highestNote - (index - (index ~/ 2) - 2);
    }else if(index < 40) {
      return highestNote - (index - (index ~/ 2) - 2.5).toInt();
    }else if(index < 45) {
      return highestNote - (index - (index ~/ 2) - 3);
    }else if(index < 52) {
      return highestNote - (index - (index ~/ 2) - 3.5).toInt();
    }else if(index < 57) {
      return highestNote - (index - (index ~/ 2) - 4);
    }else if(index < 64) {
      return highestNote - (index - (index ~/ 2) - 4.5).toInt();
    }else if(index < 69) {
      return highestNote - (index - (index ~/ 2) - 5);
    }else if(index < 76) {
      return highestNote - (index - (index ~/ 2) - 5.5).toInt();
    }else if(index < 81) {
      return highestNote - (index - (index ~/ 2) - 6);
    }else if(index < 88) {
      return highestNote - (index - (index ~/ 2) - 6.5).toInt();
    }else {
      return highestNote - (index - (index ~/ 2) - 7);
    }
  }
}

enum ENoteType {
  wholeNote,
  halfNote,
  quarterNote,
  eigthNote,
  sixteenthNote,
  wholePause,
  halfPause,
  quarterPause,
  eigthPause,
  sixteenthPause
}

class MusicSheet {
  MusicSheet(int musicSheetParts) {
    notes = List<List<MusicNote>?>.filled(musicSheetParts, null);
  }

  String musicSheetName = "";
  late List<List<MusicNote>?> notes;

  void cutPauses(double wholeNoteLength) {
    MyApp.logger.t('Started cutting pauses!');
    List<List<MusicNote>> newNotesWithPauses =
        List<List<MusicNote>>.empty(growable: true);

    double count = 0.0;
    for (var note in notes) {
      if (note == null) {
        MyApp.logger.t('Pause found');
        count++;
      } else {
        MyApp.logger.t('Notes found');
        if (count != 0) {
          addNoteWithMuchValue(wholeNoteLength, newNotesWithPauses, count);

          count = 0;
        }

        newNotesWithPauses.add(note);
      }
    }
    addNoteWithMuchValue(wholeNoteLength, newNotesWithPauses, count);

    notes = newNotesWithPauses;
  }

  void addNoteWithMuchValue(double wholeNoteLength,
      List<List<MusicNote>?> newNotesWithPauses, double count) {
    for (double i = wholeNoteLength; i < count; i += wholeNoteLength) {
      newNotesWithPauses.add(List<MusicNote>.filled(
          1, MusicNote(ENote.pause, ENoteType.wholePause)));
    }

    if (count > 0) {
      newNotesWithPauses.add(List<MusicNote>.filled(
          1, MusicNote(ENote.pause, _getPauseLength(count, wholeNoteLength))));
    }
  }

  ENoteType _getPauseLength(double length, double wholeLength) {
    if (length > (wholeLength / 2 + wholeLength / 4)) {
      return ENoteType.wholePause;
    } else if (length > (wholeLength / 4 + wholeLength / 8)) {
      return ENoteType.halfPause;
    } else if (length > (wholeLength / 8 + wholeLength / 16)) {
      return ENoteType.quarterPause;
    } else if (length > (wholeLength / 16 + wholeLength / 32)) {
      return ENoteType.eigthPause;
    } else {
      return ENoteType.sixteenthPause;
    }
  }
}
