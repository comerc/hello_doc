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
    var items = entitieSchedule.itemsbyWeekday(weekday);
    for (var interval in items) {
      if (interval.isIntersectionWith(freeDayTimeInterval)) return false;
    }
    return true;
  }

  @override
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var items = entitieSchedule.itemsbyWeekday(weekday);
      if (items.isEmpty) {
        freeDayTimeInterval = pack_entities.DayTimeInterval(
            weekday, Duration.zero, Duration(hours: 24));
        onComplete(this);
        return;
      }
      for (var interval in items) {
        if (interval.freeLeft != null && interval.freeRight != null) {
          freeDayTimeInterval = interval.freeLeft;
          if (isReallyFreeInterval(entitieSchedule)) {
            onComplete(this);
            return;
          } else {
            freeDayTimeInterval = interval.freeRight;
            if (isReallyFreeInterval(entitieSchedule)) {
              onComplete(this);
              return;
            }
          }
        } else if (interval.freeLeft != null) {
          freeDayTimeInterval = interval.freeLeft;
        } else if (interval.freeRight != null) {
          freeDayTimeInterval = interval.freeRight;
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
        error = Error("unknown");
        return;
      }
      onComplete(this);
    }
  }
}
