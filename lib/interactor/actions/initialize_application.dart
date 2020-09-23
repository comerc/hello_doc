import 'action_base.dart';
import '../accessor.dart';
// import '../data_stores/network/index.dart' as pack_network;
// import '../data_stores/database/index.dart' as pack_database;
// import '../entities/index.dart' as pack_entities;
// import '../../utilities/logging.dart';

class InitializeApplication extends ActionBase {
  InitializeApplication();

  @override
  void doAction(
    IAccessor accessor,
    void Function(ActionBase result) onComplete,
  ) async {
    await accessor.initialize();
    onComplete(this);
  }
}
