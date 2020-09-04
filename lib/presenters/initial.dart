import 'dart:io';
import 'package:flutter/material.dart';
import 'presenter_base.dart';
import '../interactor/actions/index.dart';
import '../interactor/notifications/index.dart';
import '../interactor/entities/index.dart';

class Initial extends PresenterBase {
  Initial();
  @override
  void initiate() async {
    await execute(InitializeApplication());
  }
}
