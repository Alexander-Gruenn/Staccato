import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/register_page.dart';
import 'package:staccato/main.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key}) : email = null;

  const LoginPage.alreadyExists(this.email, {super.key});

  final String? email;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String eMail = '';

  String errorText = '';

  final controller = TextEditingController();

  bool get _emailFieldIsFilledOut => eMail.isNotEmpty;

  bool get _buttonIsActive => loginFunction != null;

  set buttonIsActive(bool buttonActivation) {
    if (buttonActivation) {
      MyApp.logger.d('Login button has been activated');
      loginFunction = () async {
        MyApp.logger.t('User is trying to log in');
        MyApp.logger.t('Checking if password less log in possible...');
        if (await User.checkIfPasswordLessLoginIsPossible(eMail)) {
          MyApp.logger.d('Password less log in is possible');
          if (!context.mounted) {
            MyApp.logger.f('Context is not mounted');
            return;
          }
          MyApp.logger.t('Switching to log in page without password');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => PasswordLessLogInPage(eMail)));
        } else {
          MyApp.logger.d('Password less log in is not possible');
          if (!context.mounted) {
            MyApp.logger.f('Context is not mounted');
            return;
          }
          MyApp.logger.t('Switching to log in page with password');
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => LoginWithPasswordPage(eMail)));
        }
      };
      return;
    }

    MyApp.logger.d('Login button has been deactivated');
    loginFunction = null;
  }

  @override
  void initState() {
    MyApp.logger.t('Login page is being initialized...');
    if (widget.email != null) {
      MyApp.logger.d('E-Mail is already set to ${widget.email}');
      eMail = widget.email!;
      controller.text = eMail;
      errorText = AppLocalizations.of(context)!.account_already_exists_error;
    }

    super.initState();
  }

  dynamic loginFunction;

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Building...');
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
                      placeholder: AppLocalizations.of(context)!
                          .email_or_username_placeholder,
                      style: Theme.of(context).textTheme.labelMedium,
                      clearButtonMode: OverlayVisibilityMode.editing,
                      autofocus: true,
                      onChanged: (text) {
                        eMail = text;
                        setState(() {
                          if (_buttonIsActive != _emailFieldIsFilledOut) {
                            buttonIsActive = _emailFieldIsFilledOut;
                          }
                        });
                      },
                      controller: controller,
                    ),
                    Text(errorText,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    ElevatedButton(
                      onPressed: loginFunction,
                      child: Text(AppLocalizations.of(context)!.login_button),
                    ),
                    const Gap(8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) {
                        MyApp.logger.t('User switched to register site');
                        return const RegisterPage();
                      })),
                      child:
                          Text(AppLocalizations.of(context)!.register_button),
                    ),
                    const Gap(8),
                    TextButton(
                        onPressed: () => User.continueWithoutLogin(context),
                        child: Text(AppLocalizations.of(context)!
                            .continue_without_login_button))
                  ],
                ),
              ),
            )));
  }
}

class LoginWithPasswordPage extends StatefulWidget {
  const LoginWithPasswordPage(this.email, {super.key});

  final String email;

  @override
  State<LoginWithPasswordPage> createState() => _LoginWithPasswordPageState();
}

class _LoginWithPasswordPageState extends State<LoginWithPasswordPage> {
  String password = '';

  final controller = TextEditingController();

  bool get _passwordFieldIsFilledOut => password.isNotEmpty;

  bool get _buttonIsActive => loginFunction != null;

  set buttonIsActive(bool buttonActivation) {
    if (buttonActivation) {
      MyApp.logger.d('Login button has been activated');
      loginFunction = () => User.login(widget.email, password, context);
      return;
    }

    MyApp.logger.d('Login button has been deactivated');
    loginFunction = null;
  }

  @override
  void initState() {
    MyApp.logger.t('Login page is being initialized...');
    controller.text = widget.email;
    super.initState();
  }

  dynamic loginFunction;

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('Login page is being build...');
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
                  placeholder: AppLocalizations.of(context)!
                      .email_or_username_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.never,
                  controller: controller,
                  readOnly: true,
                  autofocus: false,
                ),
                const Gap(10),
                CupertinoTextField(
                    placeholder:
                        AppLocalizations.of(context)!.password_placeholder,
                    style: Theme.of(context).textTheme.labelMedium,
                    clearButtonMode: OverlayVisibilityMode.editing,
                    autofocus: true,
                    obscureText: true,
                    onChanged: (text) {
                      password = text;
                      setState(() {
                        if (_buttonIsActive != _passwordFieldIsFilledOut) {
                          buttonIsActive = _passwordFieldIsFilledOut;
                        }
                      });
                    }),
                const Gap(10),
                ElevatedButton(
                  onPressed: loginFunction,
                  child: Text(AppLocalizations.of(context)!.login_button),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    MyApp.logger.t('User switched to register site');
                    return const RegisterPage();
                  })),
                  child: Text(AppLocalizations.of(context)!.register_button),
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

class PasswordLessLogInPage extends StatefulWidget {
  const PasswordLessLogInPage(this.email, {super.key});

  final String email;

  @override
  State<PasswordLessLogInPage> createState() => _PasswordLessLogInPageState();
}

class _PasswordLessLogInPageState extends State<PasswordLessLogInPage> {
  final controller = TextEditingController();

  bool get _buttonIsActive => loginFunction != null;

  set buttonIsActive(bool buttonActivation) {
    if (buttonActivation) {
      MyApp.logger.d('Login button has been activated');
      loginFunction = () => User.loginWithPasskey(widget.email, context);
      return;
    }

    MyApp.logger.d('Login button has been deactivated');
    loginFunction = null;
  }

  @override
  void initState() {
    MyApp.logger.t('Login page is being initialized...');
    controller.text = widget.email;
    super.initState();
  }

  dynamic loginFunction;

  @override
  Widget build(BuildContext context) {
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
                  placeholder: AppLocalizations.of(context)!
                      .email_or_username_placeholder,
                  style: Theme.of(context).textTheme.labelMedium,
                  clearButtonMode: OverlayVisibilityMode.never,
                  controller: controller,
                  readOnly: true,
                  autofocus: false,
                ),
                const Gap(10),
                ElevatedButton(
                  onPressed: loginFunction,
                  child: Text(AppLocalizations.of(context)!.login_button),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    MyApp.logger.t('User switched to register site');
                    return const RegisterPage();
                  })),
                  child: Text(AppLocalizations.of(context)!.register_button),
                ),
                const Gap(8),
                ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacement(MaterialPageRoute(builder: (context) {
                    MyApp.logger
                        .t('User switched to log in with password page');
                    return LoginWithPasswordPage(widget.email);
                  })),
                  child: Text(
                      AppLocalizations.of(context)!.login_with_password_button),
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
