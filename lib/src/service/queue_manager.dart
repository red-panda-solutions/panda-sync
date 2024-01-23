import 'package:hive/hive.dart';

import 'package:panda_sync/src/model/request.dart';

class QueueManager {
  final Box<Request> _queueBox;

  QueueManager(this._queueBox);

  void push(Request request) {
    _queueBox.add(request);
  }

  Request? pop() {
    if (_queueBox.isNotEmpty) {
      var request = _queueBox.getAt(0);
      _queueBox.deleteAt(0);
      return request;
    }
    return null;
  }

  bool isQueueEmpty() {
    return _queueBox.isEmpty;
  }
}