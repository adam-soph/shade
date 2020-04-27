import 'route_step.dart';
import 'middleware.dart';

class Controller {
  final String path;
  const Controller([this.path]);
}

abstract class EndpointAnnotation {
  final String httpMethod;
  final String path;
  const EndpointAnnotation._(this.httpMethod, this.path);
}

class Any extends EndpointAnnotation {
  const Any([String path]) : super._("*", path);
}

class Get extends EndpointAnnotation {
  const Get([String path]) : super._("GET", path);
}

class Put extends EndpointAnnotation {
  const Put([String path]) : super._("PUT", path);
}

class Post extends EndpointAnnotation {
  const Post([String path]) : super._("POST", path);
}

class Patch extends EndpointAnnotation {
  const Patch([String path]) : super._("PATCH", path);
}

class Delete extends EndpointAnnotation {
  const Delete([String path]) : super._("DELETE", path);
}

class Options extends EndpointAnnotation {
  const Options([String path]) : super._("OPTIONS", path);
}

class MiddlewareAnnotation {
  final dynamic middleware;
  const MiddlewareAnnotation._(this.middleware) : 
    assert(middleware is Type || middleware is Middleware || middleware is RouteStep || middleware is List);
}

class Preware extends MiddlewareAnnotation {
  const Preware(middleware) : super._(middleware);
}

class Postware extends MiddlewareAnnotation {
  const Postware(middleware) : super._(middleware);
}
