import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:staccato/managers/language_manager.dart';
import 'package:staccato/main.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Change language page is being build...');
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.change_language),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          const Gap(10),
          //English
          InkWell(
              onTap: () {
                MyApp.logger.t(
                    'User is trying to change the app language to english...');
                if (LanguageManager.languageManager.languageAsString ==
                    "english") {
                  MyApp.logger.d('Language is already english');
                  return;
                }
                LanguageManager.languageManager
                    .changeAppLanguage(Language.english);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(AppLocalizations.of(context)!.english,
                    style: Theme.of(context).textTheme.displayMedium),
              )),
          const Gap(5),
          //German
          InkWell(
              onTap: () {
                MyApp.logger.t(
                    'User is trying to change the app language to german...');
                if (LanguageManager.languageManager.languageAsString ==
                    "german") {
                  MyApp.logger.d('Language is already German');
                  return;
                }
                LanguageManager.languageManager
                    .changeAppLanguage(Language.german);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(AppLocalizations.of(context)!.german,
                    style: Theme.of(context).textTheme.displayMedium),
              )),
          const Gap(5),
          //Spanish
          InkWell(
              onTap: () {
                MyApp.logger.t(
                    'User is trying to change the app language to spanish...');
                if (LanguageManager.languageManager.languageAsString ==
                    "spanish") {
                  MyApp.logger.d('Language is already Spanish');
                  return;
                }
                LanguageManager.languageManager
                    .changeAppLanguage(Language.spanish);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(AppLocalizations.of(context)!.spanish,
                    style: Theme.of(context).textTheme.displayMedium),
              )),
          const Gap(5),
          //Portuguese
          InkWell(
              onTap: () {
                MyApp.logger.t(
                    'User is trying to change the app language to portuguese...');
                if (LanguageManager.languageManager.languageAsString ==
                    "portuguese") {
                  MyApp.logger.d('Language is already Portuguese');
                  return;
                }
                LanguageManager.languageManager
                    .changeAppLanguage(Language.portuguese);
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(AppLocalizations.of(context)!.portuguese,
                    style: Theme.of(context).textTheme.displayMedium),
              )),
        ],
      ),
    );
  }
}
