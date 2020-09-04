import '../accessor.dart';

import '../entities/entity_base.dart';

abstract class NotificationBase {
  NotificationBase() {
    _id = counter;
    ++counter;
  }
  bool whenNotify(EntityBase model, IAccessor accessor);
  void grabData(EntityBase model, IAccessor accessor);

  int get id => _id;

  int _id;
  static int counter = 0;
}
