import 'package:flutter/material.dart';
import '../views/view_base.dart';
import '../presenters/index.dart' as presenters;
import '../widgets/index.dart' as widgets;
import '../components/index.dart' as components;
import '../interactor/notifications/index.dart' as notifications;
// import 'package:platform_alert_dialog/platform_alert_dialog.dart' as alert;

class Schedule extends ViewBase {
  @override
  Widget build(BuildContext context) {
    final presenter =
        presenters.PresenterProvider.of<presenters.Schedule>(context);
    return MaterialApp(
      navigatorKey: presenter.mainNavigationKey,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        // TODO: исправить Scaffold.appBar (SafeArea, preferredSize)
        appBar: PreferredSize(
            child: SafeArea(child: Container()), preferredSize: Size(0, 30)),
        backgroundColor: Color(0xFFF2F5F8),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: presenter.loading,
            builder: (context, loading, _) {
              return ValueListenableBuilder(
                  valueListenable: presenter.isErrorLoading,
                  builder: (context, bool isErrorLoading, _) {
                    if (isErrorLoading || loading) return Container();
                    return ValueListenableBuilder<bool>(
                        valueListenable: presenter.busy,
                        builder: (context, busy, _) {
                          return SizedBox(
                            width: 250,
                            child: IgnorePointer(
                              ignoring: busy,
                              child: RaisedButton(
                                color: Color(0xFF5775FF),
                                // shape: ShapeBorder(),
                                onPressed: () async {
                                  var error = await presenter.save();
                                  if (error != null) {
                                    // ignore: unawaited_futures
                                    _showInfo(
                                        context, error.title, error.detail);
                                  }
                                },
                                child: busy
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Готово',
                                        style: TextStyle(
                                          fontFamily: 'Ubuntu',
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          );
                        });
                  });
            }),
        body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: ValueListenableBuilder(
              valueListenable: presenter.isErrorLoading,
              builder: (context, bool isErrorLoading, _) {
                if (isErrorLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Не удалось загрузить расписание'),
                        ),
                        ValueListenableBuilder<bool>(
                            valueListenable: presenter.busy,
                            builder: (context, busy, _) {
                              return SizedBox(
                                width: 250,
                                child: IgnorePointer(
                                  ignoring: busy,
                                  child: RaisedButton(
                                    color: Color(0xFF5775FF),
                                    // shape: ShapeBorder(),
                                    onPressed: () async {
                                      await presenter.reload();
                                    },
                                    child: busy
                                        ? SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Загрузить снова',
                                            style: TextStyle(
                                              fontFamily: 'Ubuntu',
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              );
                            })
                      ],
                    ),
                  );
                } else {
                  return ValueListenableBuilder(
                    valueListenable: presenter.loading,
                    builder: (context, bool loading, _) {
                      return loading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : CustomScrollView(
                              slivers: <Widget>[
                                widgets.SnapSliver(
                                  floating: false,
                                  pinned: false,
                                  maxHeight:
                                      MediaQuery.of(context).padding.top + 130,
                                  minHeight:
                                      MediaQuery.of(context).padding.top + 130,
                                  onSnapChanged: (snap) {},
                                  child: components.Header(),
                                ),
                                StreamBuilder<List<notifications.DayItem>>(
                                    stream: presenter.scheduleModelStream,
                                    builder: (context, snapshot) {
                                      return SliverList(
                                          delegate: snapshot.hasData
                                              ? SliverChildListDelegate(
                                                  buildSheduleList(snapshot,
                                                      presenter, context),
                                                )
                                              : SliverChildListDelegate([]));
                                    }),
                              ],
                            );
                    },
                  );
                }
              }),
        ),
      ),
    );
  }

  List<Widget> buildSheduleList(
      AsyncSnapshot<List<notifications.DayItem>> snapshot,
      presenters.Schedule presenter,
      BuildContext context) {
    var res = List<Widget>.from(
      snapshot.data.map<Widget>((dayItem) {
        return components.DaySchedule(
          key: Key('DaySchedule_${dayItem.name}'),
          name: dayItem.name,
          intervals: dayItem.intervals,
          active: dayItem.active,
          weekday: dayItem.number,
          onActiveChanged: (value, weekday) {
            if (value) {
              presenter.activateDay(weekday);
            } else {
              presenter.deactivateDay(weekday);
            }
          },
          onIntervalAdded: (weekday) async {
            var error = await presenter.addScheduleInterval(weekday);
            if (error != null) {
              // ignore: unawaited_futures
              _showInfo(context, error.title, error.detail);
            }
          },
          onIntervalChanged: (start, end, weekday, intervalId) {
            presenter.changeInterval(weekday, start, end, intervalId);
          },
        );
      }),
    );
    res.add(Container(
      height: MediaQuery.of(context).padding.bottom + 80,
    ));
    return res;
  }

  Future<void> _showInfo(
      BuildContext context, String header, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header ?? 'Ошибка'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(content ?? 'Что-то пошло не так...'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Ок'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
