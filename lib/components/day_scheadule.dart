import 'package:flutter/material.dart';
import 'package:hello_doc/interactor/entities/index.dart';
import 'package:hello_doc/interactor/notifications/index.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

extension FormatDuration on Duration {
  String get toFormatString {
    String twoDigits(num n) {
      if (n >= 10) {
        return '$n';
      }
      return '0$n';
    }

    if (inMicroseconds < 0) {
      return '-${(-this).toFormatString}';
    }
    final twoDigitMinutes =
        twoDigits(inMinutes.remainder(Duration.minutesPerHour));
    final twoDigitHours = twoDigits(inHours.remainder(Duration.hoursPerDay));
    return '$twoDigitHours:$twoDigitMinutes';
  }

  double get toValue {
    return inMinutes / 1440;
  }
}

Duration durationFromValue(double value) {
  return Duration(minutes: (1440 * value).round());
}

class DaySchedule extends StatefulWidget {
  final String name;
  final bool active;
  final int weekday;
  final List<IntervalItem> intervals;
  final void Function(bool value, int weekday) onActiveChanged;
  final void Function(Duration start, Duration end, int weekday,
      DayTimeIntervalId intervalId) onIntervalChanged;
  final void Function(int weekday) onIntervalAdded;

  const DaySchedule({
    Key key,
    this.name,
    this.active,
    this.intervals,
    this.weekday,
    this.onActiveChanged,
    this.onIntervalChanged,
    this.onIntervalAdded,
  }) : super(key: key);

  @override
  _DayScheduleState createState() => _DayScheduleState();
}

class _DayScheduleState extends State<DaySchedule> {
  @override
  void didUpdateWidget(covariant DaySchedule oldWidget) {
    var needSetState = false;
    if (widget.name != oldWidget.name) {
      needSetState = true;
    }
    if (widget.active != oldWidget.active) {
      needSetState = true;
    }
    if (widget.weekday != oldWidget.weekday) {
      needSetState = true;
    }
    if (widget.intervals.length != oldWidget.intervals.length) {
      needSetState = true;
    } else {
      for (var i = 0; i < widget.intervals.length; i++) {
        if (widget.intervals[i] != oldWidget.intervals[i]) {
          needSetState = true;
          break;
        }
      }
    }
    if (needSetState) setState(() {});
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: content(context),
    );
  }

  List<Widget> content(BuildContext context) {
    final result = <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.name),
            Switch(
                activeColor: Color(0xFF5775FF),
                value: widget.active,
                onChanged: (value) =>
                    widget.onActiveChanged(value, widget.weekday))
          ],
        ),
      ),
    ];
    if (!widget.active) return result;
    result.addAll(
      widget.intervals.map<Widget>((interval) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: intervalDisplay(interval),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: intervalInput(interval),
            ),
          ],
        );
      }),
    );
    result.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: addInterval(),
    ));
    result.add(
      Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Divider(
          thickness: 10,
          indent: 0,
          color: Color(0xFFF2F5F8),
          height: 10,
        ),
      ),
    );
    return result;
  }

  Widget addInterval() {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: FlatButton(
          padding: EdgeInsets.zero,
          onPressed: () => widget.onIntervalAdded(widget.weekday),
          child: Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                  border: Border.all(
                    width: 1,
                    color: Color(0xFFBFBFD5),
                  ),
                ),
                child: Center(
                  child: Icon(
                    MdiIcons.plus,
                    color: Color(0xFF5775FF),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Добавить временной промежуток',
                    style: TextStyle(
                        fontFamily: 'Ubuntu',
                        fontSize: 17,
                        color: Color(0xFF5775FF)),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget intervalInput(IntervalItem interval) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: RangeSlider(
        activeColor:
            interval.isIntersected ? Colors.redAccent : Color(0xFF5775FF),
        divisions: 48,
        values: RangeValues(interval.start.toValue, interval.end.toValue),
        onChanged: (RangeValues rangeValues) {
          widget.onIntervalChanged(durationFromValue(rangeValues.start),
              durationFromValue(rangeValues.end), widget.weekday, interval.id);
        },
      ),
    );
  }

  Widget intervalDisplay(IntervalItem interval) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Container(
            height: 55,
            // width: 141,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                width: 1,
                color: Color(0xFFBFBFD5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  interval.start.toFormatString,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 24),
                child: Divider(
                  height: 1,
                  color: Color(0xFFBFBFD5),
                ),
              ),
            ),
          ),
          Container(
            height: 55,
            // width: 141,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                width: 1,
                color: Color(0xFFBFBFD5),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: Text(
                  interval.end.toFormatString,
                  style: TextStyle(
                    fontFamily: 'Ubuntu',
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
