import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_prime_test/stream_utils.dart';

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
      body: Center(
        child: Execute(
          entryPoint: _bgGenPrimes,
          builder: (stream) => StreamListView(stream: stream),
        ),
      ),
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

class Execute extends StatefulWidget {
  const Execute({@required this.entryPoint, @required this.builder});

  final Function entryPoint;
  final Widget Function(Stream) builder;

  @override
  _ExecuteState createState() => _ExecuteState();
}

class _ExecuteState extends State<Execute> {
  ReceivePort _receivePort;
  Isolate _isolate;

  @override
  void initState() {
    _receivePort = ReceivePort();
    Isolate.spawn(widget.entryPoint, _receivePort.sendPort)
        .then((i) => _isolate = i);
    super.initState();
  }

  @override
  void dispose() {
    _isolate?.kill(priority: Isolate.immediate);
    _receivePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_receivePort);
  }
}

class StreamListView extends StatefulWidget {
  const StreamListView({@required this.stream, this.follow = true});

  final Stream stream;
  final bool follow;

  @override
  _StreamListViewState createState() => _StreamListViewState();
}

class _StreamListViewState extends State<StreamListView> {
  List _items;
  StreamSubscription _subscription;
  ScrollController _scroll;

  @override
  void initState() {
    _items = [];
    _scroll = ScrollController();
    _subscription = widget.stream
        .transform(const EveryNth(250))
        .transform(const Timestamp())
        .transform(const Timer())
        .listen((prime) {
      setState(() {
        _items.add(prime);
        if (widget.follow && _items.length > 10) {
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
