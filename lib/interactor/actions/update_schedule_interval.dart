import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class UpdateSchedulenterval extends ActionBase {
  pack_entities.DayTimeIntervalId intervalId;
  Duration startTime;
  Duration endTime;
  UpdateSchedulenterval(this.intervalId, {this.startTime, this.endTime})
      : assert(intervalId != null);
  @override
  void doAction(
    IAccessor accessor,
    void Function(ActionBase result) onComplete,
  ) async {
    if (endTime - startTime < Duration(minutes: 30)) {
      onComplete(this);
      return;
    }
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var oldInterval = entitieSchedule.items
          .firstWhere((element) => element.id == intervalId);
      var newInterval =
          oldInterval.copyWith(startTime: startTime, endTime: endTime);
      entitieSchedule.updateItem(newInterval);

      var items = List<pack_entities.DayTimeInterval>.from(
          entitieSchedule.itemsByWeekday(newInterval.weekday));

      for (var i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(isInersected: false);
      }
      for (var i = 0; i < items.length; i++) {
        for (var j = 0; j < items.length; j++) {
          if (items[i].id == items[j].id) continue;
          final intersected = items[i].isIntersectionWith(items[j]);
          if (intersected) {
            items[i] = items[i].copyWith(isInersected: true);
          }
        }
      }
      for (var i = 0; i < items.length; i++) {
        entitieSchedule.updateItem(items[i]);
      }
    } catch (e) {
      if (e is pack_entities.ScheduleException) {
        error = Error(e.type.toString(), detail: e.description);
      } else {
        error = Error('unknown');
      }
      onComplete(this);
    }
  }
}
