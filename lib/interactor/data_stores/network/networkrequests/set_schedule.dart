import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'networkrequest.dart';
import '../../../entities/index.dart' as entities;
import '../../../../utilities/bit_array.dart';

class SetSchedule extends NetworkRequest<List<entities.DayTimeInterval>> {
  final entities.UserId userId;
  final List<entities.DayTimeInterval> schedule;
  static const Map<String, int> _weekdayMap = {
    "monday": 1,
    "tuesday": 2,
    "wednesday": 3,
    "thursday": 4,
    "friday": 5,
    "saturday": 6,
    "sunday": 7
  };

  SetSchedule(this.userId, List<entities.DayTimeInterval> schedule)
      : schedule = List<entities.DayTimeInterval>.unmodifiable(schedule);

  @override
  String get url => '/api/v1/users/${userId.netwokId}/schedule/';

  @override
  Map<String, dynamic> get data {
    Map<String, dynamic> res = {};

    for (int weekday = 1; weekday <= 7; weekday++) {
      String weekDayString = _weekdayMap
          .map<int, String>((key, value) => MapEntry(value, key))[weekday];
      BitArray array = BitArray();
      var weekdayShedule =
          schedule.where((element) => element.weekday == weekday);
      if (weekdayShedule.isEmpty) continue;

      for (var interval in weekdayShedule) {
        int startIndex = (interval.startTime.inMinutes / 30).round();
        int endIndex = (interval.startTime.inMinutes / 30).round();

        if (startIndex > 48) throw Exception("startIndex > 48");
        if (endIndex > 48) throw Exception("endIndex > 48");
        for (int i = startIndex; i <= endIndex; i++) {
          array[i] = true;
        }
      }
      res[weekDayString] = array.value;
    }
    return res;
  }

  @override
  dio.Options get options => dio.Options(responseType: dio.ResponseType.json);

  @override
  TypeRequest get typeRequest => TypeRequest.patch_request;

  @override
  List<entities.DayTimeInterval> onAnswer(dio.Response answer) {
    List<entities.DayTimeInterval> res = [];
    if (data == null) return res;
    Map<String, int> intervalsMap = answer.data as Map<String, int>;

    for (String key in intervalsMap.keys) {
      BitArray interval = BitArray(value: intervalsMap[key]);
      int startInterval;
      for (int i = 0; i < 48; i++) {
        if (interval[i] && startInterval == null) {
          startInterval = i;
        }
        if (!interval[i] && startInterval != null) {
          var startDuration = Duration(minutes: 30 * startInterval + 1);
          var endDuration = Duration(minutes: 30 * i);
          var newInterval = entities.DayTimeInterval(
              _weekdayMap[key], startDuration, endDuration);
          startInterval = null;
          res.add(newInterval);
        }
      }
    }
    return res;
  }

  @override
  bool get authorized => true;
}
