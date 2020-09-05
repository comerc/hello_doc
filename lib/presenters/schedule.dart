import 'dart:io';
import 'package:flutter/material.dart';
import 'presenter_base.dart';
import '../interactor/actions/index.dart' as actions;
import '../interactor/notifications/index.dart' as notifications;
import '../interactor/entities/index.dart' as entities;

class Schedule extends PresenterBase {
  Schedule();
  var loading = ValueNotifier<bool>(true);

  Stream<List<notifications.DayItem>> get scheduleModelStream {
    _scheduleNotifierStream ??= subscribeTo(notifications.ScheduleNotifier());
    return _scheduleNotifierStream.map((event) => event.model);
  }

  final GlobalKey<NavigatorState> mainNavigationKey =
      GlobalKey<NavigatorState>();

  Future<actions.Error> addScheduleInterval(int weekday) async {
    var resultGetFreeInterval = await execute(actions.GetFreeInterval(weekday));
    if (resultGetFreeInterval.error != null) {
      return resultGetFreeInterval.error;
    }
    if (resultGetFreeInterval.freeDayTimeInterval != null) {
      var resultAddSchedulenterval = await execute(actions.AddSchedulenterval(
          resultGetFreeInterval.freeDayTimeInterval));
      if (resultAddSchedulenterval.error != null) {
        return resultGetFreeInterval.error;
      }
    }
    return null;
  }

  Future<actions.Error> activateDay(int weekday) async {
    return addScheduleInterval(weekday);
  }

  Future<actions.Error> deactivateDay(int weekday) async {
    var result = await execute(actions.ClearDay(weekday));
    if (result.error != null) {
      return result.error;
    }
    return null;
  }

  Future<actions.Error> changeInterval(int weekday, Duration startTime,
      Duration endTime, entities.DayTimeIntervalId intervalId) async {
    var result = execute(actions.UpdateSchedulenterval(intervalId,
        startTime: startTime, endTime: endTime));
    return null;
  }

  Future<actions.Error> save() async {}

  @override
  void initiate() async {
    await execute(actions.InitializeApplication());
    await execute(actions.LoadSchedule(entities.UserId(342)));
    loading.value = false;
  }

  Stream<notifications.ScheduleNotifier> _scheduleNotifierStream;
}
