import 'dart:async';

import 'package:deferred_state/deferred_state.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<StatefulWidget> createState() => _SchedulPageState();
}

/// Derive from DeferredState rather than State
class _SchedulPageState extends DeferredState<SchedulePage> {
  /// requires async initialisation
  late final System system;

  /// requires sync initialisation so it can be disposed.
  late final TextEditingController _nameController;

  /// Items that are to be disposed must go in [initState]
  @override
  void initState() {
    _nameController = TextEditingController();
    // this must be called last.
    super.initState();
  }

  /// Items that need to be initialised asychronously
  /// go here. Make certain to await them, use
  /// a [Completer] if necessary.
  @override
  Future<void> asyncInitState() async {
    system = await DaoSystem().get();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Waits for [asyncInitState] to complete and then calls
    /// the builder.
    return DeferredBuilder(this, builder: (context) => Text(system.name));
  }
}

class System {
  System(this.name);
  String name;
}

class DaoSystem {
  Future<System> get() async {
    /// get the system record from the db.
    return System('example');
  }
}
