import 'package:gate/gate.dart';
import '../utilities/logging.dart';
import 'dart:isolate';
import 'dart:async';
import 'actions/action_base.dart';
import 'notifications/notification_base.dart';
import 'accessor.dart';

class AccessorController extends Controller {
  final StreamController<NotificationBase> _controller =
      StreamController<NotificationBase>.broadcast(onListen: () {
    Logger.logAccessor('InteractorController, notification: LISTEN');
  }, onCancel: () {
    Logger.logAccessor('InteractorController, notification: CANCEL');
  });

  final StreamController<ActionBase> _actionController =
      StreamController<ActionBase>.broadcast(
    onListen: () {
      Logger.logAccessor('InteractorController, action: LISTEN');
    },
    onCancel: () {
      Logger.logAccessor('InteractorController, action: CANCEL');
    },
  );
  final List<NotificationBase> _notificationsBuffer = <NotificationBase>[];
  final List<ActionBase> _actionsBuffer = <ActionBase>[];
  static final AccessorController _interator = AccessorController._internal();
  AccessorController._internal();

  Stream<NotificationBase> get notificationStream => _controller.stream;
  Stream<ActionBase> get actionStream => _actionController.stream;

  void addNotification(NotificationBase notification) {
    if (state == ControllerState.initialized) {
      send(notification);
    } else {
      _notificationsBuffer.add(notification);
    }
  }

  void removeNotification(int notificationId) {
    if (state == ControllerState.initialized) send(notificationId);
  }

  void addAction(ActionBase action) {
    if (state == ControllerState.initialized) {
      send(action);
    } else {
      _actionsBuffer.add(action);
    }
  }

  static bool initial = false;
  factory AccessorController() {
    if (!initial) {
      _interator.startWorking(work);
      initial = true;
    }
    return _interator;
  }

  @override
  void onNewMessage(dynamic data) {
    if (data is NotificationBase) {
      Logger.logAccessor('New message from interactor: $data, ${data.id}');
      _controller.sink.add(data);
    } else if (data is ActionBase) {
      Logger.logAccessor('New message from interactor: $data, ${data.id}');
      _actionController.sink.add(data);
    }
  }

  @override
  void onError(dynamic err) {
    Logger.logError('$err');
  }

  @override
  void onStateChanged(ControllerState state) {
    Logger.logAccessor('New controller state: $state');
    if (state == ControllerState.initialized) {
      if (_notificationsBuffer.isNotEmpty) {
        for (final notification in _notificationsBuffer) {
          send(notification);
        }
        _notificationsBuffer.clear();
      }
      if (_actionsBuffer.isNotEmpty) {
        for (final action in _actionsBuffer) {
          send(action);
        }
        _actionsBuffer.clear();
      }
    }
  }

  static void work(SendPort sendPort) {
    Accessor(sendPort).work();
  }

  void dispose() {
    _controller.close();
    _actionController.close();
  }
}
