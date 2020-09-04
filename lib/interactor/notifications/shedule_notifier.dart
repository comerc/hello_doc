import 'package:flutter/foundation.dart';

import 'notification_base.dart';
import '../entities/index.dart';
import '../accessor.dart';

@immutable
class IntervalItem {
  final Duration start;
  final Duration end;
  final DateTime localCreationDate;
  IntervalItem(this.start, this.end, this.localCreationDate);
}

@immutable
class DayItem {
  final String name;
  final bool active;
  final int number;
  final List<IntervalItem> intervals;
  DayItem(this.name, this.active, this.intervals, this.number);
}

class SheduleNotifier extends NotificationBase {
  static const Map<int, String> weekdayNames = {
    1: "Понедельник",
    2: "Вторник",
    3: "Среда",
    4: "Четверг",
    5: "Пятница",
    6: "Суббота",
    7: "Воскресение",
  };

  List<DayItem> model;

  bool whenNotify(EntityBase entity, IAccessor accessor) {
    if (!(entity is ISchedule)) return false;
    return true;
  }

  void grabData(EntityBase entity, IAccessor accessor) {
    if (!(entity is ISchedule)) return;
    List<DayItem> newModel = [];
    ISchedule schedule = entity;
    for (int i = 1; i <= 7; i++) {
      var intervals = schedule.itemsbyWeekday(i);
      if (intervals.isEmpty) {
        newModel.add(DayItem(weekdayNames[i], false, [], i));
      } else {
        List<IntervalItem> intervalItems = List<IntervalItem>.from(
          intervals.map<IntervalItem>(
            (e) => IntervalItem(e.startTime, e.endTime, e.localCreationDate),
          ),
        );
        intervalItems.sort((a, b) {
          return a.localCreationDate.compareTo(b.localCreationDate);
        });
        newModel.add(DayItem(weekdayNames[i], true, intervalItems, i));
      }
    }
    newModel.sort((a, b) {
      return a.number.compareTo(b.number);
    });
    model = newModel;
  }
}
