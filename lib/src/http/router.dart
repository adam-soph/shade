import 'package:shade/src/utilities/pair.dart';

import 'route_step.dart';
import 'errors.dart';
import 'route_node.dart';

enum _RouteSegmentType { LITERAL, CATCHALL, VARIABLE }

/// The result of a [Router]'s [route] function.
///
/// If [matchPath] is `false` then so will [matchEndpoint] and [chain], [path], and [pathParameters] will be null.
class RouteResult {
  final bool matchPath;
  final bool matchEndpoint;
  final Iterator<RouteStep> chain;
  final String path;
  final Map<String, String> pathParameters;

  const RouteResult(this.matchPath, this.matchEndpoint, this.chain, this.path,
      this.pathParameters);
}

class Router {
  final _alphanumeric = RegExp(r"^[a-zA-Z0-9_-]*$");

  RouteNode _head;

  Router() {
    this._head = RouteNode();
  }

  void addRoute(String path, String httpMethod, Iterable<RouteStep> chain) {
    path = this._washPath(path);
    httpMethod = this._washHttpMethod(httpMethod);
    var segments = path == "" ? <String>[] : path.split("/");
    var cur = this._head;

    for (var i = 0; i < segments.length; i++) {
      var segment = segments[i];
      var segmentType = this._getSegmentType(segment);
      var node = RouteNode();

      switch (segmentType) {
        case _RouteSegmentType.LITERAL:
          if (cur.literalChildren.containsKey(segment)) {
            node = cur.literalChildren[segment];
          } else {
            cur.literalChildren[segment] = node;
          }
          break;
        case _RouteSegmentType.CATCHALL:
          if (cur.catchAllChild != null) {
            throw RouteConfigurationError(
                "Duplicate route with path ${path} and method ${httpMethod}."); // duplicate route
          }
          if (i != segments.length - 1) {
            throw RouteConfigurationError(
                "* must be last path segement."); // * isn't last node
          }
          cur.catchAllChild = node;
          break;
        case _RouteSegmentType.VARIABLE:
          if (cur.variableChild != null) {
            if (cur.variableChild.left != segment.substring(1)) {
              throw RouteConfigurationError(
                  "Duplicate route with path ${path} and method ${httpMethod}."); // duplicate route
            }
            node = cur.variableChild.right;
          } else {
            cur.variableChild = Pair(segment.substring(1), node);
          }
          break;
      }
      cur = node;
    }

    if (httpMethod == "*") {
      cur.catchAllEndpoint = chain;
    } else {
      cur.endpoints[httpMethod] = chain;
    }
  }

  _RouteSegmentType _getSegmentType(String segment) {
    if (segment.startsWith(":")) {
      return _RouteSegmentType.VARIABLE;
    } else if (segment == "*") {
      return _RouteSegmentType.CATCHALL;
    } else if (this._alphanumeric.hasMatch(segment)) {
      return _RouteSegmentType.LITERAL;
    } else {
      throw RouteConfigurationError("Invlaid path segment ${segment}");
    }
  }

  String _washPath(String path) {
    while (path.startsWith("/")) {
      path = path.substring(1);
    }
    while (path.endsWith("/")) {
      path = path.substring(0, path.length - 1);
    }
    return path;
  }

  String _washHttpMethod(String httpMethod) {
    return httpMethod.toUpperCase();
  }

  /// Gets the route result of specific [segements] and [httpMethod] from the constructed
  /// [RouteNode] tree.
  RouteResult route(Iterator<String> segments, String httpMethod) {
    var result = this._head.climb(segments, {}, StringBuffer());
    if (result.match) {
      var endpoint = result.routeNode.endpoints[httpMethod];
      if (endpoint == null) {
        if (result.routeNode.catchAllEndpoint != null) {
          return RouteResult(
              true,
              true,
              result.routeNode.catchAllEndpoint.iterator,
              result.path,
              result.pathParameters);
        }
        return RouteResult(
            true, false, null, result.path, result.pathParameters);
      }
      return RouteResult(
          true, true, endpoint.iterator, result.path, result.pathParameters);
    }
    return RouteResult(false, false, null, result.path, result.pathParameters);
  }
}
