import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'notification_base.dart';
import '../entities/index.dart';
import '../accessor.dart';

@immutable
class IntervalItem extends Equatable {
  final Duration start;
  final Duration end;
  final DateTime localCreationDate;
  final DayTimeIntervalId id;
  final bool isIntersected;
  IntervalItem(this.start, this.end, this.localCreationDate, this.id,
      this.isIntersected);

  @override
  List<Object> get props => [start, end, localCreationDate, id, isIntersected];
}

@immutable
class DayItem {
  final String name;
  final bool active;
  final int number;
  final List<IntervalItem> intervals;
  DayItem(this.name, this.active, this.intervals, this.number);
}

class ScheduleNotifier extends NotificationBase {
  static const Map<int, String> weekdayNames = {
    1: 'Понедельник',
    2: 'Вторник',
    3: 'Среда',
    4: 'Четверг',
    5: 'Пятница',
    6: 'Суббота',
    7: 'Воскресение',
  };

  List<DayItem> model;

  @override
  bool whenNotify(EntityBase entity, IAccessor accessor) {
    if (!(entity is ISchedule)) return false;
    return true;
  }

  @override
  void grabData(EntityBase entity, IAccessor accessor) {
    if (!(entity is ISchedule)) return;
    final newModel = <DayItem>[];
    final schedule = entity as ISchedule;
    for (var i = 1; i <= 7; i++) {
      var intervals = schedule.itemsByWeekday(i);
      if (intervals.isEmpty) {
        newModel.add(DayItem(weekdayNames[i], false, [], i));
      } else {
        final intervalItems = List<IntervalItem>.from(
            intervals.map<IntervalItem>((e) => IntervalItem(e.startTime,
                e.endTime, e.localCreationDate, e.id, e.isInersected)));
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
