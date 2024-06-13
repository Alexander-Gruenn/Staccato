import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:staccato/main.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

abstract class ChangePageManager {
  static Widget createChangeButton(
      VoidCallback? onPressed, BuildContext context) {
    MyApp.logger.t('Creating change button...');
    return ElevatedButton(
        onPressed: onPressed,
        child: Text(AppLocalizations.of(context)!.change_button));
  }

  static Widget createPage(List<CupertinoTextField> textFields,
      VoidCallback? onPressed, String errorText, BuildContext context) {
    MyApp.logger.t('Creating change page...');
    var title = FittedBox(
      child: Text(
        'Staccato',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
    var widgets = <Widget>[title];

    MyApp.logger.t('Adding ${textFields.length} audios');
    for (var textField in textFields) {
      widgets.add(textField);
      widgets.add(const Gap(10));
    }

    widgets.add(Text(errorText,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: Theme.of(context).colorScheme.error)));
    widgets.add(createChangeButton(onPressed, context));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widgets,
          ),
        ),
      ),
    );
  }
}
