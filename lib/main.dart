import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prime Test'),
      ),
      body: Center(child: DartPrimes2()),
    );
  }
}

class DartPrimes extends StatelessWidget {
  final Iterator<int> _iterator = _genPrimes().iterator;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, i) {
        final next = _iterator.moveNext();
        assert(next);
        return Text(_iterator.current.toString());
      },
    );
  }
}

class DartPrimes2 extends StatefulWidget {
  @override
  _DartPrimes2State createState() => _DartPrimes2State();
}

class _DartPrimes2State extends State<DartPrimes2> {
  List _items;
  Isolate _isolate;
  StreamSubscription _subscription;
  ScrollController _scroll;

  @override
  void initState() {
    _items = [];
    _scroll = ScrollController();
    final receivePort = ReceivePort();
    Isolate.spawn(_bgGenPrimes, receivePort.sendPort).then((i) => _isolate = i);
    _subscription = receivePort.transform(EveryNth(250)).listen((prime) {
      setState(() {
        _items.add(prime);
        if (_items.length > 10) {
          _scroll.jumpTo(_scroll.position.maxScrollExtent);
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _scroll.dispose();
    _isolate?.kill(priority: Isolate.immediate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      controller: _scroll,
      itemBuilder: (context, i) {
        return Text(_items[i].toString());
      },
    );
  }
}

Stream<int> _primes = Stream<int>.fromIterable(_genPrimes());

void _bgGenPrimes(SendPort sendPort) {
  for (final prime in _genPrimes()) {
    sendPort.send(prime);
  }
}

Iterable<int> _genPrimes() sync* {
  for (int i = 2;; i++) {
    if (_isPrime(i)) {
      yield i;
    }
  }
}

bool _isPrime(int n) {
  if (n == 2) {
    return true;
  }
  for (int i = n - 1; i > 1; i--) {
    if (n % i == 0) {
      return false;
    }
  }
  return true;
}

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
