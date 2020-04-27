import 'dart:io';

import 'exceptions.dart';
import 'state.dart';
import 'router.dart';
import 'request.dart';
import 'response.dart';
import 'route_Step.dart';

class RequestContext {

  final State _state;
  final Request _request;
  final Response _response;
  final Iterator<RouteStep> _chain;
  final ErrorRouteStep _errorFunction;

  const RequestContext._(State this._state, this._request, Response this._response, Iterator<RouteStep> this._chain, ErrorRouteStep this._errorFunction);

  static void create(HttpRequest httpRequest, Router router, ErrorRouteStep errorFunction) {
    var result = router.route(RequestContext._trimSegments(httpRequest.requestedUri.pathSegments).iterator, httpRequest.method);
    
    var res = Response(httpRequest.response);
    var req = Request(httpRequest, result.pathParameters);
    var state = State();

    if (!result.matchEndpoint || !result.matchPath) {
      errorFunction(state, req, res, RouteNotFoundException(httpRequest.requestedUri.path, httpRequest.method));
    } else {
      RequestContext._(state, req, res, result.chain, errorFunction)..send();
    }
  }

  static List<String> _trimSegments(List<String> pathSegments) {
    var segements = List<String>.of(pathSegments);
    while (segements.last == "") {
      segements.removeAt(segements.length - 1);
    }
    return segements;
  }

  void _step([error]) {

    if (error != null) {
      this._errorFunction(this._state, this._request, this._response, error);
    }

    this._chain.moveNext();

    if (this._chain.current != null) {
      var routeFunction = this._chain.current;
      try {
        routeFunction(this._state, this._request, this._response, this._step);
      } catch (error) {
        this._errorFunction(this._state, this._request, this._response, error);
      }
    }
  }

  void send() async {
    this._step();
  }

}