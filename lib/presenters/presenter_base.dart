import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import '../utilities/logging.dart';
import '../interactor/accessor_controller.dart';
import '../interactor/actions/action_base.dart';
import '../interactor/notifications/notification_base.dart';
import '../interactor/actions/index.dart';

abstract class PresenterBase {
  final AccessorController _controller = AccessorController();
  bool initiated = false;

  final Set<int> _myNotifications = {};
  final Set<String> _myActions = {};

  final ValueNotifier<String> networkError = ValueNotifier<String>(null);

  PresenterBase() {
    // Logger.logPresenter("New bloc presenter: $runtimeType");
  }
  int get backButtonZIndex => 0;
  void doInitiate() {
    BackButtonInterceptor.add(onBackButton, zIndex: backButtonZIndex);
    initiate();
    initiated = true;
  }

  void initiate();

  Future<T> execute<T extends ActionBase>(T action) async {
    T actionRes;
    _myActions.add(action.id);
    _controller.addAction(action);

    Logger.logAccessor('Execute start: ${action.id}');

    await _controller.actionStream.any((ActionBase action) {
      if (!(action is T)) return false;
      final result = _myActions.contains(action.id);
      if (result) {
        _myActions.remove(action.id);
        actionRes = action as T;
      }
      if (initiated) {
        return result;
      } else {
        return false;
      }
    });
    if (initiated) return actionRes;
    return null;
  }

  Stream<T> subscribeTo<T extends NotificationBase>(T notification) {
    _myNotifications.add(notification.id);
    _controller.addNotification(notification);
    return _controller.notificationStream.where((notification) {
      var result = false;
      if (_myNotifications.contains(notification.id)) {
        result = notification is T;
      }
      return result;
    }).cast<T>();
  }

  void unsubscribeTo(NotificationBase notification) {
    _controller.removeNotification(notification.id);
    _myNotifications.remove(notification.id);
  }

  bool onBackButton(bool stop, RouteInfo routeInfo) => false;

  void dispose() {
    Logger.logPresenter('Dispose presenter: $runtimeType');
    BackButtonInterceptor.remove(onBackButton);

    for (final notificationId in _myNotifications) {
      _controller.removeNotification(notificationId);
    }
    _myNotifications.clear();
    initiated = false;
  }
}

enum PhoneCodeConfirmationResult {
  Success,
  Discard,
}
