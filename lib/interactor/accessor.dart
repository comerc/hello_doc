import 'dart:core';
import 'dart:async';
import 'dart:isolate';
import 'package:gate/gate.dart';
import '../utilities/logging.dart';
import 'entities/index.dart' as pack_entities;
import 'data_stores/network/index.dart' as pack_data_stores;
import 'actions/action_base.dart';
import 'notifications/notification_base.dart';

abstract class IAccessor {
  pack_data_stores.INetwork get dataStoreNetwork;
  pack_entities.ISchedule get entitieSchedule;

  Future initialize();

  void completeAsynchronousAction(AsynchronousActionBase action);
}

class Accessor extends Worker implements IAccessor {
  pack_data_stores.INetwork _dataStoreNetwork;
  pack_entities.ISchedule _entitieSchedule;
  final List<NotificationBase> _notifications = [];
  final StreamController<pack_entities.EntityBase> _controller =
      StreamController<pack_entities.EntityBase>.broadcast();
  Map<String, dynamic> mainThreadData;

  Accessor(SendPort sendPort) : super(sendPort);

  @override
  pack_data_stores.INetwork get dataStoreNetwork {
    _dataStoreNetwork ??= pack_data_stores.RestNetwork();
    return _dataStoreNetwork;
  }

  @override
  pack_entities.ISchedule get entitieSchedule {
    _entitieSchedule ??= pack_entities.Schedule(_controller);
    return _entitieSchedule;
  }

  @override
  Future initialize() async {
    dataStoreNetwork.init();
  }

  @override
  void onNewMessage(dynamic data) {
    Logger.logAccessor('New message from controller: $data');
    if (data is NotificationBase) {
      _notifications.add(data);
      _testNotificationOnActiveModels(data);
    } else if (data is ActionBase) {
      final action = data;
      _runAction(action);
    } else if (data is int) {
      final notificationId = data;
      _notifications.removeWhere((item) {
        return item.id == notificationId;
      });
    }
  }

  @override
  void onWork() {
    _controller.stream.listen((pack_entities.EntityBase entity) {
      for (final notification in _notifications) {
        _testNotification(notification, entity);
      }
    });
  }

  void _testNotification(
      NotificationBase notification, pack_entities.EntityBase entity) {
    if (entity == null) return;
    if (notification.whenNotify(entity, this)) {
      notification.grabData(entity, this);
      send(notification);
    }
  }

  void _runAction(ActionBase action) {
    if (action is AsynchronousActionBase) {
    } else {
      action.doAction(this, (ActionBase result) {
        send(result);
      });
    }
  }

  void _testNotificationOnActiveModels(NotificationBase notification) {
    _testNotification(notification, _entitieSchedule);
  }

  void dispose() {
    _controller.close();
  }

  @override
  void completeAsynchronousAction(AsynchronousActionBase action) {
    send(action);
  }
}
