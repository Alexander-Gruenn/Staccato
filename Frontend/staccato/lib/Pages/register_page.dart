import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:gap/gap.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/login_page.dart';
import 'package:staccato/main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String username = '';
  String eMail = '';
  String password = '';
  String confirmationPassword = '';

  bool get _everythingIsFilledOutCorrectly =>
      username.isNotEmpty &&
      eMail.isNotEmpty &&
      password.isNotEmpty &&
      confirmationPassword.isNotEmpty &&
      _passwordsMatch &&
      _isEmail &&
      _passwordMatchesRequirements;

  bool get _usernameMatchesRequirements => usernameRegEx.hasMatch(username);

  bool get _passwordsMatch => password == confirmationPassword;

  bool get _isEmail => _emailRegEx.hasMatch(eMail);

  bool get _passwordMatchesRequirements => passwordRegEx.hasMatch(password);

  String errorText = "";

  final usernameRegEx = RegExp(r"^.{4,50}$");
  final _usernameFocusNode = FocusNode();
  final _confirmationPasswordFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final passwordRegEx =
      RegExp(r"^(?=\S*[a-z])(?=\S*[A-Z])(?=\S*[\W_])(?=\S*[0-9])\S{8,40}$");
  final _emailFocusNode = FocusNode();
  final _emailRegEx =
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$", caseSensitive: false);

  VoidCallback? registerFunction;

  bool get buttonIsActive => registerFunction != null;

  set buttonIsActive(bool buttonActivation) {
    if (buttonActivation) {
      MyApp.logger.d('Register button has been activated');
      registerFunction =
          () => User.sendCode(username, password, eMail, context);
      return;
    }

    MyApp.logger.d('Register button has been deactivated');
    registerFunction = null;
  }

  @override
  void initState() {
    MyApp.logger.t('Register page is being initialized...');
    _usernameFocusNode.addListener(createErrorMessage);
    _passwordFocusNode.addListener(createErrorMessage);
    _confirmationPasswordFocusNode.addListener(createErrorMessage);
    _emailFocusNode.addListener(createErrorMessage);
    super.initState();
  }

  @override
  void dispose() {
    MyApp.logger.t('Register page is being disposed...');
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmationPasswordFocusNode.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void createErrorMessage() {
    MyApp.logger.t('Error message is changing...');
    setState(() {
      if (username.isNotEmpty) {
        if (!_usernameMatchesRequirements) {
          errorText = AppLocalizations.of(context)!.username_to_short_error;
          return;
        }
      }
      if (eMail.isNotEmpty) {
        if (!_isEmail) {
          errorText =
              AppLocalizations.of(context)!.not_valid_email_address_error;
          return;
        }
      }
      if (password.isNotEmpty) {
        if (!_passwordMatchesRequirements) {
          errorText = AppLocalizations.of(context)!.not_valid_password_error;
          return;
        }
      }
      if (confirmationPassword.isNotEmpty) {
        if (!_passwordsMatch) {
          errorText =
              AppLocalizations.of(context)!.passwords_do_not_match_error;
          return;
        }
      }
      errorText = "";
    });
    MyApp.logger.d('Error message has changed to "$errorText"');
  }

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Register page is being build...');
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: SizedBox(
            width: 410,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: FittedBox(
                    child: Text(
                      'Staccato',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                CupertinoTextField(
                  placeholder:
                      AppLocalizations.of(context)!.username_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autofocus: true,
                  onChanged: (text) {
                    username = text;
                    setState(() {
                      if (buttonIsActive != _everythingIsFilledOutCorrectly) {
                        buttonIsActive = _everythingIsFilledOutCorrectly;
                      }
                    });
                  },
                ),
                const Gap(10),
                CupertinoTextField(
                  placeholder: AppLocalizations.of(context)!.email_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autofocus: false,
                  onChanged: (text) {
                    eMail = text;
                    setState(() {
                      if (buttonIsActive != _everythingIsFilledOutCorrectly) {
                        buttonIsActive = _everythingIsFilledOutCorrectly;
                      }
                    });
                  },
                  focusNode: _emailFocusNode,
                ),
                const Gap(10),
                CupertinoTextField(
                  placeholder:
                      AppLocalizations.of(context)!.password_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autofocus: false,
                  obscureText: true,
                  onChanged: (text) {
                    password = text;
                    setState(() {
                      if (buttonIsActive != _everythingIsFilledOutCorrectly) {
                        buttonIsActive = _everythingIsFilledOutCorrectly;
                      }
                    });
                  },
                  focusNode: _passwordFocusNode,
                ),
                const Gap(10),
                CupertinoTextField(
                  placeholder: AppLocalizations.of(context)!
                      .confirm_password_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.editing,
                  autofocus: false,
                  obscureText: true,
                  onChanged: (text) {
                    confirmationPassword = text;
                    setState(() {
                      if (buttonIsActive != _everythingIsFilledOutCorrectly) {
                        buttonIsActive = _everythingIsFilledOutCorrectly;
                      }
                    });
                  },
                  focusNode: _confirmationPasswordFocusNode,
                ),
                Text(errorText,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Theme.of(context).colorScheme.error)),
                ElevatedButton(
                  onPressed: registerFunction,
                  child: Text(AppLocalizations.of(context)!.register_button),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () {
                    MyApp.logger.t('User switched to log in page');
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const LoginPage()));
                  },
                  child: Text(AppLocalizations.of(context)!.login_button),
                ),
                const Gap(8),
                TextButton(
                    onPressed: () => User.continueWithoutLogin(context),
                    child: Text(AppLocalizations.of(context)!
                        .continue_without_login_button))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConfirmationCodeSite extends StatefulWidget {
  const ConfirmationCodeSite(this.username, this.eMail, this.password,
      {super.key});

  final String username;
  final String eMail;
  final String password;

  @override
  State<ConfirmationCodeSite> createState() => _ConfirmationCodeSiteState();
}

class _ConfirmationCodeSiteState extends State<ConfirmationCodeSite> {
  String confirmationCode = "";

  VoidCallback? loginFunction;

  bool get buttonIsActive => loginFunction != null;

  set buttonIsActive(bool buttonActivation) {
    if (buttonActivation) {
      MyApp.logger.d('Register button has been activated');
      loginFunction = () => User.register(widget.eMail, widget.password,
          widget.username, confirmationCode, context);
      return;
    }

    MyApp.logger.d('Register button has been deactivated');
    loginFunction = null;
  }

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Confirmation code site is being build...');
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            CupertinoTextField(
              placeholder:
                  AppLocalizations.of(context)!.confirmation_code_placeholder,
              style: Theme.of(context).textTheme.labelMedium,
              clearButtonMode: OverlayVisibilityMode.editing,
              autofocus: true,
              keyboardType: TextInputType.number,
              onChanged: (text) {
                confirmationCode = text;
                setState(() {
                  if (buttonIsActive != text.isNotEmpty) {
                    buttonIsActive = text.isNotEmpty;
                  }
                });
              },
            ),
            ElevatedButton(
              onPressed: loginFunction,
              child: Text(AppLocalizations.of(context)!.register_button),
            ),
          ],
        ),
      ),
    );
  }
}
