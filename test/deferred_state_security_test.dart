import 'dart:async';

import 'package:deferred_state/deferred_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Probe extends StatefulWidget {
  const _Probe(this.initialize, {this.errorBuilder, super.key});

  final Future<void> Function() initialize;
  final Widget Function(BuildContext, Object)? errorBuilder;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _NoBuilderProbe extends StatefulWidget {
  const _NoBuilderProbe(this.initialize);

  final Future<void> Function() initialize;

  @override
  State<_NoBuilderProbe> createState() => _NoBuilderProbeState();
}

class _NoBuilderProbeState extends DeferredState<_NoBuilderProbe> {
  @override
  Future<void> asyncInitState() => widget.initialize();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _ProbeState extends DeferredState<_Probe> {
  @override
  Future<void> asyncInitState() => widget.initialize();

  @override
  Widget build(BuildContext context) => DeferredBuilder(
        this,
        errorBuilder: widget.errorBuilder,
        builder: (_) => const Text('ready'),
      );
}

void main() {
  testWidgets('asynchronous failure completes with a safe error view', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(home: _Probe(() => initialization.future)),
    );
    expect(find.text('ready'), findsNothing);

    initialization.completeError(StateError('token=private-value'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Unable to initialise this view.'), findsOneWidget);
    expect(find.textContaining('private-value'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('synchronous initializer throw reaches a custom error view', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _Probe(
          () => throw StateError('failed'),
          errorBuilder: (_, error) => Text('handled: ${error.runtimeType}'),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('handled: StateError'), findsOneWidget);
    expect(find.text('ready'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful initialization renders content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: _Probe(() async {})),
    );
    await tester.pump();
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('initialization error is handled without a mounted builder', (
    tester,
  ) async {
    final initialization = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(home: _NoBuilderProbe(() => initialization.future)),
    );
    initialization.completeError(StateError('failure without builder'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('initialization preserves the original error and stack', (
    tester,
  ) async {
    final initialization = Completer<void>();
    final key = GlobalKey<_ProbeState>();
    await tester.pumpWidget(
      MaterialApp(home: _Probe(() => initialization.future, key: key)),
    );
    final error = StateError('initialization failed');
    final stack = StackTrace.current;
    Object? observedError;
    StackTrace? observedStack;
    final observed = key.currentState!.initialised.then<void>(
      (_) => fail('Expected an initialization error'),
      onError: (Object actual, StackTrace actualStack) {
        observedError = actual;
        observedStack = actualStack;
      },
    );
    initialization.completeError(error, stack);
    await tester.pump();
    await observed;
    expect(identical(observedError, error), isTrue);
    expect(identical(observedStack, stack), isTrue);
    expect(tester.takeException(), isNull);
  });
}
