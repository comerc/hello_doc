import 'package:flutter/material.dart';
import 'package:hello_doc/utilities/logging.dart';
import 'presenter_base.dart';
// import '../views/view_base.dart';

class PresenterProvider<T extends PresenterBase> extends StatefulWidget {
  final T presenter;
  final Widget child;

  PresenterProvider({
    Key key,
    @required this.child,
    @required this.presenter,
  }) : super(key: key);

  @override
  _ProviderState<T> createState() => _ProviderState<T>();

  static T of<T extends PresenterBase>(BuildContext context) {
    final provider =
        context.findAncestorWidgetOfExactType<PresenterProvider<T>>();
    return provider?.presenter;
  }

  static bool hasPresenter<T extends PresenterBase>(BuildContext context) {
    var hasPresenter = false;
    try {
      hasPresenter = PresenterProvider.of<T>(context) != null;
    } catch (error) {
      Logger.logError(error);
    }
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
