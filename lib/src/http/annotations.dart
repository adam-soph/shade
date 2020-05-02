import 'route_step.dart';
import 'middleware.dart';

/// Marks the annotated class as a controller.
///
/// Takes an optional parameter [path] which defaults to "/" and is the base path to all
/// endpoints within the controller. The "/" at the start of the path is optional.
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///   ...
/// }
/// ```
class Controller {
  final String path;
  const Controller([this.path = "/"]);
}

/// Base class for all endpoint annotations.
abstract class EndpointAnnotation {
  final String httpMethod;
  final String path;
  const EndpointAnnotation._(this.httpMethod, this.path);
}

/// Annotates an endpoint that catches all HTTP methods.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Any("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Any("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Any extends EndpointAnnotation {
  const Any([path = ""]) : super._("*", path);
}

/// Annotates an endpoint that catches requests with a `GET` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Get("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Get("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Get extends EndpointAnnotation {
  const Get([path = ""]) : super._("GET", path);
}

/// Annotates an endpoint that catches requests with a `PUT` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Put("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Put("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Put extends EndpointAnnotation {
  const Put([path = ""]) : super._("PUT", path);
}

/// Annotates an endpoint that catches requests with a `POST` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Post("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Post("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Post extends EndpointAnnotation {
  const Post([path = ""]) : super._("POST", path);
}

/// Annotates an endpoint that catches requests with a `PATCH` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Patch("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Patch("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Patch extends EndpointAnnotation {
  const Patch([path = ""]) : super._("PATCH", path);
}

/// Annotates an endpoint that catches requests with a `DELETE` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Delete("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Delete("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Delete extends EndpointAnnotation {
  const Delete([path = ""]) : super._("DELETE", path);
}

/// Annotates an endpoint that catches requests with a `OPTIONS` HTTP method.
///
/// Takes an optional parameter [path] which defaults to an empty String. The function
/// annotated must be of type [RouteStep].
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// class ExampleController {
///
///   @Options("/some-path")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
///   @Options("/:some-path-paramter")
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Options extends EndpointAnnotation {
  const Options([path = ""]) : super._("OPTIONS", path);
}

/// Base class for all Middleware annotations.
class MiddlewareAnnotation {
  final dynamic middleware;
  const MiddlewareAnnotation._(this.middleware)
      : assert(middleware is Type ||
            middleware is Middleware ||
            middleware is RouteStep ||
            middleware is List);
}

/// Annotates middleware that will be executed before an endpoint or all of a controller's
/// endpoints.
///
/// Takes a parameter [middleware] that can either be a [List] or a just one [Type] of [Middleware], an instance of [Middleware],
/// or a [RouteStep].
///
/// If [middleware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [ApplicationBuilder]'s specified
/// injections.
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// @Preware(SomeOtherMiddleware)
/// class ExampleController {
///
///   @Get("/some-path")
///   @Preware(SomeMiddleware)
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Preware extends MiddlewareAnnotation {
  const Preware(middleware) : super._(middleware);
}

/// Annotates middleware that will be executed after an endpoint or all of a controller's
/// endpoints.
///
/// Takes a parameter [middleware] that can either be a [List] or a just one [Type] of [Middleware], an instance of [Middleware],
/// or a [RouteStep].
///
/// If [middleware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [ApplicationBuilder]'s specified
/// injections.
///
/// Example:
/// ```dart
/// @Controller("/some-base-path")
/// @Postware(SomeOtherMiddleware)
/// class ExampleController {
///
///   @Get("/some-path")
///   @Postware(SomeMiddleware)
///   void someEndpoint(State state, Request req, Response res, Step step) {
///     ...
///   }
///
/// }
/// ```
class Postware extends MiddlewareAnnotation {
  const Postware(middleware) : super._(middleware);
}
