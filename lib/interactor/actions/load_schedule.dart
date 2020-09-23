import 'package:hello_doc/utilities/logging.dart';
import 'action_base.dart';
import '../accessor.dart';
import '../entities/index.dart' as pack_entities;
import '../data_stores/network/index.dart' as pack_network;

class LoadSchedule extends ActionBase {
  final pack_entities.UserId userId;

  LoadSchedule(this.userId);
  @override
  void doAction(
    IAccessor accessor,
    void Function(ActionBase result) onComplete,
  ) async {
    var dataStoreNetwork = accessor.dataStoreNetwork;
    var entitieSchedule = accessor.entitieSchedule;
    try {
      var result = await dataStoreNetwork
          .sendRequest<List<pack_entities.DayTimeInterval>>(
              pack_network.GetSchedule(userId));
      entitieSchedule.items = result;
    } catch (e) {
      if (e is Error) {
        error = e;
      } else {
        error = Error('unknown');
      }
      // TODO: почему ошибка не попадает в Logger? (много подобного в наследниках ActionBase)
      Logger.logError(error);
    }
    onComplete(this);
    return;
  }
}
