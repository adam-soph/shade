import 'context.dart';

/// Commands that can be passed to the [Step] parameter of a [RouteStep].
enum ApplicationCommand {
  /// This will break the chain and will not execute anymore [RouteStep]s.
  BREAK
}

/// This function is a parameter in a [RouteStep] that will move the context to the next [RouteStep].
///
/// Takes a parameter [arg], if it is of type [ApplicationCommand] then it will execute the command.
/// Otherwise, it will be treated as an error or execption and passed into the [Application]'s error
/// handler as an error.
typedef Step = void Function([dynamic arg]);

/// A step in the route chain of an endpoint.
///
/// Functions of this type are endpoints and middleware that get executed in order within
/// the request context.
typedef RouteStep = void Function(Request req, Response res, Step step);

/// The error handler of an [Application].
typedef ErrorRouteStep = void Function(Request req, Response res, dynamic err);
