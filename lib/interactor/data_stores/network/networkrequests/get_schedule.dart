import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'networkrequest.dart';
import '../../../entities/index.dart' as entities;
import '../../../../utilities/bit_array.dart';

class GetSchedule extends NetworkRequest<List<entities.DayTimeInterval>> {
  final entities.UserId userId;
  static const Map<String, int> _weekdayMap = {
    "monday": 1,
    "tuesday": 2,
    "wednesday": 3,
    "thursday": 4,
    "friday": 5,
    "saturday": 6,
    "sunday": 7
  };

  GetSchedule(this.userId);

  @override
  String get url => '/api/v1/users/${userId.netwokId}/schedule/';

  @override
  Map<String, dynamic> get data => {};

  @override
  dio.Options get options => dio.Options(responseType: dio.ResponseType.json);

  @override
  TypeRequest get typeRequest => TypeRequest.get_request;

  @override
  List<entities.DayTimeInterval> onAnswer(dio.Response answer) {
    List<entities.DayTimeInterval> res = [];
    if (data == null) return res;
    Map intervalsMap = answer.data;

    for (String key in intervalsMap.keys) {
      if (!_weekdayMap.keys.contains(key)) continue;
      BitArray interval = BitArray(value: intervalsMap[key]);
      int startInterval;
      for (int i = 0; i < 48; i++) {
        if (interval[i] && startInterval == null) {
          startInterval = i;
        }
        if ((!interval[i] || (i == 47)) && (startInterval != null)) {
          var startDuration = Duration(minutes: 30 * startInterval);
          var endDuration = i == 47
              ? Duration(minutes: 30 * (i + 1))
              : Duration(minutes: 30 * i);
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
