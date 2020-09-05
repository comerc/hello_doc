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
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
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

      for (var currentInterval
          in entitieSchedule.itemsbyWeekday(newInterval.weekday)) {
        for (var testInterval
            in entitieSchedule.itemsbyWeekday(newInterval.weekday)) {
          if (currentInterval.id == testInterval.id) continue;
          var intersectedInterval = currentInterval.copyWith(
              isInersected: currentInterval.isIntersectionWith(testInterval));

          entitieSchedule.updateItem(intersectedInterval);
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
