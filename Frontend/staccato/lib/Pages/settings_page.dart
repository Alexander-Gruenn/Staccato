import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:staccato/Pages/change_language_page.dart';
import 'package:staccato/managers/theme_manager.dart';
import 'package:staccato/main.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var themeIcon = Icons.sunny;

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Settings page is being build...');
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings_page_title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          const Gap(10),
          InkWell(
              onTap: () {
                MyApp.logger.t('User is trying to change the app theme...');
                var themeManager = ThemeManager.themeManager;
                themeManager.changeThemeToDarkMode(themeManager.isLightMode);
                setState(() {
                  if (themeManager.isLightMode) {
                    MyApp.logger.d('App Theme has been changed to light mode');
                    themeIcon = Icons.sunny;
                    return;
                  }
                  MyApp.logger.d('App Theme has been changed to dark mode');
                  themeIcon = Icons.nightlight;
                });
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    Text(AppLocalizations.of(context)!.change_theme_button,
                        style: Theme.of(context).textTheme.displayMedium),
                    const MaxGap(50000),
                    Icon(themeIcon),
                  ],
                ),
              )),
          const Gap(5),
          InkWell(
              onTap: () {
                MyApp.logger.t('User is trying to change the app language');
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const ChangeLanguagePage()));
              },
              borderRadius: BorderRadius.circular(15),
              child: Ink(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15)),
                child: Text(AppLocalizations.of(context)!.change_language,
                    style: Theme.of(context).textTheme.displayMedium),
              )),
        ],
      ),
    );
  }
}
