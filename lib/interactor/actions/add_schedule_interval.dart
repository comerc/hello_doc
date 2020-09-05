import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;

class AddSchedulenterval extends ActionBase {
  pack_entities.DayTimeInterval interval;
  AddSchedulenterval(this.interval) : assert(interval != null);
  @override
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
    var entitieSchedule = accessor.entitieSchedule;
    try {
      entitieSchedule.addItem(interval);
    } catch (e) {
      if (e is pack_entities.ScheduleException) {
        error = Error(e.type.toString(), detail: e.description);
      } else {
        error = Error("unknown");
        return;
      }
    }
    onComplete(this);
  }
}
