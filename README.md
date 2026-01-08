# DeferredState

DeferredState Provides a simple way of doing asynchronous initialisation for a StatefulWidget.

> The StatefulWidget doesn't allow you to easily do async
initialisation in [initState], resulting in the need for convulated methods to initialise state.

DeferredState provides a reliable and simple method of overcoming this
problem by augmenting the [State] class with a [asyncInitState] method which 
behaves in a simiar manner to [initState] but allows async calls when
coupled with the [DeferedBuilder].

There are two classes in the async_state package [DeferredState] and [DeferredBuilder].  

To use [DeferredState] you derive your StatefulWidget's state from [DeferredState] instead of [State].


You then use [DeferredBuilder] in the State's [build] method so the builder
isn't called until the async initialisation is complete. (DeferredBuilder wraps a 
FutureBuilder under the hood).

## Custom UI
Whilst the UI is waiting or if an error occurs, DeferredBuilder provides a default 
[waitingBuilder] and [errorBuilder] implementation but you can roll your own (see below).


# Sponsored by OnePub
Help support DeferredState by supporting [OnePub](https://onepub.dev), the private dart repository.
OnePub allows you to privately share dart packages between your own projects or with colleagues.
Try it for free and publish your first private package in seconds.

https://onepub.dev

Publish a private package in six commands:
```bash
dart pub global activate onepub
onepub login
flutter create -t package mypackage
cd mypackage
onepub pub private
dart pub publish
```
You can now add your private package to any app
```bash
onepub pub add mypackage
```

# Example
The easist way to understand DeferredState is by an example.

```dart
import 'package:deferred_state/deferred_state.dart';
import 'package:flutter/material.dart';

class SchedulePage extends StatefulWidget {
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
    // This must be called last.
    super.initState();
  }

  /// Items that need to be initialised asychronously 
  /// go here. Make certain to [await] them, use 
  /// a [completer] if necessary.
  @override
  Future<void> asyncInitState() async {
    system = await DaoSystem().get();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

```

# customising the waiting and error UI
The [DeferredBuilder] includes [waitingBuilder] and  [errorBuilder] arguments 
to allow you to customise the UI during these phases but provides default 
builders for both.

If you don't like the default [waitingBuilder] and [errorBuilder] you can create you own version of DeferredBuilder with
your own custom builders so you don't have to specify the 
[waitingBuilder] and [errorBuilder] at every call 
site.

The example includes [waitingBuilder] or [errorBuilder] as optional arguments 
to your  [MyDeferredBuilder]. 
This isn't necessary unless you have call sites that need additional 
customisation (you may be better off creating multiple versions of [MyDeferredBuilder]).  If you don't need this level of customisation then
 just delete the [waitingBuilder] and [errorBuilder] args
that are passed to [MyDeferredBuilder].

```dart
/// Create your on [DeferredBuilder] to customise the
/// error and waiting builders without having to
/// specify them at every call site.
class MyDeferredBuilder extends StatelessWidget {
  MyDeferredBuilder(this.state,
      {required this.builder, this.waitingBuilder, this.errorBuilder});
  final DeferredState state;
  final WidgetBuilder builder;

  /// Include the waiting and error builders as arguments to
  /// [MyDeferredBuilder] if you might want to do further customisation at some
  /// call sites, otherwise delete these fields.
  final WaitingBuilder? waitingBuilder;
  final ErrorBuilder? errorBuilder;

  Widget build(BuildContext context) => DeferredBuilder(state,
      /// Customise the waiting message here
      waitingBuilder: (c => Center(child: Text('waiting')), here
      /// Customise the error message here.
      errorBuilder: (context, error) => Center(child: Text(error.toString())),
      builder: (context) => builder(context));
}
```