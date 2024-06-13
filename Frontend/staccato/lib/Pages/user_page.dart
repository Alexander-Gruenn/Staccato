import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:staccato/Classes/user.dart';
import 'package:staccato/Pages/ChangePages/changePassword.dart';
import 'package:staccato/Pages/ChangePages/change_email.dart';
import 'package:staccato/Pages/ChangePages/change_username.dart';
import 'package:staccato/main.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  void changeData(BuildContext context) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ChangePasswordPage()));
  }

  //TODO remove password verification
  var password = '';

  @override
  Widget build(BuildContext context) {
    MyApp.logger.t('User page is being build...');
    String username;

    username =
        User.isLoggedIn ? User.getCurrentlyLoggedInUser!.username : "Guest";

    ImageProvider<Object> image = (User
                .getCurrentlyLoggedInUser?.profilePicture ==
            null
        ? const AssetImage("assets/placeholder/profile_picture_placeholder.png")
        : Image.memory(User.getCurrentlyLoggedInUser!.profilePicture!).image);

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.profile_page_title)),
      body: Center(
        child: Column(
          children: [
            const Gap(15),
            InkWell(
              onTap: () async {
                MyApp.logger.t('User is trying to change profile picture');
                var picker = ImagePicker();

                var newProfilePicture =
                    await picker.pickImage(source: ImageSource.gallery);

                if (newProfilePicture == null) {
                  MyApp.logger.e('User did not select a picture');
                  return;
                }
                MyApp.logger.t('Saving new profile picture...');
                User.getCurrentlyLoggedInUser
                    ?.changeProfilePicture(newProfilePicture);
              },
              child: Ink(
                //TODO put ink inside Circle Avatar
                child: CircleAvatar(radius: 100, backgroundImage: image),
              ),
            ),
            Text(username, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              "#0000",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Gap(25),
            ElevatedButton(
                onPressed: () {
                  MyApp.logger.t('User is trying to change his username');
                  MyApp.logger.t('Navigating to "Changed username" page...');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangeUsernamePage()));
                },
                child: Text(AppLocalizations.of(context)!.change_username)),
            const Gap(5),
            ElevatedButton(
                onPressed: () {
                  MyApp.logger.t('User is trying to change his email');
                  MyApp.logger.t('Navigating to "Changed email" page....');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangeEmailPage()));
                },
                child: Text(AppLocalizations.of(context)!.change_email)),
            const Gap(5),
            ElevatedButton(
                onPressed: () {
                  MyApp.logger.t('User is trying to change his password');
                  MyApp.logger.t('Navigating to "Changed password" page...');
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChangePasswordPage()));
                },
                child: Text(AppLocalizations.of(context)!.change_password)),
            const Gap(5),
            ElevatedButton(
                onPressed: () {
                  MyApp.logger.t('User is trying to log out');
                  User.logout(context);
                },
                child: Text(AppLocalizations.of(context)!.logout_button)),
            const Gap(5),
            ElevatedButton(
                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                    backgroundColor: MaterialStatePropertyAll(
                        Theme.of(context).colorScheme.error)),
                onPressed: () {
                  MyApp.logger.t('User is trying to delete his account...');
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text(
                                AppLocalizations.of(context)!.delete_account),
                            content: Text(
                              AppLocalizations.of(context)!
                                  .sure_delete_account_question,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context,
                                        AppLocalizations.of(context)!.yes);
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text(
                                                  AppLocalizations.of(context)!
                                                      .delete_account),
                                              content: CupertinoTextField(
                                                placeholder: AppLocalizations
                                                        .of(context)!
                                                    .current_password_placeholder,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelMedium,
                                                onChanged: (newText) =>
                                                    password = newText,
                                                obscureText: true,
                                              ),
                                              actions: [
                                                TextButton(
                                                    onPressed: () => User
                                                        .getCurrentlyLoggedInUser
                                                        ?.deleteAccount(
                                                            password, context),
                                                    child: Text(
                                                        AppLocalizations.of(
                                                                context)!
                                                            .delete_account))
                                              ],
                                            ));
                                  },
                                  child:
                                      Text(AppLocalizations.of(context)!.yes)),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, 'No'),
                                  child:
                                      Text(AppLocalizations.of(context)!.no)),
                            ],
                          ),
                      barrierDismissible: true);
                },
                child: Text(AppLocalizations.of(context)!.delete_account)),
          ],
        ),
      ),
    );
  }
}
