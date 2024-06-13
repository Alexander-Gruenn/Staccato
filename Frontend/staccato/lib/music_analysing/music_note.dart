import 'package:staccato/music_analysing/music_sheet.dart';

class MusicNote {
  MusicNote(this.note, this.noteType);

  final ENote note;
  final ENoteType noteType;

  MusicNote.fromJson(Map<String, dynamic> json)
      : note = ENote.values[json['note']],
        noteType = ENoteType.values[json['noteType']];

  Map<String, dynamic> toJson() {
    return {
      'note': note.index,
      'noteType': noteType.index
    };
  }
}