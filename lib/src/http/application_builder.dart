import 'dart:mirrors';

import 'package:shade/shade.dart';
import 'package:shade/src/inject/injector.dart';
import 'package:shade/src/utilities/metadata.dart';

import 'annotations.dart';
import 'errors.dart';
import 'router.dart';
import 'error_handler.dart';
import 'application.dart';
import 'middleware.dart';
import 'route_step.dart';

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

  void setSecurityContext(SecurityContext securityContext) {
    this._securityContext = securityContext;
  }

  void addAllInjections(Map<String, dynamic> injections) {
    this._injections.addAll(injections);
  }

  void addInjection(String token, injection) {
     this._injections[token] = injection;
  }

  void addPreware(preware) {
    this._preware.add(preware);
  }

  void addAllPreware(List preware) {
    this._preware.addAll(preware);
  }

  void addPostware(postware) {
    this._postware.add(postware);
  }

  void addAllPostware(List postware) {
    this._postware.addAll(postware);
  }

  void setErrorHandler(Type errorHandler) {
    this._errorHandler = errorHandler;
  }

  void addAllControllers(List<Type> controllers) {
    this._controllers.addAll(controllers);
  }

  void addController(Type controller) {
    this._controllers.add(controller);
  }

  Application build() {
    var router = Router();
    var injector = Injector(this._injections);
    
    var errorHandler = injector.resolveType(this._errorHandler);
    var errorRouteFunction;

    if (errorHandler is ErrorHandler) {
      errorRouteFunction = errorHandler.handle;
    } else {
      throw RouteConfigurationError("Invalid error handler. Must extend ErrorHandler");
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
    return Application(router, errorRouteFunction, this._securityContext);
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


