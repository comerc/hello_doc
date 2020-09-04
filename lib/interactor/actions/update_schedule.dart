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
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var oldInterval = entitieSchedule.items
          .firstWhere((element) => element.id == intervalId);
      entitieSchedule.updateItem(
          oldInterval.copyWith(startTime: startTime, endTime: endTime));
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
