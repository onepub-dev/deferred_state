import 'package:async_state/async_state.dart';
import 'package:flutter/material.dart';
import 'package:future_builder_ex/future_builder_ex.dart';

/// Create your on [AwaitAsyncInit] to customise the
/// error and waiting builders without having to
/// specify them at every call site.
class MyAwaitAsyncInit extends StatelessWidget {
  MyAwaitAsyncInit(this.state,
      {required this.builder, this.waitingBuilder, this.errorBuilder});
  final AsyncState state;
  final WidgetBuilder builder;

  /// Include the waiting and error builders if you
  /// might want to do further customisation at some
  /// call sites otherwise delete these fields.
  final WaitingBuilder? waitingBuilder;
  final ErrorBuilder? errorBuilder;

  Widget build(BuildContext context) => AwaitAsyncInit(state,
      waitingBuilder: (context) => Center(child: Text('waiting')),
      errorBuilder: (context, error) => Center(child: Text(error.toString())),
      builder: (context) => builder(context));
}
