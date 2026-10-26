import 'package:flutter/material.dart';
import 'package:future_builder_ex/future_builder_ex.dart';

import 'deferred_state.dart';

/// Use [DeferredBuilder] in your [State] build method to wait for
/// the [DeferredState] to complete initialisation.
/// ```dart
/// Widget build(BuildContext context)
/// {
///   return DeferredBuilder(this, builder: (context) =>  ....)
/// }
/// ```
class DeferredBuilder extends StatelessWidget {
  const DeferredBuilder(this.state,
      {required this.builder,
      this.waitingBuilder,
      this.errorBuilder,
      super.key});

  final DeferredState state;
  final WaitingBuilder? waitingBuilder;
  final ErrorBuilder? errorBuilder;
  final WidgetBuilder builder;
  @override
  Widget build(BuildContext context) => FutureBuilderEx(
      future: state.initialised,
      waitingBuilder: waitingBuilder,
      errorBuilder: errorBuilder ??
          (context, error) =>
              const Center(child: Text('Unable to initialise this view.')),
      builder: (context, _) => builder(context));
}
