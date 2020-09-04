import 'package:flutter/material.dart';
import 'presenter_base.dart';
import '../views/view_base.dart';

class PresenterProvider<T extends PresenterBase> extends StatefulWidget {
  final presenter;
  final ViewBase child;

  PresenterProvider({
    Key key,
    @required this.child,
    @required this.presenter,
  }) : super(key: key);

  @override
  _ProviderState<T> createState() => _ProviderState<T>();

  static T of<T extends PresenterBase>(BuildContext context) {
    PresenterProvider<T> provider =
        context.findAncestorWidgetOfExactType<PresenterProvider<T>>();
    return provider?.presenter;
  }

  static bool hasPresenter<T extends PresenterBase>(BuildContext context) {
    bool hasPresenter = false;
    try {
      hasPresenter = PresenterProvider.of<T>(context) != null;
    } catch (e) {}
    return hasPresenter;
  }
}

class _ProviderState<T> extends State<PresenterProvider<PresenterBase>>
    with AutomaticKeepAliveClientMixin {
  bool presenterInited = false;

  @override
  void didUpdateWidget(PresenterProvider oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    widget.presenter?.doInitiate();
    super.initState();
  }

  @override
  void dispose() {
    widget.presenter?.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
