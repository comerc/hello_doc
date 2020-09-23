import 'dart:async';
import 'accessor.dart';
import 'entities/index.dart' as pack_entities;
import 'data_stores/network/index.dart' as pack_data_stores;
import 'actions/action_base.dart';
import 'notifications/notification_base.dart';

class AccessorDummy implements IAccessor {
  Map<String, Completer<ActionBase>> actions = {};
  final Map<NotificationBase, Function> _notifications = {};
  final StreamController<pack_entities.EntityBase> _controller =
      StreamController<pack_entities.EntityBase>.broadcast();
  pack_data_stores.INetwork _dataStoreNetwork;

  AccessorDummy() {
    _controller.stream.listen((pack_entities.EntityBase entity) {
      _notifications
          .forEach((NotificationBase notification, Function function) {
        _testNotification(notification, entity);
      });
    });
  }

  @override
  Future initialize() async {}

  // ignore: missing_return
  Future<ActionBase> runAction(ActionBase action) async {}

  void addNotification(NotificationBase notification,
      void Function(NotificationBase result) onNotify) {
    _notifications[notification] = onNotify;
    _testNotificationOnActiveModels(notification);
  }

  void removeNotification(int id) {
    _notifications.removeWhere((item, func) {
      return item.id == id;
    });
  }

  void _testNotification(
      NotificationBase notification, pack_entities.EntityBase entity) {
    if (notification.whenNotify(entity, this)) {
      notification.grabData(entity, this);
      _notifications[notification](notification);
    }
  }

  void _testNotificationOnActiveModels(NotificationBase notification) {}

  void dispose() {
    _controller.close();
  }

  @override
  pack_data_stores.INetwork get dataStoreNetwork {
    return _dataStoreNetwork;
  }

  @override
  void completeAsynchronousAction(AsynchronousActionBase result) {
    actions[result.id].complete(result);
    actions.remove(result.id);
  }

  @override
  // TODO: implement entitieSchedule
  pack_entities.ISchedule get entitieSchedule => throw UnimplementedError();
}
