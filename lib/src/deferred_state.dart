import 'dart:async';

import 'package:flutter/material.dart';

import '../deferred_state.dart';
import 'deferred_builder.dart';

///
/// [DeferredState] makes it easy to do async initialisation
/// of a [StatefulWidget]
///
/// Instead of [StatefulWidget] deriving from [State] you derive
/// from [DeferredState].
///
/// You can then override the 'asyncInitState' method to do some
/// asynchrounus initialisation.
/// You then use [DeferredBuilder] to wait for the state
/// to be initialised.
///

///
/// Any items that are to be disposed should be called in the standard
/// [initState] as in some cases the [dispose] can be called before
/// [asyncInitState] has completed.
///
/// ```dart
///
/// class _WeekScheduleState extends DeferredState<WeekSchedule> {
///
/// late final System system;
/// late final EventController<JobActivity> _weekController;
///
/// /// Items that are to be disposed must go in [initState]
/// @override
/// void initState() {
///     _weekController = EventController();
///     // this must be called last.
///     super.initState();
/// }
///
/// @override
/// Future<void> asyncInitState() async {
///     system = await DaoSystem().get();
/// }
///
///  @override
///  void dispose() {
///    _weekController.dispose();
///    super.dispose();
///  }
///
/// Widget build(BuildContext context)
/// {
///   /// Waits for [asyncInitState] to complete and then calls
///   /// the builder.
///   return DeferredBuilder(this, builder: (context) =>  Text(system.name));
/// }
/// ```
///
abstract class DeferredState<T extends StatefulWidget> extends State<T> {
  final _initialised = Completer<void>();

  @override
  void initState() {
    super.initState();

    unawaited(asyncInitState().then<void>(_initialised.complete));
  }

  /// Do any asynchronous intialisation in this method
  /// As soon as you code returns from this method
  /// the state is considered initialised, so use await to ensure
  /// all your initialisation is complete before returning.
  /// 
  /// Ensure that in your [initState] that you call [super.initState] at
  /// the end of the method.
  Future<void> asyncInitState();

  Future<void> get initialised => _initialised.future;
}
