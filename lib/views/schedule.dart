import 'package:flutter/material.dart';
import 'package:hello_doc/application_settings.dart';
import '../presenters/index.dart' as presenters;
import '../components/index.dart' as components;
import '../interactor/notifications/index.dart' as notifications;
// import 'package:platform_alert_dialog/platform_alert_dialog.dart' as alert;

class Schedule extends StatefulWidget {
  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  ScrollController _controller;
  bool isElevation = false;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_scrollListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final presenter =
        presenters.PresenterProvider.of<presenters.Schedule>(context);
    return MaterialApp(
      title: ApplicationSettings.appName,
      navigatorKey: presenter.mainNavigationKey,
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        appBar: PreferredSize(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Material(
                  elevation: isElevation ? 2 : 0,
                  child: Container(
                    color: Color(0xFFF2F5F8),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                    ),
                    height: 110,
                    child: components.Header(),
                  ),
                );
              },
            ),
            preferredSize: Size(0, 130)),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ValueListenableBuilder<bool>(
            valueListenable: presenter.loading,
            builder: (BuildContext context, bool loading, _) {
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
                                onPressed: () async {
                                  final error = await presenter.save();
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
        body: ValueListenableBuilder(
            valueListenable: presenter.isErrorLoading,
            builder: (BuildContext context, bool isErrorLoading, _) {
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
                                                  AlwaysStoppedAnimation<Color>(
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
              }
              return ValueListenableBuilder(
                valueListenable: presenter.loading,
                builder: (BuildContext context, bool loading, _) {
                  if (loading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return CustomScrollView(
                    controller: _controller,
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          child: Text(
                            'Укажите время, когда вы доступны для звонков и сможете быстро отвечать пациентам',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF464850)),
                          ),
                        ),
                      ),
                      StreamBuilder<List<notifications.DayItem>>(
                          stream: presenter.scheduleModelStream,
                          builder: (context, snapshot) {
                            return SliverList(
                                delegate: snapshot.hasData
                                    ? SliverChildListDelegate(
                                        _buildSheduleList(
                                            snapshot, presenter, context),
                                      )
                                    : SliverChildListDelegate([]));
                          }),
                    ],
                  );
                },
              );
            }),
      ),
    );
  }

  List<Widget> _buildSheduleList(
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

  void _scrollListener() {
    if (isElevation != (_controller.offset > 0)) {
      setState(() {
        isElevation = !isElevation;
      });
    }
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
