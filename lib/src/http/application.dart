import 'dart:io';
import 'dart:mirrors';

import 'package:shade/src/inject/injector.dart';
import 'package:shade/src/utilities/metadata.dart';

import 'annotations.dart';
import 'errors.dart';
import 'context.dart';
import 'router.dart';
import 'error_handler.dart';
import 'middleware.dart';
import 'route_step.dart';


/// A class that will take controllers, their endpoints, and their middleware and build an [Application].
/// 
/// Example
/// ```dart
/// var builder = ApplicationBuilder()
///   ..addController(SomeController)
///   ..addInjections({
///     "someToken": SomeService
///   })
///   ..addPreware(SomeMiddleware)
///   ..addPostware(SomeOtherMiddleware);
/// 
/// var app = builder.build();
/// ```
class ApplicationBuilder {

  Map<String, dynamic> _injections;
  List<Type> _controllers;
  List _preware;
  List _postware;
  Type _errorHandler;
  SecurityContext _securityContext;

  ApplicationBuilder() : 
    _injections = {}, 
    _controllers = [], 
    _preware = [], 
    _postware = [], 
    _errorHandler = DefaultErrorHandler;

  /// Sets the HTTP security context to your application.
  void setSecurityContext(SecurityContext securityContext) {
    this._securityContext = securityContext;
  }

  /// Adds the map of injections to be used in the [Injector] when [build] is called.
  void addAllInjections(Map<String, dynamic> injections) {
    this._injections.addAll(injections);
  }

  /// Adds a single injection to be used in the [Injector] when [build] is called.
  void addInjection(String token, injection) {
     this._injections[token] = injection;
  }

  /// Adds a single [Application] wide middleware to a list of [Middleware] that will be executed before all requests to the 
  /// Application.
  /// 
  /// Takes a parameter [preware] that must be either a [Type] of [Middleware], an instance of [Middleware],
  /// or a [RouteStep].
  /// 
  /// If [preware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [Application]'s specified
  /// injections.
  void addPreware(preware) {
    this._preware.add(preware);
  }

  /// Adds a [List] of [Application] wide middleware to a list of [Middleware] that will be executed before all requests to the 
  /// [Application].
  /// 
  /// Takes a parameter [preware] that is a [List] of either a [Type] of [Middleware], an instance of [Middleware],
  /// or a [RouteStep].
  /// 
  /// If an element of [preware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [Application]'s specified
  /// injections.
  void addAllPreware(List preware) {
    this._preware.addAll(preware);
  }

  /// Adds a single [Application] wide middleware to a list of [Middleware] that will be executed after all requests to the 
  /// [Application].
  /// 
  /// Takes a parameter [postware] that must be either a [Type] of [Middleware], an instance of [Middleware],
  /// or a [RouteStep].
  /// 
  /// If [postware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [Application]'s specified
  /// injections.
  void addPostware(postware) {
    this._postware.add(postware);
  }

  /// Adds a [List] of [Application] wide middleware to a list of [Middleware] that will be executed after all requests to the 
  /// [Application].
  /// 
  /// Takes a parameter [postware] that is a [List] of either a [Type] of [Middleware], an instance of [Middleware],
  /// or a [RouteStep].
  /// 
  /// If an element of [postware] is a [Type] of [Middleware] it will be resolved with an [Injector] using the [Application]'s specified
  /// injections.
  void addAllPostware(List postware) {
    this._postware.addAll(postware);
  }

  /// Sets the [Application]'s error handler.
  /// 
  /// [errorHandler] will be resolved with [Injector] and the [Application]'s specified injections.
  void setErrorHandler(Type errorHandler) {
    this._errorHandler = errorHandler;
  }


  /// Adds a [List] of controllers to the [Application]'s running list of controllers.
  /// 
  /// Every controller must be annotated with a [Controller] annotation. Every controller will be resolved with [Injector] and the [Application]'s 
  /// specified injections.
  void addAllControllers(List<Type> controllers) {
    this._controllers.addAll(controllers);
  }


  /// Adds a single controller to the [Application]'s running list of controllers.
  /// 
  /// Every controller must be annotated with a [Controller] annotation. Every controller will be resolved with [Injector] and the [Application]'s 
  /// specified injections.
  void addController(Type controller) {
    this._controllers.add(controller);
  }

