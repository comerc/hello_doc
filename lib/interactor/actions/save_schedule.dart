import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;
import '../data_stores/network/index.dart' as pack_network;

class SaveSchedule extends ActionBase {
  final pack_entities.UserId userId;

  SaveSchedule(this.userId);
  @override
  void doAction(IAccessor accessor, void onComplete(ActionBase result)) async {
    var dataStoreNetwork = accessor.dataStoreNetwork;
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var schedule = entitieSchedule.items;
      if (schedule.firstWhere((element) => element.isInersected,
              orElse: () => null) !=
          null) {
        error = Error("have_intersections",
            detail: "В текущем расписании есть пересекающиеся интервалы.");
        onComplete(this);
        return;
      }
      await dataStoreNetwork.sendRequest<List<pack_entities.DayTimeInterval>>(
          pack_network.SetSchedule(userId, schedule));
    } catch (e) {
      if (e is Error) {
        error = e;
      } else {
        error = Error("unknown");
        return;
      }
    }
    onComplete(this);
    return;
  }
}
