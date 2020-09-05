import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class ClearDay extends ActionBase {
  final int weekday;
  ClearDay(this.weekday) : assert(weekday != null);
  @override
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      List<pack_entities.DayTimeInterval> intervals =
          List<pack_entities.DayTimeInterval>.from(
              entitieSchedule.itemsbyWeekday(weekday));
      for (var interval in intervals) {
        entitieSchedule.removeItem(interval);
      }
    } catch (e) {
      if (e is pack_entities.ScheduleException) {
        error = Error(e.type.toString(), detail: e.description);
      } else {
        error = Error("unknown");
      }
    }
    onComplete(this);
  }
}
