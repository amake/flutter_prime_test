import 'dart:async';

import 'package:flutter/foundation.dart';

class EveryNth<S> extends StreamTransformerBase<S, S> {
  const EveryNth(this.n);

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

@immutable
class TimestampedValue<T> {
  const TimestampedValue(this.value, this.timestamp);

  final T value;
  final DateTime timestamp;

  @override
  String toString() => '$value @ $timestamp';
}

class Timestamp<S> extends StreamTransformerBase<S, TimestampedValue<S>> {
  const Timestamp();

  @override
  Stream<TimestampedValue<S>> bind(Stream<S> stream) =>
      Stream.eventTransformed(stream, (sink) => TimestampSink(sink));
}

class TimestampSink<S> extends EventSink<S> {
  TimestampSink(this.outSink);

  final EventSink<TimestampedValue<S>> outSink;
  @override
  void add(S event) {
    outSink.add(TimestampedValue(event, DateTime.now()));
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

class TimedValue<T> {
  const TimedValue(this.value, this.elapsed);

  final T value;
  final Duration elapsed;

  @override
  String toString() => '$value (+$elapsed)';
}

class EventTimer<S>
    extends StreamTransformerBase<TimestampedValue<S>, TimedValue<S>> {
  const EventTimer();

  @override
  Stream<TimedValue<S>> bind(Stream<TimestampedValue<S>> stream) =>
      Stream.eventTransformed(stream, (sink) => TimerSink(sink));
}

class TimerSink<S> extends EventSink<TimestampedValue<S>> {
  TimerSink(this.outSink);

  final EventSink<TimedValue<S>> outSink;
  TimestampedValue<S> previous;

  @override
  void add(TimestampedValue<S> event) {
    if (previous != null) {
      outSink.add(TimedValue(
          previous.value, event.timestamp.difference(previous.timestamp)));
    }
    previous = event;
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
