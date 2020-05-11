import 'dart:io';
import 'dart:convert';

import 'route_step.dart';
import 'context.dart';

/// The definition of a middleware object.
///
/// This is meant to be used as an interface.
///
/// If your middleware doesn't require dependencies or parameters it is recommended that you just use a [RouteStep].
abstract class Middleware {
  void step(Request req, Response res, Step step);
}
