import 'package:flutter/material.dart';

import '../main.dart';

enum Language {
  english,
  german,
  portuguese,
  spanish
}

class LanguageManager with ChangeNotifier {

  LanguageManager._();
  static final languageManager = LanguageManager._();

  //TODO save users preferred language
  var _language = Language.english;

  Locale get languageAsLocal {
    switch(_language) {
      case Language.english:
        MyApp.logger.t('Changing language to english...');
        return const Locale('en');
      case Language.german:
        MyApp.logger.t('Changing language to german...');
        return const Locale('de');
      case Language.portuguese:
        MyApp.logger.t('Changing language to portuguese...');
        return const Locale('pt');
      case Language.spanish:
        MyApp.logger.t('Changing language to spanish...');
        return const Locale('es');
    }
  }

  String get languageAsString => _language.name;


  void changeAppLanguage(Language language) {
    _language = language;
    notifyListeners();
  }

}