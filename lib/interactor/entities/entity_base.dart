import 'dart:async';

abstract class EntityBase {
  final StreamController<EntityBase> _controller;
  EntityBase(this._controller) {
    changed();
  }
  EntityBase.from(EntityBase other) : _controller = other._controller;
  void changed() {
    if (_controller == null) return;
    _controller.sink.add(clone());
  }

  EntityBase clone();
}
