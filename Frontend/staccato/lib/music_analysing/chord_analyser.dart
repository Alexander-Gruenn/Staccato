import "music_sheet.dart";
import 'music_note.dart';

enum SimpleMusicNote {
  C,
  Db,
  D,
  Eb,
  E,
  F,
  Gb,
  G,
  Ab,
  A,
  Bb,
  B
}

class ChordAnalyser {
  final MusicSheet sheet;

  ChordAnalyser(this.sheet);

  List<String> getChords() {
    List<String> chords = [];

    for (var notes in sheet.notes) {
      chords.add(getChord(notes!));
    }
    return chords;
  }

  String getChord(List<MusicNote> notes) {
    List<SimpleMusicNote> simpleMusicNotes = [];

    for (var note in notes) {
      if (!simpleMusicNotes.contains(SimpleMusicNote.values[note.note.intIndex % 12]) && note.note != ENote.pause) {
        simpleMusicNotes.add(SimpleMusicNote.values[note.note.intIndex % 12]);
      }
    }

    simpleMusicNotes.sort((a,b) => a.index.compareTo(b.index));
    if (simpleMusicNotes.length == 3) {
      return getTriadChord(simpleMusicNotes);
    }

    if (simpleMusicNotes.length == 4) {
      return getFourChord(simpleMusicNotes);
    }
    return '';
  }

  String getFourChord(List<SimpleMusicNote> simpleMusicNotes) {
    int chordValue1 = (simpleMusicNotes[0].index - simpleMusicNotes[1].index).abs();
    int chordValue2 = (simpleMusicNotes[1].index - simpleMusicNotes[2].index).abs();
    int chordValue3 = (simpleMusicNotes[2].index - simpleMusicNotes[3].index).abs();

    if (chordValue1 == 4 && chordValue2 == 3 && chordValue3 == 4)
      return '${simpleMusicNotes[0]}-maj7 A';
    else if (chordValue1 == 1 && chordValue2 == 4 && chordValue3 == 3)
      return '${simpleMusicNotes[1]}-maj7 B';
    else if (chordValue1 == 4 && chordValue2 == 1 && chordValue3 == 4)
      return '${simpleMusicNotes[2]}-maj7 C';
    else if (chordValue1 == 3 && chordValue2 == 4 && chordValue3 == 1)
      return '${simpleMusicNotes[3]}-maj7 D';

    else if (chordValue1 == 3 && chordValue2 == 4 && chordValue3 == 3)
      return '${simpleMusicNotes[0]}-m7 A';
    else if (chordValue1 == 1 && chordValue2 == 3 && chordValue3 == 4)
      return '${simpleMusicNotes[1]}-m7 B';
    else if (chordValue1 == 3 && chordValue2 == 2 && chordValue3 == 3)
      return '${simpleMusicNotes[2]}-m7 C';
    else if (chordValue1 == 4 && chordValue2 == 3 && chordValue3 == 2)
      return '${simpleMusicNotes[3]}-m7 D';

    else if (chordValue1 == 4 && chordValue2 == 3 && chordValue3 == 3)
      return '${simpleMusicNotes[0]}7 A';
    else if (chordValue1 == 2 && chordValue2 == 4 && chordValue3 == 3)
      return '${simpleMusicNotes[1]}7 B';
    else if (chordValue1 == 3 && chordValue2 == 2 && chordValue3 == 4)
      return '${simpleMusicNotes[2]}7 C';
    else if (chordValue1 == 3 && chordValue2 == 3 && chordValue3 == 2)
      return '${simpleMusicNotes[3]}7 D';

    else if (chordValue1 == 3 && chordValue2 == 3 && chordValue3 == 3)
      return '${simpleMusicNotes[0]}-dim7';

    else if (chordValue1 == 3 && chordValue2 == 3 && chordValue3 == 4)
      return '${simpleMusicNotes[0]}-m7b5 A';
    else if (chordValue1 == 2 && chordValue2 == 3 && chordValue3 == 3)
      return '${simpleMusicNotes[1]}-m7b5 B';
    else if (chordValue1 == 4 && chordValue2 == 2 && chordValue3 == 3)
      return '${simpleMusicNotes[2]}-m7b5 C';
    else if (chordValue1 == 3 && chordValue2 == 4 && chordValue3 == 2)
      return '${simpleMusicNotes[3]}-m7b5 D';

    return '';
  }


  String getTriadChord(List<SimpleMusicNote> simpleMusicNotes) {
    int chordValue1 = (simpleMusicNotes[0].index - simpleMusicNotes[1].index).abs();
    int chordValue2 = (simpleMusicNotes[1].index - simpleMusicNotes[2].index).abs();

    if (chordValue1 == 4 && chordValue2 == 3)
      return '${simpleMusicNotes[0]}-maj A';
    else if (chordValue1 == 5 && chordValue2 == 4)
      return '${simpleMusicNotes[1]}-maj B';
    else if (chordValue1 == 3 && chordValue2 == 5)
      return '${simpleMusicNotes[2]}-maj C';

    else if (chordValue1 == 4 && chordValue2 == 4)
      return '${simpleMusicNotes[0]}-Übermäßig';

    else if (chordValue1 == 3 && chordValue2 == 4)
      return '${simpleMusicNotes[0]}-m A';
    else if (chordValue1 == 4 && chordValue2 == 5)
      return '${simpleMusicNotes[1]}-m B';
    else if (chordValue1 == 5 && chordValue2 == 3)
      return '${simpleMusicNotes[2]}-m C';

    else if (chordValue1 == 3 && chordValue2 == 3)
      return '${simpleMusicNotes[0]}-dim A';
    else if (chordValue1 == 6 && chordValue2 == 3)
      return '${simpleMusicNotes[1]}-dim B';
    else if (chordValue1 == 3 && chordValue2 == 6)
      return '${simpleMusicNotes[2]}-dim C';

    return '';
  }

}
