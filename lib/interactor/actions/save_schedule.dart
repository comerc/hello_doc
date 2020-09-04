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

      await dataStoreNetwork.sendRequest<List<pack_entities.DayTimeInterval>>(
          pack_network.SetSchedule(userId, schedule));
    } catch (e) {
      if (e is Error) {
        error = e;
      } else {
        error = Error("unknown");
        return;
      }
      onComplete(this);
    }
  }
}
