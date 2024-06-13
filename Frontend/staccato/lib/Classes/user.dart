import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:staccato/Classes/audiofile.dart';
import 'package:staccato/main.dart';
import 'package:staccato/music_analysing/audio_edit.dart';
import 'package:staccato/music_analysing/music_note.dart';
import 'package:staccato/music_analysing/music_sheet.dart';
import 'package:staccato/music_analysing/process_wav.dart';

import '../Pages/login_page.dart';
import '../Pages/register_page.dart';

class User {
  User(
      {required String username,
      required String eMail,
      required String authToken,
      bool isPremium = false})
      : _username = username,
        _eMail = eMail,
        _authToken = authToken,
        _isPremium = isPremium {
    MyApp.logger.t('New user is being created...');
    _user = this;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        username: json['user']['username'],
        eMail: json['user']['email'],
        authToken: json['token'],
        isPremium: json['user']['permission_level'] > 0);
  }

  String _username;
  String _eMail;
  bool _isPremium;
  Uint8List? _profilePicture;
  String _authToken;

  String get username => _username;

  String get eMail => _eMail;

  String get authToken => _authToken;

  bool get isPremium => _isPremium;

  Uint8List? get profilePicture => _profilePicture;

  bool get hasProfilePicture => _profilePicture != null;

  static User? _user;

  static User? get getCurrentlyLoggedInUser => _user;

  static bool get isLoggedIn => _user != null;

  static Future<bool> checkIfPasswordLessLoginIsPossible(String email) async {
    MyApp.logger.i('Check if password less log in is possible has not been'
        'implemented yet. Returning false per default');
    return false;
  }

  static void continueWithoutLogin(BuildContext context) =>
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) {
        MyApp.logger.t('User continued without login');
        return const MyHomePage(title: 'Staccato');
      }));

  Future<bool> downloadProfilePicture() async {
    MyApp.logger.t('Downloading profile picture of user...');

    if (!isLoggedIn) {
      MyApp.logger.f('User is not logged in');
      return false;
    }

    final response = await http.get(
        Uri.parse('http://fileserver.foxel.at:1220/profile_picture'),
        headers: <String, String>{'authorization': 'Bearer $_authToken'});

    MyApp.logger.d(response.statusCode);

    if (response.statusCode == 204) {
      MyApp.logger.d('The user has no profile picture');
      return false;
    }

    if (response.statusCode == 200) {
      MyApp.logger.t('Saving profile picture...');
      _profilePicture = response.bodyBytes;
      return true;
    }

    MyApp.logger.e('The request has failed', error: response);
    return false;
  }

  Future<List<Audio>?> downloadAudioFiles() async {
    MyApp.logger.t('Downloading audio files...');

    if (!isLoggedIn) {
      MyApp.logger.f('The user is not logged in. Stopping download...');
      return null;
    }

    final response = await http.get(
        Uri.parse('http://localhost:1220/audiofile/all'),
        headers: <String, String>{'authorization': 'Bearer $_authToken'});

    MyApp.logger.d(response.statusCode);

    if (response.statusCode != 200) {
      MyApp.logger.e('Request has failed', error: response.body);
      return null;
    }

    MyApp.logger.t('Request successful. Loading audio files...');
    //TODO load all new audio files

    MyApp.logger.t('Loading audio directory...');

    final appDirectory = await getApplicationDocumentsDirectory();
    final audiosPath = Directory("${appDirectory.path}/Staccato/Audio");

    if (!await audiosPath.exists()) {
      MyApp.logger.t('Audio directory does not exists. Creating it...');
      await audiosPath.create(recursive: true);
      MyApp.logger.t('Audio directory created');
    } else {
      MyApp.logger.t('Audio directory does exists');
    }

    List<Audio> audios = List<Audio>.empty(growable: true);

    for (var audioFileData in jsonDecode(response.body)) {
      final uInt8List = List<int>.from(audioFileData['buffer']['data']);
      var audioFile = XFile.fromData(Uint8List.fromList(uInt8List));
      var path = '${audiosPath.path}/${audioFileData['name']}';

      MyApp.logger.t('Saving audio file ${audioFileData['name']}...');

      await audioFile.saveTo(path);

      List<dynamic> noteAnalysisResults =
          audioFileData['note_analysis_result'];

      MyApp.logger.i('Length: ${noteAnalysisResults.length}');

      var musicSheet = MusicSheet(noteAnalysisResults.length);

      var notesForTheMusicSheet = List<List<MusicNote>>.generate(
          noteAnalysisResults.length,
          (index) => List<MusicNote>.generate(
              noteAnalysisResults[index].length,
              (indexOfNote) =>
                  MusicNote.fromJson(noteAnalysisResults[index][indexOfNote])));

      musicSheet.notes = notesForTheMusicSheet;

      audios.add(Audio(
        MusicPiece(
            audioFileData['displayed_name'], path, DateTime.now(), musicSheet),
        isSynced: true,
      ));
    }

    return audios;
  }

  static Future<bool> login(
      String eMail, String password, BuildContext context) async {
    MyApp.logger.t('User is trying to log in...');

    if (isLoggedIn) {
      MyApp.logger.f('User is already logged in');
      return false;
    }

    final response = await http.post(
        Uri.parse('http://fileserver.foxel.at:1220/user/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body:
            jsonEncode(<String, String>{'email': eMail, 'password': password}));

    if (response.statusCode != 200) {
      MyApp.logger
          .e('Status code: ${response.statusCode}', error: response.body);
      return false;
    }

    MyApp.logger.d('Status code: ${response.statusCode}');

    MyApp.logger.t('User successfully logged in');

    final user = jsonDecode(response.body);
    MyApp.logger.d(user);
    User.fromJson(user);
    MyApp.logger.d('New user saved:\n ${User.getCurrentlyLoggedInUser}');

    MyApp.logger.t('Navigating to main page...');
    if (!context.mounted) {
      MyApp.logger.f('The context is already mounted');
      return false;
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(title: 'Staccato')),
        (route) => false);

    User.getCurrentlyLoggedInUser!.downloadProfilePicture();
    return true;
  }

  static Future<bool> loginWithPasskey(
      String email, BuildContext context) async {
    MyApp.logger.i('Passkey log in has bot been implemented yet');
    return false;
  }

  static Future<bool> sendCode(String username, String password, String eMail,
      BuildContext context) async {
    MyApp.logger.t('User is trying to register');
    //POST request to the server to send the confirmation code
    var response = await http.post(
      Uri.parse('http://fileserver.foxel.at:1220/user/code'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'email': eMail}),
    );

    MyApp.logger.d('Status code: ${response.statusCode}');

    if (response.statusCode == 227) {
      MyApp.logger.d('Registration confirmed, confirmation code sent');
      if (!context.mounted) {
        MyApp.logger.f('Context is already mounted');
        return false;
      }
      MyApp.logger.t('Navigating to confirmation code site...');
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ConfirmationCodeSite(username, eMail, password)));
      return true;
    }
    if (response.statusCode == 409) {
      MyApp.logger
          .e('A user with this email already exists', error: response.body);
      if (!context.mounted) {
        MyApp.logger.f('Context is already mounted');
        return false;
      }
      MyApp.logger
          .t('Navigating to log in page with email already filled out...');
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage.alreadyExists(eMail)));
      return false;
    }
    //TODO What happens if request fails
    MyApp.logger.e('Request has failed', error: response.body);
    return false;
  }

  static Future<bool> register(String eMail, String password, String username,
      String confirmationCode, BuildContext context) async {
    MyApp.logger.t('User is trying to register...');

    if (isLoggedIn) {
      MyApp.logger.f('User is already logged in');
      return false;
    }

    var response = await http.post(
      Uri.parse('http://fileserver.foxel.at:1220/user'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': eMail,
        'password': password,
        'username': username,
        'code': confirmationCode,
      }),
    );

    if (response.statusCode != 201) {
      //TODO What happens if status code is not 200
      MyApp.logger.e('Request has failed', error: response.body);
      return false;
    }
    MyApp.logger.t('User successfully registered');
    final user = jsonDecode(response.body);
    MyApp.logger.d(user);
    User.fromJson(user);
    MyApp.logger.i('The register endpoint does not return a token yet. '
        'Please logout and login again if you want to change anything');
    MyApp.logger.d('New user saved:\n ${User.getCurrentlyLoggedInUser}');

    MyApp.logger.t('Navigating to home page...');
    if (!context.mounted) {
      MyApp.logger.f('Context is not mounted');
      return false;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) => const MyHomePage(
                  title: 'Staccato',
                )),
        (route) => route.isCurrent);
    return true;
  }

  static void logout(BuildContext context) {
    MyApp.logger.t('Navigating to log in page and clearing widget tree...');
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);
    MyApp.logger.t('Deleting user data');
    _user = null;
  }

  Future<bool> changeData(String password,
      {String? newUsername, String? newPassword, String? newEMail}) async {
    MyApp.logger.t('Changing user data...');

    MyApp.logger.d('New e mail: $newEMail\n'
        'New username: $newUsername\n'
        'New password: $newPassword');

    final updateData = await http.put(
        Uri.parse('http://fileserver.foxel.at:1220/user'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Bearer $_authToken'
        },
        body: jsonEncode(<String, String>{
          'old_email': eMail,
          'old_password': password,
          'username': newUsername ?? username,
          'email': newEMail ?? eMail,
          'password': newPassword ?? password,
          'is_premium': isPremium.toString(),
        }));

    MyApp.logger.d('Status code: ${updateData.statusCode}');

    if (updateData.statusCode != 201) {
      if (updateData.statusCode == 400) {
        MyApp.logger.e('There was a problem with the auth token',
            error: updateData.body);
        return false;
      }
      MyApp.logger.e('Updating data in the database has failed',
          error: updateData.body);
      return false;
    }

    if (newUsername != null) _username = newUsername;
    if (newEMail != null) _eMail = newEMail;

    MyApp.logger.t('Data updated');
    return true;
  }

  Future<bool> changeProfilePicture(XFile file) async {
    MyApp.logger.t('Changing profile picture...');

    var request = http.MultipartRequest('PATCH',
        Uri.parse('http://fileserver.foxel.at:1220/user/profile_picture'))
      ..headers['authorization'] = 'Bearer $_authToken'
      ..files.add(http.MultipartFile.fromBytes(
          'profile_picture', await file.readAsBytes(),
          filename: file.name));

    MyApp.logger.d(request);

    var response = await request.send();

    MyApp.logger.d('Status code: ${response.statusCode}');

    if (response.statusCode != 204) {
      if (response.statusCode == 400) {
        MyApp.logger.e('There was a problem with the auth token',
            error: response); //TODO Change error to something that makes sense
        return false;
      }
      MyApp.logger.e('Request has failed',
          error: response); //TODO Change error to something that makes sense
      return false;
    }

    _profilePicture = await file.readAsBytes();
    MyApp.logger.t('New profile picture has been saved');
    return true;
  }

  Future<bool> deleteAccount(String password, BuildContext context) async {
    MyApp.logger.t('User is trying to delete his account...');

    var response = await http.delete(
        Uri.parse('http://fileserver.foxel.at:1220/user'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'authorization': 'Bearer $_authToken'
        },
        body: jsonEncode(
            <String, String>{'token': _authToken, 'password': password}));

    MyApp.logger.d('Status code: ${response.statusCode}');

    if (response.statusCode != 200) {
      if (response.statusCode == 400) {
        MyApp.logger
            .e('There was a problem with the auth token', error: response.body);
        return false;
      }
      MyApp.logger.e('Request failed', error: response.body);
      return false;
    }

    MyApp.logger.t('User has been deleted');

    if (!context.mounted) {
      MyApp.logger.f('Context is not mounted');
      return false;
    }

    MyApp.logger.t('User is being logged out...');

    _user = null;

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false);

    return true;
  }

  @override
  String toString() {
    var builder = StringBuffer();

    builder.writeln('Username: $username');
    builder.writeln('E-Mail: $eMail');
    builder.writeln('Is premium: $isPremium');
    builder.write('Has profile picture: $hasProfilePicture');

    return builder.toString();
  }
}
