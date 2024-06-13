import 'package:flutter/material.dart';
import 'package:flutter/src/cupertino/text_field.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/ChangePages/change_page_interface.dart';
import 'package:staccato/managers/change_page_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../main.dart';

class ChangeUsernamePage extends StatefulWidget {
  const ChangeUsernamePage({super.key});

  @override
  State<ChangeUsernamePage> createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage>
    implements IChangeState {
  @override
  String errorText = '';

  @override
  VoidCallback? onPressed;

  @override
  set activateButton(bool setActive) {
    if (setActive) {
      MyApp.logger.t('Activating button...');
      onPressed = () async {
        var dataHasChanged = await User.getCurrentlyLoggedInUser?.changeData(
            currentPasswordController.value.text,
            newUsername: newUsernameController.value.text);

        if (dataHasChanged == true) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      };
    } else {
      MyApp.logger.t('Deactivating button...');
      onPressed = null;
    }
  }

  @override
  bool get buttonIsActive => onPressed != null;

  var currentPasswordController = TextEditingController();
  var newUsernameController = TextEditingController();

  final usernameRegEx = RegExp(r"^.{4,50}$");

  @override
  void onChange() {
    MyApp.logger.t('Changing error text...');
    var currentPasswordLength = currentPasswordController.value.text.length;
    var newEmailLength = newUsernameController.value.text.length;

    //Check if button should be active
    if (currentPasswordLength == 0 || newEmailLength == 0) {
      setState(() {
        if (buttonIsActive) activateButton = false;
        errorText = '';
      });
      return;
    }

    if (!usernameRegEx.hasMatch(newUsernameController.value.text)) {
      setState(() {
        if (buttonIsActive) activateButton = false;
        errorText = AppLocalizations.of(context)!.username_to_short_error;
      });
      return;
    }

    setState(() {
      if (!buttonIsActive) activateButton = true;
      errorText = '';
    });
    MyApp.logger.t('Error message changed to "$errorText"');
  }

  @override
  List<CupertinoTextField> get textFields => [
        CupertinoTextField(
          autofocus: true,
          style: Theme.of(context).textTheme.labelMedium,
          placeholder:
              AppLocalizations.of(context)!.current_password_placeholder,
          clearButtonMode: OverlayVisibilityMode.editing,
          controller: currentPasswordController,
        ),
        CupertinoTextField(
          style: Theme.of(context).textTheme.labelMedium,
          placeholder: AppLocalizations.of(context)!.new_username_placeholder,
          clearButtonMode: OverlayVisibilityMode.editing,
          controller: newUsernameController,
        )
      ];

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Building username change site...');

    currentPasswordController.addListener(onChange);
    newUsernameController.addListener(onChange);

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.change_username)),
      body: ChangePageManager.createPage(
          textFields, onPressed, errorText, context),
    );
  }
}
