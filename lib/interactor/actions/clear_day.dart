import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class ClearDay extends ActionBase {
  final int weekday;
  ClearDay(this.weekday) : assert(weekday != null);
  @override
  void doAction(
    IAccessor accessor,
    void Function(ActionBase result) onComplete,
  ) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      final intervals = List<pack_entities.DayTimeInterval>.from(
          entitieSchedule.itemsByWeekday(weekday));
      for (final interval in intervals) {
        entitieSchedule.removeItem(interval);
      }
    } catch (e) {
      if (e is pack_entities.ScheduleException) {
        error = Error(e.type.toString(), detail: e.description);
      } else {
        error = Error('unknown');
      }
    }
    onComplete(this);
  }
}
