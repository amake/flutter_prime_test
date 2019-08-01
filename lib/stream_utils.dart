import 'dart:async';

class EveryNth<S> extends StreamTransformerBase<S, S> {
  EveryNth(this.n);

  final int n;
  @override
  Stream<S> bind(Stream<S> stream) =>
      Stream.eventTransformed(stream, (sink) => EveryNthSink<S>(n, sink));
}

class EveryNthSink<S> extends EventSink<S> {
  EveryNthSink(this.n, this.outSink);

  final int n;
  final EventSink<S> outSink;
  int i = 0;

  @override
  void add(S event) {
    if (++i % n == 0) {
      outSink.add(event);
    }
  }

  @override
  void addError(Object error, [StackTrace stackTrace]) {
    outSink.addError(error, stackTrace);
  }

  @override
  void close() {
    outSink.close();
  }
}
