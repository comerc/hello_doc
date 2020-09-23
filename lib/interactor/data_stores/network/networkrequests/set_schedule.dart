import 'package:dio/dio.dart' as dio;
import 'networkrequest.dart';
import '../../../entities/index.dart' as entities;
import '../../../../utilities/bit_array.dart';

class SetSchedule extends NetworkRequest<List<entities.DayTimeInterval>> {
  final entities.UserId userId;
  final List<entities.DayTimeInterval> schedule;
  static const Map<String, int> _weekdayMap = {
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
    'sunday': 7
  };

  SetSchedule(this.userId, List<entities.DayTimeInterval> schedule)
      : schedule = List<entities.DayTimeInterval>.unmodifiable(schedule);

  @override
  String get url => '/api/v1/users/${userId.netwokId}/schedule/';

  @override
  Map<String, dynamic> get data {
    final result = <String, dynamic>{};

    for (var weekday = 1; weekday <= 7; weekday++) {
      final weekDayString = _weekdayMap
          .map<int, String>((key, value) => MapEntry(value, key))[weekday];
      final array = BitArray();
      var weekdayShedule =
          schedule.where((element) => element.weekday == weekday);

      for (var interval in weekdayShedule) {
        final startIndex = (interval.startTime.inMinutes / 30).round();
        final endIndex = (interval.endTime.inMinutes / 30).round();

        if (startIndex > 48) throw Exception('startIndex > 48');
        if (endIndex > 48) throw Exception('endIndex > 48');
        for (var i = startIndex; i < endIndex; i++) {
          array[i] = true;
        }
      }
      result[weekDayString] = array.value;
    }
    return result;
  }

  @override
  dio.Options get options => dio.Options(responseType: dio.ResponseType.json);

  @override
  TypeRequest get typeRequest => TypeRequest.patch_request;

  @override
  List<entities.DayTimeInterval> onAnswer(dio.Response answer) {
    return [];
  }

  @override
  bool get authorized => true;
}
