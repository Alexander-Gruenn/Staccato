import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/ChangePages/change_page_interface.dart';
import 'package:staccato/managers/change_page_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

import '../../main.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<StatefulWidget> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    implements IChangeState {
  final passwordRegEx =
      RegExp(r"^(?=\S*[a-z])(?=\S*[A-Z])(?=\S*[\W_])(?=\S*[0-9])\S{8,40}$");

  @override
  var errorText = "";

  @override
  VoidCallback? onPressed;

  @override
  set activateButton(bool setActive) {
    if (setActive) {
      MyApp.logger.t('Activating button...');
      onPressed = () async {
        var dataHasChanged = await User.getCurrentlyLoggedInUser?.changeData(
            currentPwController.value.text,
            newPassword: newPwController.value.text);

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

  final currentPwController = TextEditingController();
  final newPwController = TextEditingController();
  final confirmNewPwController = TextEditingController();

  @override
  void onChange() {
    MyApp.logger.t('Changing error text...');
    var currentPwLength = currentPwController.value.text.length;
    var newPwLength = newPwController.value.text.length;
    var confirmPwLength = confirmNewPwController.value.text.length;

    //Check if error should be displayed
    if (newPwLength == 0) {
      setState(() {
        errorText = "";
      });
      if (buttonIsActive) {
        setState(() {
          activateButton = false;
        });
      }
      return;
    }

    if (newPwController.value.text != confirmNewPwController.value.text) {
      setState(() {
        errorText = AppLocalizations.of(context)!.passwords_do_not_match_error;
      });
      if (buttonIsActive) {
        setState(() {
          activateButton = false;
        });
      }
      return;
    }

    if (!passwordRegEx.hasMatch(newPwController.value.text)) {
      setState(() {
        errorText = AppLocalizations.of(context)!.not_valid_password_error;
      });
      if (buttonIsActive) {
        setState(() {
          activateButton = false;
        });
      }
      return;
    }

    errorText = '';

    //Check if button should be active
    if (currentPwLength == 0 || newPwLength == 0 || confirmPwLength == 0) {
      if (buttonIsActive) {
        setState(() {
          activateButton = false;
        });
      }
    } else {
      if (!buttonIsActive) {
        setState(() {
          activateButton = true;
        });
      }
    }
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
          controller: currentPwController,
        ),
        CupertinoTextField(
          style: Theme.of(context).textTheme.labelMedium,
          placeholder: AppLocalizations.of(context)!.new_password_placeholder,
          clearButtonMode: OverlayVisibilityMode.editing,
          controller: newPwController,
        ),
        CupertinoTextField(
          style: Theme.of(context).textTheme.labelMedium,
          placeholder:
              AppLocalizations.of(context)!.confirm_new_password_placeholder,
          clearButtonMode: OverlayVisibilityMode.editing,
          controller: confirmNewPwController,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Building password change site...');

    var site =
        ChangePageManager.createPage(textFields, onPressed, errorText, context);

    currentPwController.addListener(onChange);
    newPwController.addListener(onChange);
    confirmNewPwController.addListener(onChange);

    return Scaffold(
        appBar:
            AppBar(title: Text(AppLocalizations.of(context)!.change_password)),
        body: site);
  }
}
