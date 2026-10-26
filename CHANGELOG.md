# 1.1.1
- Complete deferred initialisation with an error when an initializer
  fails, so the view does not wait forever or report an unhandled zone error.
- The new failure path uses a generic default error message so
  exception details are not exposed in the UI. Apps can provide a custom
  `errorBuilder`.
- Remove a tracked local analyzer log from the package repository.

# 1.1.0
- improved doco around calling super.initState at the end of your method.
- highlighted the ability to customise the ui.

## 1.0.0

- Initial version.
