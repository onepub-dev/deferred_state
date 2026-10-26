import 'package:deferred_state/deferred_state.dart';
import 'package:flutter/material.dart';
import 'package:future_builder_ex/future_builder_ex.dart';

/// Create your on [DeferredBuilder] to customise the
/// error and waiting builders without having to
/// specify them at every call site.
class MyDeferredBuilder extends StatelessWidget {
  const MyDeferredBuilder(this.state,
      {required this.builder,
      super.key,
      this.waitingBuilder,
      this.errorBuilder});
  final DeferredState state;
  final WidgetBuilder builder;

  /// Include the waiting and error builders if you
  /// might want to do further customisation at some
  /// call sites otherwise delete these fields.
  final WaitingBuilder? waitingBuilder;
  final ErrorBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) => DeferredBuilder(state,
      waitingBuilder:
          waitingBuilder ?? (context) => const Center(child: Text('waiting')),
      errorBuilder: errorBuilder ??
          (context, error) =>
              const Center(child: Text('Unable to load this view.')),
      builder: builder);
}
