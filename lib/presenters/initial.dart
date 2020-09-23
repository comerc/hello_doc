import '../interactor/actions/index.dart';
import 'presenter_base.dart';

class Initial extends PresenterBase {
  Initial();
  @override
  void initiate() async {
    await execute(InitializeApplication());
  }
}
