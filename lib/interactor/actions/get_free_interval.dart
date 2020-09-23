import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class GetFreeInterval extends ActionBase {
  final int weekday;
  pack_entities.DayTimeInterval freeDayTimeInterval;
  GetFreeInterval(
    this.weekday,
  )   : assert(weekday > 0),
        assert(weekday <= 7);

  bool isReallyFreeInterval(pack_entities.ISchedule entitieSchedule) {
    if (freeDayTimeInterval == null) return false;
    var items = entitieSchedule.itemsByWeekday(weekday);
    for (var interval in items) {
      if (interval.isIntersectionWith(freeDayTimeInterval)) return false;
    }
    return true;
  }

  @override
  void doAction(
    IAccessor accessor,
    void Function(ActionBase result) onComplete,
  ) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var items = entitieSchedule.itemsByWeekday(weekday);
      if (items.isEmpty) {
        freeDayTimeInterval = pack_entities.DayTimeInterval(
            weekday, Duration(hours: 8), Duration(hours: 20));
        onComplete(this);
        return;
      } else {
        var start = Duration.zero;
        var end = Duration.zero;
        final intervals = List<pack_entities.DayTimeInterval>.from(items);
        intervals.sort((a, b) => a.startTime.compareTo(b.startTime));

        for (var i = 0; i <= intervals.length; i++) {
          if (i > 0) {
            start = intervals[i - 1].endTime + Duration(minutes: 30);
          } else {
            start = Duration.zero;
          }
          if (i < intervals.length) {
            end = intervals[i].startTime - Duration(minutes: 30);
          } else {
            end = Duration(minutes: 1440);
          }
          if ((end - start) >= Duration(minutes: 30)) {
            freeDayTimeInterval =
                pack_entities.DayTimeInterval(weekday, start, end);
            break;
          }
        }
        if (isReallyFreeInterval(entitieSchedule)) {
          onComplete(this);
          return;
        } else {
          freeDayTimeInterval = null;
        }
      }
    } catch (e) {
      if (e is pack_entities.ScheduleException) {
        error = Error(e.type.toString(), detail: e.description);
      } else {
        error = Error('unknown');
      }
    }
    if (freeDayTimeInterval == null) {
      error = Error(
        'no_free_intervals',
        detail: 'Все временные интервалы уже заняты',
      );
    }
    onComplete(this);
    return;
  }
}