  /// Builds an application.
  /// 
  /// Returns an instance of [Application].
  /// 
  /// Throws a [RouteConfigurationError] if the routes are configured improperly.
  Application build() {
    var router = Router();
    var injector = Injector(this._injections);
    
    var errorHandler = injector.resolveType(this._errorHandler);
    var errorRouteFunction;

    if (errorHandler is ErrorHandler) {
      errorRouteFunction = errorHandler.handle;
    } else {
      throw RouteConfigurationError("Invalid error handler. Must be of type ErrorHandler.");
    }

    var applicationPreware = this._processMiddleware(injector, this._preware);
    var applicationPostware = this._processMiddleware(injector, this._postware);

    this._controllers.forEach((controller) {
      var resolvedController = injector.resolveType(controller);
      var classMirror = reflect(resolvedController);
      var controllerAnnotation = getAnnotation<Controller>(classMirror.type.metadata);
      if (controllerAnnotation == null) {
        throw RouteConfigurationError("${controller} is not a controller."); 
      }
      var basePath = controllerAnnotation.path ?? "/";

      var controllerPreware = getAllAnnotations<Preware>(classMirror.type.metadata);
      var superPreware = this._processMiddleware(injector, controllerPreware);

      var controllerPostware = getAllAnnotations<Postware>(classMirror.type.metadata);
      var superPostware = this._processMiddleware(injector, controllerPostware);

      classMirror.type.instanceMembers.forEach((name, methodMirror) {
        var routeAnnotation = getAnnotation<EndpointAnnotation>(methodMirror.metadata);
        if (routeAnnotation != null) {
          var path = routeAnnotation.path ?? "";
          var endpointPrewareAnnotations = getAllAnnotations<Preware>(methodMirror.metadata);
          var routePreware = this._processMiddleware(injector, endpointPrewareAnnotations);

          var endpointPostwareAnnotations = getAllAnnotations<Postware>(methodMirror.metadata);
          var routePostware = this._processMiddleware(injector, endpointPostwareAnnotations);

          var httpMethod = routeAnnotation.httpMethod;
          var endpointRouteFunction = classMirror.getField(name).reflectee;
          if (!(endpointRouteFunction is RouteStep)) {
            throw RouteConfigurationError("Invalid endpoint signature.");
          }
          routePreware.add(endpointRouteFunction);
          Iterable<RouteStep> chain = (applicationPreware + superPreware + routePreware + routePostware + superPostware + applicationPostware);
          path = basePath + path;
          router.addRoute(path, httpMethod, chain);
        }
      });

    });
    return Application._(router, errorRouteFunction, this._securityContext);
  }

  List<RouteStep> _processMiddleware(Injector injector, middleware) {
    if (middleware is List<MiddlewareAnnotation>) {
      return middleware.map((middlewareElement) => this._getMiddlewareRouteFunction(injector, middlewareElement.middleware)).toList();
    }
    if (middleware is List) {
      return middleware.map((middlewareEndpoint) => this._getMiddlewareRouteFunction(injector, middlewareEndpoint)).toList();
    }
    return [this._getMiddlewareRouteFunction(injector, middleware)];
  }

  RouteStep _getMiddlewareRouteFunction(Injector injector, middleware) {
    if (middleware is Type) {
      middleware = injector.resolveType(middleware);
    }
    if (middleware is Middleware) {
      return middleware.step;
    } else if (middleware is RouteStep) {
      return middleware;
    } else {
      throw RouteConfigurationError("Invalid middleware type.");
    }
  }

}

/// A shade HTTP server application.
class Application {
  
  Router _router;
  ErrorRouteStep _errorRouteFunction;
  SecurityContext _securityContext;

  Application._(Router router, ErrorRouteStep errorRouteFunction, [SecurityContext securityContext]) {
    this._router = router;
    this._errorRouteFunction = errorRouteFunction;
    this._securityContext = securityContext;
  }

  /// Starts your [Application].
  /// 
  /// [port] is the port to listen on.
  /// [callback] is called with no parameters once the the server has started listening.
  void listen(int port, [Function callback]) async {
    HttpServer server;
    if (this._securityContext != null) {
      server = await HttpServer.bindSecure(InternetAddress.loopbackIPv4, port, this._securityContext);
    } else {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    }
    callback();
    await for (HttpRequest httpRequest in server) {
      var routeResult = this._router.route(this._trimSegments(httpRequest.requestedUri.pathSegments).iterator, httpRequest.method);
      RequestContext.start(httpRequest, routeResult, this._errorRouteFunction);
    }
  }

  List<String> _trimSegments(List<String> pathSegments) {
    var segements = List<String>.of(pathSegments);
    while (segements.last == "") {
      segements.removeAt(segements.length - 1);
    }
    return segements;
  }

}
