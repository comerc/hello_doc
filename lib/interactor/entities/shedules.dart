import 'dart:async';
import 'package:equatable/equatable.dart';
import 'index.dart';
import 'entity_base.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class UserId extends Equatable {
  final int netwokId;
  UserId(this.netwokId);

  @override
  List<Object> get props => [netwokId];
}

class DayTimeIntervalId extends Equatable {
  final String localId;
  DayTimeIntervalId({String localId}) : localId = localId ?? Uuid().v1();

  @override
  List<Object> get props => [localId];
}

@immutable
class DayTimeInterval extends Equatable {
  final Duration startTime;
  final Duration endTime;
  final int weekday;
  final DateTime localCreationDate;
  final DayTimeIntervalId id;
  final bool isInersected;

  DayTimeInterval(this.weekday, this.startTime, this.endTime,
      [DateTime localCreationDate, DayTimeIntervalId id, bool isIntersected])
      : localCreationDate = localCreationDate ?? DateTime.now(),
        id = id ?? DayTimeIntervalId(),
        isInersected = isIntersected ?? false,
        assert(startTime.compareTo(endTime) <= 0),
        assert(startTime.inMinutes < 14440),
        assert(endTime.inMinutes < 14440),
        assert(weekday != null),
        assert(startTime != null),
        assert(endTime != null);

  DayTimeInterval copyWith(
      {Duration startTime, Duration endTime, bool isInersected}) {
    return DayTimeInterval(
        this.weekday,
        startTime ?? this.startTime,
        endTime ?? this.endTime,
        this.localCreationDate,
        this.id,
        isInersected ?? this.isInersected);
  }

  DayTimeInterval get freeLeft {
    if (startTime == Duration.zero) {
      return null;
    } else {
      return DayTimeInterval(
        this.weekday,
        Duration.zero,
        startTime - Duration(minutes: 30),
      );
    }
  }

  DayTimeInterval get freeRight {
    if (endTime == Duration(hours: 24)) {
      return null;
    } else {
      return DayTimeInterval(
        this.weekday,
        endTime + Duration(minutes: 30),
        Duration(hours: 24),
      );
    }
  }

  bool isIntersectionWith(DayTimeInterval other) {
    bool res = false;

    if (other.startTime.compareTo(this.startTime) >= 0 &&
        other.startTime.compareTo(this.endTime) <= 0) {
      res = true;
    } else if (other.endTime.compareTo(this.startTime) >= 0 &&
        other.endTime.compareTo(this.endTime) <= 0) {
      res = true;
    } else if (other.startTime.compareTo(this.startTime) <= 0 &&
        other.endTime.compareTo(this.endTime) >= 0) {
      res = true;
    }
    return res;
  }

  @override
  List<Object> get props =>
      [startTime, endTime, weekday, localCreationDate, id];
}

enum SheduleExceptionType {
  unknown,
  intersect,
  not_contains,
  already_contains,
  more_than_one
}

class ScheduleException implements Exception {
  final SheduleExceptionType type;
  final dynamic source;
  final int offset;
  @pragma("vm:entry-point")
  const ScheduleException(
      [this.type = SheduleExceptionType.unknown, this.source, this.offset]);

  @override
  String toString() {
    return "ScheduleException: $type";
  }

  String get description {
    switch (type) {
      case SheduleExceptionType.unknown:
        return "Что-то пошло не так...";
        break;
      case SheduleExceptionType.intersect:
        return "Интервалы не должны пересекаться";
        break;
      case SheduleExceptionType.not_contains:
        return "Интервал не существует...";
        break;
      case SheduleExceptionType.already_contains:
        return "Интервал уже существует...";
        break;
      case SheduleExceptionType.more_than_one:
        return "Более одного идентичного интевала";
        break;
      default:
        return "Что-то пошло не так...";
    }
  }
}

abstract class ISchedule extends EntityBase {
  ISchedule(StreamController<EntityBase> controller) : super(controller);
  List<DayTimeInterval> get items;
  set items(List<DayTimeInterval> val);
  Iterable<DayTimeInterval> itemsbyWeekday(int weekday);
  void addItem(DayTimeInterval item);
  void removeItem(DayTimeInterval item);
  void updateItem(DayTimeInterval item);
}

class Schedule extends ISchedule {
  List<DayTimeInterval> _items = [];
  Schedule(StreamController<EntityBase> controller,
      {List<DayTimeInterval> items})
      : _items = items ?? [],
        super(controller);

  @override
  List<DayTimeInterval> get items {
    return List<DayTimeInterval>.unmodifiable(_items);
  }

  @override
  set items(List<DayTimeInterval> items) {
    _items = List<DayTimeInterval>.from(items);
    changed();
  }

  Iterable<DayTimeInterval> itemsbyWeekday(int weekday) =>
      _items.where((element) => element.weekday == weekday);

  @override
  void removeItem(DayTimeInterval item) {
    var intervalsInDay =
        itemsbyWeekday(item.weekday).where((element) => element == item);
    if (intervalsInDay.isEmpty) {
      throw ScheduleException(SheduleExceptionType.not_contains);
    }
    if (intervalsInDay.length > 1) {
      throw ScheduleException(SheduleExceptionType.more_than_one);
    }
    _items.removeWhere((element) => element.id == item.id);
    changed();
  }

  void addItem(DayTimeInterval newInterval) {
    for (var currentInterval in itemsbyWeekday(newInterval.weekday)) {
      if (currentInterval == newInterval) {
        throw ScheduleException(SheduleExceptionType.already_contains);
      }
      if (currentInterval.isIntersectionWith(newInterval)) {
        throw ScheduleException(SheduleExceptionType.intersect);
      }
    }
    _items.add(newInterval);
    changed();
  }

  @override
  void updateItem(DayTimeInterval newInterval) {
    var itemIndex =
        _items.indexWhere((element) => element.id == newInterval.id);

    if (itemIndex < 0) {
      throw ScheduleException(SheduleExceptionType.not_contains);
    }
    // for (var currentInterval in itemsbyWeekday(newInterval.weekday)) {
    //   if (currentInterval.id == newInterval.id) continue;
    //   if (currentInterval.isIntersectionWith(newInterval)) {
    //     if()
    //     throw ScheduleException(SheduleExceptionType.intersect);
    //   }
    // }
    _items[itemIndex] = newInterval;
    changed();
  }

  @override
  EntityBase clone() {
    return Schedule(null, items: List<DayTimeInterval>.from(this._items));
  }
}
