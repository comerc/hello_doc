import 'package:flutter/material.dart';
import 'presenter_base.dart';
import '../interactor/actions/index.dart' as actions;
import '../interactor/notifications/index.dart' as notifications;
import '../interactor/entities/index.dart' as entities;

class Schedule extends PresenterBase {
  Schedule();
  final loading = ValueNotifier<bool>(true);
  final busy = ValueNotifier<bool>(false);
  final isErrorLoading = ValueNotifier<bool>(false);

  Stream<List<notifications.DayItem>> get scheduleModelStream {
    _scheduleNotifierStream ??= subscribeTo(notifications.ScheduleNotifier());
    return _scheduleNotifierStream.map((event) => event.model);
  }

  final GlobalKey<NavigatorState> mainNavigationKey =
      GlobalKey<NavigatorState>();

  Future<actions.Error> addScheduleInterval(int weekday) async {
    busy.value = true;
    var resultGetFreeInterval = await execute(actions.GetFreeInterval(weekday));
    if (resultGetFreeInterval.error != null) {
      busy.value = false;
      return resultGetFreeInterval.error;
    }
    if (resultGetFreeInterval.freeDayTimeInterval != null) {
      var resultAddSchedulenterval = await execute(actions.AddSchedulenterval(
          resultGetFreeInterval.freeDayTimeInterval));
      if (resultAddSchedulenterval.error != null) {
        busy.value = false;
        return resultGetFreeInterval.error;
      }
    }
    busy.value = false;
    return null;
  }

  Future<actions.Error> activateDay(int weekday) async {
    return addScheduleInterval(weekday);
  }

  Future<actions.Error> deactivateDay(int weekday) async {
    busy.value = true;
    var result = await execute(actions.ClearDay(weekday));
    if (result.error != null) {
      busy.value = false;
      return result.error;
    }
    busy.value = false;
    return null;
  }

  Future<actions.Error> changeInterval(int weekday, Duration startTime,
      Duration endTime, entities.DayTimeIntervalId intervalId) async {
    var result = await execute(actions.UpdateSchedulenterval(intervalId,
        startTime: startTime, endTime: endTime));
    if (result.error != null) {
      return result.error;
    }
    return null;
  }

  Future<actions.Error> save() async {
    busy.value = true;
    var result = await execute(actions.SaveSchedule(entities.UserId(342)));
    if (result.error != null) {
      busy.value = false;
      return result.error;
    }
    busy.value = false;
    return null;
  }

  Future<actions.Error> reload() async {
    isErrorLoading.value = false;
    loading.value = true;
    var result = await execute(actions.LoadSchedule(entities.UserId(342)));
    if (result.error != null) {
      loading.value = false;
      isErrorLoading.value = true;
      return result.error;
    }
    loading.value = false;
    return null;
  }

  @override
  void initiate() async {
    await execute(actions.InitializeApplication());
    var result = await execute(actions.LoadSchedule(entities.UserId(342)));
    loading.value = false;
    if (result.error != null) {
      isErrorLoading.value = true;
    }
  }

  Stream<notifications.ScheduleNotifier> _scheduleNotifierStream;
}
