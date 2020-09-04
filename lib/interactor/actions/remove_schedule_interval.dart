import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class RemoveSchedulenterval extends ActionBase {
  pack_entities.DayTimeIntervalId intervalId;
  RemoveSchedulenterval(this.intervalId) : assert(intervalId != null);
  @override
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      entitieSchedule.removeItem(entitieSchedule.items
          .firstWhere((element) => element.id == intervalId));
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
