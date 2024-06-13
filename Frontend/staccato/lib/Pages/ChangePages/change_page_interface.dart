import 'package:flutter/cupertino.dart';

abstract class IChangeState {

  List<CupertinoTextField> get textFields;

  VoidCallback? onPressed;
  late String errorText;

  void onChange();

  bool get buttonIsActive;
  set activateButton(bool setActive);

}