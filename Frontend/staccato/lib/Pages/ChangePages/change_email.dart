import 'package:flutter/material.dart';
import 'package:flutter/src/cupertino/text_field.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/ChangePages/change_page_interface.dart';
import 'package:staccato/managers/change_page_manager.dart';
import 'package:staccato/main.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class ChangeEmailPage extends StatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage>
    implements IChangeState {
  @override
  String errorText = "";

  @override
  VoidCallback? onPressed;

  @override
  set activateButton(bool setActive) {
    if (setActive) {
      MyApp.logger.t('Activating button...');
      onPressed = () async {
        var dataHasChanged = await User.getCurrentlyLoggedInUser?.changeData(
            currentPasswordController.value.text,
            newEMail: newEmailController.value.text);

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

  final _emailRegEx =
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", caseSensitive: false);

  @override
  void onChange() {
    MyApp.logger.t('Changing error text...');
    var currentPasswordLength = currentPasswordController.value.text.length;
    var newEmailLength = newEmailController.value.text.length;

    if (!_emailRegEx.hasMatch(newEmailController.value.text)) {
      setState(() {
        errorText = AppLocalizations.of(context)!.not_valid_email_address_error;
        if (buttonIsActive) activateButton = false;
      });
      return;
    }

    setState(() {
      errorText = "";
    });

    //Check if button should be active
    if (currentPasswordLength == 0 || newEmailLength == 0) {
      setState(() {
        if (buttonIsActive) activateButton = false;
      });
      return;
    }

    setState(() {
      if (!buttonIsActive) activateButton = true;
    });

    MyApp.logger.t('Error message changed to "$errorText"');
  }

  var currentPasswordController = TextEditingController();
  var newEmailController = TextEditingController();

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
          placeholder: AppLocalizations.of(context)!.new_email_placeholder,
          clearButtonMode: OverlayVisibilityMode.editing,
          controller: newEmailController,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Building email change site...');

    var site =
        ChangePageManager.createPage(textFields, onPressed, errorText, context);

    currentPasswordController.addListener(onChange);
    newEmailController.addListener(onChange);

    return Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.change_email)),
        body: site);
  }
}
