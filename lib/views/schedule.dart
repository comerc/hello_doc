import 'package:flutter/material.dart';
import '../views/view_base.dart';
import '../presenters/index.dart' as presenters;
import '../widgets/index.dart' as widgets;
import '../components/index.dart' as components;
import '../interactor/notifications/index.dart' as notifications;

class Schedule extends ViewBase {
  @override
  Widget build(BuildContext context) {
    final presenters.Schedule presenter =
        presenters.PresenterProvider.of<presenters.Schedule>(context);
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
      ),
      home: Scaffold(
        appBar: PreferredSize(
            child: SafeArea(child: Container()), preferredSize: Size(0, 30)),
        backgroundColor: Color(0xFFF2F5F8),
        body: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: ValueListenableBuilder(
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
                          maxHeight: MediaQuery.of(context).padding.top + 130,
                          minHeight: MediaQuery.of(context).padding.top + 130,
                          onSnapChanged: (snap) {},
                          child: components.Header(),
                        ),
                        StreamBuilder<List<notifications.DayItem>>(
                            stream: presenter.scheduleModelStream,
                            builder: (context, snapshot) {
                              return SliverList(
                                  delegate: snapshot.hasData
                                      ? SliverChildListDelegate(
                                          List<Widget>.from(
                                            snapshot.data
                                                .map<Widget>((dayItem) {
                                              return components.DaySchedule(
                                                name: dayItem.name,
                                                intervals: dayItem.intervals,
                                                active: dayItem.active,
                                                onActiveChanged:
                                                    (value, weekday) {},
                                                onIntervalAdded: (weekday) {},
                                                onIntervalChanged: (start, end,
                                                    weekday, intervalId) {},
                                              );
                                            }),
                                          ),
                                        )
                                      : SliverChildListDelegate([]));
                            }),
                      ],
                    );
            },
          ),
        ),
      ),
    );
  }
}
