import 'package:uuid/uuid.dart';
import '../entities/index.dart' as pack_entities;
import '../accessor.dart';

class Error {
  final int status;
  final String title;
  final String detail;
  final String code;
  final Map data;

  Error(
    this.code, {
    this.status,
    this.title,
    this.detail,
    this.data,
  });
}

abstract class ActionBase {
  Error error;
  final String _id;
  bool isHaveError() {
    return (error != null);
  }

  ActionBase({String id}) : _id = id ?? Uuid().v4();

  void doAction(IAccessor accessor, void onComplete(ActionBase result));
  String get id => _id;
}

enum AsynchronousActionState { unknown, in_progress, pause, complete, error }
enum ErrorStatus { resolved, unresolved, need_user_response }

abstract class AsynchronousActionBase extends ActionBase {
  AsynchronousActionBase({String id}) : super(id: id);
  AsynchronousActionState state = AsynchronousActionState.unknown;

  Future<ErrorStatus> resolveError(IAccessor accessor);
  Future init(IAccessor accessor);
}
